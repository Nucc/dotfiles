#!/usr/bin/env bash

# Get direction from argument (next or previous)
direction="${1:-next}"

# Get current filter mode
filter_mode=$(tmux show-option -gv @session-filter-mode 2>/dev/null || echo "all")

# Get current session
current_session=$(tmux display-message -p '#S')

# Get all sessions
all_sessions=$(tmux list-sessions -F "#{session_name}" 2>/dev/null | sort)

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
            filtered_sessions="${filtered_sessions}${session}"$'\n'
            ;;
    esac
done <<< "$all_sessions"

# Remove trailing newline
filtered_sessions=$(echo "$filtered_sessions" | sed '/^$/d')

# If no filtered sessions, exit
if [ -z "$filtered_sessions" ]; then
    tmux display-message "No sessions found in current filter"
    exit 0
fi

# Convert to array
IFS=$'\n' read -r -d '' -a sessions_array <<< "$filtered_sessions"

# Find current session index
current_index=-1
for i in "${!sessions_array[@]}"; do
    if [ "${sessions_array[$i]}" = "$current_session" ]; then
        current_index=$i
        break
    fi
done

# Calculate next/previous index
total_sessions=${#sessions_array[@]}

if [ "$direction" = "next" ]; then
    next_index=$(( (current_index + 1) % total_sessions ))
else
    next_index=$(( (current_index - 1 + total_sessions) % total_sessions ))
fi

# Get target session
target_session="${sessions_array[$next_index]}"

# Switch to target session
if [ -n "$target_session" ]; then
    tmux switch-client -t "$target_session"
else
    tmux display-message "No target session found"
fi
