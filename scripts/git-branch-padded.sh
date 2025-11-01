#!/usr/bin/env bash

# Get the directory argument
dir="${1:-$PWD}"

# Get git branch
if git -C "$dir" rev-parse --git-dir > /dev/null 2>&1; then
    branch=$(git -C "$dir" symbolic-ref --short HEAD 2>/dev/null || git -C "$dir" rev-parse --short HEAD 2>/dev/null)
else
    branch=""
fi

# If no branch, return 3 spaces
if [ -z "$branch" ]; then
    printf '%*s' 3 ''
    exit 0
fi

# Get the length
branch_length=${#branch}

# Target width (minimum 20 characters)
target_width=20

# Always return 3 spaces minimum
min_padding=3

# If branch is longer than target, return minimum padding
if [ $branch_length -ge $target_width ]; then
    printf '%*s' "$min_padding" ''
else
    # Calculate padding needed
    padding=$((target_width - branch_length + min_padding))

    # Return padding spaces only
    printf '%*s' "$padding" ''
fi
