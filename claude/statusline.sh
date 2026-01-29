#!/bin/bash
input=$(cat)

MODEL=$(echo "$input" | jq -r '.model.display_name')
SUBAGENT=$(echo "$input" | jq -r '.subagent_type // empty')
COLOR=$(echo "$input" | jq -r '.color // empty')

RESET="\033[0m"

# Map color names to ANSI codes
color_to_ansi() {
  case "$1" in
    "black")         echo "\033[30m" ;;
    "red")           echo "\033[31m" ;;
    "green")         echo "\033[32m" ;;
    "yellow")        echo "\033[33m" ;;
    "blue")          echo "\033[34m" ;;
    "magenta")       echo "\033[35m" ;;
    "cyan")          echo "\033[36m" ;;
    "white")         echo "\033[37m" ;;
    "bright_black")  echo "\033[90m" ;;
    "bright_red")    echo "\033[91m" ;;
    "bright_green")  echo "\033[92m" ;;
    "bright_yellow") echo "\033[93m" ;;
    "bright_blue")   echo "\033[94m" ;;
    "bright_magenta")echo "\033[95m" ;;
    "bright_cyan")   echo "\033[96m" ;;
    "bright_white")  echo "\033[97m" ;;
    *)               echo "" ;;
  esac
}

if [[ -n "$SUBAGENT" ]]; then
  # Use agent-specified color if available
  if [[ -n "$COLOR" ]]; then
    FG=$(color_to_ansi "$COLOR")
  fi

  # Fallback colors for built-in agents without config
  if [[ -z "$FG" ]]; then
    case "$SUBAGENT" in
      "Explore")         FG="\033[36m" ;;  # Cyan
      "Plan")            FG="\033[35m" ;;  # Magenta
      "Bash")            FG="\033[33m" ;;  # Yellow
      "general-purpose") FG="\033[37m" ;;  # White
      *)                 FG="\033[37m" ;;  # White (default)
    esac
  fi
  echo -e "${FG}${SUBAGENT}${RESET} (${MODEL})"
else
  # Color by model when no sub-agent
  case "$MODEL" in
    "Opus"*)   FG="\033[95m" ;;  # Bright Magenta
    "Sonnet"*) FG="\033[94m" ;;  # Bright Blue
    "Haiku"*)  FG="\033[92m" ;;  # Bright Green
    *)         FG="\033[96m" ;;  # Bright Cyan
  esac
  echo -e "${FG}${MODEL}${RESET}"
fi
