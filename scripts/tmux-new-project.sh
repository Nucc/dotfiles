#!/bin/bash

# Read the project name from stdin (when called from popup)
read -p "Project name: " project_name

# Trim whitespace
project_name=$(echo "$project_name" | xargs)

# Exit if no name provided
if [ -z "$project_name" ]; then
  echo "No project name provided. Exiting."
  sleep 1
  exit 1
fi

# Create the directory
project_path="$HOME/Code/$project_name"

if [ -d "$project_path" ]; then
  echo "Project directory already exists: $project_path"
  echo "Opening existing project..."
  sleep 1
else
  echo "Creating project directory: $project_path"
  mkdir -p "$project_path"
fi

# Create a new tmux window with the project name
tmux new-window -n "$project_name" -c "$project_path"

# Run the window setup script to configure panes
~/.dotfiles/scripts/tmux-window-setup.sh
