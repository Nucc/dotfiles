#!/usr/bin/env bash

# Link shared files/directories from ~/Code/shared/{owner}/{repo} to the current worktree
# This script should be called after creating a worktree to set up symlinks to shared resources

set -e

worktree_path="$1"

# If no path provided, use current directory
if [ -z "$worktree_path" ]; then
    worktree_path=$(pwd)
fi

# Verify we're in a worktree
if ! git -C "$worktree_path" rev-parse --git-dir &>/dev/null; then
    echo "Error: Not in a git repository"
    exit 1
fi

# Get the absolute worktree path
worktree_path=$(cd "$worktree_path" && pwd)

# Verify this is actually a worktree path in ~/Code/worktrees/
if [[ "$worktree_path" != "$HOME/Code/worktrees/"* ]]; then
    echo "Error: Path is not in ~/Code/worktrees/"
    echo "Path: $worktree_path"
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
    echo "Error: Could not parse owner/repo from path: $worktree_path"
    exit 1
fi

# Shared directory for this repository
shared_dir="$HOME/Code/shared/$owner/$repo"

# Check if shared directory exists
if [ ! -d "$shared_dir" ]; then
    echo "No shared directory found at: $shared_dir"
    echo "Skipping shared file linking."
    exit 0
fi

echo "Linking shared files from: $shared_dir"
echo "To worktree: $worktree_path"
echo ""

linked_count=0
skipped_count=0
replaced_count=0

# Function to create symlink
create_symlink() {
    local target="$1"
    local link_path="$2"
    local relative_name="${target#$shared_dir/}"

    # Get the directory of the link
    local link_dir=$(dirname "$link_path")

    # Create parent directory if it doesn't exist
    if [ ! -d "$link_dir" ]; then
        mkdir -p "$link_dir"
    fi

    # Check if link already exists and points to the correct target
    if [ -L "$link_path" ]; then
        current_target=$(readlink "$link_path")
        if [ "$current_target" = "$target" ]; then
            echo "  ✓ Already linked: $relative_name"
            ((skipped_count++))
            return
        else
            echo "  ⚠ Replacing existing symlink: $relative_name"
            rm "$link_path"
            ((replaced_count++))
        fi
    elif [ -e "$link_path" ]; then
        echo "  ⚠ Replacing existing file/directory: $relative_name"
        rm -rf "$link_path"
        ((replaced_count++))
    fi

    # Create the symlink
    if ln -s "$target" "$link_path"; then
        echo "  → Linked: $relative_name"
        ((linked_count++))
    else
        echo "  ✗ Failed to link: $relative_name"
    fi
}

# Recursively find all files in shared folder (not directories)
# This ensures we symlink individual files, preserving directory structure
find "$shared_dir" -type f | while IFS= read -r shared_file; do
    # Get the relative path from shared_dir
    relative_path="${shared_file#$shared_dir/}"

    # Skip .git files
    if [[ "$relative_path" == .git/* ]] || [[ "$relative_path" == .git ]]; then
        continue
    fi

    # Target path in worktree
    link_path="$worktree_path/$relative_path"

    # Create symlink
    create_symlink "$shared_file" "$link_path"
done

echo ""
echo "Summary:"
echo "  Newly linked: $linked_count"
echo "  Replaced: $replaced_count"
echo "  Already linked: $skipped_count"
echo ""
echo "✓ Shared file linking complete"
