#!/usr/bin/env bash
# tmux-which-key.sh - LazyVim-style which-key popup for tmux
# Usage: tmux-which-key.sh <pane_id>

set -uo pipefail

PANE_ID="${1:-}"
CONFIG_FILE="$HOME/.config/tmux-which-key.json"

# Nord theme colors
COLOR_KEY="\033[38;2;235;203;139m"      # #EBCB8B - yellow for keys
COLOR_GROUP="\033[38;2;136;192;208m"     # #88C0D0 - cyan for groups
COLOR_DESC="\033[38;2;216;222;233m"      # #D8DEE9 - light gray for descriptions
COLOR_SEP="\033[38;2;76;86;106m"         # #4C566A - dark gray for separators
COLOR_HEADER="\033[38;2;129;161;193m"    # #81A1C1 - blue for header
COLOR_RESET="\033[0m"

# Validate
if [[ -z "$PANE_ID" ]]; then
    echo "Usage: tmux-which-key.sh <pane_id>"
    exit 1
fi

if [[ ! -f "$CONFIG_FILE" ]]; then
    echo "Config not found: $CONFIG_FILE"
    exit 1
fi

if ! jq empty "$CONFIG_FILE" 2>/dev/null; then
    echo "Invalid JSON in $CONFIG_FILE"
    exit 1
fi

# Navigation stack (array of jq path segments)
NAV_STACK=()

get_items_path() {
    local path=".items"
    for idx in "${NAV_STACK[@]}"; do
        path="${path}[${idx}].items"
    done
    echo "$path"
}

get_breadcrumb() {
    local crumb="root"
    local path=".items"
    for idx in "${NAV_STACK[@]}"; do
        local desc
        desc=$(jq -r "${path}[${idx}].description" "$CONFIG_FILE")
        crumb="${crumb} > ${desc}"
        path="${path}[${idx}].items"
    done
    echo "$crumb"
}

render_menu() {
    clear

    local items_path
    items_path=$(get_items_path)
    local breadcrumb
    breadcrumb=$(get_breadcrumb)

    # Header
    printf "${COLOR_HEADER}  Which Key${COLOR_RESET}  ${COLOR_SEP}│${COLOR_RESET}  ${COLOR_DESC}%s${COLOR_RESET}\n" "$breadcrumb"
    printf "${COLOR_SEP}"
    printf '%.0s─' {1..98}
    printf "${COLOR_RESET}\n"

    # Get items
    local count
    count=$(jq -r "${items_path} | length" "$CONFIG_FILE" 2>/dev/null || echo "0")

    if [[ "$count" -eq 0 ]]; then
        printf "  ${COLOR_DESC}(empty)${COLOR_RESET}\n"
        return
    fi

    # Build formatted lines
    local lines=()
    for ((i = 0; i < count; i++)); do
        local key desc item_type
        key=$(jq -r "${items_path}[${i}].key" "$CONFIG_FILE")
        desc=$(jq -r "${items_path}[${i}].description" "$CONFIG_FILE")
        item_type=$(jq -r "${items_path}[${i}].type" "$CONFIG_FILE")

        if [[ "$item_type" == "group" ]]; then
            lines+=("$(printf "${COLOR_KEY}%s${COLOR_RESET}  ${COLOR_GROUP}+%s${COLOR_RESET}" "$key" "$desc")")
        else
            lines+=("$(printf "${COLOR_KEY}%s${COLOR_RESET}  ${COLOR_DESC}%s${COLOR_RESET}" "$key" "$desc")")
        fi
    done

    # Calculate column layout
    local total=${#lines[@]}
    local term_width=96
    local col_width=30
    local num_cols=$((term_width / col_width))
    if [[ $num_cols -lt 1 ]]; then
        num_cols=1
    fi
    if [[ $num_cols -gt 3 ]]; then
        num_cols=3
    fi

    local num_rows=$(( (total + num_cols - 1) / num_cols ))

    # Render column-major layout
    for ((row = 0; row < num_rows; row++)); do
        printf "  "
        for ((col = 0; col < num_cols; col++)); do
            local idx=$((col * num_rows + row))
            if [[ $idx -lt $total ]]; then
                # Print item with padding
                # We need to calculate visible length for padding
                local key desc item_type
                key=$(jq -r "${items_path}[${idx}].key" "$CONFIG_FILE")
                desc=$(jq -r "${items_path}[${idx}].description" "$CONFIG_FILE")
                item_type=$(jq -r "${items_path}[${idx}].type" "$CONFIG_FILE")

                local prefix=""
                local desc_color="$COLOR_DESC"
                if [[ "$item_type" == "group" ]]; then
                    prefix="+"
                    desc_color="$COLOR_GROUP"
                fi

                local visible_len=$(( ${#key} + 2 + ${#prefix} + ${#desc} ))
                local pad=$((col_width - visible_len))
                if [[ $pad -lt 0 ]]; then pad=0; fi

                printf "${COLOR_KEY}%s${COLOR_RESET}  ${desc_color}%s%s${COLOR_RESET}" "$key" "$prefix" "$desc"
                printf '%*s' "$pad" ""
            fi
        done
        printf "\n"
    done

    # Footer
    printf "\n${COLOR_SEP}"
    printf '%.0s─' {1..98}
    printf "${COLOR_RESET}\n"
    if [[ ${#NAV_STACK[@]} -gt 0 ]]; then
        printf "  ${COLOR_SEP}Esc/Backspace: back${COLOR_RESET}\n"
    else
        printf "  ${COLOR_SEP}Esc: close${COLOR_RESET}\n"
    fi
}

handle_key() {
    local keypress="$1"
    local items_path
    items_path=$(get_items_path)

    local count
    count=$(jq -r "${items_path} | length" "$CONFIG_FILE" 2>/dev/null || echo "0")

    for ((i = 0; i < count; i++)); do
        local key item_type command
        key=$(jq -r "${items_path}[${i}].key" "$CONFIG_FILE")
        item_type=$(jq -r "${items_path}[${i}].type" "$CONFIG_FILE")
        command=$(jq -r "${items_path}[${i}].command // empty" "$CONFIG_FILE")

        if [[ "$key" == "$keypress" ]]; then
            case "$item_type" in
                group)
                    NAV_STACK+=("$i")
                    return 0  # Continue loop
                    ;;
                action)
                    tmux send-keys -t "$PANE_ID" -l "$command"
                    exit 0
                    ;;
                tmux)
                    tmux $command
                    exit 0
                    ;;
                script)
                    tmux run-shell "$command"
                    exit 0
                    ;;
            esac
        fi
    done

    # Key not found - ignore
    return 0
}

# Main loop
while true; do
    render_menu

    # Read a single keypress
    IFS= read -rsn1 keypress

    # Handle escape sequences
    if [[ "$keypress" == $'\x1b' ]]; then
        # Check for escape sequence (arrow keys, etc.)
        read -rsn1 -t 0.1 seq1 || true
        if [[ -z "$seq1" ]]; then
            # Plain Escape
            if [[ ${#NAV_STACK[@]} -gt 0 ]]; then
                unset 'NAV_STACK[${#NAV_STACK[@]}-1]'
            else
                exit 0
            fi
        fi
        # Ignore other escape sequences
        continue
    fi

    # Handle backspace (0x7f or 0x08)
    if [[ "$keypress" == $'\x7f' || "$keypress" == $'\x08' ]]; then
        if [[ ${#NAV_STACK[@]} -gt 0 ]]; then
            unset 'NAV_STACK[${#NAV_STACK[@]}-1]'
        else
            exit 0
        fi
        continue
    fi

    # Handle regular keypress
    if [[ -n "$keypress" ]]; then
        handle_key "$keypress"
    fi
done
