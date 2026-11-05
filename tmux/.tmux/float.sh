#!/usr/bin/env bash
# Hideable floating panels behind C-8 / C-9 / C-0 (see .tmux.conf). Each kind is a session on a
# separate tmux server ("float", config ~/.tmux/float.conf): hiding a panel only detaches the
# popup's client, and the panels stay out of the main server's session list.
# Usage: float.sh open <kind>          inside display-popup: create the session if missing, attach
#        float.sh ensure <kind> [dir]  create the session if missing (float.conf's switch keys)
# Kinds: scratch (helix on a new note in the de-vault), omp, term (plain shell). omp and term
# start in the directory of the main pane the popup was opened from, even when switched to
# from another panel (@float_origin).
set -euo pipefail

ft() { env -u TMUX tmux -L float -f "$HOME/.tmux/float.conf" "$@"; }

ensure() {
  local kind=$1 dir=$2
  ft has-session -t "=$kind" 2>/dev/null && return
  case "$kind" in
    scratch)
      local vault="${SFK_VAULT:-$HOME/notes/de-vault}"
      local notes="$vault/people/david-morgan/scratch"
      mkdir -p "$notes"
      # helix only writes the file on save, so a panel quit without saving leaves nothing to sync
      ft new-session -d -s scratch -c "$vault" hx "$notes/$(date +%Y%m%d-%H%M%S).md" ;;
    omp)  ft new-session -d -s omp -c "$dir" omp ;;
    term) ft new-session -d -s term -c "$dir" ;;
    *) echo "float.sh: unknown kind '$kind' (scratch|omp|term)" >&2; exit 1 ;;
  esac
}

case "${1:-}" in
  open)
    ensure "$2" "$PWD"
    ft set-option -g @float_origin "$PWD"
    # The main server ($TMUX) repaints the whole popup, border included, on every status-bar
    # redraw: each status-interval tick plus each #() job finishing, 3 repaints every 5s here,
    # which flickers. Pause status refresh while the popup is open. The stash skips 0 so a
    # second popup opened meanwhile can't save the paused value.
    interval=$(tmux show-options -gv status-interval)
    [ "$interval" = 0 ] || tmux set-option -g @float_status_interval "$interval"
    tmux set-option -g status-interval 0
    trap 'tmux set-option -g status-interval "$(tmux show-options -gv @float_status_interval)"' EXIT
    trap 'exit 1' HUP TERM
    ft attach-session -t "=$2" ;;
  ensure) ensure "$2" "${3:-$PWD}" ;;
  *) echo "usage: float.sh open <kind> | ensure <kind> [dir]" >&2; exit 1 ;;
esac
