#!/usr/bin/env bash

# Get current filter mode
filter_mode=$(tmux show-option -gv @session-filter-mode 2>/dev/null || echo "work")

# Determine suffix based on filter mode
case "$filter_mode" in
    work)
        suffix="[W]"
        ;;
    personal)
        suffix="[P]"
        ;;
    all)
        # Default to work if in "all" mode
        suffix="[W]"
        ;;
esac

# Session name is always "zsh"
session_name="zsh"
session_dir="$HOME"

# Find a unique session name by appending a number if needed
base_name="${session_name}${suffix}"
full_session_name="$base_name"
counter=1

while tmux has-session -t "$full_session_name" 2>/dev/null; do
    counter=$((counter + 1))
    full_session_name="${session_name}-${counter}${suffix}"
done

# Create new session
tmux new-session -d -s "$full_session_name" -c "$session_dir"

# Switch to the new session
tmux switch-client -t "$full_session_name"

# Display message
tmux display-message "Created session: $full_session_name"
