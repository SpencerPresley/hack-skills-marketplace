<!-- GSD:project-start source:PROJECT.md -->
## Project

**hack-skills-marketplace**

A personal Claude Code marketplace that curates `yaklang/hack-skills` (102 skills) into topically-grouped, individually-enableable plugins. Each group exposes a curated subset via `strict: false` + a `skills` array, so users can toggle on only the categories relevant to current feature work — keeping context windows lean while leaving the upstream repo untouched.

**Core Value:** Selective topical activation of hacking-skill prompts so a session's context only carries skills relevant to whatever topical area is being worked on right now.

### Constraints

- **Source immutability**: Never modify files in `yaklang/hack-skills`. All curation happens in this repo's `marketplace.json`.
- **Install command shape**: No `@branch` suffixes — use the default ref. Install commands must be plain `/plugin install <name>@hack-skills-marketplace`.
- **Sync model**: Snapshot consumption only. No tooling around auto-pulling upstream changes.
- **Group sizing**: Target 8–15 skills per group. Beyond ~15 the group pollutes context as much as enabling everything; below ~5 the group probably isn't worth being its own entry.
- **Grouping axis**: Group by skill-content topicality, NOT by yaklang's own categorization. Skills that don't map to any topical bucket probably shouldn't have a group at all.
<!-- GSD:project-end -->

<!-- GSD:stack-start source:STACK.md -->
## Technology Stack

Technology stack not yet documented. Will populate after codebase mapping or first phase.
<!-- GSD:stack-end -->

<!-- GSD:conventions-start source:CONVENTIONS.md -->
## Conventions

Conventions not yet established. Will populate as patterns emerge during development.
<!-- GSD:conventions-end -->

<!-- GSD:architecture-start source:ARCHITECTURE.md -->
## Architecture

Architecture not yet mapped. Follow existing patterns found in the codebase.
<!-- GSD:architecture-end -->

<!-- GSD:skills-start source:skills/ -->
## Project Skills

No project skills found. Add skills to any of: `.claude/skills/`, `.agents/skills/`, `.cursor/skills/`, `.github/skills/`, or `.codex/skills/` with a `SKILL.md` index file.
<!-- GSD:skills-end -->

<!-- GSD:workflow-start source:GSD defaults -->
## GSD Workflow Enforcement

Before using Edit, Write, or other file-changing tools, start work through a GSD command so planning artifacts and execution context stay in sync.

Use these entry points:
- `/gsd-quick` for small fixes, doc updates, and ad-hoc tasks
- `/gsd-debug` for investigation and bug fixing
- `/gsd-execute-phase` for planned phase work

Do not make direct repo edits outside a GSD workflow unless the user explicitly asks to bypass it.
<!-- GSD:workflow-end -->



<!-- GSD:profile-start -->
## Developer Profile

> Profile not yet configured. Run `/gsd-profile-user` to generate your developer profile.
> This section is managed by `generate-claude-profile` -- do not edit manually.
<!-- GSD:profile-end -->
