# hack-skills-marketplace

## What This Is

A personal Claude Code marketplace that curates `yaklang/hack-skills` (102 skills) into topically-grouped, individually-enableable plugins. Each group exposes a curated subset via `strict: false` + a `skills` array against a `git-subdir` source descriptor (path: `skills`), so users (primarily Spencer, working on the `purplehaze` security product) can toggle on only the categories relevant to current feature work — keeping context windows lean while leaving the upstream repo untouched.

## Core Value

Selective topical activation of hacking-skill prompts so a session's context only carries skills relevant to whatever `purplehaze` feature is being worked on right now.

## Requirements

### Validated

- [x] Schema assumptions verified: individual-skill addressing (VERIFY-01), context isolation (VERIFY-02), and per-plugin cache behavior (VERIFY-03) all confirmed against real Claude Code installs (Phase 1, 2026-05-22). Required correction during verification: `source: { source: "github", repo: ... }` does NOT honor the `skills` array filter — Claude Code 2.1.148 appears to auto-discover `./skills/*/SKILL.md` at source root. `source: { source: "git-subdir", url: "https://github.com/yaklang/hack-skills.git", path: "skills" }` with root-level skill paths (no `./skills/` prefix) is the working mechanism. Token cost validated end-to-end: ~10,503 tok always-on under broken pattern, ~205 tok always-on for the 2-skill auth-bypass curation under fix.

### Active

- [ ] ~8 topical group plugins defined based on `purplehaze`'s feature surface (not yaklang's categorization)
- [ ] All ~8 groups implemented in `.claude-plugin/marketplace.json` cherry-picking specific skills from `yaklang/hack-skills` via the `skills` array
- [ ] Each group is independently installable and limits the session to its curated 8–15 skills
- [ ] Marketplace is published and live at `github.com/SpencerPresley/hack-skills-marketplace` such that `/plugin marketplace add SpencerPresley/hack-skills-marketplace` works for anyone

### Out of Scope

- **Upstream PR to `yaklang/hack-skills`** — Sibling effort tracked separately in `docs/PR-PLAN.md`. This GSD project only covers the personal marketplace.
- **Modifying upstream skill files** — `yaklang/hack-skills` is read-only inspiration. Curation happens via marketplace cherry-picking, never edits.
- **Auto-sync / live tracking from upstream** — Snapshot consumption is fine. Manual cache refresh is acceptable.
- **Forking and physically regrouping upstream into subdirectory plugins** — Defeated by `strict: false` + `skills` arrays. The whole partitioning lives in `marketplace.json`.
- **Non-skill components (hooks, agents, MCP, commands) in groups** — Groups are skill-only curations. Other component types are not the focus.
- **Symlink trees or alternative directory layouts to work around schema limitations** — If verification reveals individual-skill paths don't work, the plan changes; symlink workarounds are explicitly rejected.

## Context

- **Source repo**: `github.com/yaklang/hack-skills` — 102 skill directories under `skills/`, each with `SKILL.md`. Already canonical Claude Code plugin layout.
- **Consumer**: `~/work/purple-haze-backend/firm/purplehaze` — a security product being built; uses hack-skills as idea-fuel during feature planning, not as core tooling.
- **Problem**: Even installed as a single plugin, 102 skill descriptions appear in every session's system reminder. Useful for one topic at a time, noise for everything else.
- **Existing artifacts**: `docs/PLAN.md` captures the schema lessons, the marketplace skeleton, the 3 open questions, the build order, and suggested topical buckets. `docs/PR-PLAN.md` covers the upstream PR (out of scope for this GSD project but linked from PROJECT context).
- **Suggested initial buckets** (from PLAN.md, to be refined by reading through all 102 skills): `recon`, `auth-bypass`, `injection`, `payloads`, `mobile`, `binary`, `ad` (Active Directory), `crypto`.
- **Remote**: `git@github.com:SpencerPresley/hack-skills-marketplace.git` — public, already initialized, gh CLI authed.

## Constraints

- **Source immutability**: Never modify files in `yaklang/hack-skills`. All curation happens in this repo's `marketplace.json`.
- **Install command shape**: No `@branch` suffixes — use the default ref. Install commands must be plain `/plugin install <name>@hack-skills-marketplace`.
- **Sync model**: Snapshot consumption only. No tooling around auto-pulling upstream changes.
- **Group sizing**: Target 8–15 skills per group. Beyond ~15 the group pollutes context as much as enabling everything; below ~5 the group probably isn't worth being its own entry.
- **Grouping axis**: Group by what's relevant to `purplehaze`'s feature surface, NOT by yaklang's own categorization. Skills that don't map to any `purplehaze` feature bucket probably shouldn't have a group at all.

## Key Decisions

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| Use `strict: false` on every plugin entry | Upstream has no `plugin.json`; `strict: false` makes the marketplace entry the full plugin definition, so we don't need to add one. | ✓ Validated (Phase 1) |
| Cherry-pick skills via the `skills` array per plugin entry | Documented as a valid marketplace-entry field. Lets one source repo back N differently-scoped plugins. | ✓ Validated (Phase 1) — works ONLY when paths sit at the root of the cloned source (not nested under `./skills/`). See git-subdir decision below. |
| **Use `git-subdir` source descriptor with `path: "skills"` (NOT plain `github` source)** | Phase 1 found that `source: { source: "github", repo: "yaklang/hack-skills" }` ignored the `skills` array — `claude plugin details` reported all 102 upstream skills and ~10,503 always-on tokens. Working precedents (wondelai-skills, oracle/netsuite-suitecloud-sdk) all clone content such that skill dirs land at the source root. `git-subdir` with `path: "skills"` sparse-clones only `yaklang/hack-skills`'s `skills/` subdir, making each skill directory addressable as `./<skill-name>` from the source root. | ✓ Validated (Phase 1) — see `.planning/phases/01-schema-verification/01-VERIFICATION.md` |
| Multiple plugin entries share `yaklang/hack-skills` as their `source` | Duplicate-detection is on `name`, not `source`. Per-plugin caching means N entries → N separate clones; storage is small for a text-only repo. | ✓ Validated (Phase 1) — `~/.claude/plugins/cache/hack-skills-marketplace/` contains a parallel `<plugin-name>/<sha>-<path-hash>/` subdir per installed plugin; cache slot tokens include the path-hash suffix unique to `git-subdir` clones, but no collision across plugins sharing the same source SHA. |
| Group by `purplehaze` feature surface, not yaklang's categorization | We're building this for `purplehaze` work, not as a general-purpose mirror. Yaklang's structure isn't optimized for our usage. | — Pending |
| Treat upstream PR as a separate effort | The PR is minimal and diplomatic (single-bundled-plugin); the personal marketplace is opinionated and grouped. Conflating them confuses both. | ✓ Good |
| Verify the 3 open questions before building out all groups | A "no" on Open Question 1 (individual-skill addressing) changes the entire approach. Cheap to verify with a 2-group MVP first. | ✓ Done (Phase 1) — required a mid-phase mechanism correction, see git-subdir row above |

## Evolution

This document evolves at phase transitions and milestone boundaries.

**After each phase transition** (via `/gsd-transition`):
1. Requirements invalidated? → Move to Out of Scope with reason
2. Requirements validated? → Move to Validated with phase reference
3. New requirements emerged? → Add to Active
4. Decisions to log? → Add to Key Decisions
5. "What This Is" still accurate? → Update if drifted

**After each milestone** (via `/gsd:complete-milestone`):
1. Full review of all sections
2. Core Value check — still the right priority?
3. Audit Out of Scope — reasons still valid?
4. Update Context with current state

---
*Last updated: 2026-05-22 after initialization*
