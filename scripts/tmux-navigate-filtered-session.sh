#!/usr/bin/env bash

# Get direction from argument (next or previous)
direction="${1:-next}"

# Get current filter mode
filter_mode=$(tmux show-option -gv @session-filter-mode 2>/dev/null || echo "all")

# Get current session
current_session=$(tmux display-message -p '#S')

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
            if [[ "$session" == *"[W]" ]]; then
                filtered_sessions="${filtered_sessions}${session}"$'\n'
            fi
            ;;
        personal)
            if [[ "$session" == *"[P]" ]]; then
                filtered_sessions="${filtered_sessions}${session}"$'\n'
            fi
            ;;
        all)
            # Show only sessions without [W] or [P]
            if [[ "$session" != *"[W]" && "$session" != *"[P]" ]]; then
                filtered_sessions="${filtered_sessions}${session}"$'\n'
            fi
            ;;
    esac
done <<< "$all_sessions"

# Remove trailing newline and sort
filtered_sessions=$(echo "$filtered_sessions" | sed '/^$/d' | sort)

# If no filtered sessions, exit
if [ -z "$filtered_sessions" ]; then
    tmux display-message "No sessions in $filter_mode filter"
    exit 0
fi

# Convert to array
mapfile -t sessions_array <<< "$filtered_sessions"

# Check if we have sessions
if [ ${#sessions_array[@]} -eq 0 ]; then
    tmux display-message "No sessions available"
    exit 0
fi

# If only one session, stay on it
if [ ${#sessions_array[@]} -eq 1 ]; then
    tmux display-message "Only one session in $filter_mode filter"
    exit 0
fi

# Find current session index
current_index=-1
for i in "${!sessions_array[@]}"; do
    if [ "${sessions_array[$i]}" = "$current_session" ]; then
        current_index=$i
        break
    fi
done

# If current session not found in filtered list, go to first session
if [ $current_index -eq -1 ]; then
    target_session="${sessions_array[0]}"
else
    # Calculate next/previous index
    total_sessions=${#sessions_array[@]}

    if [ "$direction" = "next" ]; then
        next_index=$(( (current_index + 1) % total_sessions ))
    else
        next_index=$(( (current_index - 1 + total_sessions) % total_sessions ))
    fi

    target_session="${sessions_array[$next_index]}"
fi

# Switch to target session
if [ -n "$target_session" ]; then
    tmux switch-client -t "$target_session"
    # Store this as the last active session for this filter mode
    tmux set-option -g "@session-last-${filter_mode}" "$target_session"
    tmux refresh-client -S
else
    tmux display-message "No target session found"
fi
