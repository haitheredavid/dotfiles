---
description: Write a ctx TDD for one DD work-breakdown row, or from a spec when the DD is skipped (ctx-writer agent)
argument-hint: "<DD path + row, or spec path> [notes]"
---

Dispatch the `ctx-writer` agent with the `task` tool to write a **TDD** for this repo.
Source and notes: $ARGUMENTS

Name the source doc and, for a DD, the work-breakdown row. Not clear from the arguments: ask me.
Do not draft the TDD yourself. When the agent returns, relay its verdict, path, gate result, and
halt conditions; for `SPLIT`, relay the proposed split.
