#!/usr/bin/env bash
# Build the Linux image and check the shell config on Linux: an interactive login
# zsh loads it, finds its tools, and prints no errors. Needs Docker.
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.."

fail() { echo "FAIL: $*" >&2; exit 1; }

docker build -q -f linux/Dockerfile -t dotfiles-linux-check . >/dev/null
# `|| true`: a missing tool must reach the checks below, not abort under pipefail.
out="$(docker run --rm -t dotfiles-linux-check zsh -il -c \
  'echo ZDOTDIR=$ZDOTDIR; whence -p hx tmux fzf zoxide gh bun mise stow' 2>&1 | tr -d '\r')" || true
echo "$out"
grep -q 'ZDOTDIR=/home/.*/\.config/zsh' <<<"$out" || fail "zsh did not load the dotfiles"
for t in hx tmux fzf zoxide gh bun mise stow; do
  grep -q "/$t\$" <<<"$out" || fail "$t not on PATH"
done
! grep -iE 'not found|cannot find|error|no such file|permission denied' <<<"$out" || fail "zsh startup printed errors"
echo "dotfiles linux check ok"
