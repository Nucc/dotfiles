#!/usr/bin/env bash

# Get current filter mode (work/personal/all -> others)
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

# Filter sessions first
filtered_sessions=""
while IFS= read -r session; do
  [[ -z "$session" ]] && continue

  if [[ "$filter_mode" == "work" ]]; then
    # Show only [W] sessions
    [[ "$session" == *"[W]" ]] && filtered_sessions+="${session}"$'\n'
  elif [[ "$filter_mode" == "personal" ]]; then
    # Show only [P] sessions
    [[ "$session" == *"[P]" ]] && filtered_sessions+="${session}"$'\n'
  else
    # Show only sessions WITHOUT [W] or [P]
    [[ "$session" != *"[W]" && "$session" != *"[P]" ]] && filtered_sessions+="${session}"$'\n'
  fi
done <<<"$sessions"

# Sort filtered sessions (to match tmux-switch-session-number.sh)
filtered_sessions=$(echo "$filtered_sessions" | sed '/^$/d' | sort)

# Format sorted sessions
formatted_sessions=""
count=0

while IFS= read -r session; do
  [[ -z "$session" ]] && continue

  count=$((count + 1))

  # Get display name (remove [W] or [P] suffix)
  display_name="$session"
  if [[ "$filter_mode" == "work" ]]; then
    display_name="${session%\[W\]}"
  elif [[ "$filter_mode" == "personal" ]]; then
    display_name="${session%\[P\]}"
  fi

  if [ "$session" = "$current_session" ]; then
    formatted_sessions+="#[fg=black,bg=yellow,bold] ${count}| ${display_name} #[fg=#D8DEE9,bg=#292929,nobold] "
  else
    formatted_sessions+="#[fg=white,bg=brightblack] ${count}| ${display_name} #[fg=#D8DEE9,bg=#292929] "
  fi
done <<<"$filtered_sessions"

# Output (no filter labels)
[ $count -eq 0 ] && echo "#[fg=red]No sessions" || echo "$formatted_sessions"
