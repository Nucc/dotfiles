#!/bin/bash
# git-branch.sh

# Get the current branch name in the current directory
branch=$(git symbolic-ref --short HEAD 2>/dev/null || echo "not a git repo")
echo $branch
