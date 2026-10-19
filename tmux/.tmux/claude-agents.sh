#!/usr/bin/env bash
# Toggle a full-height left sidebar running `claude agents` in a tmux window.
# Usage: claude-agents.sh [target-pane] [start-dir]   (defaults: current pane, its cwd)

target="${1:-${TMUX_PANE:-}}"
dir="${2:-$(tmux display-message -p -t "$target" '#{pane_current_path}')}"
width="${CLAUDE_AGENTS_WIDTH:-30%}"

existing=$(tmux list-panes -t "$target" -F '#{pane_id} #{@claude_agents}' | awk '$2 == 1 { print $1; exit }')
if [ -n "$existing" ]; then
  tmux kill-pane -t "$existing"
  exit 0
fi

pane=$(tmux split-window -t "$target" -hbf -l "$width" -c "$dir" -P -F '#{pane_id}' 'claude agents')
tmux set-option -p -t "$pane" @claude_agents 1
tmux select-pane -t "$pane" -T agents
