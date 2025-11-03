# Dotfiles

Personal dotfiles configuration for development environment.

## Documentation

- [Git Worktree Setup](git_worktree_setup.md) - Comprehensive guide to the git worktree structure with tmux integration

## Features

- Tmux configuration with git worktree integration
- Custom scripts for worktree and session management
- Midnight Commander themes and configuration

## Scripts

Located in `scripts/`:

- `tmux-worktree-creator.sh` - Interactive worktree creation and switching
- `tmux-worktree-window-creator.sh` - Batch create tmux windows for all worktrees
- `tmux-worktree-lister.sh` - Display tmux windows in status line
- `tmux-project-creator.sh` - Create new tmux project sessions
- `tmux-rename-session.sh` - Rename tmux sessions with space detection

## Git Worktree Structure

This setup uses a specialized git worktree structure for efficient multi-branch workflows:

```
~/Code/
├── repositories/{owner}/{repo}/        # Bare repositories
└── worktrees/{owner}/{repo}-{branch}/  # Working tree checkouts
```

See [Git Worktree Setup](git_worktree_setup.md) for detailed documentation.
