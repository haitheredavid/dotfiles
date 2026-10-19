---
name: "ctx-scaffold"
description: "Scaffold .context/, AGENTS.md, and .devcontainer/ into the current working directory from a ctx preset. Use when the user wants to add agent-readable context to a new or existing local project. Triggers on: 'scaffold ctx', 'add ctx context', 'init ctx', 'ctx preset', 'add AGENTS.md', or the user names a preset (frontend-ts, backend-ts, fullstack-ts, api-ts, library-ts, python, api-py, library-py, combo-ts-python)."
metadata:
  version: "0.1.0"
---

# ctx-scaffold

Drops a `ctx` preset (AGENTS.md + .context/ + .devcontainer/) into the user's current working directory. Mirrors what `./init.sh --preset <name>` does inside a freshly-templated `ctx` repo, but for any local directory.

## Source

Preset files live in `presets/` next to this skill (a symlink to `/Users/david/suffolk/ctx/presets/`). Whatever lives in the canonical ctx repo is what gets applied.

## Presets

| Variant | Pick when |
|---|---|
| `frontend-ts` | React + Vite + Tailwind SPA. |
| `backend-ts` | Node + Hono + Drizzle + Postgres service. |
| `fullstack-ts` | One repo, React + Hono with shared Zod contracts. |
| `api-ts` | Node + Hono + Zod HTTP API. No DB assumed. |
| `library-ts` | Published TS package or CLI. ESM, `tsc`-only. |
| `python` | `uv` + `ruff` + `ty` + `pytest`. |
| `api-py` | Python + FastAPI + Pydantic HTTP API. |
| `library-py` | Published Python package or CLI. |
| `combo-ts-python` | React+Vite (`web/`) + FastAPI (`api/`) combo. |

## Flow

1. Confirm cwd. **Never apply outside the user's intended directory.** If `pwd` looks like a system path or the canonical ctx repo itself, stop and ask.
2. If the user didn't name a preset, show the table above and ask.
3. Check for collisions: existing `AGENTS.md`, `.context/`, or `.devcontainer/` in cwd. If any exist, surface them and ask before overwriting. Default to **skip existing** unless the user says overwrite.
4. Copy from `~/.claude/skills/ctx-scaffold/presets/<chosen>/.` into cwd. Use `cp -R` so dotfiles and the devcontainer come along. Example:

   ```bash
   cp -R ~/.claude/skills/ctx-scaffold/presets/<chosen>/. .
   ```

5. Print a closing summary:

   ```bash
   grep -rn TODO .context/ AGENTS.md     # fill in markers
   ```

## Safety

- Do not read or copy `.env`, `.secrets`, certs, tokens.
- Do not touch files outside cwd.
- Do not modify the canonical ctx repo (`/Users/david/suffolk/ctx`) through this skill — it is the source.
- If the symlink at `presets/` is broken (canonical repo moved), tell the user instead of guessing.

## Updating presets

Edit presets in `/Users/david/suffolk/ctx/presets/<variant>/`. The symlink picks up changes instantly — no skill reinstall needed.
