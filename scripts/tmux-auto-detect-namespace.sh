#!/usr/bin/env bash

# Auto-detect namespace from current session and set filter mode accordingly

# Get current session name
current_session=$(tmux display-message -p '#S')

# Determine the namespace based on session name
if [[ "$current_session" == *"[W]" ]]; then
  new_mode="work"
elif [[ "$current_session" == *"[P]" ]]; then
  new_mode="personal"
else
  new_mode="all"
fi

# Get current filter mode
current_mode=$(tmux show-option -gv @session-filter-mode 2>/dev/null || echo "all")

# Only update if different to avoid unnecessary refreshes
if [ "$new_mode" != "$current_mode" ]; then
  tmux set-option -g @session-filter-mode "$new_mode"
  tmux refresh-client -S
fi
