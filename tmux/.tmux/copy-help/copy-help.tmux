#!/usr/bin/env bash
# Copy-mode cheat sheet: press `i` (override with @copy-help-key) inside copy mode.
dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
key="$(tmux show -gqv @copy-help-key)"
key="${key:-i}"

# Size the popup to the sheet: +2 border rows, +1 less prompt row; +2 border cols, +2 padding.
sheet="$dir/cheatsheet.txt"
height=$(( $(wc -l < "$sheet") + 3 ))
width=$(( $(awk '{ if (length > m) m = length } END { print m }' "$sheet") + 4 ))

tmux bind-key -T copy-mode-vi "$key" display-popup -E -x C -y C -w "$width" -h "$height" \
  -T " copy mode " "$dir/show.sh"
