#!/bin/bash

# Check the argument passed
if [ "$1" == "hide" ]; then
  # Command to hide desktop icons
  defaults write com.apple.finder CreateDesktop false
  killall Finder
  echo "Desktop icons hidden."
elif [ "$1" == "show" ]; then
  # Command to show desktop icons
  defaults write com.apple.finder CreateDesktop true
  killall Finder
  echo "Desktop icons shown."
else
  echo "Usage: $0 {hide|show}"
fi
