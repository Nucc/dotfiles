# Dotfiles

Personal dotfiles configuration for macOS development environment.

## Installation

Run the installation script to set up your environment:

```bash
./install.sh
```

The script will:
- ✅ Install fonts from `fonts/` directory
- 🔄 Install Homebrew packages (coming soon)
- 🔄 Configure system settings (coming soon)

## Documentation

- [Git Worktree Setup](git_worktree_setup.md) - Comprehensive guide to git worktree structure with tmux integration

## Features

- Tmux configuration with git worktree integration
- Custom scripts for worktree and session management
- Midnight Commander themes and configuration
- Alacritty terminal configuration
- Neovim (with LazyVim)
- Hammerspoon configuration
- Font management

## Scripts

Located in `scripts/`:

- `tmux-worktree-creator.sh` - Interactive worktree creation and switching
- `tmux-worktree-window-creator.sh` - Batch create tmux windows for all worktrees
- `tmux-worktree-lister.sh` - Display tmux windows in status line
- `tmux-project-creator.sh` - Create new tmux project sessions
- `tmux-rename-session.sh` - Rename tmux sessions with space detection

## Structure

```
.
├── install.sh          # Main installation script
├── fonts/              # Font files
├── alacritty/          # Alacritty terminal configuration
├── nvim/               # Neovim configuration
├── tmux.conf           # Tmux configuration
├── hammerspoon/        # Hammerspoon configuration
└── README.md           # This file
```

## Fonts

The repository includes JetBrainsMono Nerd Font Mono in various weights:
- Regular, Bold, Light, Medium, SemiBold, ExtraBold, ExtraLight, Thin
- Italic variants for each weight

## Requirements

- macOS
- Bash shell

## Usage

After installation, dotfiles are configured to work with:
- Alacritty terminal
- Neovim (with LazyVim)
- Tmux
- Hammerspoon

## Git Worktree Structure

This setup uses a specialized git worktree structure for efficient multi-branch workflows:

```
~/Code/
├── repositories/{owner}/{repo}/        # Bare repositories
└── worktrees/{owner}/{repo}-{branch}/  # Working tree checkouts
```

See [Git Worktree Setup](git_worktree_setup.md) for detailed documentation.