#!/usr/bin/env bash

# Get current filter mode (work/personal/all -> others)
filter_mode=$(tmux show-option -gv @session-filter-mode 2>/dev/null || echo "all")

# Get current session name
current_session=$(tmux display-message -p '#S')

# Get all sessions in one call
sessions=$(tmux list-sessions -F "#{session_name}" 2>/dev/null)

# Quick exit if no sessions
if [ -z "$sessions" ]; then
    echo "#[fg=red]No sessions"
    exit 0
fi

# Filter and format sessions
formatted_sessions=""
count=0

# Process sessions
while IFS= read -r session; do
    [[ -z "$session" ]] && continue

    # Quick filter check
    show_session=false
    display_name="$session"

    if [[ "$filter_mode" == "work" ]]; then
        # Show only [W] sessions
        [[ "$session" == *"[W]" ]] && { show_session=true; display_name="${session%\[W\]}"; }
    elif [[ "$filter_mode" == "personal" ]]; then
        # Show only [P] sessions
        [[ "$session" == *"[P]" ]] && { show_session=true; display_name="${session%\[P\]}"; }
    else
        # Show only sessions WITHOUT [W] or [P]
        if [[ "$session" != *"[W]" && "$session" != *"[P]" ]]; then
            show_session=true
            display_name="$session"
        fi
    fi

    # Format if should be shown
    if [ "$show_session" = true ]; then
        count=$((count + 1))

        if [ "$session" = "$current_session" ]; then
            formatted_sessions+="#[fg=black,bg=yellow,bold] ${count}:${display_name} #[fg=#D8DEE9,bg=#292929,nobold] "
        else
            formatted_sessions+="#[fg=white,bg=brightblack] ${count}:${display_name} #[fg=#D8DEE9,bg=#292929] "
        fi
    fi
done <<< "$sessions"

# Output (no filter labels)
[ $count -eq 0 ] && echo "#[fg=red]No sessions" || echo "$formatted_sessions"
