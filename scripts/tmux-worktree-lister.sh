#!/usr/bin/env bash

# Get current window index
current_window=$(tmux display-message -p '#I')

# Get all windows in the current session
windows=$(tmux list-windows -F "#{window_index}:#{window_name}:#{window_active}" 2>/dev/null)

# Format windows for display
formatted_windows=""
count=0

while IFS=: read -r index name active; do
    # Skip empty lines
    [[ -z "$index" ]] && continue

    count=$((count + 1))

    # Highlight active window
    if [ "$active" = "1" ]; then
        formatted_windows="${formatted_windows}#[fg=black,bg=yellow,bold] ${index}:${name} #[fg=#D8DEE9,bg=#1c1c1c,nobold] "
    else
        formatted_windows="${formatted_windows}#[fg=white,bg=#3a3a3a] ${index}:${name} #[fg=#D8DEE9,bg=#1c1c1c] "
    fi
done <<< "$windows"

# Output formatted windows
if [ $count -eq 0 ]; then
    echo ""
else
    echo "${formatted_windows}"
fi
