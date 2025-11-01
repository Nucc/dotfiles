#!/usr/bin/env bash

# Get the path argument
path="${1:-$PWD}"

# Replace home with ~
path="${path/#$HOME/\~}"

# Get the length
path_length=${#path}

# Target width (minimum 20 characters)
target_width=20

# Always return 3 spaces minimum
min_padding=3

# If path is longer than target, return minimum padding
if [ $path_length -ge $target_width ]; then
    printf '%*s' "$min_padding" ''
else
    # Calculate padding needed
    padding=$((target_width - path_length + min_padding))

    # Return padding spaces only
    printf '%*s' "$padding" ''
fi
