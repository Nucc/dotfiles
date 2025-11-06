#!/bin/bash
# Script to install/update the tmux-branches widgets to Übersicht

WIDGETS_BASE="$HOME/Library/Application Support/Übersicht/widgets"

# Install original side widget
WIDGET_SOURCE="$HOME/dotfiles/widgets/tmux-branches.widget"
WIDGET_DEST="$WIDGETS_BASE/tmux-branches.widget"

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

# Install top widget
TOP_WIDGET_SOURCE="$HOME/dotfiles/widgets/tmux-branches-top.widget"
TOP_WIDGET_DEST="$WIDGETS_BASE/tmux-branches-top.widget"

echo "Installing tmux-branches-top widget to Übersicht..."

# Remove existing widget (whether it's a file, directory, or symlink)
if [ -e "$TOP_WIDGET_DEST" ] || [ -L "$TOP_WIDGET_DEST" ]; then
    echo "Removing existing top widget..."
    rm -rf "$TOP_WIDGET_DEST"
fi

# Create the widget directory
echo "Creating top widget directory..."
mkdir -p "$TOP_WIDGET_DEST"

# Copy the widget files
echo "Copying top widget files..."
cp -r "$TOP_WIDGET_SOURCE/"* "$TOP_WIDGET_DEST/"

# Install other sessions widget
OTHER_WIDGET_SOURCE="$HOME/dotfiles/widgets/tmux-branches-other-sessions.widget"
OTHER_WIDGET_DEST="$WIDGETS_BASE/tmux-branches-other-sessions.widget"

echo "Installing tmux-branches-other-sessions widget to Übersicht..."

# Remove existing widget (whether it's a file, directory, or symlink)
if [ -e "$OTHER_WIDGET_DEST" ] || [ -L "$OTHER_WIDGET_DEST" ]; then
    echo "Removing existing other-sessions widget..."
    rm -rf "$OTHER_WIDGET_DEST"
fi

# Create the widget directory
echo "Creating other-sessions widget directory..."
mkdir -p "$OTHER_WIDGET_DEST"

# Copy the widget files
echo "Copying other-sessions widget files..."
cp -r "$OTHER_WIDGET_SOURCE/"* "$OTHER_WIDGET_DEST/"

echo "✓ All three widgets installed successfully!"
echo ""
echo "To see changes:"
echo "  1. Restart Übersicht, or"
echo "  2. Click Übersicht menu bar icon → Refresh All Widgets"
