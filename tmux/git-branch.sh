#!/bin/sh
# Print " <branch>" (with leading Nerd Font glyph) for the dir passed as $1.
# Silent (empty output) when $1 is not a git repo or does not exist.
cd "$1" 2>/dev/null || exit 0
br=$(git symbolic-ref --short HEAD 2>/dev/null) \
  || br=$(git rev-parse --short HEAD 2>/dev/null) \
  || exit 0
printf ' %s' "$br"
