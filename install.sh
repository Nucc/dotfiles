#!/bin/bash

# Dotfiles Installation Script
# This script installs all dependencies and configurations for the dotfiles environment

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running on macOS
check_os() {
    if [[ "$OSTYPE" != "darwin"* ]]; then
        log_error "This script is designed for macOS only"
        exit 1
    fi
    log_success "Running on macOS"
}

# Install fonts
install_fonts() {
    log_info "Installing fonts..."

    local fonts_dir="$HOME/Library/Fonts"
    local repo_fonts_dir="$(dirname "$0")/fonts"

    # Create fonts directory if it doesn't exist
    mkdir -p "$fonts_dir"

    # Check if fonts directory exists in repo
    if [[ ! -d "$repo_fonts_dir" ]]; then
        log_error "Fonts directory not found at $repo_fonts_dir"
        return 1
    fi

    # Copy all font files
    local font_count=0
    for font_file in "$repo_fonts_dir"/*.ttf; do
        if [[ -f "$font_file" ]]; then
            local font_name=$(basename "$font_file")
            local target_path="$fonts_dir/$font_name"

            # Skip if font already exists
            if [[ -f "$target_path" ]]; then
                log_warning "Font $font_name already exists, skipping"
                continue
            fi

            log_info "Installing $font_name..."
            cp "$font_file" "$target_path"
            ((font_count++))
        fi
    done

    if [[ $font_count -gt 0 ]]; then
        log_success "Installed $font_count fonts"
        # Refresh font cache
        if command -v fc-cache >/dev/null 2>&1; then
            fc-cache -fv
        fi
    else
        log_warning "No new fonts to install"
    fi
}

# Install Homebrew packages (placeholder for future implementation)
install_homebrew_packages() {
    log_info "Homebrew packages installation not implemented yet"
    # TODO: Add Homebrew package installation logic here
}

# Install Claude Code commands and agents
# Copies files from dotfiles to ~/.claude, overwriting existing files with same names
# Does NOT touch settings.json or other sensitive config
install_claude_config() {
    log_info "Installing Claude Code commands and agents..."

    local repo_claude_dir="$(dirname "$0")/claude"
    local target_claude_dir="$HOME/.claude"

    # Check if claude directory exists in repo
    if [[ ! -d "$repo_claude_dir" ]]; then
        log_warning "Claude directory not found at $repo_claude_dir, skipping"
        return 0
    fi

    # Create target directories if they don't exist
    mkdir -p "$target_claude_dir/commands"
    mkdir -p "$target_claude_dir/agents"
    mkdir -p "$target_claude_dir/hooks"

    # Copy commands (preserving directory structure, overwrites existing)
    if [[ -d "$repo_claude_dir/commands" ]]; then
        local cmd_count=$(find "$repo_claude_dir/commands" -type f -name "*.md" | wc -l | tr -d ' ')
        log_info "Installing $cmd_count Claude command(s)..."
        cp -R "$repo_claude_dir/commands/"* "$target_claude_dir/commands/" 2>/dev/null || true
        log_success "Claude commands installed"
    fi

    # Copy agents (overwrites existing)
    if [[ -d "$repo_claude_dir/agents" ]]; then
        local agent_count=$(find "$repo_claude_dir/agents" -type f -name "*.md" | wc -l | tr -d ' ')
        log_info "Installing $agent_count Claude agent(s)..."
        cp -R "$repo_claude_dir/agents/"* "$target_claude_dir/agents/" 2>/dev/null || true
        log_success "Claude agents installed"
    fi

    # Copy hooks (overwrites existing)
    if [[ -d "$repo_claude_dir/hooks" ]]; then
        local hook_count=$(find "$repo_claude_dir/hooks" -type f | wc -l | tr -d ' ')
        log_info "Installing $hook_count Claude hook(s)..."
        cp -R "$repo_claude_dir/hooks/"* "$target_claude_dir/hooks/" 2>/dev/null || true
        log_success "Claude hooks installed"
    fi

    log_success "Claude Code configuration installed (settings.json preserved)"
    log_warning "Note: Files with same names were overwritten"
}

# Main installation function
main() {
    log_info "Starting dotfiles installation..."

    check_os

    # Install fonts
    install_fonts

    # Install Claude Code commands and agents
    install_claude_config

    # Future installations can be added here
    # install_homebrew_packages

    log_success "Dotfiles installation completed!"
}

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi