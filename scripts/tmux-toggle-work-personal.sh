#!/usr/bin/env bash

# Get current filter mode
current_mode=$(tmux show-option -gv @session-filter-mode 2>/dev/null || echo "all")
current_session=$(tmux display-message -p '#S')

# Toggle between work and personal (skip "all")
case "$current_mode" in
    work)
        new_mode="personal"
        message="Session filter: Personal"
        target_suffix="[P]"
        ;;
    personal)
        new_mode="work"
        message="Session filter: Work"
        target_suffix="[W]"
        ;;
    all|*)
        # If currently "all" or unknown, default to work
        new_mode="work"
        message="Session filter: Work"
        target_suffix="[W]"
        ;;
esac

# Set the new filter mode
tmux set-option -g @session-filter-mode "$new_mode"

# Refresh the status bar
tmux refresh-client -S

# Find a session matching the new filter
target_session=""

# Get all sessions matching the new filter
all_sessions=$(tmux list-sessions -F "#{session_name}" 2>/dev/null | sort)

while IFS= read -r session; do
    [[ -z "$session" ]] && continue

    if [[ "$session" == *"$target_suffix" ]]; then
        target_session="$session"
        break
    fi
done <<< "$all_sessions"

# Switch to target session if found and different from current
if [ -n "$target_session" ] && [ "$target_session" != "$current_session" ]; then
    tmux switch-client -t "$target_session"
    tmux display-message "$message - switched to $target_session"
elif [ -z "$target_session" ]; then
    tmux display-message "$message - no sessions found"
else
    tmux display-message "$message"
fi
