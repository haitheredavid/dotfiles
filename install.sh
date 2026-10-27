#!/usr/bin/env bash
# Stow every package into $HOME (file-level links, --no-folding).
# Anything already occupying a package path that isn't our link is moved to
# ~/.dotfiles-backup/<timestamp>/<path> first. Idempotent.
set -euo pipefail

DOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGES=(zsh tmux helix ghostty omp claude agents)
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

# launchagent: helix theme sync (launchd needs absolute paths, so render instead of link)
PLIST="$HOME/Library/LaunchAgents/com.user.helix-theme-sync.plist"
mkdir -p "$(dirname "$PLIST")"
sed "s#\$HOME#$HOME#g" "$DOT/launchagents/com.user.helix-theme-sync.plist" > "$PLIST"
echo "render  $PLIST"

# oh-my-zsh: stock clone; the official installer would overwrite .zshrc
[[ -d "$HOME/.oh-my-zsh" ]] || git clone --depth 1 https://github.com/ohmyzsh/ohmyzsh.git "$HOME/.oh-my-zsh"

# tmux plugin manager + the @plugin list in tmux/.tmux.conf (no running server needed)
[[ -d "$HOME/.tmux/plugins/tpm" ]] || git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
"$HOME/.tmux/plugins/tpm/bin/install_plugins"

echo
echo "Done. Next:"
echo "  launchctl unload '$PLIST' 2>/dev/null; launchctl load '$PLIST'"
echo "  tmux source-file ~/.tmux.conf   (or prefix+r)"
echo "  ghostty: cmd+shift+,            (reload config)"
