#!/usr/bin/env bash
# PreToolUse(Bash): on git commit / gh pr, surface current branch + active gh account to Claude.
input=$(cat)
cmd=$(jq -r '.tool_input.command // empty' <<<"$input")
case "$cmd" in
  *"git commit"*|*"gh pr create"*|*"gh pr merge"*) ;;
  *) exit 0 ;;
esac

cwd=$(jq -r '.cwd // empty' <<<"$input")
[[ -n "$cwd" ]] && cd "$cwd" 2>/dev/null
branch=$(git branch --show-current 2>/dev/null)
msg="git-context: branch=${branch:-?}"
if [[ "$cmd" == *"gh pr"* ]]; then
  acct=$(gh auth status --active 2>&1 | grep -m1 -oE 'account [^ ]+' | awk '{print $2}')
  msg="${msg} gh_account=${acct:-unknown}"
fi

jq -n --arg m "$msg — confirm this is intended (cd in the command may change the branch)." \
  '{hookSpecificOutput: {hookEventName: "PreToolUse", additionalContext: $m}}'
