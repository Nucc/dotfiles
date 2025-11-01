#!/usr/bin/env bash

# Get current filter mode (all/work/personal)
filter_mode=$(tmux show-option -gv @session-filter-mode 2>/dev/null || echo "all")

# Get current session name
current_session=$(tmux display-message -p '#S')

# Get all sessions
sessions=$(tmux list-sessions -F "#{session_name}" 2>/dev/null)

# Filter and format sessions
formatted_sessions=""
count=0

while IFS= read -r session; do
    # Skip empty lines
    [[ -z "$session" ]] && continue

    # Check if session matches filter
    show_session=false
    display_name="$session"

    case "$filter_mode" in
        work)
            if [[ "$session" == *"[W]" ]]; then
                show_session=true
                display_name="${session%\[W\]}"  # Remove [W] suffix
            fi
            ;;
        personal)
            if [[ "$session" == *"[P]" ]]; then
                show_session=true
                display_name="${session%\[P\]}"  # Remove [P] suffix
            fi
            ;;
        all)
            show_session=true
            # Remove both [W] and [P] suffixes for display
            display_name="${session%\[W\]}"
            display_name="${display_name%\[P\]}"
            ;;
    esac

    # If session should be shown, format it
    if [ "$show_session" = true ]; then
        count=$((count + 1))

        # Highlight current session
        if [ "$session" = "$current_session" ]; then
            formatted_sessions="${formatted_sessions}#[fg=black,bg=yellow,bold] ${display_name} #[fg=#D8DEE9,bg=#292929,nobold] "
        else
            formatted_sessions="${formatted_sessions}#[fg=white,bg=brightblack] ${display_name} #[fg=#D8DEE9,bg=#292929] "
        fi
    fi
done <<< "$sessions"

# Add filter mode indicator
filter_indicator=""
case "$filter_mode" in
    work)
        filter_indicator="#[fg=#A3BE8C,bg=#292929] [Work]#[fg=#D8DEE9] "
        ;;
    personal)
        filter_indicator="#[fg=#A3BE8C,bg=#292929] [Personal]#[fg=#D8DEE9] "
        ;;
    all)
        filter_indicator="#[fg=#A3BE8C,bg=#292929] [All]#[fg=#D8DEE9] "
        ;;
esac

# Output formatted sessions with filter indicator
if [ $count -eq 0 ]; then
    echo "${filter_indicator}#[fg=red]No sessions found"
else
    echo "${filter_indicator}${formatted_sessions}"
fi
