#!/bin/bash

# Find all local directories under ~/Code (1 level deep, excluding zendesk itself)
# and all directories under ~/Code/zendesk (1 level deep)
LOCAL_PROJECTS=$({
  ls -d ~/Code/*/ 2>/dev/null | grep -v "/zendesk/$"
  ls -d ~/Code/zendesk/*/ 2>/dev/null
} | sed 's|/$||' | sort)

# Cache file for GitHub repositories
CACHE_FILE="$HOME/Code/.github-repos-cache"

# Load cached repos
if [ ! -f "$CACHE_FILE" ]; then
  echo "Cache file not found. Run ~/.dotfiles/scripts/tmux-project-cache-builder.sh to build it."
  read -n 1 -s -r -p "Press any key to continue..."
  exit 1
fi

GITHUB_REPOS=$(cat "$CACHE_FILE" 2>/dev/null)

# Combine local projects and GitHub repos
# Show all repos, let user decide (no existence checking for speed)

TEMP_DISPLAY=$(mktemp)

# Add local projects
if [ -n "$LOCAL_PROJECTS" ]; then
  echo "$LOCAL_PROJECTS" | sed "s|$HOME|~|g" > "$TEMP_DISPLAY"
fi

# Add all GitHub repos as cloneable
if [ -n "$GITHUB_REPOS" ]; then
  while IFS= read -r repo; do
    if [ -n "$repo" ]; then
      # Determine local path based on owner
      if [[ "$repo" == zendesk/* ]]; then
        repo_name=${repo#zendesk/}
        echo "~/Code/zendesk/$repo_name"
      else
        repo_name=$(basename "$repo")
        echo "~/Code/$repo_name"
      fi
    fi
  done <<< "$GITHUB_REPOS" >> "$TEMP_DISPLAY"
fi

DISPLAY_PROJECTS=$(cat "$TEMP_DISPLAY" | sort -u)
rm -f "$TEMP_DISPLAY"

# If no projects found, exit
if [ -z "$DISPLAY_PROJECTS" ]; then
  echo "No projects found"
  read -n 1 -s -r -p "Press any key to continue..."
  exit 1
fi

# Use fzf to select a project
SELECTED_DISPLAY=$(echo "$DISPLAY_PROJECTS" | fzf \
  --height=100% \
  --reverse \
  --border \
  --prompt="Open project: " \
  --preview="path=\$(echo {} | sed 's|^~|$HOME|'); if [ -d \"\$path\" ]; then ls -la \"\$path\"; else echo 'Repository will be cloned'; fi" \
  --preview-window=right:50%:wrap \
  --header="Use ↑↓ to navigate, Enter to open/clone, Esc to cancel")

if [ -n "$SELECTED_DISPLAY" ]; then
  # Convert back to full path
  SELECTED_DIR=${SELECTED_DISPLAY/#~/$HOME}

  # Check if directory exists (determines if we need to clone)
  IS_CLONE=false
  if [ ! -d "$SELECTED_DIR" ]; then
    IS_CLONE=true
  fi

  # Get the project name for the session name
  PROJECT_NAME=$(basename "$SELECTED_DIR")

  # Prompt for work/personal designation
  echo ""
  echo "Is this a work or personal project?"
  echo "1) Work"
  echo "2) Personal"
  read -n 1 -r -p "Select (1/2): " DESIGNATION
  echo ""

  case "$DESIGNATION" in
    1)
      SESSION_NAME="${PROJECT_NAME}[W]"
      ;;
    2)
      SESSION_NAME="${PROJECT_NAME}[P]"
      ;;
    *)
      # Default to work if no valid selection
      SESSION_NAME="${PROJECT_NAME}[W]"
      ;;
  esac

  if [ "$IS_CLONE" = true ]; then
    # Determine the GitHub repo URL
    if [[ "$SELECTED_DIR" == "$HOME/Code/zendesk/"* ]]; then
      REPO_NAME=$(basename "$SELECTED_DIR")
      GH_REPO="zendesk/$REPO_NAME"
    else
      REPO_NAME=$(basename "$SELECTED_DIR")
      # Get the owner from gh
      GH_REPO=$(gh repo list --limit 1000 --json nameWithOwner --jq '.[].nameWithOwner' | grep "/$REPO_NAME$" | head -1)
    fi

    # Extract owner and repo name from GH_REPO (format: owner/repo)
    OWNER=$(echo "$GH_REPO" | cut -d'/' -f1)
    REPO=$(echo "$GH_REPO" | cut -d'/' -f2)

    # Get the default branch name
    DEFAULT_BRANCH=$(gh repo view "$GH_REPO" --json defaultBranchRef --jq '.defaultBranchRef.name')

    if [ -z "$DEFAULT_BRANCH" ]; then
      echo "Failed to detect default branch. Using 'main' as fallback."
      DEFAULT_BRANCH="main"
    fi

    # Define paths
    BARE_REPO_DIR="$HOME/Code/repositories/$OWNER/$REPO"
    WORKTREE_DIR="$HOME/Code/worktrees/$OWNER/$REPO-$DEFAULT_BRANCH"
    SYMLINK_PATH="$HOME/Code/$OWNER/$REPO"

    # Create parent directories
    mkdir -p "$(dirname "$BARE_REPO_DIR")"
    mkdir -p "$(dirname "$WORKTREE_DIR")"
    mkdir -p "$(dirname "$SYMLINK_PATH")"

    # Check if session already exists
    if tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
      echo "Session '$SESSION_NAME' already exists. Switching to it..."
      tmux switch-client -t "$SESSION_NAME"
    else
      # Create new session and execute the clone workflow
      # Name the first window after the default branch
      tmux new-session -d -s "$SESSION_NAME" -n "$DEFAULT_BRANCH" -c "$HOME/Code"

      # Build the command to execute in the tmux session
      CLONE_COMMAND="echo 'Cloning bare repository...' && "
      CLONE_COMMAND+="git clone --bare https://github.com/$GH_REPO.git '$BARE_REPO_DIR' && "
      CLONE_COMMAND+="echo 'Creating worktree for $DEFAULT_BRANCH branch...' && "
      CLONE_COMMAND+="git -C '$BARE_REPO_DIR' worktree add '$WORKTREE_DIR' '$DEFAULT_BRANCH' && "
      CLONE_COMMAND+="echo 'Creating symlink...' && "
      CLONE_COMMAND+="ln -s '$WORKTREE_DIR' '$SYMLINK_PATH' && "
      CLONE_COMMAND+="echo 'Setup complete!' && "
      CLONE_COMMAND+="cd '$WORKTREE_DIR' && "
      CLONE_COMMAND+="~/.dotfiles/scripts/tmux-window-setup.sh"

      tmux send-keys -t "$SESSION_NAME" "$CLONE_COMMAND" C-m
      tmux switch-client -t "$SESSION_NAME"
      echo "Cloning bare repository: $GH_REPO"
      echo "Bare repo: $BARE_REPO_DIR"
      echo "Worktree: $WORKTREE_DIR"
      echo "Symlink: $SYMLINK_PATH"
    fi
  else
    # Check if session already exists
    if tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
      echo "Session '$SESSION_NAME' already exists. Switching to it..."
      tmux switch-client -t "$SESSION_NAME"
    else
      # Create new session for existing project
      tmux new-session -d -s "$SESSION_NAME" -c "$SELECTED_DIR"
      tmux send-keys -t "$SESSION_NAME" "~/.dotfiles/scripts/tmux-window-setup.sh" C-m
      tmux switch-client -t "$SESSION_NAME"
      echo "Opened project: $SELECTED_DIR in session '$SESSION_NAME'"
    fi
  fi
else
  echo "No project selected"
fi
