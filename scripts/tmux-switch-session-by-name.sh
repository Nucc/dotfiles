#!/usr/bin/env bash

# Interactive session switcher with fzf
current_session=$(tmux display-message -p '#{session_name}')

# Get all sessions
all_sessions=$(tmux list-sessions -F "#{session_name}" | grep -v "$current_session" 2>/dev/null)

if [ -z "$all_sessions" ]; then
    echo "No other sessions to switch to"
    exit 0
fi

# Use fzf to select session
selected_session=$(echo "$all_sessions" | fzf --height 10 --prompt="Switch to session: ")

if [ -n "$selected_session" ]; then
    # Switch to selected session
    tmux switch-client -t "$selected_session"

    # Update filter mode if needed
    filter_mode=$(tmux show-option -gv @session-filter-mode 2>/dev/null || echo "all")
    tmux set-option -g "@session-last-${filter_mode}" "$selected_session"

    echo "Switched to session: $selected_session"
else
    echo "No session selected"
fi