#!/usr/bin/env bash
# Links to local checkouts on this machine (not part of install.sh). Each step is
# skipped when its checkout is missing. Run after install.sh. Idempotent.
set -euo pipefail

# ctx-scaffold skill presets live in the ctx checkout (absolute link, so stow can't own it)
CTX_PRESETS="$HOME/suffolk/ctx/presets"
if [[ -d "$CTX_PRESETS" ]]; then
  ln -sfn "$CTX_PRESETS" "$HOME/.claude/skills/ctx-scaffold/presets"
  echo "link    ~/.claude/skills/ctx-scaffold/presets -> $CTX_PRESETS"
fi

# herdr plugins from local checkouts (keybinds in herdr/.config/herdr/config.toml; scratchpad list in
# herdr/.config/herdr/plugins/config/ctx.herdr-flow/scratchpads.toml). `plugin link` runs no build,
# so herdr-flow is built here (needs cargo) when its binary is missing.
if command -v herdr >/dev/null; then
  HERDR_PLUGINS="$(herdr plugin list 2>/dev/null || true)"
  FLOW="$HOME/projects/ctx-herdr"
  if [[ -d "$FLOW" && ! -x "$FLOW/target/release/herdr-flow" ]]; then
    (cd "$FLOW" && cargo build --release)
  fi
  for spec in "ctx.herdr-flow=$FLOW" "panoptes=$HOME/suffolk/herdr-panoptes"; do
    if [[ -d "${spec#*=}" ]] && ! grep -q "^- ${spec%%=*} " <<<"$HERDR_PLUGINS"; then
      herdr plugin link "${spec#*=}"
    fi
  done
fi
