#!/usr/bin/env bash

# Get current directory
current_dir=$(tmux display-message -p '#{pane_current_path}')

# Check if we're in ~/Code/worktrees/ directory
if [[ "$current_dir" != "$HOME/Code/worktrees/"* ]]; then
    echo "Error: This tool only works when you're in a ~/Code/worktrees/ directory"
    echo "Current directory: $current_dir"
    read -n 1 -s -r -p "Press any key to close..."
    exit 1
fi

# Check if we're in a git repository
if ! git -C "$current_dir" rev-parse --git-dir &>/dev/null; then
    echo "Error: Not in a git repository"
    read -n 1 -s -r -p "Press any key to close..."
    exit 1
fi

# Get the git root directory (this will be the worktree directory)
worktree_path=$(git -C "$current_dir" rev-parse --show-toplevel 2>/dev/null)

if [ -z "$worktree_path" ]; then
    echo "Error: Could not find git worktree directory"
    read -n 1 -s -r -p "Press any key to close..."
    exit 1
fi

# Extract repository info from worktree path
# Expected format: ~/Code/worktrees/{owner}/{repo}-{branch}
relative_path="${worktree_path#$HOME/Code/worktrees/}"

# Extract owner and repo-branch
owner=$(echo "$relative_path" | cut -d'/' -f1)
repo_with_branch=$(echo "$relative_path" | cut -d'/' -f2)

# Extract repo name (everything before the last dash and branch name)
# For repo-main -> repo=repo, branch=main
# For my-repo-feature -> need to find the actual branch
current_branch=$(git -C "$worktree_path" rev-parse --abbrev-ref HEAD 2>/dev/null)

# Remove -branch suffix to get repo name
repo=$(echo "$repo_with_branch" | sed "s/-${current_branch}$//")

if [ -z "$owner" ] || [ -z "$repo" ]; then
    echo "Error: Could not parse repository info from path: $worktree_path"
    read -n 1 -s -r -p "Press any key to close..."
    exit 1
fi

# Find the bare repository
bare_repo_dir="$HOME/Code/repositories/$owner/$repo"

if [ ! -d "$bare_repo_dir" ]; then
    echo "Error: Bare repository not found at: $bare_repo_dir"
    read -n 1 -s -r -p "Press any key to close..."
    exit 1
fi

# Worktrees base for this repository
worktrees_base="$HOME/Code/worktrees/$owner"

# Create worktrees directory if it doesn't exist
mkdir -p "$worktrees_base"

echo "Repository: $owner/$repo"
echo "Bare repo: $bare_repo_dir"
echo "Current worktree: $current_branch"
echo ""

# Get existing worktrees (use -C to run git commands against bare repo)
worktree_list=$(git -C "$bare_repo_dir" worktree list --porcelain | grep "^branch" | sed 's/^branch refs\/heads\///' | sort -u)

# Add option to create new worktree
options="[NEW WORKTREE]\n${worktree_list}"

# Use fzf to select worktree or create new one
selected=$(echo -e "$options" | fzf \
    --height=100% \
    --reverse \
    --border \
    --prompt="Select worktree or create new: " \
    --preview="if [ '{}' = '[NEW WORKTREE]' ]; then echo 'Create a new worktree with a new branch'; else git log --oneline --graph --color=always {} 2>/dev/null | head -50; fi" \
    --preview-window=right:60%:wrap \
    --header="↑↓ to navigate, Enter to select, Esc to cancel")

if [ -z "$selected" ]; then
    echo "No worktree selected"
    exit 0
fi

# Handle new worktree creation
if [ "$selected" = "[NEW WORKTREE]" ]; then
    echo ""
    read -p "Enter new branch name: " new_branch_name

    if [ -z "$new_branch_name" ]; then
        echo "Error: Branch name cannot be empty"
        read -n 1 -s -r -p "Press any key to close..."
        exit 1
    fi

    # Check if branch already exists
    if git -C "$bare_repo_dir" show-ref --verify --quiet "refs/heads/$new_branch_name"; then
        echo "Error: Branch '$new_branch_name' already exists"
        read -n 1 -s -r -p "Press any key to close..."
        exit 1
    fi

    branch_name="$new_branch_name"
    create_new=true
else
    # Selected an existing branch - check if worktree exists
    branch_name="$selected"

    # Get worktree path using new structure: ~/Code/worktrees/owner/repo-branch
    dir_name=$(echo "$branch_name" | sed 's/\//-/g')
    worktree_path="${worktrees_base}/${repo}-${dir_name}"

    # Check if worktree directory exists
    if [ ! -d "$worktree_path" ]; then
        echo ""
        echo "Worktree for branch '$branch_name' doesn't exist yet."
        echo "Creating worktree at: $worktree_path"
        echo ""

        # Create the worktree for this existing branch
        if git -C "$bare_repo_dir" worktree add "$worktree_path" "$branch_name"; then
            echo "✓ Worktree created successfully"
        else
            echo "✗ Failed to create worktree"
            read -n 1 -s -r -p "Press any key to close..."
            exit 1
        fi
    fi

    # Get current session name
    session_name=$(tmux display-message -p '#S')

    # Check if window with this name already exists
    if tmux list-windows -t "$session_name" -F "#{window_name}" 2>/dev/null | grep -q "^${branch_name}$"; then
        echo "Switching to existing window '$branch_name'..."
        tmux select-window -t "${session_name}:${branch_name}"
    else
        # Create new window for the worktree
        echo "Creating tmux window '$branch_name'..."
        tmux new-window -t "$session_name" -n "$branch_name" -c "$worktree_path"

        # Run window setup if it exists
        if [ -f "$HOME/.dotfiles/scripts/tmux-window-setup.sh" ]; then
            tmux send-keys -t "${session_name}:${branch_name}" "~/.dotfiles/scripts/tmux-window-setup.sh" C-m
        fi
    fi

    echo "✓ Done! Switched to worktree window."
    exit 0
fi

# Sanitize branch name for directory (replace / with -)
dir_name=$(echo "$branch_name" | sed 's/\//-/g')

# Worktree path using new structure: ~/Code/worktrees/owner/repo-branch
worktree_path="${worktrees_base}/${repo}-${dir_name}"

# Check if worktree path already exists
if [ -d "$worktree_path" ]; then
    echo "Error: Directory '$worktree_path' already exists"
    read -n 1 -s -r -p "Press any key to close..."
    exit 1
fi

echo ""
echo "Creating worktree:"
echo "  Branch: $branch_name"
echo "  Path: $worktree_path"
echo ""

# Get the default branch to fork from
default_branch=$(git -C "$bare_repo_dir" symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@')
if [ -z "$default_branch" ]; then
    default_branch="main"
fi

# Create the worktree using absolute paths
if [ "$create_new" = true ]; then
    # Create new branch and worktree, forking from default branch
    if git -C "$bare_repo_dir" worktree add -b "$branch_name" "$worktree_path" "$default_branch"; then
        echo "✓ Worktree created successfully"
    else
        echo "✗ Failed to create worktree"
        read -n 1 -s -r -p "Press any key to close..."
        exit 1
    fi
else
    # Create worktree from existing branch
    if git -C "$bare_repo_dir" worktree add "$worktree_path" "$branch_name"; then
        echo "✓ Worktree created successfully"
    else
        echo "✗ Failed to create worktree"
        read -n 1 -s -r -p "Press any key to close..."
        exit 1
    fi
fi

# Get current session name
session_name=$(tmux display-message -p '#S')

# Check if window with this name already exists
if tmux list-windows -t "$session_name" -F "#{window_name}" 2>/dev/null | grep -q "^${branch_name}$"; then
    echo ""
    echo "Window '$branch_name' already exists, switching to it..."
    tmux select-window -t "${session_name}:${branch_name}"
else
    # Create new window for the worktree
    echo ""
    echo "Creating tmux window '$branch_name'..."
    tmux new-window -t "$session_name" -n "$branch_name" -c "$worktree_path"

    # Run window setup if it exists
    if [ -f "$HOME/.dotfiles/scripts/tmux-window-setup.sh" ]; then
        tmux send-keys -t "${session_name}:${branch_name}" "~/.dotfiles/scripts/tmux-window-setup.sh" C-m
    fi
fi

echo "✓ Done! Switched to worktree window."
