#!/bin/bash
# git-branch.sh
cd "$1"
# Get the current branch name in the current directory
branch=$(git symbolic-ref --short HEAD 2>/dev/null || echo "-----")
echo $branch
