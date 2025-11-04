#!/usr/bin/env bash

# Manually re-link shared files for the current worktree
# Useful for updating symlinks after changes to the shared folder

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

echo "Re-linking shared files for worktree:"
echo "  Path: $worktree_path"
echo ""

# Call the shared linking script
if [ -f "$HOME/.dotfiles/scripts/tmux-worktree-link-shared.sh" ]; then
    "$HOME/.dotfiles/scripts/tmux-worktree-link-shared.sh" "$worktree_path"
else
    echo "Error: Shared linking script not found"
    exit 1
fi

echo ""
read -n 1 -s -r -p "Press any key to close..."
