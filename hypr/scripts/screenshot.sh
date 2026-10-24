#!/bin/bash
# Usage: screenshot.sh [region|full] — saves to ~/Pictures/Screenshots and copies to clipboard
dir="$HOME/Pictures/Screenshots"
mkdir -p "$dir"
file="$dir/$(date +%F_%H-%M-%S).png"
if [ "$1" = full ]; then
    grim "$file"
else
    geom=$(slurp) || exit 1
    grim -g "$geom" "$file"
fi
wl-copy < "$file"
