#!/bin/bash

# Get current window index
current_window=$(tmux display-message -p '#{window_index}')

# Get all window indices
windows=$(tmux list-windows -F '#{window_index}' | sort -n)

# Build the output string
output="["
first=true

for win in $windows; do
    if [ "$win" = "$current_window" ]; then
        # Current window in yellow
        output+="#[fg=yellow]${win}#[fg=green]"
    else
        # Other windows in green
        output+="${win}"
    fi
done

output+="]"

echo "$output"
