#!/usr/bin/env bash

# Get current session name and strip suffix
current_session=$(tmux display-message -p '#S')
base_name="${current_session%% \[*\]}"

# Show command prompt with base name only
tmux command-prompt -p "Rename session to:" -I "$base_name" "run-shell '~/.dotfiles/scripts/tmux-rename-session.sh \"%%\"'"
