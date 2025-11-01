#!/usr/bin/env bash

# Get current directory
current_dir=$(tmux display-message -p '#{pane_current_path}')

# Check if we're in a git repository
if ! git -C "$current_dir" rev-parse --git-dir &>/dev/null; then
    echo "Error: Not in a git repository"
    read -n 1 -s -r -p "Press any key to close..."
    exit 1
fi

# Get the git root directory
git_root=$(git -C "$current_dir" rev-parse --show-toplevel 2>/dev/null)
repo_name=$(basename "$git_root")

if [ -z "$git_root" ]; then
    echo "Error: Could not find git root directory"
    read -n 1 -s -r -p "Press any key to close..."
    exit 1
fi

cd "$git_root" || exit 1

# Get worktrees directory (parent of git root)
worktrees_base=$(dirname "$git_root")

echo "Repository: $repo_name"
echo "Current location: $git_root"
echo ""

# Get list of branches (local and remote)
branches=$(git branch -a --format='%(refname:short)' | sed 's|^origin/||' | grep -v '^HEAD' | sort -u)

# Get existing worktrees to filter them out
existing_worktrees=$(git worktree list --porcelain | grep "^branch" | sed 's/^branch refs\/heads\///' | sort -u)

# Filter out branches that already have worktrees
available_branches=""
while IFS= read -r branch; do
    if ! echo "$existing_worktrees" | grep -q "^${branch}$"; then
        available_branches="${available_branches}${branch}\n"
    fi
done <<< "$branches"

# Add option to create new branch
options="[NEW BRANCH]\n${available_branches}"

# Use fzf to select branch or create new one
selected=$(echo -e "$options" | fzf \
    --height=100% \
    --reverse \
    --border \
    --prompt="Select branch or create new: " \
    --preview="if [ '{}' = '[NEW BRANCH]' ]; then echo 'Create a new branch and worktree'; else git log --oneline --graph --color=always {} 2>/dev/null | head -50; fi" \
    --preview-window=right:60%:wrap \
    --header="↑↓ to navigate, Enter to select, Esc to cancel")

if [ -z "$selected" ]; then
    echo "No branch selected"
    exit 0
fi

# Handle new branch creation
if [ "$selected" = "[NEW BRANCH]" ]; then
    echo ""
    read -p "Enter new branch name: " new_branch_name

    if [ -z "$new_branch_name" ]; then
        echo "Error: Branch name cannot be empty"
        read -n 1 -s -r -p "Press any key to close..."
        exit 1
    fi

    # Check if branch already exists
    if git show-ref --verify --quiet "refs/heads/$new_branch_name"; then
        echo "Error: Branch '$new_branch_name' already exists"
        read -n 1 -s -r -p "Press any key to close..."
        exit 1
    fi

    branch_name="$new_branch_name"
    create_new=true
else
    branch_name="$selected"
    create_new=false
fi

# Sanitize branch name for directory (replace / with -)
dir_name=$(echo "$branch_name" | sed 's/\//-/g')

# Worktree path
worktree_path="${worktrees_base}/${repo_name}-${dir_name}"

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

# Create the worktree
if [ "$create_new" = true ]; then
    # Create new branch and worktree
    if git worktree add -b "$branch_name" "$worktree_path"; then
        echo "✓ Worktree created successfully"
    else
        echo "✗ Failed to create worktree"
        read -n 1 -s -r -p "Press any key to close..."
        exit 1
    fi
else
    # Create worktree from existing branch
    if git worktree add "$worktree_path" "$branch_name"; then
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
