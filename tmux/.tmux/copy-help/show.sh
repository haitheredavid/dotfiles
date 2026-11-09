#!/usr/bin/env bash
# Render cheatsheet.txt with `## ` headings in the dark-tundra accent; q closes.
dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
awk '/^## /{printf "\033[1;38;2;102;209;161m%s\033[0m\n", substr($0, 4); next} {print}' \
  "$dir/cheatsheet.txt" | less -R -P ' q to close '
