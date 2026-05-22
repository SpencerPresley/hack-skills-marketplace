# hack-skills-marketplace

## What This Is

A personal Claude Code marketplace that curates `yaklang/hack-skills` (102 skills) into topically-grouped, individually-enableable plugins. Each group exposes a curated subset via `strict: false` + a `skills` array against a `git-subdir` source descriptor (path: `skills`), so users can toggle on only the categories relevant to current feature work — keeping context windows lean while leaving the upstream repo untouched.

A sidecar `hack-skills-router` plugin (v2.0) layers routing intelligence and methodology scaffolding on top of the topical plugins without touching them — adapted from upstream `yaklang/hack-skills` and supplemented with hooks for trust gating and expert-intuition injection.

## Core Value

Selective topical activation of hacking-skill prompts, with optional routing and methodology scaffolding via the sidecar router plugin — so a session's context only carries skills relevant to whatever topical area is being worked on right now AND the agent is prompted to apply structured testing methodology with the boundary conditions baseline AI commonly misses.

## Current Milestone: v2.0 Router & Hooks (Sidecar)

**Goal:** Add a sidecar router plugin that layers routing intelligence + methodology scaffolding + trust gating on top of v1's 13 topical plugins, without breaking v1.

**Target features:**
- `hack-skills-router` plugin authored under `plugins/hack-skills-router/` (NOT a curation of upstream — original content authored by us)
- `SessionStart` hook: once-per-session injection of trust model, workflow philosophy, and the expert-intuitions snapshot
- `UserPromptSubmit` hook: regex-matched per-prompt nudge to load router and surface boundary conditions
- Router `SKILL.md` with hybrid routing strategy: static signal → topic-skill table primary; model reasoning fallback for ambiguous cases
- Progressive disclosure: `patterns/routing-tables.md`, `patterns/expert-intuitions.md`, `examples/workflow-walkthroughs.md` loaded on demand from router body
- Live validation against published v2 marketplace

**Key context:** Decisions and rationale captured in `.planning/specs/2026-05-22-v2-router-design.md` (committed 2026-05-22). v1.0 is live at `github.com/SpencerPresley/hack-skills-marketplace`; v2 is additive.

## Requirements

### Validated

- [x] Schema assumptions verified: individual-skill addressing (VERIFY-01), context isolation (VERIFY-02), and per-plugin cache behavior (VERIFY-03) all confirmed against real Claude Code installs (Phase 1, 2026-05-22). Required correction during verification: `source: { source: "github", repo: ... }` does NOT honor the `skills` array filter — Claude Code 2.1.148 appears to auto-discover `./skills/*/SKILL.md` at source root. `source: { source: "git-subdir", url: "https://github.com/yaklang/hack-skills.git", path: "skills" }` with root-level skill paths (no `./skills/` prefix) is the working mechanism. Token cost validated end-to-end: ~10,503 tok always-on under broken pattern, ~205 tok always-on for the 2-skill auth-bypass curation under fix.
- [x] Topical group taxonomy defined (Phase 2, 2026-05-22): 14 buckets — 11 primary topical + 3 themed catch-alls — covering all 102 upstream skills exactly once (D-07 invariant verified). Hybrid derivation (D-01 starter scaffold → D-02 resize → D-06 catch-all routing) settled at: `binary-exploitation` (12), `web-injection` (10), `web-client-attacks` (10), `linux-and-post-exploit` (10), `auth-bypass` (9), `server-side-execution` (8), `web-protocol-attacks` (7), `hack-skills-routers` (7 catch-all), `crypto-attacks` (7), `active-directory-and-windows` (7), `recon` (6), `mobile` (3), `forensics-and-misc-recovery` (3 catch-all), `ai-and-supply-chain` (3 catch-all). Drop-in `02-CLASSIFICATION.json` ready for Phase 3 to lift into marketplace.json plugin `skills` arrays.
- [x] All 13 topical groups implemented in `.claude-plugin/marketplace.json` cherry-picking specific skills from `yaklang/hack-skills` via the `skills` array (Phase 3, 2026-05-22). `hack-skills-routers` intentionally excluded per the grouping-axis constraint below. 95 skills exposed across 13 plugins.
- [x] Each topical group is independently installable and limits the session to its curated 8–15 (or sized-with-reason / catch-all) skills (Phase 3, smoke-tested via `hack-skills-mobile` install→details→uninstall; schema-identical for all 13 per drift-check universal-quantifier).
- [x] Marketplace published and live at `github.com/SpencerPresley/hack-skills-marketplace` (default branch `main`, public visibility; user confirmed live install works 2026-05-22).
- [x] v2.0 plugin mechanism end-to-end validated: `hack-skills-router` sidecar (in-repo authored, relative-path `source`) installs from the local marketplace, both hooks register (`claude plugin details` reports `Hooks (2)  SessionStart, UserPromptSubmit`), both stub markers (`[Phase 1 stub] SessionStart hook fired.`, `[Phase 1 stub] UserPromptSubmit hook fired.`) are observable in Claude's session context after a session boundary, and the sidecar coexists with a v1 topical plugin (`hack-skills-auth-bypass`) without conflict (Phase 1 spike, 2026-05-22 — see `01-VERIFICATION.md`). Real hook content + router SKILL body land in Phases 2–3.
- [x] Router `SKILL.md` provides hybrid routing (static signal table + model-reasoning fallback) and references `patterns/` + `examples/` sub-files for progressive disclosure (Phase 2, 2026-05-22). SKILL.md body finalized at 89 lines across 7 D-12 sections (when-to-use, trust model, hybrid routing strategy, 3-step operating model, plugin-availability handling, boundary conditions quick reference, workflow examples cross-ref); frontmatter respects dual-cap (224-char first paragraph ≤ 250 cap, 844-char total ≤ 1024 cap); zero STUB markers. Progressive-disclosure sub-files: `patterns/routing-tables.md` (13 plugin-keyed sections, 35 signal→deep-skill rows, 6 dual-load rules, plugin-recommendation template, all names byte-exact vs `marketplace.json`); `patterns/expert-intuitions.md` (8 upstream intuitions w/ Lede + Mechanism + Example, MIT attribution to yaklang/hack-skills); `examples/workflow-walkthroughs.md` (4 worked traces in locked D-01 order). Manual smoke check of runtime auto-invocation persists in `02-HUMAN-UAT.md` until run.

### Active

v2.0 milestone scope — see `.planning/REQUIREMENTS.md` for the REQ-ID-tagged enumeration:

- [ ] Sidecar `hack-skills-router` plugin authored in repo (`plugins/hack-skills-router/`) with valid `plugin.json`, referenced from `marketplace.json` via relative-path `source`.
- [ ] `SessionStart` hook fires once per session, injecting trust gate + operating model + expert-intuitions snapshot.
- [ ] `UserPromptSubmit` hook fires only on prompts matching the security-context regex, injecting the routing nudge.
- [ ] Live validation: install `hack-skills-router` against published v2 marketplace, verify hooks fire, verify routing decisions land on existing topical plugins, verify "plugin not installed" recommendation flow.

### Out of Scope

- **Upstream PR to `yaklang/hack-skills`** — Sibling effort tracked separately in `docs/PR-PLAN.md`. This GSD project only covers the personal marketplace.
- **Modifying upstream skill files** — `yaklang/hack-skills` is read-only inspiration. Curation happens via marketplace cherry-picking, never edits.
- **Auto-sync / live tracking from upstream** — Snapshot consumption is fine. Manual cache refresh is acceptable.
- **Forking and physically regrouping upstream into subdirectory plugins** — Defeated by `strict: false` + `skills` arrays. The whole partitioning lives in `marketplace.json`.
- **Non-skill components in topical groups** — v1's 13 topical groups remain pure curations of `yaklang/hack-skills`. Hooks and original-authored content live ONLY in the sidecar `hack-skills-router` plugin, not in topical groups. (Updated from v1.0's "no non-skill components anywhere" stance at v2.0 milestone open.)
- **Symlink trees or alternative directory layouts to work around schema limitations** — If verification reveals individual-skill paths don't work, the plan changes; symlink workarounds are explicitly rejected.
- **Forced output template on every security response** ("Testing Phase: X / Signal Route: Y" headers) — Considered during v2 design and rejected as performative for ad-hoc questions; the SessionStart + light-nudge model is the design (see `.planning/specs/2026-05-22-v2-router-design.md` §3 decision 2).
- **Multi-language router triggers** — English only. Upstream's `hack` SKILL.md is bilingual; v2 is not.

## Context

- **Source repo**: `github.com/yaklang/hack-skills` — 102 skill directories under `skills/`, each with `SKILL.md`. Already canonical Claude Code plugin layout.
- **Consumer**: This marketplace serves as idea-fuel for the user's security feature work — not as core tooling, but as a curated reference library activated topically per session.
- **Problem v1 solved**: 102 skill descriptions in every session's system reminder. v1's 13 plugins curate to a per-topic subset, dropping always-on cost from ~10,500 tok to ~900 tok for a typical 9-skill plugin.
- **Problem v2 addresses**: just-the-skills isn't enough for serious security work — the agent skips recon, jumps to exploits, misses boundary conditions. The router adds methodology scaffolding without forcing structure on every response.
- **v1.0 shipped**: 13 topical plugins live at the public marketplace (`github.com/SpencerPresley/hack-skills-marketplace`).
- **Existing artifacts**: `docs/PLAN.md` captures the schema lessons (v1 era). `docs/PR-PLAN.md` covers the upstream PR (out of scope). `.planning/specs/2026-05-22-v2-router-design.md` captures the v2 design.
- **Reference plugins consulted during v2 design**: `simple-but-powerful` (own-repo marketplace pattern), `rust-skills` (canonical hook+router+progressive-disclosure), `oh-my-claudecode` (multi-hook lifecycle, smart context-management patterns).
- **Remote**: `git@github.com:SpencerPresley/hack-skills-marketplace.git` — public, initialized, live.

## Constraints

- **Source immutability**: Never modify files in `yaklang/hack-skills`. All curation happens in this repo's `marketplace.json`.
- **Install command shape**: No `@branch` suffixes — use the default ref. Install commands must be plain `/plugin install <name>@hack-skills-marketplace`.
- **Sync model**: Snapshot consumption only. No tooling around auto-pulling upstream changes.
- **Group sizing**: Target 8–15 skills per group. Beyond ~15 the group pollutes context as much as enabling everything; below ~5 the group probably isn't worth being its own entry.
- **Grouping axis**: Group by skill-content topicality, NOT by yaklang's own categorization. Skills that don't map to any topical bucket probably shouldn't have a group at all.
- **Sidecar pattern (v2.0+)**: The `hack-skills-router` plugin authors original content (router skill + hooks) under `plugins/hack-skills-router/`. Topical plugins remain pure curation of `yaklang/hack-skills`. Hooks and original-authored content do not get added to topical plugins (avoids duplication and preserves v1's selective-activation guarantee).

## Key Decisions

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| Use `strict: false` on every plugin entry | Upstream has no `plugin.json`; `strict: false` makes the marketplace entry the full plugin definition, so we don't need to add one. | ✓ Validated (Phase 1) |
| Cherry-pick skills via the `skills` array per plugin entry | Documented as a valid marketplace-entry field. Lets one source repo back N differently-scoped plugins. | ✓ Validated (Phase 1) — works ONLY when paths sit at the root of the cloned source (not nested under `./skills/`). See git-subdir decision below. |
| **Use `git-subdir` source descriptor with `path: "skills"` (NOT plain `github` source)** | Phase 1 found that `source: { source: "github", repo: "yaklang/hack-skills" }` ignored the `skills` array — `claude plugin details` reported all 102 upstream skills and ~10,503 always-on tokens. Working precedents (wondelai-skills, oracle/netsuite-suitecloud-sdk) all clone content such that skill dirs land at the source root. `git-subdir` with `path: "skills"` sparse-clones only `yaklang/hack-skills`'s `skills/` subdir, making each skill directory addressable as `./<skill-name>` from the source root. | ✓ Validated (Phase 1) — see `.planning/phases-archive-v1.0/01-schema-verification/01-VERIFICATION.md` |
| Multiple plugin entries share `yaklang/hack-skills` as their `source` | Duplicate-detection is on `name`, not `source`. Per-plugin caching means N entries → N separate clones; storage is small for a text-only repo. | ✓ Validated (Phase 1) — `~/.claude/plugins/cache/hack-skills-marketplace/` contains a parallel `<plugin-name>/<sha>-<path-hash>/` subdir per installed plugin; cache slot tokens include the path-hash suffix unique to `git-subdir` clones, but no collision across plugins sharing the same source SHA. |
| Group by skill-content topicality, not yaklang's categorization | Optimized for selective topical activation per-session, not as a general-purpose mirror. Yaklang's structure isn't optimized for that usage. | ✓ Validated (Phase 3) — 13 topical plugins shipped; upstream's 7 router skills excluded as non-topical. |
| Treat upstream PR as a separate effort | The PR is minimal and diplomatic (single-bundled-plugin); the personal marketplace is opinionated and grouped. Conflating them confuses both. | ✓ Good |
| Verify the 3 open questions before building out all groups | A "no" on Open Question 1 (individual-skill addressing) changes the entire approach. Cheap to verify with a 2-group MVP first. | ✓ Done (Phase 1) — required a mid-phase mechanism correction, see git-subdir row above |
| **Sidecar router plugin instead of bundling router/hooks into topical plugins** | Preserves v1's selective-activation guarantee, avoids 13× duplication of router/hook files, keeps maintenance burden on a single file. Cross-topic routing works because router lives outside any single topical plugin. Trade-off accepted: users do `/plugin install` twice (router + topic) instead of once. | — Pending v2.0 implementation |
| **Heavy methodology enforcement (rust-skills forced-output-template style) rejected; redefined-middle hook weight adopted** | Forced output template ("Testing Phase: X / Signal Route: Y" headers) is correctness-check theater for security work and interferes with payload/checklist responses. Per-prompt cost of full rust-skills hook (~600 tok) compounds over a session. The redefined middle (SessionStart for once-per-session scaffolding + UserPromptSubmit for ~75-tok nudge) keeps the valuable parts (trust gating, boundary conditions, routing intelligence) without the bureaucracy. | — Pending v2.0 implementation |

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
*Last updated: 2026-05-22 after v2.0 Phase 2 (router-skill-content) completion. Previous: 2026-05-22 after v2.0 Phase 1 (plugin-mechanism-spike) completion.*
