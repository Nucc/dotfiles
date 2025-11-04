# Worktree Shared Files

This feature allows you to share files and directories across all worktrees of a repository by placing them in a central location and symlinking them to each worktree.

## Directory Structure

```
~/Code/
├── repositories/          # Bare git repositories
│   └── {owner}/
│       └── {repo}/
├── worktrees/            # Git worktrees
│   └── {owner}/
│       ├── {repo}-main/
│       ├── {repo}-feature-1/
│       └── {repo}-feature-2/
└── shared/               # Shared files across worktrees
    └── {owner}/
        └── {repo}/
            ├── .env              # Shared environment file
            ├── .env.local        # Shared local config
            ├── node_modules/     # Shared dependencies
            └── vendor/           # Shared vendor folder
```

## How It Works

When you create a new worktree using the worktree creator script, it automatically:

1. Checks if a shared directory exists at `~/Code/shared/{owner}/{repo}`
2. For each **file** (not directory) in the shared folder, creates a symlink in the worktree
3. Preserves the directory structure by creating parent directories as needed
4. Replaces existing files if they conflict (backs up nothing - use with caution!)

## Usage

### Automatic Linking (Recommended)

Shared files are automatically linked when you create a worktree:

1. Press `Cmd-Ctrl-Shift-T` in a worktree to create a new worktree
2. Select or create a branch
3. The script automatically links shared files

### Manual Linking

To manually re-link shared files for an existing worktree:

1. Navigate to the worktree directory
2. Run: `~/.dotfiles/scripts/tmux-worktree-relink-shared.sh`

Or bind it to a tmux key for easy access.

## Setup Example

Let's say you have a repository `myorg/myapp` and want to share `.env` and `node_modules`:

1. Create the shared directory:
   ```bash
   mkdir -p ~/Code/shared/myorg/myapp
   ```

2. Move shared files there:
   ```bash
   cp ~/Code/worktrees/myorg/myapp-main/.env ~/Code/shared/myorg/myapp/.env
   ```

3. Create a new worktree or re-link existing ones:
   ```bash
   # For existing worktrees
   cd ~/Code/worktrees/myorg/myapp-main
   ~/.dotfiles/scripts/tmux-worktree-relink-shared.sh
   ```

4. Now all worktrees will have `.env` symlinked to the shared location

## Common Use Cases

### Sharing Environment Files
```
~/Code/shared/myorg/myapp/
├── .env
├── .env.local
└── .env.production
```

### Sharing Configuration Directories
```
~/Code/shared/myorg/myapp/
├── config/
│   ├── database.yml
│   └── secrets.yml
└── certs/
    ├── development.crt
    └── development.key
```

### Sharing Individual Dependency Files
```
~/Code/shared/myorg/myapp/
├── package-lock.json     # Share lockfiles
├── composer.lock
└── Gemfile.lock
```

## Important Notes

- **Only files are symlinked, not directories**: Directories are created in the worktree, and individual files inside them are symlinked
- **Directory structure is preserved**: If you have `config/database.yml` in shared, it creates `config/` directory and symlinks the file
- **Existing files are replaced**: The script will delete existing files and replace them with symlinks
- **Directories are never replaced**: Existing directories remain intact; only files inside them are symlinked
- **No backup is created**: Make sure you don't have important files before linking
- **Git handles symlinks correctly**: Symlinked files won't be committed to git (they're just pointers)

## Scripts

- `tmux-worktree-link-shared.sh` - Core linking logic (can be called standalone)
- `tmux-worktree-relink-shared.sh` - Interactive tool to re-link from tmux
- Integration in `tmux-worktree-creator.sh` - Automatic linking on worktree creation

## Tips

1. **Add shared directory to gitignore globally**: Create `~/.gitignore_global` with common shared items
2. **Share lockfiles, not dependencies**: Since only files are symlinked, share lockfiles like `package-lock.json`, `composer.lock`, etc., but keep `node_modules` separate per worktree
3. **Be careful with databases**: Don't share SQLite databases or other stateful files across worktrees
4. **Environment-specific configs**: Share base configs but keep environment overrides separate
5. **Nested configurations**: You can organize shared files in subdirectories like `config/`, `certs/`, etc.
