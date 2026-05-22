---
description: STUB — routing + scaffolding for security/hacking tasks. Phase 2 will replace this body with the full router that picks the right deep skill from the hack-skills marketplace and surfaces boundary conditions a baseline AI often misses. Triggers on security, hacking, pentest, vulnerability, XSS, SQLi, CVE.
---

# Hack-Skills Router (STUB)

This is a Phase 1 mechanism-spike stub. The full router skill body lands in Phase 2.

When loaded, the router will route security tasks to the correct deep skill from the
hack-skills marketplace and surface boundary conditions a baseline AI often misses.

Phase 1 verifies the plugin shell loads, the SessionStart hook injects on session boundaries,
and the UserPromptSubmit hook fires on every prompt (matcher is silently ignored in
Claude Code 2.1.x per RESEARCH §Pitfall 3 — gating moves into nudge.sh in Phase 3).

## What Phase 2 will replace

- Frontmatter `description`: keyword-dense multi-paragraph trigger description per design spec §5.6.
- Body: ~80 lines including when-to-use bullets, trust model, hybrid routing strategy,
  3-step operating model, plugin-availability handling, boundary-conditions quick reference,
  and a cross-reference to workflow examples.
- New sibling files: `patterns/routing-tables.md`, `patterns/expert-intuitions.md`,
  `examples/workflow-walkthroughs.md` for progressive disclosure.

## Phase 1 success signal

If you can see this body via `Skill(hack-skills-router)` after installing the plugin,
the mechanism wiring works and Phase 2 can replace this content in place.
