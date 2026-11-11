#!/usr/bin/env bash
# Stow every package into $HOME (file-level links, --no-folding).
# Anything already occupying a package path that isn't our link is moved to
# ~/.dotfiles-backup/<timestamp>/<path> first. Idempotent.
set -euo pipefail

DOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGES=(zsh tmux helix ghostty herdr omp claude agents markdown)
BACKUP="$HOME/.dotfiles-backup/$(date +%Y%m%d%H%M%S)"

command -v stow >/dev/null || { echo "stow not found: brew install stow" >&2; exit 1; }

for pkg in "${PACKAGES[@]}"; do
  while IFS= read -r -d '' src; do
    rel="${src#"$DOT/$pkg/"}"
    dst="$HOME/$rel"
    [[ -e "$dst" || -L "$dst" ]] || continue
    [[ -L "$dst" && "$(readlink "$dst")" == *"/${DOT##*/}/$pkg/$rel" ]] && continue
    mkdir -p "$(dirname "$BACKUP/$rel")"
    mv "$dst" "$BACKUP/$rel"
    echo "backup  ~/$rel -> $BACKUP/$rel"
  done < <(find "$DOT/$pkg" \( -type f -o -type l \) ! -name .DS_Store -print0)
done

stow --dir "$DOT" --target "$HOME" --no-folding --ignore '\.DS_Store' --restow -v "${PACKAGES[@]}"

# ctx-scaffold skill presets live in the ctx checkout (absolute link, so stow can't own it)
CTX_PRESETS="$HOME/suffolk/ctx/presets"
[[ -d "$CTX_PRESETS" ]] && ln -sfn "$CTX_PRESETS" "$HOME/.claude/skills/ctx-scaffold/presets"

# oh-my-zsh: stock clone; the official installer would overwrite .zshrc
[[ -d "$HOME/.oh-my-zsh" ]] || git clone --depth 1 https://github.com/ohmyzsh/ohmyzsh.git "$HOME/.oh-my-zsh"

# herdr plugins (keybinds in herdr/.config/herdr/config.toml). After oh-my-zsh: the ohmyzsh.shell
# build step links itself into $ZSH_CUSTOM/plugins/herdr. sessionizer's build needs bun.
# `plugin link` runs no build: build the local checkouts (cargo build --release) yourself.
if command -v herdr >/dev/null; then
  HERDR_PLUGINS="$(herdr plugin list 2>/dev/null || true)"
  for spec in herdr-bar=jeffarese/herdr-bar sessionizer=andrewchng/herdr-sessionizer ohmyzsh.shell=robbyrussell/herdr-ohmyzsh; do
    grep -q "^- ${spec%%=*} " <<<"$HERDR_PLUGINS" || herdr plugin install "${spec#*=}" --yes
  done
  for spec in "ctx.herdr-flow=$HOME/projects/ctx-herdr" "panoptes=$HOME/suffolk/herdr-panoptes"; do
    if [[ -d "${spec#*=}" ]] && ! grep -q "^- ${spec%%=*} " <<<"$HERDR_PLUGINS"; then
      herdr plugin link "${spec#*=}"
    fi
  done
fi

# tmux plugin manager + the @plugin list in tmux/.tmux.conf (no running server needed)
[[ -d "$HOME/.tmux/plugins/tpm" ]] || git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
"$HOME/.tmux/plugins/tpm/bin/install_plugins"

echo
echo "Done. Next:"
echo "  tmux source-file ~/.tmux.conf   (or prefix+r)"
echo "  ghostty: cmd+shift+,            (reload config)"
