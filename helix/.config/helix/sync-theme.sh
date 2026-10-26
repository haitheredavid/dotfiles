#!/usr/bin/env bash
# Sync Helix theme with macOS appearance.
# Override themes via env: HELIX_DARK_THEME, HELIX_LIGHT_THEME.

set -eu

DARK_THEME="${HELIX_DARK_THEME:-dark_tundra_transparent}"
LIGHT_THEME="${HELIX_LIGHT_THEME:-dark_tundra_transparent}"
CONFIG="${HELIX_CONFIG:-$HOME/.config/helix/config.toml}"

if defaults read -g AppleInterfaceStyle >/dev/null 2>&1; then
  THEME="$DARK_THEME"
else
  THEME="$LIGHT_THEME"
fi

CURRENT="$(awk -F'"' '/^theme[[:space:]]*=/{print $2; exit}' "$CONFIG" 2>/dev/null || true)"
if [ "$CURRENT" = "$THEME" ]; then
  exit 0
fi

TMP="$(mktemp)"
if grep -qE '^theme[[:space:]]*=' "$CONFIG" 2>/dev/null; then
  awk -v t="$THEME" '
    BEGIN{done=0}
    /^theme[[:space:]]*=/ && !done {print "theme=\"" t "\""; done=1; next}
    {print}
  ' "$CONFIG" > "$TMP"
else
  { printf 'theme="%s"\n' "$THEME"; cat "$CONFIG" 2>/dev/null || true; } > "$TMP"
fi
mv "$TMP" "$CONFIG"

# Live-reload running Helix sessions.
pkill -USR1 -x hx 2>/dev/null || true
