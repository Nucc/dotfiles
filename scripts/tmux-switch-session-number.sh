#!/usr/bin/env bash

# Get target number from argument
target_number="${1:-1}"

# Get current filter mode
filter_mode=$(tmux show-option -gv @session-filter-mode 2>/dev/null || echo "all")

# Get all sessions
all_sessions=$(tmux list-sessions -F "#{session_name}" 2>/dev/null)

if [ -z "$all_sessions" ]; then
    tmux display-message "No sessions found"
    exit 0
fi

# Filter sessions based on current mode
filtered_sessions=""
while IFS= read -r session; do
    [[ -z "$session" ]] && continue

    case "$filter_mode" in
        work)
            [[ "$session" == *"[W]" ]] && filtered_sessions+="${session}"$'\n'
            ;;
        personal)
            [[ "$session" == *"[P]" ]] && filtered_sessions+="${session}"$'\n'
            ;;
        all)
            # Show only sessions without [W] or [P]
            [[ "$session" != *"[W]" && "$session" != *"[P]" ]] && filtered_sessions+="${session}"$'\n'
            ;;
    esac
done <<< "$all_sessions"

# Remove trailing newline and sort
filtered_sessions=$(echo "$filtered_sessions" | sed '/^$/d' | sort)

# If no filtered sessions, exit
if [ -z "$filtered_sessions" ]; then
    tmux display-message "No sessions in current filter"
    exit 0
fi

# Convert to array
mapfile -t sessions_array <<< "$filtered_sessions"

# Check if target number is valid
total_sessions=${#sessions_array[@]}

if [ "$target_number" -lt 1 ] || [ "$target_number" -gt "$total_sessions" ]; then
    tmux display-message "Session $target_number not found (1-$total_sessions available)"
    exit 0
fi

# Get target session (array is 0-indexed)
target_session="${sessions_array[$((target_number - 1))]}"

# Switch to target session
if [ -n "$target_session" ]; then
    tmux switch-client -t "$target_session"
    # Store this as the last active session for this filter mode
    tmux set-option -g "@session-last-${filter_mode}" "$target_session"
    tmux refresh-client -S
else
    tmux display-message "Session $target_number not found"
fi
