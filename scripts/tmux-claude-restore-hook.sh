#!/bin/bash
# Hook script to restore Claude in panes where it was running
# This is called by tmux-resurrect after restoring

CLAUDE_SAVE_FILE="$HOME/.local/share/tmux/resurrect/claude_panes.txt"
LOG_FILE="$HOME/.local/share/tmux/resurrect/claude_restore.log"

# Log function
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" >> "$LOG_FILE"
}

# Clear old log
> "$LOG_FILE"

log "=== Restore hook started ==="
log "Hook called at: $(date)"
log "PID: $$"
log "PWD: $(pwd)"

# Create a visible marker that the hook ran
touch "$HOME/.local/share/tmux/resurrect/RESTORE_HOOK_RAN_$(date +%s)"

# Give tmux a moment to restore panes
sleep 3

# Check if save file exists
if [ ! -f "$CLAUDE_SAVE_FILE" ]; then
    log "No save file found at $CLAUDE_SAVE_FILE"
    exit 0
fi

log "Found save file with $(wc -l < "$CLAUDE_SAVE_FILE") entries"
log "Save file contents:"
cat "$CLAUDE_SAVE_FILE" >> "$LOG_FILE"

# Read saved panes and start Claude in them
while IFS='|' read -r pane_spec session_id current_path; do
    log ""
    log "Processing: pane_spec=$pane_spec session_id=$session_id path=$current_path"

    # Find the current pane ID for this pane spec
    # Use awk for more reliable matching instead of grep
    new_pane_id=$(tmux list-panes -a -F '#{session_name}:#{window_index}.#{pane_index} #{pane_id}' | \
        awk -v spec="$pane_spec" '$1 == spec {print $2}')

    if [ -z "$new_pane_id" ]; then
        log "  Could not find pane for spec: $pane_spec"
        log "  Available panes:"
        tmux list-panes -a -F '  #{session_name}:#{window_index}.#{pane_index} #{pane_id}' >> "$LOG_FILE"
        continue
    fi

    log "  Found new pane ID: $new_pane_id"

    # Check if the pane is ready (running a shell, not already running Claude)
    current_command=$(tmux display-message -p -t "$new_pane_id" '#{pane_current_command}')
    log "  Current command in pane: $current_command"

    if [[ "$current_command" =~ bash|zsh ]] && [[ ! "$current_command" =~ claude ]]; then
        log "  Sending claude command to pane $new_pane_id"
        tmux send-keys -t "$new_pane_id" "claude -r $session_id" C-m
        log "  ✓ Command sent successfully"
    else
        log "  Skipping: pane not ready (command: $current_command)"
    fi
done < "$CLAUDE_SAVE_FILE"

log ""
log "=== Restore hook completed ==="
