#!/usr/bin/env bash

# Get current directory
current_dir="${1:-$(tmux display-message -p '#{pane_current_path}')}"

# Check if we're in a git repository
if ! git -C "$current_dir" rev-parse --git-dir &>/dev/null; then
    echo "Error: Not in a git repository"
    exit 1
fi

# Get the git root directory
git_root=$(git -C "$current_dir" rev-parse --show-toplevel 2>/dev/null)

if [ -z "$git_root" ]; then
    echo "Error: Could not find git root directory"
    exit 1
fi

# Get all worktrees
worktrees=$(git -C "$git_root" worktree list --porcelain 2>/dev/null | grep -E "^worktree|^branch" | paste -d' ' - -)

if [ -z "$worktrees" ]; then
    echo "No worktrees found in this repository"
    exit 0
fi

# Get current session name
session_name=$(tmux display-message -p '#S')

# Get existing window names in current session
existing_windows=$(tmux list-windows -t "$session_name" -F "#{window_name}" 2>/dev/null)

created_count=0
skipped_count=0

echo "Creating windows for worktrees..."
echo ""

# Parse worktrees and create windows
while IFS= read -r line; do
    # Extract worktree path and branch
    worktree_path=$(echo "$line" | awk '{print $2}')
    branch_info=$(echo "$line" | awk '{print $4}')

    # Get branch name (remove refs/heads/ prefix)
    branch_name="${branch_info#refs/heads/}"

    # Skip if branch name is empty
    if [ -z "$branch_name" ]; then
        continue
    fi

    # Check if window with this name already exists
    if echo "$existing_windows" | grep -q "^${branch_name}$"; then
        echo "  ⊘ Skipping '$branch_name' - window already exists"
        skipped_count=$((skipped_count + 1))
        continue
    fi

    # Create new window with branch name
    tmux new-window -t "$session_name" -n "$branch_name" -c "$worktree_path" -d

    echo "  ✓ Created window '$branch_name' for worktree at $worktree_path"
    created_count=$((created_count + 1))
done <<< "$worktrees"

echo ""
echo "Summary:"
echo "  Created: $created_count windows"
echo "  Skipped: $skipped_count windows (already exist)"
echo ""
echo "Press any key to close..."
read -n 1 -s -r
