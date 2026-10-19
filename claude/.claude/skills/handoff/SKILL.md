---
name: handoff
description: Write a session-handoff memory note so work can continue in a fresh session, or resume from one. Use when the user says "/handoff", "hand this off", "context is getting big", "move this to a new session", "write a handoff", or "/handoff resume <name>" / "resume <name>" to pick one up.
---

# Handoff

Two modes. No args (or a topic) → **write**. `resume <name>` → **resume**.

## Write

1. **Gather state** (run, don't recall):
   - `git status --short`, `git branch --show-current`, `git log --oneline -5`
   - Open PRs for the branch (`gh pr list --head <branch>` / `gh pr view`), per the gh account memory if one exists.
   - Any active TDD under `.context/active/` this work belongs to.
   - IDs from this session: job/pipeline/run IDs, workspace, profile, tables.
2. **Dirty work**: list uncommitted files. Do not commit or stash unless the user says to; ask once if anything looks unsaved.
3. **Pick the note**: memory dir is the project memory directory from the system prompt. If a project memory for this work already exists, update it in place instead of creating a new one. Otherwise create `<kebab-slug>.md`.
4. **Write the note** using the template below. Point to the TDD, PRs, and other memories (`[[name]]`); do not copy their contents. Convert relative dates to absolute.
5. **Index line** in `MEMORY.md`, placed at the top:
   `- [Title](slug.md) — NEXT YYYY-MM-DD: <next action in ≤12 words>`
   Replace any older line for the same note.
6. **Prune**: if a previous handoff note for this same work is now finished, collapse its index line to DONE or delete it.
7. **Print** for the user:
   - the note path
   - dirty files left behind (if any)
   - the resume prompt: `/handoff resume <slug>`

### Template

```markdown
---
name: <slug>
description: "NEXT (fresh session) YYYY-MM-DD — <goal in one line>"
metadata:
  type: project
---

**Goal:** <one line>. **Done when:** <exit condition>.

**State (YYYY-MM-DD):**
- Branch `<branch>` @ `<sha>`; dirty: <files or "clean">.
- PRs: #NNNN <status>, …
- Resources: <workspace / profile / job ids / pipeline ids / tables>.
- Design doc: `.context/active/<file>` (if any).

**Done (with evidence):**
- <claim> — <run id / query / PR / output that proves it>

**Ruled out:**
- <hypothesis> — <why it is wrong>

**User decisions:**
- <decision the user made; do not re-litigate>

**Landmines:**
- <gotcha that will bite the next session>

**Next action:**
1. <first concrete command or check>
2. <…>
- Needs the user: <prod runs, profile choice, approvals>.

Related: [[other-memory]]
```

Keep it skimmable. Omit empty sections except **Next action** and **Ruled out** (write "none" if truly none — the next session should know it was considered).

## Resume

1. Read the named memory note (and the `[[links]]` it points to, if relevant).
2. **Verify against reality before acting**: `git status`, branch/sha, PR states, and any job/pipeline state the note claims. Notes go stale.
3. Report in a few lines: what still holds, what changed since the note, and the next action. Do not redo items under **Done** or retry items under **Ruled out** unless verification shows they changed.
4. Proceed with **Next action**, stopping at anything listed under "Needs the user".
5. When the work finishes, update the note to its final state (or delete it) and drop `NEXT` from its index line.
