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
    # Ours only if it resolves to this checkout's file: links into another checkout
    # (same directory name, different location) are backed up like anything else.
    [[ -L "$dst" && "$(readlink -f "$dst")" == "$(readlink -f "$src")" ]] && continue
    mkdir -p "$(dirname "$BACKUP/$rel")"
    mv "$dst" "$BACKUP/$rel"
    echo "backup  ~/$rel -> $BACKUP/$rel"
  done < <(find "$DOT/$pkg" \( -type f -o -type l \) ! -name .DS_Store -print0)
done

stow --dir "$DOT" --target "$HOME" --no-folding --ignore '\.DS_Store' --restow -v "${PACKAGES[@]}"

# oh-my-zsh: stock clone; the official installer would overwrite .zshrc
[[ -d "$HOME/.oh-my-zsh" ]] || git clone --depth 1 https://github.com/ohmyzsh/ohmyzsh.git "$HOME/.oh-my-zsh"

# herdr plugins (keybinds in herdr/.config/herdr/config.toml). After oh-my-zsh: the ohmyzsh.shell
# build step links itself into $ZSH_CUSTOM/plugins/herdr. sessionizer's build needs bun.
# Local-checkout plugins are linked by install-local.sh.
if command -v herdr >/dev/null; then
  HERDR_PLUGINS="$(herdr plugin list 2>/dev/null || true)"
  for spec in herdr-bar=jeffarese/herdr-bar sessionizer=andrewchng/herdr-sessionizer ohmyzsh.shell=robbyrussell/herdr-ohmyzsh; do
    grep -q "^- ${spec%%=*} " <<<"$HERDR_PLUGINS" || herdr plugin install "${spec#*=}" --yes
  done
  # herdr-extras plugins build with cargo during install; skipped without it.
  if command -v cargo >/dev/null; then
    grep -q "^- herdr-extras.track " <<<"$HERDR_PLUGINS" || herdr plugin install haitheredavid/herdr-extras/plugins/track --yes
  fi
fi

# omp plugins (state lives in ~/.omp/plugins, not stowed). Skips what is already installed.
# caveman and headroom stay disabled: caveman forces full caveman on every new session; `omp plugin enable` to opt in.
if command -v omp >/dev/null; then
  OMP_PLUGINS="$(omp plugin list 2>/dev/null || true)"
  OMP_MARKETS="$(omp plugin marketplace list 2>/dev/null || true)"
  for market in erikh3/omp-marketplace pedropb/pi-extensions; do
    grep -q "$market" <<<"$OMP_MARKETS" || omp plugin marketplace add "$market"
  done
  for spec in herdr-session-agent-name-sync@erikh3-omp-marketplace \
    herdr-interactive-tool-block@erikh3-omp-marketplace redmine@pedropb-pi-extensions; do
    grep -qF " $spec (" <<<"$OMP_PLUGINS" || omp plugin install "$spec"
  done
  # npm/git plugins: "<package name>=<install source>" (source defaults to the name)
  for spec in cc-safety-net omp-enforce-uv @kryoz/caveman-plugin @estebanforge/pi-ask-codex \
    omp-agent-sdk-bridge=git:github.com/poog26/omp-agent-sdk-bridge \
    omp-extras=git:github.com/haitheredavid/omp-extras; do
    grep -qF " ${spec%%=*}@" <<<"$OMP_PLUGINS" || omp plugin install "${spec#*=}"
  done
  # headroom is linked from a local checkout by install-local.sh; disabled here only once present
  OMP_PLUGINS="$(omp plugin list 2>/dev/null || true)"
  for off in @kryoz/caveman-plugin omp-headroom; do
    grep -qF "$off" <<<"$OMP_PLUGINS" || continue
    grep -qF " $off@" <<<"$OMP_PLUGINS" || omp plugin disable "$off"
  done
fi

# Claude Code plugins: install what claude/.claude/settings.json enables (the *-lsp ones
# need their language server on PATH). Marketplaces come from its extraKnownMarketplaces,
# so adding one leaves the stowed settings.json as it is; a plugin from a marketplace
# declared nowhere is skipped. Skips what is already installed.
if command -v claude >/dev/null && command -v jq >/dev/null; then
  CLAUDE_SETTINGS="$HOME/.claude/settings.json"
  claude_markets() { claude plugin marketplace list --json 2>/dev/null | jq -r '.[].name' || true; }
  CLAUDE_MARKETS="$(claude_markets)"
  while read -r name repo; do
    grep -qxF "$name" <<<"$CLAUDE_MARKETS" || claude plugin marketplace add "$repo"
  done < <(jq -r '.extraKnownMarketplaces // {} | to_entries[] | select(.value.source.source == "github") | "\(.key) \(.value.source.repo)"' "$CLAUDE_SETTINGS")
  CLAUDE_MARKETS="$(claude_markets)"
  CLAUDE_PLUGINS="$(claude plugin list --json 2>/dev/null | jq -r '.[].id' || true)"
  for spec in $(jq -r '.enabledPlugins // {} | to_entries[] | select(.value) | .key' "$CLAUDE_SETTINGS"); do
    grep -qxF "$spec" <<<"$CLAUDE_PLUGINS" && continue
    if grep -qxF "${spec#*@}" <<<"$CLAUDE_MARKETS"; then
      claude plugin install "$spec"
    else
      echo "claude plugin $spec: marketplace ${spec#*@} unknown; add it to extraKnownMarketplaces" >&2
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
