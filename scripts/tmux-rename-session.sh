#!/usr/bin/env bash

# This script is called by tmux command-prompt with the new name as argument
# Usage: tmux-rename-session.sh <new_base_name>

new_name="$1"

# Get current session name
current_session=$(tmux display-message -p '#S')

# Strip any existing suffix from input (in case user left it in)
new_name="${new_name%% \[*\]}"

# If empty input, cancel
if [ -z "$new_name" ]; then
  tmux display-message "Rename cancelled"
  exit 0
fi

# Determine the space based on current session name
if [[ "$current_session" == *"[W]" ]]; then
  suffix="[W]"
elif [[ "$current_session" == *"[P]" ]]; then
  suffix="[P]"
else
  # Default to current filter mode if session has no suffix
  current_mode=$(tmux show-option -gv @session-filter-mode 2>/dev/null || echo "all")
  case "$current_mode" in
    work)
      suffix="[W]"
      ;;
    personal)
      suffix="[P]"
      ;;
    *)
      # No suffix for "all" mode
      suffix=""
      ;;
  esac
fi

# Construct new session name with appropriate suffix
if [ -n "$suffix" ]; then
  new_session_name="${new_name} ${suffix}"
else
  new_session_name="${new_name}"
fi

# Check if a session with this name already exists (and it's not the current one)
if [ "$new_session_name" != "$current_session" ] && tmux has-session -t "$new_session_name" 2>/dev/null; then
  tmux display-message "Session '$new_session_name' already exists"
  exit 1
fi

# Rename the session
tmux rename-session "$new_session_name"

# Refresh the status bar
tmux refresh-client -S
