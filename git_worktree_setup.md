# Git Worktree Setup Documentation

## Overview

This document describes the git worktree setup used in this dotfiles repository, providing a structured approach to managing multiple branches simultaneously with tmux integration.

## Directory Structure

```
~/Code/
├── repositories/           # Bare git repositories
│   └── {owner}/
│       └── {repo}/        # Bare repo (core.bare=true)
└── worktrees/             # Working tree checkouts
    └── {owner}/
        └── {repo}-{branch}/ # Each branch in its own directory
```

**Example:**
```
~/Code/repositories/nucc/dotfiles/          (bare repo)
~/Code/worktrees/nucc/dotfiles-main/        (main branch)
~/Code/worktrees/nucc/dotfiles-test/        (test branch)
~/Code/nucc/dotfiles/                       (symlink -> active worktree)
```

**Note:** A convenience symlink exists at `~/Code/{owner}/{repo}/` pointing to the currently active worktree for backward compatibility with existing tools and scripts.

## Key Components

### 1. Bare Repository Storage

**Location:** `~/Code/repositories/{owner}/{repo}/`

- Single bare git repository per project
- No working directory, just git data
- Central source for all worktrees
- Configured with `core.bare=true`

### 2. Worktree Checkouts

**Location:** `~/Code/worktrees/{owner}/{repo}-{branch}/`

- One directory per branch
- Naming convention: `{repo}-{branch}`
- Slashes in branch names are replaced with dashes
- Example: `dotfiles-feature-authentication` (from branch `feature/authentication`)

### 3. Tmux Integration Scripts

#### a) `tmux-worktree-creator.sh`

**Location:** `scripts/tmux-worktree-creator.sh`

Creates new worktrees or switches to existing ones with tmux integration.

**Features:**
- Must be run from within `~/Code/worktrees/` directory
- Interactive fzf selection of branches with three categories:
  - Local worktrees (already checked out)
  - Local branches (not yet checked out)
  - Remote branches (need to track locally)
- Creates worktree for selected branch
- Automatically creates tmux window named after branch
- Switches to that window
- Preview pane shows git log for each branch

**Usage:**
Run from any worktree directory in `~/Code/worktrees/{owner}/{repo}-{branch}/`

#### b) `tmux-worktree-window-creator.sh`

**Location:** `scripts/tmux-worktree-window-creator.sh`

Batch creates tmux windows for all existing worktrees.

**Features:**
- Scans git worktree list from current repository
- Creates one tmux window per worktree
- Window names match branch names
- Skips windows that already exist
- Shows summary of created/skipped windows

**Usage:**
Run from any worktree directory in the project

#### c) `tmux-worktree-lister.sh`

**Location:** `scripts/tmux-worktree-lister.sh`

Lists all tmux windows in current session with visual formatting.

**Features:**
- Displays all windows with their indices and names
- Highlights active window in yellow
- Used for tmux status line display
- Formats output with tmux color codes

## Workflow

1. **Bare repo exists** at `~/Code/repositories/{owner}/{repo}/`
2. **Worktrees are created** at `~/Code/worktrees/{owner}/{repo}-{branch}/`
3. **Each worktree gets a tmux window** named after the branch
4. **Switch between branches** by switching tmux windows (no checkout needed)

## Benefits

- **No branch switching overhead:** Each branch is always checked out
- **Parallel work:** Work on multiple branches simultaneously
- **Clean separation:** Each branch has its own build artifacts and dependencies
- **Tmux integration:** Quick navigation between branches via window switching
- **Disk efficiency:** Shares git objects between worktrees via the bare repository

## Migration Plan for Other Git Projects

### Current State

Projects currently exist in `~/Code/` as regular git repositories with working directories.

### Migration Script Approach

A migration script should handle three phases:

#### Phase 1: Preparation
1. Detect git repository owner (from remote URL)
2. Extract repository name
3. Verify current branch and uncommitted changes
4. Create backup reference

#### Phase 2: Conversion
1. Clone as bare repository to `~/Code/repositories/{owner}/{repo}/`
2. Create worktree for current branch at `~/Code/worktrees/{owner}/{repo}-{branch}/`
3. Preserve all local branches as worktrees (optional)
4. Update remote tracking branches

#### Phase 3: Cleanup
1. Verify worktree is functional
2. Remove old repository directory (optional, with confirmation)
3. Create symlink from old location to new worktree (optional)

### Migration Options

#### Option A: Minimal (Single Branch)
- Convert to bare repo
- Create worktree only for current branch
- Fast, simple migration

#### Option B: Full (All Local Branches)
- Convert to bare repo
- Create worktrees for all local branches
- Preserves your existing branch structure

#### Option C: Selective (Choose Branches)
- Convert to bare repo
- Interactive selection of branches to create worktrees for
- Most control over the migration

### Safety Features

The migration script should include:

1. **Dry-run mode** - Preview changes without executing
2. **Uncommitted changes detection** - Warn before migration
3. **Backup creation** - Keep reference to original repo
4. **Rollback capability** - Undo migration if needed
5. **Validation checks** - Verify worktree functionality

### Post-Migration Steps

1. Update any IDE/editor workspace settings
2. Update any hardcoded paths in scripts
3. Optional: Create tmux session for the project
4. Test build/test commands in new worktree

## Example: Manual Migration

To manually migrate a project:

```bash
# 1. Navigate to existing repo
cd ~/Code/myproject

# 2. Get remote info
REMOTE_URL=$(git config --get remote.origin.url)
OWNER=$(echo $REMOTE_URL | sed -E 's|.*[:/]([^/]+)/[^/]+\.git|\1|')
REPO=$(basename $(git rev-parse --show-toplevel))
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)

# 3. Create bare repo
mkdir -p ~/Code/repositories/$OWNER
git clone --bare . ~/Code/repositories/$OWNER/$REPO

# 4. Create worktree for current branch
mkdir -p ~/Code/worktrees/$OWNER
git -C ~/Code/repositories/$OWNER/$REPO worktree add \
  ~/Code/worktrees/$OWNER/$REPO-$CURRENT_BRANCH $CURRENT_BRANCH

# 5. Verify
cd ~/Code/worktrees/$OWNER/$REPO-$CURRENT_BRANCH
git status

# 6. Optional: Remove old repo
# cd ~/Code
# rm -rf myproject
```

## Tips and Best Practices

1. **Branch naming:** Use descriptive branch names as they become directory and window names
2. **Cleanup old worktrees:** Regularly prune unused worktrees with `git worktree prune`
3. **Remote tracking:** Always fetch from the bare repo to update all worktrees
4. **Disk space:** Monitor worktree directories as each has its own working files
5. **Tmux sessions:** Create project-specific tmux sessions for better organization

## Troubleshooting

### Worktree doesn't show in fzf selector
- Ensure you're running the script from within a `~/Code/worktrees/` directory
- Check that the bare repo exists at `~/Code/repositories/{owner}/{repo}/`

### Branch conflicts
- Use `git -C ~/Code/repositories/{owner}/{repo} fetch` to update branches
- Check for diverged branches with `git worktree list`

### Missing tmux windows
- Run `tmux-worktree-window-creator.sh` to recreate all windows
- Verify tmux session is active
