#!/bin/bash
# short-path.sh

# Get the current directory
dir=$1

# Replace $HOME with ~
short_dir=${dir/#$HOME/\~}

# Remove worktrees/$NAME from the path
# If path is like: ~/Code/zendesk/voice/worktrees/worktree-test
# Result should be: ~/Code/zendesk/voice
# If path is like: ~/Code/zendesk/voice/worktrees/worktree-test/src
# Result should be: ~/Code/zendesk/voice/src
short_dir=$(echo "$short_dir" | sed -E 's|/worktrees/[^/]+||')

echo $short_dir
