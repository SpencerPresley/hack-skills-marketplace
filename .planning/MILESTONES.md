# Milestones

Project-level history of milestones. Updated at milestone open and milestone complete.

## v1.0 — Topical Pre-Curation (shipped 2026-05-22)

**Goal achieved:** Curate `yaklang/hack-skills` (102 skills) into 13 topically-grouped, individually-enableable plugins so a session's context only carries skills relevant to the current topical area.

**Phases (archived to `.planning/phases-archive-v1.0/`):**
- Phase 1: Schema Verification — verified individual-skill addressing, context isolation, per-plugin caching via 2-group test marketplace; required mid-phase correction from `source: github` to `source: git-subdir` pattern. (4 plans)
- Phase 2: Skill Classification & Taxonomy — read all 102 SKILL.md descriptions; produced 14-bucket taxonomy (11 primary + 3 themed catch-alls) covering all 102 skills exactly once. (2 plans)
- Phase 3: Marketplace Build-Out — generated full `marketplace.json` from classification JSON; 13 plugins shipped (`hack-skills-routers` excluded as non-topical). (1 plan)
- Phase 4: Publish & Live Validation — published to `github.com/SpencerPresley/hack-skills-marketplace`; live install verified by user. (Closed via informal user confirmation rather than formal GSD verify-phase artifacts; v1 is shipped and working.)

**Shipped artifacts:**
- `.claude-plugin/marketplace.json` — 13 plugin entries (95 skills exposed)
- Public repo `github.com/SpencerPresley/hack-skills-marketplace` (default branch `main`, public visibility)
- Install path: `/plugin marketplace add SpencerPresley/hack-skills-marketplace` then `/plugin install hack-skills-<topic>@hack-skills-marketplace`

**What we learned:**
- `source: git-subdir` with `path: "skills"` is the working pattern for cherry-picking individual skill paths from an upstream Claude Code plugin repo whose canonical layout puts skills under `./skills/*/`.
- One source repo can back N differently-scoped plugins; per-plugin caching uses `<sha>-<path-hash>` subdirs so no collision occurs across plugins sharing a source.
- Always-on description cost is ~100 tok per curated skill — selective topical activation drops the always-on tax from ~10,500 (all 102) to ~900 (typical 9-skill plugin).

---

## v2.0 — Router & Hooks (Sidecar) (active, opened 2026-05-22)

**Goal:** Add a sidecar `hack-skills-router` plugin that layers routing intelligence + methodology scaffolding + trust gating on top of v1's 13 topical plugins, without breaking v1.

**Design spec:** `.planning/specs/2026-05-22-v2-router-design.md` (committed `6d9d0ef`).

**Status:** Defining requirements + roadmap. See `.planning/STATE.md` for current phase.

---

*Last updated: 2026-05-22 at v2.0 milestone open.*
