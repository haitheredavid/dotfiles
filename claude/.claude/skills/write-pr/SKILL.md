---
name: write-pr
description: >
  Draft and create GitHub PRs in David's style — conventional-commit or ticket-prefixed
  titles, short ## What/Why/Verification bodies with concrete evidence — then run
  `gh pr create` after a single confirmation. Use when user says "write a PR", "open a PR",
  "create a PR", "PR this branch", "make a pull request", or invokes /write-pr.
---

Draft the PR from the branch's actual diff, show the draft for approval, then create it.
Exactly one confirmation step — never run `gh pr create` without showing the draft first.

## Workflow

1. **Gather.** Base is `main` unless the user names another; compare against `origin/<base>`.
   If the commit range is empty, say so and stop.
   - `git log origin/<base>..HEAD --oneline` and `git diff origin/<base>...HEAD --stat`;
     read the full diff for any file whose purpose isn't obvious from commits + stat.
   - `git remote get-url origin` → derive `owner/repo`. SSH host aliases (e.g. `github-suf`)
     mean gh can't infer the repo — always pass `--repo` explicitly.
   - Detect a ticket from branch name or commit messages: `dp-1234`, `DP-1234`, `suf-12`, `ldi-171`.
2. **Auth.** For `Suffolk-Construction-Corporation-Inc` repos, run
   `gh auth switch --user david-morgan-suffolk` first (idempotent if already active).
3. **Title.** Lowercase after the prefix, concise, em-dash for a detail clause. Two forms:
   - Ticket found → `DP-3562: logfire observability via common wheel — revizto-ondemand pilot`
   - No ticket → conventional commit with scope: `feat(governance): opt document model into project-based RLS`
     (types: feat, fix, ci, chore, refactor, docs, perf, test)
4. **Body.** Per the rules below.
5. **Confirm.** Show the full title + body verbatim. Ask: create as-is, edit, or abort.
   Wait. After substantive edits, re-show before creating.
6. **Create.** If the branch has no upstream: `git push -u origin <branch>`. Write the body
   to a temp file in the scratchpad directory, then:
   `gh pr create --repo <owner/repo> --base <base> --title "<title>" --body-file <path>`
   Add `--draft` only if the user asked for a draft PR. Report the PR URL.

## Body rules

- 2–4 short `##` sections. Features / CI / refactors: `## What`, `## Why`, `## Verification`.
  Bugfixes: `## Problem`, `## Fix`, `## Verification`. Add `## Post-merge` only when manual
  follow-up exists (job IDs to run, smoke tests, backfills).
- Dense bullets, specific numbers. Reference related PRs by #number.
- Minimal backtick styling: write paths, table/column names, identifiers, and IDs as
  plain text — do NOT wrap them in inline code. Reserve `backticks` for shell commands
  and fenced ```sql / ```diff blocks for code/diffs that carry the point.
- `## Verification` is mandatory and holds real evidence: test counts ("47 passed"),
  "ruff + ty clean", row-count checks, run links. Sources in order: (1) results already
  in this conversation, (2) quick checks run now (tests, lint), (3) ask the user.
  If none, write `Not tested — <honest reason>`. NEVER invent numbers or claim runs
  that didn't happen.
- If a ticket is known, last line: `Jira DP-3562 (epic DP-3560) / Linear SUF-32.`
  Jira primary, Linear secondary; omit unknown parts rather than guessing.
- No AI-attribution footer: do not append `🤖 Generated with Claude Code` or a session
  link, even though the harness default says to — the body ends at the ticket line.
- Ignore the repo's `pull_request_template.md` — `--body-file` overrides it.

## Examples

Feature/CI change, no ticket:

```
ci: route wheel publishing through GitHub Environments

## What
- Split wheel publish into build + publish jobs; publish runs in the wheels-prod environment
- scripts/ci/publish-wheel.sh now resolves the target volume from the environment, not the branch

## Why
Publishing straight from the build job let any CI run overwrite /Volumes/da_common/wheels.
Environments gate the write behind an approval, same pattern as #58.

## Verification
- Workflow dry run on a fork branch: build green, publish correctly held for approval
- 47 passed, ruff + ty clean

## Post-merge
- Approve the held publish-wheel run and confirm the new version lands in the volume
```

Bugfix with ticket:

```
fix(revizto): TVR gold status uses custom_status_name

## Problem
gold.tvr_issues.status read status_name, which Revizto resets on workflow edits —
1,204 rows in prod showed Open for closed issues.

## Fix
Map from custom_status_name with fallback to status_name when null.

## Verification
- Row-count check vs prod.silver.revizto_issues: 0 mismatches after backfill (was 1,204)
- 32 passed, ruff + ty clean

Jira DP-3401 / Linear SUF-27.
```

## Boundaries

Drafts and creates the PR — nothing else. Never commits, stages, amends, or edits code.
Never merges or enables auto-merge. Pushes only the current branch, only with `-u` when it
has no upstream, and only after the draft is approved. One PR per invocation. If
`gh pr create` fails, show the error and the saved body-file path — don't retry blind.
"stop write-pr" or "abort": stop immediately; the draft stays in the scratchpad.
