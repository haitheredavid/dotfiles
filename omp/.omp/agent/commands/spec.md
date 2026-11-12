---
description: Write a ctx spec in .context/active/ (ctx-writer agent)
argument-hint: "<topic and what you know: problem, users, approver>"
---

Dispatch the `ctx-writer` agent with the `task` tool to write a **spec** for this repo.
Pass this brief through unchanged: $ARGUMENTS

Add to the brief any facts from this conversation that bear on the problem, users, baseline, or
approver. Do not draft the spec yourself. When the agent returns, relay its verdict, path, and the
open questions it added, then ask me those questions.
