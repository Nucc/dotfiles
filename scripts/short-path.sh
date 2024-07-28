#!/bin/bash
# short-path.sh

# Get the current directory
dir=$1

# Replace $HOME with ~
short_dir=${dir/#$HOME/\~}

echo $short_dir
