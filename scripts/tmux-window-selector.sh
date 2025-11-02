#!/usr/bin/env bash

# Get current session name
session_name=$(tmux display-message -p '#S')

# Get all windows in the current session with their details
windows=$(tmux list-windows -t "$session_name" -F "#{window_index}:#{window_name}:#{window_active}:#{pane_current_path}" 2>/dev/null)

if [ -z "$windows" ]; then
    echo "No windows found in current session"
    exit 0
fi

# Build options list with window details and worktree info
options=""
while IFS=: read -r index name active path; do
    # Skip empty lines
    [[ -z "$index" ]] && continue

    # Get worktree info if the path is in ~/Code/worktrees/
    worktree_info=""
    if [[ "$path" == "$HOME/Code/worktrees/"* ]]; then
        # Extract relative path from worktrees
        relative_path="${path#$HOME/Code/worktrees/}"

        # Get owner and repo-branch
        owner=$(echo "$relative_path" | cut -d'/' -f1)
        repo_with_branch=$(echo "$relative_path" | cut -d'/' -f2)

        # Get current branch
        if git -C "$path" rev-parse --git-dir &>/dev/null 2>&1; then
            current_branch=$(git -C "$path" rev-parse --abbrev-ref HEAD 2>/dev/null)
            repo=$(echo "$repo_with_branch" | sed "s/-${current_branch}$//")
            worktree_info="[$owner/$repo @ $current_branch]"
        else
            worktree_info="[$relative_path]"
        fi
    else
        # Not a worktree, just show the path
        short_path=$(echo "$path" | sed "s|^$HOME|~|")
        worktree_info="[$short_path]"
    fi

    # Mark active window
    active_marker=""
    if [ "$active" = "1" ]; then
        active_marker="*"
    fi

    # Format: "index: name [worktree_info] active_marker"
    options="${options}${index}: ${name} ${worktree_info} ${active_marker}\n"
done <<< "$windows"

# Use fzf to select a window
selected=$(echo -e "$options" | fzf \
    --height=100% \
    --reverse \
    --border \
    --prompt="Select window: " \
    --bind='enter:accept' \
    --preview="
        # Extract window index from selection
        window_idx=\$(echo {} | awk '{print \$1}' | tr -d ':')

        # Get window details
        window_path=\$(tmux list-windows -t '$session_name' -F '#{window_index}:#{pane_current_path}' | grep \"^\${window_idx}:\" | cut -d: -f2-)

        echo \"Window: \$window_idx\"
        echo \"Path: \$window_path\"
        echo \"\"

        # Show git status if in a git repo
        if git -C \"\$window_path\" rev-parse --git-dir &>/dev/null 2>&1; then
            echo \"=== Git Status ===\"
            git -C \"\$window_path\" status --short 2>/dev/null || echo \"No git status available\"
            echo \"\"
            echo \"=== Recent Commits ===\"
            git -C \"\$window_path\" log --oneline --graph --color=always -10 2>/dev/null || echo \"No git history available\"
        else
            echo \"Not a git repository\"
        fi
    " \
    --preview-window=right:60%:wrap \
    --header="↑↓ navigate, Enter select, Esc cancel")

if [ -z "$selected" ]; then
    exit 0
fi

# Extract window index from selection
window_index=$(echo "$selected" | awk '{print $1}' | tr -d ':')

# Switch to the selected window
tmux select-window -t "${session_name}:${window_index}"
