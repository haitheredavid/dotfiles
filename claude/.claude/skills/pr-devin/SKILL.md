---
name: pr-devin
description: Take a branch from push to a green, review-clean PR — open it (via write-pr), then loop on CI checks and Devin/reviewer comments, fixing valid findings until CI is green and nothing new is reported. Use when user says "/pr-devin", "shepherd this PR", "get this PR green", "handle the Devin review", or "PR and triage reviews".
---

# PR → green, review-clean

Stops at a mergeable PR. Never merges, never deploys unless the user says so in this session.

## 1. Preflight
- `git branch --show-current` — confirm intended branch; `git status --short` — report dirty files, don't commit unrelated work.
- `git remote get-url origin` → `owner/repo`; always pass `--repo` to gh.
- `gh auth status` — confirm account (Suffolk repos: `gh auth switch --user david-morgan-suffolk`).
- Self-review before pushing: spawn an agent to review `git diff origin/main...HEAD` as a strict reviewer (broken imports/exports, release/deploy ordering, serialization/loading crashes, env/target mismatches). Fix valid findings.
- Run the repo's lint/type/test commands for the touched scope. Report exact scope.

## 2. Open
- If no PR exists for the branch: push, then follow the `write-pr` skill (one confirmation).
- If one exists: `gh pr view --repo <r> --json number,url,state`.

## 3. Loop (until exit condition)
1. `gh pr checks <n> --repo <r> --watch --fail-fast` (run in background or via Monitor; don't foreground-sleep).
2. Fetch review comments:
   - `gh api repos/<r>/pulls/<n>/comments --paginate` (inline)
   - `gh api repos/<r>/issues/<n>/comments --paginate` (summary, Devin posts here too)
   - `gh api repos/<r>/pulls/<n>/reviews`
   Track handled comment IDs; only act on new ones.
3. Triage each finding: **valid** → fix (add a test reproducing it when practical), commit, push. **False positive / out of scope** → note why; reply on the thread only if the user wants replies posted.
4. Failed CI check → `gh run view <id> --log-failed`, fix root cause, push.
5. After a push, wait for Devin to re-review the new head SHA before judging "nothing new".

**Exit:** all checks pass on HEAD, Devin has reviewed HEAD, no unhandled actionable comments. If the same failure repeats 3×, stop and ask.

## 4. Report
PR URL, head SHA, checks status, findings table (fixed / rejected + reason), anything left for the user (merge, approval, prod steps). Update the handoff note if one exists for this work.
