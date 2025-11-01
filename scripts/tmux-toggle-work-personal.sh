#!/usr/bin/env bash

# Get direction from argument (forward or backward)
direction="${1:-forward}"

# Get current filter mode
current_mode=$(tmux show-option -gv @session-filter-mode 2>/dev/null || echo "all")
current_session=$(tmux display-message -p '#S')

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

# Get all sessions matching the new filter
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
