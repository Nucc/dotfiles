#!/bin/bash
# Script to update tmux window branches info for Übersicht widget

TMP_FILE="/tmp/tmux-branches-${USER}.txt"
INTERACTION_FLAG="/tmp/claude-needs-interaction-${USER}.txt"
RUNNING_FLAG="/tmp/claude-running-${USER}.txt"
FINISHED_FLAG="/tmp/claude-finished-${USER}.txt"

# Clear the file
> "$TMP_FILE"

# Get current session name
SESSION=$(tmux display-message -p '#S')

# List all windows in the current session
tmux list-windows -t "$SESSION" -F "#{window_index}:#{window_name}:#{pane_current_path}:#{window_active}" | while IFS=: read -r index name path active; do
  # Get worktree info if the path is in ~/Code/worktrees/
  worktree_info=""
  if [[ "$path" == "$HOME/Code/worktrees/"* ]]; then
    # Get current branch for worktrees
    if git -C "$path" rev-parse --git-dir &>/dev/null 2>&1; then
      current_branch=$(git -C "$path" rev-parse --abbrev-ref HEAD 2>/dev/null)
      worktree_info="$current_branch"
    else
      # Fallback to relative path if not a git repo
      relative_path="${path#$HOME/Code/worktrees/}"
      worktree_info="$relative_path"
    fi
  elif [ -d "$path/.git" ]; then
    # Regular git repo - show branch
    branch=$(cd "$path" && git branch --show-current 2>/dev/null)
    if [ -n "$branch" ]; then
      worktree_info="$branch"
    else
      short_path=$(echo "$path" | sed "s|^$HOME|~|")
      worktree_info="$short_path"
    fi
  else
    # Not a git repo, just show the path
    short_path=$(echo "$path" | sed "s|^$HOME|~|")
    worktree_info="$short_path"
  fi

  # Determine Claude state
  # Priority: needs_interaction > running > finished > inactive
  claude_state="inactive"

  if [ -f "$INTERACTION_FLAG" ] && grep -qF "${SESSION}:${index}" "$INTERACTION_FLAG" 2>/dev/null; then
    claude_state="needs_interaction"
  elif [ -f "$RUNNING_FLAG" ] && grep -qF "${SESSION}:${index}" "$RUNNING_FLAG" 2>/dev/null; then
    claude_state="running"
  elif [ -f "$FINISHED_FLAG" ] && grep -qF "${SESSION}:${index}" "$FINISHED_FLAG" 2>/dev/null; then
    claude_state="finished"
  fi

  echo "$index|$name|$worktree_info|$active|$claude_state" >> "$TMP_FILE"
done
