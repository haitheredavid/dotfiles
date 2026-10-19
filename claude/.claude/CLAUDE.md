# Global instructions

## Working style
- State key assumptions (environment, credentials, signal semantics, target) before acting on them. If one is a guess, say so.
- Honor effort tags in requests (`[low]`, `[medium]`, `[high]`) exactly.
- Done = verified, not just written. Name what was verified and what was not; record unverified items in the handoff note.
- Never silently skip tests. If a suite skips (e.g. Spark tests without `JAVA_HOME=$(brew --prefix openjdk@17)`), fix the env or report the skip.

## Shell (zsh)
- Quote every expansion (`"$var"`). No unquoted word-splitting in loops: use arrays (`for f in "${files[@]}"`) or `while read -r`.
- Quote globs passed to git, gh, databricks, pytest.
- Non-trivial helpers or loops: write them in Python or `bash -c`, not ad-hoc zsh.
- Watchers/pollers: check for a terminal state, not the first status change. Test the exit condition against a known-finished run (or one item) before relying on it.

## Git, worktrees, PRs
- Parallel sessions often share a repo. Never switch branches in the main checkout for new work; use a worktree inside the repo dir.
- Run `git branch --show-current` right before every commit and confirm it is the intended branch.
- Run `gh auth status` before `gh pr create` / `gh pr merge` and confirm the account.
- After opening a PR: wait for CI + review-bot (Devin) comments, triage each, fix valid ones, repeat until green and nothing new (`/pr-devin`).

## Production safety
- Never run destructive prod operations (DELETE, DROP, destroy, truncate) yourself. Write a runbook: pre-checks with expected counts, exact commands, post-checks with acceptance criteria. User runs it; verify pasted results.
- Credentials are per-integration. Never reuse another integration's env vars or secrets.
