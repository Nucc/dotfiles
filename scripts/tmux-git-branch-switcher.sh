#!/bin/bash

# Get the actual current directory from tmux pane
CURRENT_DIR=$(tmux display-message -p '#{pane_current_path}')
cd "$CURRENT_DIR" || {
    echo "Error: Could not change to directory $CURRENT_DIR"
    read -n 1 -s -r -p "Press any key to continue..."
    exit 1
}
echo "Working in directory: $CURRENT_DIR"

# Check if we're in a git repository
if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo "Error: Not in a git repository"
    read -n 1 -s -r -p "Press any key to continue..."
    exit 1
fi

# Get all branches and remove the current branch marker
BRANCHES=$(git branch --format='%(refname:short)' | sort)

if [ -z "$BRANCHES" ]; then
    echo "Error: No branches found"
    read -n 1 -s -r -p "Press any key to continue..."
    exit 1
fi

# Use fzf to select a branch
SELECTED_BRANCH=$(echo "$BRANCHES" | fzf \
    --height=100% \
    --reverse \
    --border \
    --prompt="Switch to branch: " \
    --preview="git log --oneline --graph --color=always {} | head -10" \
    --preview-window=right:50%:wrap \
    --header="Use ↑↓ to navigate, Enter to select, Esc to cancel")

if [ -n "$SELECTED_BRANCH" ]; then
    # Switch to the selected branch
    echo "Switching to branch: $SELECTED_BRANCH"
    if git checkout "$SELECTED_BRANCH" 2>&1; then
        echo "Successfully switched to branch: $SELECTED_BRANCH"
    else
        echo "Failed to switch to branch: $SELECTED_BRANCH"
        read -n 1 -s -r -p "Press any key to continue..."
    fi
else
    echo "No branch selected"
fi