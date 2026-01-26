#!/bin/bash
input=$(cat)

MODEL=$(echo "$input" | jq -r '.model.display_name')

# Color by model
case "$MODEL" in
"Opus"*) BG="\033[45m" ;;   # Magenta
"Sonnet"*) BG="\033[44m" ;; # Blue
"Haiku"*) BG="\033[42m" ;;  # Green
*) BG="\033[46m" ;;         # Cyan
esac

echo -e "${BG} $MODEL \033[0m "
