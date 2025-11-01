#!/usr/bin/env bash

# Get the path argument
path="${1:-$PWD}"

# Replace home with ~
path="${path/#$HOME/\~}"

# Get the length
path_length=${#path}

# Target width (minimum 20 characters)
target_width=20

# If path is longer than target, just return it with 3 spaces padding
if [ $path_length -ge $target_width ]; then
    echo "${path}   "
else
    # Calculate padding needed (add 3 extra for consistent spacing)
    padding=$((target_width - path_length + 3))

    # Create padding spaces
    padding_str=$(printf '%*s' "$padding" '')

    # Output path with padding
    echo "${path}${padding_str}"
fi
