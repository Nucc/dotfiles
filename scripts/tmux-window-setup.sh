#!/bin/bash

# Split window vertically (create right pane)
tmux split-window -h -c "#{pane_current_path}"

# Split the right pane horizontally (create bottom right pane)
tmux select-pane -t 2
tmux split-window -v -c "#{pane_current_path}"

# Go to left pane and open nvim
tmux select-pane -t 1
tmux send-keys "nvim ." C-m

# Go to top right pane and open claude
tmux select-pane -t 2
tmux send-keys "claude" C-m

# Focus back on left pane
tmux select-pane -t 1
