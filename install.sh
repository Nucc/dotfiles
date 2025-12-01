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

# Main installation function
main() {
    log_info "Starting dotfiles installation..."

    check_os

    # Install fonts
    install_fonts

    # Future installations can be added here
    # install_homebrew_packages

    log_success "Dotfiles installation completed!"
}

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi