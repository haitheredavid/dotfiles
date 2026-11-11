#!/usr/bin/env bash
# Build the Linux image and check the shell config on Linux: an interactive login
# zsh loads it, finds its tools, defines aliases only for installed tools, and prints
# no errors. Needs Docker.
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.."

fail() { echo "FAIL: $*" >&2; exit 1; }

docker build -q -f linux/Dockerfile -t dotfiles-linux-check . >/dev/null
# `|| true`: a missing tool must reach the checks below, not abort under pipefail.
out="$(docker run --rm -t dotfiles-linux-check zsh -il -c \
  'echo ZDOTDIR=$ZDOTDIR; whence -p hx tmux fzf zoxide gh bun mise stow terraform aws
   for a in tf tfa mux txs oc blender; do (( $+aliases[$a] )) && echo alias:$a; done' 2>&1 | tr -d '\r')" || true
echo "$out"
grep -q 'ZDOTDIR=/home/.*/\.config/zsh' <<<"$out" || fail "zsh did not load the dotfiles"
for t in hx tmux fzf zoxide gh bun mise stow terraform aws; do
  grep -q "/$t\$" <<<"$out" || fail "$t not on PATH"
done
# terraform is installed here (tf, plugin's tfa); tmuxinator, opencode, Blender are not.
for a in tf tfa; do grep -qx "alias:$a" <<<"$out" || fail "alias $a missing"; done
for a in mux txs oc blender; do ! grep -qx "alias:$a" <<<"$out" || fail "alias $a defined without its tool"; done
! grep -iE 'not found|cannot find|error|no such file|permission denied' <<<"$out" || fail "zsh startup printed errors"
echo "dotfiles linux check ok"
