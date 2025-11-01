#!/usr/bin/env bash

# Get direction from argument (forward or backward)
direction="${1:-forward}"

# Get current filter mode
current_mode=$(tmux show-option -gv @session-filter-mode 2>/dev/null || echo "all")
current_session=$(tmux display-message -p '#S')

# Store the current session as the last active for this mode
tmux set-option -g "@session-last-${current_mode}" "$current_session"

# Helper function to check if there are sessions for a given mode
has_sessions_for_mode() {
  local mode="$1"
  local all_sessions=$(tmux list-sessions -F "#{session_name}" 2>/dev/null | sort)

  if [ "$mode" = "all" ]; then
    # Check for sessions without [W] or [P]
    while IFS= read -r session; do
      [[ -z "$session" ]] && continue
      if [[ "$session" != *"[W]" && "$session" != *"[P]" ]]; then
        return 0  # Found at least one
      fi
    done <<<"$all_sessions"
    return 1  # None found
  elif [ "$mode" = "work" ]; then
    # Check for sessions with [W]
    while IFS= read -r session; do
      [[ -z "$session" ]] && continue
      if [[ "$session" == *"[W]" ]]; then
        return 0
      fi
    done <<<"$all_sessions"
    return 1
  elif [ "$mode" = "personal" ]; then
    # Check for sessions with [P]
    while IFS= read -r session; do
      [[ -z "$session" ]] && continue
      if [[ "$session" == *"[P]" ]]; then
        return 0
      fi
    done <<<"$all_sessions"
    return 1
  fi
  return 1
}

# Cycle through modes based on direction
if [ "$direction" = "forward" ]; then
  # Forward: work → personal → all (others) → work (skip modes with no sessions)
  case "$current_mode" in
  work)
    if has_sessions_for_mode "personal"; then
      new_mode="personal"
      message="Session filter: Personal"
      target_suffix="[P]"
    elif has_sessions_for_mode "all"; then
      new_mode="all"
      message="Session filter: Others"
      target_suffix=""
    else
      new_mode="work"
      message="Session filter: Work"
      target_suffix="[W]"
    fi
    ;;
  personal)
    if has_sessions_for_mode "all"; then
      new_mode="all"
      message="Session filter: Others"
      target_suffix=""
    elif has_sessions_for_mode "work"; then
      new_mode="work"
      message="Session filter: Work"
      target_suffix="[W]"
    else
      new_mode="personal"
      message="Session filter: Personal"
      target_suffix="[P]"
    fi
    ;;
  all | *)
    if has_sessions_for_mode "work"; then
      new_mode="work"
      message="Session filter: Work"
      target_suffix="[W]"
    elif has_sessions_for_mode "personal"; then
      new_mode="personal"
      message="Session filter: Personal"
      target_suffix="[P]"
    else
      new_mode="all"
      message="Session filter: Others"
      target_suffix=""
    fi
    ;;
  esac
else
  # Backward: work → all (others) → personal → work (skip modes with no sessions)
  case "$current_mode" in
  work)
    if has_sessions_for_mode "all"; then
      new_mode="all"
      message="Session filter: Others"
      target_suffix=""
    elif has_sessions_for_mode "personal"; then
      new_mode="personal"
      message="Session filter: Personal"
      target_suffix="[P]"
    else
      new_mode="work"
      message="Session filter: Work"
      target_suffix="[W]"
    fi
    ;;
  all)
    if has_sessions_for_mode "personal"; then
      new_mode="personal"
      message="Session filter: Personal"
      target_suffix="[P]"
    elif has_sessions_for_mode "work"; then
      new_mode="work"
      message="Session filter: Work"
      target_suffix="[W]"
    else
      new_mode="all"
      message="Session filter: Others"
      target_suffix=""
    fi
    ;;
  personal | *)
    if has_sessions_for_mode "work"; then
      new_mode="work"
      message="Session filter: Work"
      target_suffix="[W]"
    elif has_sessions_for_mode "all"; then
      new_mode="all"
      message="Session filter: Others"
      target_suffix=""
    else
      new_mode="personal"
      message="Session filter: Personal"
      target_suffix="[P]"
    fi
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
