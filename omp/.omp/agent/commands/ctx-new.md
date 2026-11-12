---
description: Add ctx context to a new or existing project (ctx-scaffolder agent)
argument-hint: "[dir] [--preset <name>] [notes]"
---

Dispatch the `ctx-scaffolder` agent with the `task` tool.
Target and options: $ARGUMENTS

No directory given: use the current working directory. Pass a named preset through; otherwise let
the agent choose from the repo's metadata. Do not allow overwrites unless I said so here. When the
agent returns, relay its verdict, the files written and skipped, and the TODOs left.
