#!/bin/bash
# Script to update tmux window branches info for Übersicht widget

TMP_FILE="/tmp/tmux-branches-${USER}.txt"

# Create a temporary file for the new content
NEW_CONTENT=$(mktemp)

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

  # Get existing Claude state for this window if it exists
  claude_state="inactive"
  if [ -f "$TMP_FILE" ]; then
    existing_state=$(awk -v idx="$index" -F'|' '$1==idx {print $5}' "$TMP_FILE")
    if [ -n "$existing_state" ]; then
      claude_state="$existing_state"
    fi
  fi

  echo "$index|$name|$worktree_info|$active|$claude_state" >> "$NEW_CONTENT"
done

# Replace the old file with the new content
mv "$NEW_CONTENT" "$TMP_FILE"
