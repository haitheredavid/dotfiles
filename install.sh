#!/usr/bin/env bash
# Symlink dotfiles into place. Existing regular files are backed up to <path>.bak.<timestamp>.
# Idempotent: re-running replaces symlinks, skips ones already pointing here.
set -euo pipefail

DOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TS="$(date +%Y%m%d%H%M%S)"

link() {
  local src="$DOT/$1" dst="$2"
  mkdir -p "$(dirname "$dst")"
  if [[ -L "$dst" && "$(readlink "$dst")" == "$src" ]]; then
    echo "ok      $dst"; return
  fi
  if [[ -e "$dst" && ! -L "$dst" ]]; then
    mv "$dst" "$dst.bak.$TS"; echo "backup  $dst -> $dst.bak.$TS"
  fi
  ln -sfn "$src" "$dst"; echo "link    $dst -> $src"
}

# zsh (ZDOTDIR=~/.config/zsh is set in ~/.zshenv)
link zshenv                 "$HOME/.zshenv"
link zsh/zshrc              "$HOME/.config/zsh/.zshrc"
link zsh/zprofile           "$HOME/.config/zsh/.zprofile"
link zsh/p10k.zsh           "$HOME/.config/zsh/.p10k.zsh"
link zsh/completions        "$HOME/.config/zsh/completions"

# tmux
link tmux/tmux.conf         "$HOME/.tmux.conf"
link tmux/load.sh           "$HOME/.tmux/load.sh"
link tmux/git-branch.sh     "$HOME/.tmux/git-branch.sh"

# helix
link helix/config.toml      "$HOME/.config/helix/config.toml"
link helix/languages.toml   "$HOME/.config/helix/languages.toml"
link helix/sync-theme.sh    "$HOME/.config/helix/sync-theme.sh"
link helix/themes           "$HOME/.config/helix/themes"
link helix/runtime          "$HOME/.config/helix/runtime"

# ghostty (XDG config + macOS App Support config; both are loaded)
link ghostty/config         "$HOME/.config/ghostty/config"
link ghostty/themes         "$HOME/.config/ghostty/themes"
link ghostty/config.app-support "$HOME/Library/Application Support/com.mitchellh.ghostty/config"

# launchagent: helix theme sync (needs real $HOME path, so render instead of link)
PLIST="$HOME/Library/LaunchAgents/com.user.helix-theme-sync.plist"
mkdir -p "$(dirname "$PLIST")"
sed "s#\$HOME#$HOME#g" "$DOT/launchagents/com.user.helix-theme-sync.plist" > "$PLIST"
echo "render  $PLIST"

# tmux plugin manager
if [[ ! -d "$HOME/.tmux/plugins/tpm" ]]; then
  git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
fi

echo
echo "Done. Next:"
echo "  launchctl unload '$PLIST' 2>/dev/null; launchctl load '$PLIST'"
echo "  tmux source-file ~/.tmux.conf   (or prefix+r)"
echo "  ghostty: cmd+shift+,            (reload config)"
