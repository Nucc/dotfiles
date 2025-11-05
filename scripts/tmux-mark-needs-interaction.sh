#!/bin/bash
# Manually mark current window as needing interaction

INTERACTION_FLAG="/tmp/claude-needs-interaction-${USER}.txt"

# Get current tmux session and window
SESSION=$(tmux display-message -p '#S' 2>/dev/null)
WINDOW=$(tmux display-message -p '#{window_index}' 2>/dev/null)

if [ -n "$SESSION" ] && [ -n "$WINDOW" ]; then
  # Create/append to the flag file with session:window
  echo "${SESSION}:${WINDOW}" >> "$INTERACTION_FLAG"
  # Remove duplicates
  sort -u "$INTERACTION_FLAG" -o "$INTERACTION_FLAG"

  # Update the widget immediately
  ~/.dotfiles/scripts/tmux-update-branches.sh

  echo "✓ Window marked as needing interaction"
else
  echo "✗ Not in a tmux session"
fi
