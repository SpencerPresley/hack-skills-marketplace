---
status: partial
phase: 02-router-skill-content
source: [02-VERIFICATION.md]
started: 2026-05-22T18:30:00Z
updated: 2026-05-22T18:30:00Z
---

## Current Test

[awaiting human testing]

## Tests

### 1. Router runtime load + description-match auto-invocation
expected: In a Claude Code session, sending a representative security query (e.g., "How do I test JWT alg=none on this API?") causes the router to auto-load via description-match. SKILL.md body content is visible; body references `patterns/routing-tables.md` and `examples/workflow-walkthroughs.md` by name; router provides a specific deep-skill recommendation. If the recommended plugin is not installed, Claude outputs the canonical `/plugin install <plugin>@hack-skills-marketplace` install command.
result: [pending]

## Summary

total: 1
passed: 0
issues: 0
pending: 1
skipped: 0
blocked: 0

## Gaps
