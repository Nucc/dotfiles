#!/bin/bash
# Script to install/update the tmux-branches widget to Übersicht

WIDGET_SOURCE="$HOME/dotfiles/widgets/tmux-branches.widget"
WIDGET_DEST="$HOME/Library/Application Support/Übersicht/widgets/tmux-branches.widget"

echo "Installing tmux-branches widget to Übersicht..."

# Remove existing widget (whether it's a file, directory, or symlink)
if [ -e "$WIDGET_DEST" ] || [ -L "$WIDGET_DEST" ]; then
    echo "Removing existing widget..."
    rm -rf "$WIDGET_DEST"
fi

# Create the widget directory
echo "Creating widget directory..."
mkdir -p "$WIDGET_DEST"

# Copy the widget files
echo "Copying widget files..."
cp -r "$WIDGET_SOURCE/"* "$WIDGET_DEST/"

echo "✓ Widget installed successfully!"
echo ""
echo "To see changes:"
echo "  1. Restart Übersicht, or"
echo "  2. Click Übersicht menu bar icon → Refresh All Widgets"
