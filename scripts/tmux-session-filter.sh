#!/usr/bin/env bash

# Get current filter mode (all/work/personal)
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
        [[ "$session" == *"[W]" ]] && { show_session=true; display_name="${session%\[W\]}"; }
    elif [[ "$filter_mode" == "personal" ]]; then
        [[ "$session" == *"[P]" ]] && { show_session=true; display_name="${session%\[P\]}"; }
    else
        show_session=true
        display_name="${session%\[W\]}"
        display_name="${display_name%\[P\]}"
    fi

    # Format if should be shown
    if [ "$show_session" = true ]; then
        count=$((count + 1))

        if [ "$session" = "$current_session" ]; then
            formatted_sessions+="#[fg=black,bg=yellow,bold] ${display_name} #[fg=#D8DEE9,bg=#292929,nobold] "
        else
            formatted_sessions+="#[fg=white,bg=brightblack] ${display_name} #[fg=#D8DEE9,bg=#292929] "
        fi
    fi
done <<< "$sessions"

# Filter indicator
case "$filter_mode" in
    work) filter_indicator="#[fg=#A3BE8C,bg=#292929][W]#[fg=#D8DEE9] " ;;
    personal) filter_indicator="#[fg=#A3BE8C,bg=#292929][P]#[fg=#D8DEE9] " ;;
    all) filter_indicator="#[fg=#A3BE8C,bg=#292929][All]#[fg=#D8DEE9] " ;;
esac

# Output
[ $count -eq 0 ] && echo "${filter_indicator}#[fg=red]No sessions" || echo "${filter_indicator}${formatted_sessions}"
