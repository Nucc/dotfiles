#!/usr/bin/env bash

# Get current session name
current_session=$(tmux display-message -p '#S')

# Get all sessions in one call
sessions=$(tmux list-sessions -F "#{session_name}" 2>/dev/null)

# Quick exit if no sessions
if [ -z "$sessions" ]; then
    echo "#[fg=red]No sessions"
    exit 0
fi

# Separate sessions into three groups
work_sessions=""
personal_sessions=""
other_sessions=""

# Process sessions
while IFS= read -r session; do
    [[ -z "$session" ]] && continue

    display_name="$session"
    is_current=false
    [ "$session" = "$current_session" ] && is_current=true

    if [[ "$session" == *"[W]" ]]; then
        # Work session
        display_name="${session%\[W\]}"
        if [ "$is_current" = true ]; then
            work_sessions+="#[fg=black,bg=yellow,bold] ${display_name} #[fg=#D8DEE9,bg=#292929,nobold] "
        else
            work_sessions+="#[fg=white,bg=brightblack] ${display_name} #[fg=#D8DEE9,bg=#292929] "
        fi
    elif [[ "$session" == *"[P]" ]]; then
        # Personal session
        display_name="${session%\[P\]}"
        if [ "$is_current" = true ]; then
            personal_sessions+="#[fg=black,bg=yellow,bold] ${display_name} #[fg=#D8DEE9,bg=#292929,nobold] "
        else
            personal_sessions+="#[fg=white,bg=brightblack] ${display_name} #[fg=#D8DEE9,bg=#292929] "
        fi
    else
        # Other session (no suffix)
        if [ "$is_current" = true ]; then
            other_sessions+="#[fg=black,bg=yellow,bold] ${display_name} #[fg=#D8DEE9,bg=#292929,nobold] "
        else
            other_sessions+="#[fg=white,bg=brightblack] ${display_name} #[fg=#D8DEE9,bg=#292929] "
        fi
    fi
done <<< "$sessions"

# Build output with separators
output=""

# Add work sessions with label
if [ -n "$work_sessions" ]; then
    output+="#[fg=#A3BE8C,bg=#292929]W:#[fg=#D8DEE9] ${work_sessions}"
fi

# Add personal sessions with label
if [ -n "$personal_sessions" ]; then
    [ -n "$output" ] && output+="#[fg=#666,bg=#292929]│#[fg=#D8DEE9] "
    output+="#[fg=#88C0D0,bg=#292929]P:#[fg=#D8DEE9] ${personal_sessions}"
fi

# Add other sessions with label
if [ -n "$other_sessions" ]; then
    [ -n "$output" ] && output+="#[fg=#666,bg=#292929]│#[fg=#D8DEE9] "
    output+="#[fg=#666,bg=#292929]Other:#[fg=#D8DEE9] ${other_sessions}"
fi

# Output
[ -z "$output" ] && echo "#[fg=red]No sessions" || echo "$output"
