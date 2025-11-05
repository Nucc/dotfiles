#!/bin/bash
# Hook script to save which panes were running Claude
# This is called by tmux-resurrect before saving

CLAUDE_SAVE_FILE="$HOME/.local/share/tmux/resurrect/claude_panes.txt"
HISTORY_FILE="$HOME/.claude/history.jsonl"

# Create directory if it doesn't exist
mkdir -p "$(dirname "$CLAUDE_SAVE_FILE")"

# Clear the previous save file
> "$CLAUDE_SAVE_FILE"

# Get all panes with their IDs and current commands
tmux list-panes -a -F '#{session_name}:#{window_index}.#{pane_index} #{pane_id} #{pane_current_path} #{pane_current_command}' | \
while read -r pane_spec pane_id current_path current_command; do
    # Only save panes that are actually running Claude
    if [[ "$current_command" =~ ^claude$ ]] || [[ "$current_command" == "node" && "$(tmux display-message -p -t $pane_id '#{pane_title}')" =~ [Cc]laude ]]; then
        # Get the most recent Claude session for this directory
        session_id=$(tail -200 "$HISTORY_FILE" 2>/dev/null | \
            jq -r --arg proj "$current_path" \
            'select(.project == $proj) | .sessionId' | \
            tail -1)

        if [ -n "$session_id" ] && [ "$session_id" != "null" ]; then
            # Save: pane_spec|session_id|path
            echo "${pane_spec}|${session_id}|${current_path}" >> "$CLAUDE_SAVE_FILE"
        fi
    fi
done
