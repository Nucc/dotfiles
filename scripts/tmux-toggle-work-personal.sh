#!/usr/bin/env bash

# Get current filter mode
current_mode=$(tmux show-option -gv @session-filter-mode 2>/dev/null || echo "all")

# Toggle between work and personal (skip "all")
case "$current_mode" in
    work)
        new_mode="personal"
        message="Session filter: Personal"
        ;;
    personal)
        new_mode="work"
        message="Session filter: Work"
        ;;
    all|*)
        # If currently "all" or unknown, default to work
        new_mode="work"
        message="Session filter: Work"
        ;;
esac

# Set the new filter mode
tmux set-option -g @session-filter-mode "$new_mode"

# Refresh the status bar
tmux refresh-client -S

# Display message to user
tmux display-message "$message"
