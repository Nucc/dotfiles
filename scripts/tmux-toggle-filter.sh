#!/usr/bin/env bash

# Get current filter mode
current_mode=$(tmux show-option -gv @session-filter-mode 2>/dev/null || echo "all")

# Cycle through modes: all → work → personal → all
case "$current_mode" in
    all)
        new_mode="work"
        message="Session filter: Work only"
        ;;
    work)
        new_mode="personal"
        message="Session filter: Personal only"
        ;;
    personal)
        new_mode="all"
        message="Session filter: All sessions"
        ;;
    *)
        new_mode="all"
        message="Session filter: All sessions"
        ;;
esac

# Set the new filter mode
tmux set-option -g @session-filter-mode "$new_mode"

# Refresh the status bar
tmux refresh-client -S

# Display message to user
tmux display-message "$message"
