#!/bin/bash

# Get a list of window IDs
windows=$(tmux list-windows -F '#I' | sort -n)

# Initialize target window index
target=1

# Loop through each window ID and move it to the target index
for window in $windows; do
  tmux move-window -s $window -t $target
  target=$((target + 1))
done
