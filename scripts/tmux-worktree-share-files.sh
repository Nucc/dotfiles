#!/usr/bin/env bash

# Move untracked files from a worktree into ~/Code/shared/{owner}/{repo}
# and replace them with symlinks back to the shared copy.
# This is the reverse of tmux-worktree-link-shared.sh.

set -e

worktree_path="$1"

# If no path provided, use current directory
if [ -z "$worktree_path" ]; then
    worktree_path=$(pwd)
fi

# Verify we're in a git repository
if ! git -C "$worktree_path" rev-parse --git-dir &>/dev/null; then
    echo "✗ Error: Not in a git repository"
    exit 1
fi

# Get the absolute worktree path
worktree_path=$(cd "$worktree_path" && pwd)

# Verify this is actually a worktree path in ~/Code/worktrees/
if [[ "$worktree_path" != "$HOME/Code/worktrees/"* ]]; then
    echo "✗ Error: Path is not in ~/Code/worktrees/"
    echo "  Path: $worktree_path"
    exit 1
fi

# Extract owner and repo from worktree path
# Expected format: ~/Code/worktrees/{owner}/{repo}-{branch}
relative_path="${worktree_path#$HOME/Code/worktrees/}"
owner=$(echo "$relative_path" | cut -d'/' -f1)
repo_with_branch=$(echo "$relative_path" | cut -d'/' -f2)

# Get current branch to extract repo name
current_branch=$(git -C "$worktree_path" rev-parse --abbrev-ref HEAD 2>/dev/null)

# Remove -branch suffix to get repo name
repo=$(echo "$repo_with_branch" | sed "s/-${current_branch}$//")

if [ -z "$owner" ] || [ -z "$repo" ]; then
    echo "✗ Error: Could not parse owner/repo from path: $worktree_path"
    exit 1
fi

# Shared directory for this repository
shared_dir="$HOME/Code/shared/$owner/$repo"

echo "Sharing untracked files from worktree:"
echo "  Worktree: $worktree_path"
echo "  Shared:   $shared_dir"
echo ""

shared_count=0
skipped_count=0

# Read untracked files (both gitignored and non-gitignored) into an array
untracked_files=()
while IFS= read -r file; do
    [ -n "$file" ] && untracked_files+=("$file")
done < <(git -C "$worktree_path" ls-files --others)

if [ ${#untracked_files[@]} -eq 0 ]; then
    echo "No untracked files found."
    exit 0
fi

for relative_file in "${untracked_files[@]}"; do
    full_path="$worktree_path/$relative_file"

    # Skip files that are already symlinks
    if [ -L "$full_path" ]; then
        echo "  ✓ Already shared: $relative_file"
        ((skipped_count++)) || true
        continue
    fi

    # Destination in the shared folder
    shared_file="$shared_dir/$relative_file"
    shared_file_dir=$(dirname "$shared_file")

    # Create directory structure in shared folder
    if [ ! -d "$shared_file_dir" ]; then
        mkdir -p "$shared_file_dir"
    fi

    # Move the file to the shared folder
    mv "$full_path" "$shared_file"

    # Create symlink from worktree back to shared file
    if ln -s "$shared_file" "$full_path"; then
        echo "  → Shared: $relative_file"
        ((shared_count++)) || true
    else
        echo "  ✗ Failed to create symlink: $relative_file"
        # Move the file back if symlinking failed
        mv "$shared_file" "$full_path"
    fi
done

echo ""
echo "Summary:"
echo "  Newly shared: $shared_count"
echo "  Already shared: $skipped_count"
echo ""
echo "✓ Sharing complete"
