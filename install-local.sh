#!/usr/bin/env bash
# Links to local checkouts on this machine (not part of install.sh). Each step is
# skipped when its checkout (or tool) is missing; omp-headroom is cloned if absent. Run after install.sh. Idempotent.
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

# omp-headroom: own fork, linked so edits in ~/projects/omp-headroom go live. Stays disabled
# (install.sh disables it); `omp plugin enable omp-headroom` to opt in.
if command -v omp >/dev/null && command -v bun >/dev/null; then
  HEADROOM_DIR="$HOME/projects/omp-headroom"
  [[ -d "$HEADROOM_DIR" ]] || { git clone https://github.com/haitheredavid/omp-headroom.git "$HEADROOM_DIR" &&
    git -C "$HEADROOM_DIR" remote set-url --push origin git@github.com:haitheredavid/omp-headroom.git; }
  if ! omp plugin list 2>/dev/null | grep -qF " omp-headroom@"; then
    (cd "$HEADROOM_DIR" && bun install && omp plugin link .)
    omp plugin disable omp-headroom
  fi
fi

# omp-extras: own extensions, linked so edits in ~/projects/omp-extras go live. install.sh
# installs it from git first; the link replaces that copy (`plugin link` can't overwrite a directory).
if command -v omp >/dev/null && command -v bun >/dev/null && [[ -d "$HOME/projects/omp-extras" ]]; then
  if [[ ! -L "$HOME/.omp/plugins/node_modules/omp-extras" ]]; then
    omp plugin list 2>/dev/null | grep -qF " omp-extras@" && omp plugin uninstall omp-extras
    (cd "$HOME/projects/omp-extras" && bun install && omp plugin link .)
  fi
fi
