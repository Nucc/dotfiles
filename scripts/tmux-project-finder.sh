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

  # Get the project name for the window name
  PROJECT_NAME=$(basename "$SELECTED_DIR")

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

    # Create parent directory if needed
    PARENT_DIR=$(dirname "$SELECTED_DIR")
    mkdir -p "$PARENT_DIR"

    # Create new window and clone (shallow clone with depth 1 for speed)
    tmux new-window -n "$PROJECT_NAME" -c "$PARENT_DIR"
    tmux send-keys -t ":" "gh repo clone $GH_REPO $SELECTED_DIR -- --depth 1 && cd $SELECTED_DIR && ~/.dotfiles/scripts/tmux-window-setup.sh" C-m

    echo "Cloning project: $GH_REPO to $SELECTED_DIR"
  else
    # Just open existing project
    tmux new-window -n "$PROJECT_NAME" -c "$SELECTED_DIR"
    tmux send-keys -t ":" "~/.dotfiles/scripts/tmux-window-setup.sh" C-m
    echo "Opened project: $SELECTED_DIR in new window"
  fi
else
  echo "No project selected"
fi
