#!/usr/bin/env bash

# Get current filter mode
filter_mode=$(tmux show-option -gv @session-filter-mode 2>/dev/null || echo "work")

# Determine suffix based on filter mode
case "$filter_mode" in
    work)
        suffix="[W]"
        filter_name="Work"
        ;;
    personal)
        suffix="[P]"
        filter_name="Personal"
        ;;
    all)
        # If in "all" mode, prompt user to choose
        echo "Create session in:"
        echo "1) Work"
        echo "2) Personal"
        read -n 1 -r -p "Select (1/2): " choice
        echo ""

        case "$choice" in
            1)
                suffix="[W]"
                filter_name="Work"
                ;;
            2)
                suffix="[P]"
                filter_name="Personal"
                ;;
            *)
                suffix="[W]"
                filter_name="Work"
                ;;
        esac
        ;;
esac

# Prompt for session name
echo ""
read -p "Enter session name: " session_name

if [ -z "$session_name" ]; then
    echo "Error: Session name cannot be empty"
    read -n 1 -s -r -p "Press any key to close..."
    exit 1
fi

# Create full session name with suffix
full_session_name="${session_name}${suffix}"

# Check if session already exists
if tmux has-session -t "$full_session_name" 2>/dev/null; then
    echo "Session '$full_session_name' already exists. Switching to it..."
    tmux switch-client -t "$full_session_name"
    exit 0
fi

# Prompt for directory (optional)
echo ""
read -p "Enter directory (leave empty for ~): " session_dir

if [ -z "$session_dir" ]; then
    session_dir="$HOME"
else
    # Expand ~ to home directory
    session_dir="${session_dir/#~/$HOME}"

    # Check if directory exists
    if [ ! -d "$session_dir" ]; then
        echo "Directory '$session_dir' does not exist."
        read -n 1 -r -p "Create it? (y/n): " create_dir
        echo ""

        if [[ "$create_dir" =~ ^[Yy]$ ]]; then
            mkdir -p "$session_dir"
            echo "Directory created."
        else
            echo "Using home directory instead."
            session_dir="$HOME"
        fi
    fi
fi

# Create new session
echo ""
echo "Creating $filter_name session: $full_session_name"
echo "Directory: $session_dir"

tmux new-session -d -s "$full_session_name" -c "$session_dir"

# Switch to the new session
tmux switch-client -t "$full_session_name"

echo "✓ Session created and switched!"
