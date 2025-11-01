#!/usr/bin/env bash

# Get the directory argument
dir="${1:-$PWD}"

# Get git branch
if git -C "$dir" rev-parse --git-dir > /dev/null 2>&1; then
    branch=$(git -C "$dir" symbolic-ref --short HEAD 2>/dev/null || git -C "$dir" rev-parse --short HEAD 2>/dev/null)
else
    branch=""
fi

# If no branch, return empty with padding
if [ -z "$branch" ]; then
    echo "   "
    exit 0
fi

# Get the length
branch_length=${#branch}

# Target width (minimum 20 characters)
target_width=20

# If branch is longer than target, just return it with 3 spaces before
if [ $branch_length -ge $target_width ]; then
    echo "   ${branch}"
else
    # Calculate padding needed (add 3 extra for consistent spacing)
    padding=$((target_width - branch_length + 3))

    # Create padding spaces
    padding_str=$(printf '%*s' "$padding" '')

    # Output padding before branch
    echo "${padding_str}${branch}"
fi
