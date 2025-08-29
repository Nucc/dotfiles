#!/bin/bash

BOOKMARKS_FILE="$HOME/.config/tmux-bookmarks"

# Create bookmarks file if it doesn't exist
if [ ! -f "$BOOKMARKS_FILE" ]; then
  mkdir -p "$(dirname "$BOOKMARKS_FILE")"
  touch "$BOOKMARKS_FILE"
fi

case "$1" in
"add")
  # Get the actual current directory from tmux pane
  CURRENT_DIR=$(tmux display-message -p '#{pane_current_path}')

  # Check if directory is already bookmarked
  if grep -Fx "$CURRENT_DIR" "$BOOKMARKS_FILE" >/dev/null 2>&1; then
    echo "Directory already bookmarked: $CURRENT_DIR"
    exit 0
  fi

  # Add current directory to bookmarks
  echo "$CURRENT_DIR" >>"$BOOKMARKS_FILE"
  echo "Added bookmark: $CURRENT_DIR"
  ;;

"list")
  # Check if there are any bookmarks
  if [ ! -s "$BOOKMARKS_FILE" ]; then
    echo "No bookmarks found. Use 'tmux-bookmarks.sh add' to add the current directory."
    exit 1
  fi

  # Remove any directories that no longer exist
  temp_file=$(mktemp)
  while IFS= read -r dir; do
    if [ -d "$dir" ]; then
      echo "$dir" >>"$temp_file"
    fi
  done <"$BOOKMARKS_FILE"
  mv "$temp_file" "$BOOKMARKS_FILE"

  # Check again if there are any valid bookmarks
  if [ ! -s "$BOOKMARKS_FILE" ]; then
    echo "No valid bookmarks found. All bookmarked directories have been removed."
    exit 1
  fi

  # Create display format with ~ substitution for home directory
  DISPLAY_BOOKMARKS=""
  while IFS= read -r dir; do
    display_dir=${dir/#$HOME/~}
    DISPLAY_BOOKMARKS="$DISPLAY_BOOKMARKS$display_dir\n"
  done <"$BOOKMARKS_FILE"

  # Use fzf to select a bookmark
  SELECTED_DISPLAY=$(echo -e "$DISPLAY_BOOKMARKS" | sed '/^$/d' | fzf \
    --height=100% \
    --reverse \
    --border \
    --prompt="Go to bookmark: " \
    --preview="ls -la {}" \
    --preview-window=right:50%:wrap \
    --header="Use ↑↓ to navigate, Enter to select, Esc to cancel, Del to remove")

  if [ -n "$SELECTED_DISPLAY" ]; then
    # Convert back to full path
    SELECTED_DIR=${SELECTED_DISPLAY/#~/$HOME}

    # Get the current pane ID
    PANE_ID=$(tmux display-message -p '#{pane_id}')

    # Change directory in the current pane
    echo "Changing to: $SELECTED_DIR"
    tmux send-keys -t "$PANE_ID" "cd '$SELECTED_DIR'" C-m
  else
    echo "No bookmark selected"
  fi
  ;;

"remove")
  # Check if there are any bookmarks
  if [ ! -s "$BOOKMARKS_FILE" ]; then
    echo "No bookmarks found."
    read -n 1 -s -r -p "Press any key to continue..."
    exit 1
  fi

  # Create display format with ~ substitution for home directory
  DISPLAY_BOOKMARKS=""
  while IFS= read -r dir; do
    display_dir=${dir/#$HOME/~}
    DISPLAY_BOOKMARKS="$DISPLAY_BOOKMARKS$display_dir\n"
  done <"$BOOKMARKS_FILE"

  # Use fzf to select bookmark to remove
  SELECTED_DISPLAY=$(echo -e "$DISPLAY_BOOKMARKS" | sed '/^$/d' | fzf \
    --height=100% \
    --reverse \
    --border \
    --prompt="Remove bookmark: " \
    --preview="ls -la {}" \
    --preview-window=right:50%:wrap \
    --header="Use ↑↓ to navigate, Enter to remove, Esc to cancel")

  if [ -n "$SELECTED_DISPLAY" ]; then
    # Convert back to full path
    SELECTED_DIR=${SELECTED_DISPLAY/#~/$HOME}

    # Remove the bookmark
    grep -v "^$SELECTED_DIR$" "$BOOKMARKS_FILE" >"$BOOKMARKS_FILE.tmp"
    mv "$BOOKMARKS_FILE.tmp" "$BOOKMARKS_FILE"
    echo "Removed bookmark: $SELECTED_DIR"
  else
    echo "No bookmark selected for removal"
  fi
  ;;

*)
  echo "Usage: tmux-bookmarks.sh [add|list|remove]"
  echo "  add    - Add current directory to bookmarks"
  echo "  list   - Show bookmark selector and navigate to selected directory"
  echo "  remove - Remove a bookmark from the list"
  exit 1
  ;;
esac

