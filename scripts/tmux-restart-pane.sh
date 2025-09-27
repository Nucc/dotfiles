#!/bin/bash

# Script to restart the active command in a specified tmux pane
# Sends Ctrl-C, Up, Enter sequence to restart last command
# Tracks target panes per window

TARGET_PANES_DIR="$HOME/.tmux-target-panes"
mkdir -p "$TARGET_PANES_DIR"

# Function to validate pane exists
validate_pane() {
  local pane_id="$1"
  tmux list-panes -a -F "#{pane_id}" | grep -q "^$pane_id$"
}

# Function to send restart key sequence to pane
restart_command_in_pane() {
  local pane_id="$1"

  if ! validate_pane "$pane_id"; then
    tmux display-message "Error: Pane $pane_id no longer exists"
    return 1
  fi

  # Send key sequence: Ctrl-C (stop), Up arrow (last command), Enter (execute)
  tmux send-keys -t "$pane_id" C-c
  sleep 0.3
  tmux send-keys -t "$pane_id" Up
  tmux send-keys -t "$pane_id" Enter

  # tmux display-message "Sent restart keys (Ctrl-C, Up, Enter) to pane $pane_id"
  return 0
}

# Function to get current window identifier
get_current_window_id() {
  tmux display-message -p "#{session_name}:#{window_index}"
}

# Function to get target pane file for current window
get_target_pane_file() {
  local window_id=$(get_current_window_id)
  echo "$TARGET_PANES_DIR/${window_id//[^a-zA-Z0-9]/_}"
}

# Function to get stored target pane for current window
get_target_pane() {
  local target_file=$(get_target_pane_file)
  if [[ -f "$target_file" ]]; then
    cat "$target_file"
  fi
}

# Function to set target pane for current window
set_target_pane() {
  local pane_id="$1"
  local target_file=$(get_target_pane_file)
  echo "$pane_id" >"$target_file"
}

# Main logic
case "$1" in
"set")
  if [[ -n "$2" ]]; then
    if validate_pane "$2"; then
      set_target_pane "$2"
      # echo "Target pane set to: $2 for window $(get_current_window_id)"
    else
      echo "Error: Pane $2 does not exist"
      exit 1
    fi
  else
    # Set current active pane as target
    current_pane=$(tmux display-message -p "#{pane_id}")
    set_target_pane "$current_pane"
    # echo "Target pane set to: $current_pane for window $(get_current_window_id)"
  fi
  ;;
"")
  # Default behavior: restart if pane is set, otherwise prompt to set
  target_pane=$(get_target_pane)
  if [[ -n "$target_pane" ]] && validate_pane "$target_pane"; then
    # tmux display-message "Restarting command in pane $target_pane for window $(get_current_window_id)"
    restart_command_in_pane "$target_pane"
  else
    if [[ -n "$target_pane" ]]; then
      tmux display-message "Stored pane $target_pane no longer exists. Please select a new target pane."
    fi
    # Show current window's panes with display numbers and map to pane IDs
    local pane_info=$(tmux list-panes -F "#{pane_index}: #{pane_current_command} (#{pane_id})")
    tmux display-message "Current window panes: $pane_info"
    tmux command-prompt -p "Enter pane number (0,1,2,etc):" "run-shell '
                pane_id=\$(tmux list-panes -F \"#{pane_index} #{pane_id}\" | awk \"/^%% / {print \\\$2}\");
                if [[ -n \"\$pane_id\" ]]; then
                    ~/.dotfiles/scripts/tmux-restart-pane.sh set \"\$pane_id\";
                else
                    tmux display-message \"Invalid pane number: %%\";
                fi
            '"
  fi
  ;;
*)
  echo "Usage: $0 [set] [pane_id]"
  echo "  set [pane_id]  - Set the target pane (interactive if no pane_id provided)"
  echo "  (no args)      - Restart command in target pane, or set pane if not configured"
  exit 1
  ;;
esac
