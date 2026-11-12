#!/usr/bin/env bash
# Set up these dotfiles on Ubuntu 24.04 for the current (non-root) user: the Linux
# counterpart of Brewfile + install.sh. Idempotent; needs passwordless sudo for apt.
# Used by linux/Dockerfile, and by machines that clone this repo.
set -euo pipefail

DOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
say() { echo "dotfiles: $*" >&2; }
[[ "$(id -u)" -ne 0 ]] || { say "run as your user, not root"; exit 1; }

# System packages the shell config uses (Homebrew provides these on the Mac).
pkgs=(zsh stow tmux zoxide git curl ca-certificates jq ripgrep unzip xz-utils less)
missing=()
for p in "${pkgs[@]}"; do
  dpkg-query -W -f='${Status}' "$p" 2>/dev/null | grep -q 'install ok installed' || missing+=("$p")
done
if ((${#missing[@]})); then
  say "apt: installing ${missing[*]}"
  sudo apt-get update -qq
  sudo DEBIAN_FRONTEND=noninteractive apt-get install -y -qq --no-install-recommends "${missing[@]}" >/dev/null
fi

# ~/.local/bin on PATH: .zshrc only sources ~/.local/bin/env (see DEPENDENCIES.md).
mkdir -p ~/.local/bin
[[ -f ~/.local/bin/env ]] || cat >~/.local/bin/env <<'EOF'
#!/bin/sh
# add binaries to PATH if they aren't added yet
case ":${PATH}:" in
    *:"$HOME/.local/bin":*) ;;
    *) export PATH="$HOME/.local/bin:$PATH" ;;
esac
EOF
# shellcheck source=/dev/null
. ~/.local/bin/env
export PATH="$HOME/.local/share/mise/shims:$PATH"

# CLI tools without a usable apt package. fzf from mise: apt's 0.44 predates
# `fzf --zsh`, so the oh-my-zsh fzf plugin would fall back to Debian example files.
# terraform is a global default (`tf`, terraform plugin); repo mise.toml pins still win.
if ! command -v mise >/dev/null; then
  say "installing mise"
  curl -fsSL https://mise.run | MISE_INSTALL_PATH="$HOME/.local/bin/mise" sh >/dev/null
fi
MISE_YES=1 mise use -g -q helix@latest fzf@latest gh@latest bun@latest terraform@latest aws-cli@latest >/dev/null

# Stow + oh-my-zsh + herdr/omp/tmux plugins. Idempotent; the plugin steps only run
# where herdr/omp are installed, so run it every time.
"$DOT/install.sh" >/dev/null

# Prompt and line-editing addons: .zshrc takes Homebrew's copies on the Mac, else these.
addon() {
  [[ -d "$HOME/.oh-my-zsh/custom/$1" ]] || git clone -q --depth 1 "$2" "$HOME/.oh-my-zsh/custom/$1"
}
addon themes/powerlevel10k https://github.com/romkatv/powerlevel10k
addon plugins/zsh-autosuggestions https://github.com/zsh-users/zsh-autosuggestions
addon plugins/zsh-syntax-highlighting https://github.com/zsh-users/zsh-syntax-highlighting

shell="$(command -v zsh)"
[[ "$(getent passwd "$(id -un)" | cut -d: -f7)" == "$shell" ]] ||
  say "login shell is not zsh; run: sudo usermod -s $shell $(id -un)"
