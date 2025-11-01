#!/usr/bin/env bash

# Get current filter mode
current_mode=$(tmux show-option -gv @session-filter-mode 2>/dev/null || echo "all")

# Cycle through modes: all (others) → work → personal → all (others)
case "$current_mode" in
    all)
        new_mode="work"
        message="Session filter: Work"
        ;;
    work)
        new_mode="personal"
        message="Session filter: Personal"
        ;;
    personal)
        new_mode="all"
        message="Session filter: Others"
        ;;
    *)
        new_mode="all"
        message="Session filter: Others"
        ;;
esac

# Set the new filter mode
tmux set-option -g @session-filter-mode "$new_mode"

# Display message to user
tmux display-message "$message"

# Refresh the status bar immediately
tmux refresh-client -S
