#!/usr/bin/env bash

# Get direction from argument (forward or backward)
direction="${1:-forward}"

# Get current filter mode
current_mode=$(tmux show-option -gv @session-filter-mode 2>/dev/null || echo "all")
current_session=$(tmux display-message -p '#S')

# Store the current session as the last active for this mode
tmux set-option -g "@session-last-${current_mode}" "$current_session"

# Cycle through modes based on direction
if [ "$direction" = "forward" ]; then
  # Forward: work → personal → all (others) → work
  case "$current_mode" in
  work)
    new_mode="personal"
    message="Session filter: Personal"
    target_suffix="[P]"
    ;;
  personal)
    new_mode="all"
    message="Session filter: Others"
    target_suffix=""
    ;;
  all | *)
    new_mode="work"
    message="Session filter: Work"
    target_suffix="[W]"
    ;;
  esac
else
  # Backward: work → all (others) → personal → work
  case "$current_mode" in
  work)
    new_mode="all"
    message="Session filter: Others"
    target_suffix=""
    ;;
  all)
    new_mode="personal"
    message="Session filter: Personal"
    target_suffix="[P]"
    ;;
  personal | *)
    new_mode="work"
    message="Session filter: Work"
    target_suffix="[W]"
    ;;
  esac
fi

# Set the new filter mode
tmux set-option -g @session-filter-mode "$new_mode"

# Refresh the status bar
tmux refresh-client -S

# Find a session matching the new filter
target_session=""

# First, try to restore the last active session for this mode
last_session=$(tmux show-option -gv "@session-last-${new_mode}" 2>/dev/null)

# Check if the last session still exists and matches the filter
if [ -n "$last_session" ]; then
  session_exists=$(tmux list-sessions -F "#{session_name}" 2>/dev/null | grep -Fx "$last_session")

  if [ -n "$session_exists" ]; then
    # Verify it still matches the filter
    if [ "$new_mode" = "all" ]; then
      [[ "$last_session" != *"[W]" && "$last_session" != *"[P]" ]] && target_session="$last_session"
    elif [[ "$last_session" == *"$target_suffix" ]]; then
      target_session="$last_session"
    fi
  fi
fi

# If no last session found, get the first matching session
if [ -z "$target_session" ]; then
  all_sessions=$(tmux list-sessions -F "#{session_name}" 2>/dev/null | sort)

  while IFS= read -r session; do
    [[ -z "$session" ]] && continue

    if [ "$new_mode" = "all" ]; then
      # For "all" mode, find session without [W] or [P]
      if [[ "$session" != *"[W]" && "$session" != *"[P]" ]]; then
        target_session="$session"
        break
      fi
    elif [[ "$session" == *"$target_suffix" ]]; then
      target_session="$session"
      break
    fi
  done <<<"$all_sessions"
fi

# Switch to target session if found and different from current
if [ -n "$target_session" ] && [ "$target_session" != "$current_session" ]; then
  tmux switch-client -t "$target_session"
  tmux refresh-client -S
  # tmux display-message "$message - switched to $target_session"
elif [ -z "$target_session" ]; then
  tmux display-message "$message - no sessions found"
else
  tmux display-message "$message"
fi
