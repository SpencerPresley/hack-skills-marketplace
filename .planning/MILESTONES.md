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

## v2.0 — Router & Hooks (Sidecar) (shipped 2026-05-23)

**Goal achieved:** Added a sidecar `hack-skills-router` plugin layering routing intelligence + methodology scaffolding + trust gating on top of v1's 13 topical plugins, without modifying v1. The 14th marketplace entry (`hack-skills-router`) ships a router skill, a SessionStart hook (full trust + 3-step ops + 8 expert intuitions payload), and a UserPromptSubmit hook with a 522-char security-context matcher regex — all installable via `/plugin install hack-skills-router@hack-skills-marketplace` from the live published marketplace.

**Design spec:** `.planning/specs/2026-05-22-v2-router-design.md`. Pre-design exploration: `.planning/HANDOFF-v2-router-exploration.md`.

**Phases (archived to `.planning/phases-archive-v2.0/`):**
- Phase 1: Plugin Mechanism Spike — stood up the sidecar plugin shell (`plugins/hack-skills-router/`), added the 14th `marketplace.json` entry with relative-path `source`, declared SessionStart + UserPromptSubmit hooks with stub scripts; verified install + co-install with a v1 plugin + stub hook injection. (3 plans, completed 2026-05-22)
- Phase 2: Router Skill + Content — authored the production router `SKILL.md` (7-section body) + 3 progressive-disclosure sub-files: `patterns/routing-tables.md` (13 plugin-keyed sections, 35 routing rows, 6 dual-load rules), `patterns/expert-intuitions.md` (8 paraphrased intuitions with upstream MIT attribution), `examples/workflow-walkthroughs.md` (4 end-to-end traces). (4 plans, completed 2026-05-22)
- Phase 3: Hook Scripts + Regex — replaced Phase 1 stubs with the real ~250-tok SessionStart payload + ~75-tok UserPromptSubmit nudge + 522-char security-context regex; verified via 6 automated probes + 11-prompt manual UAT (5/5 SessionStart markers, 6/6 positive nudge fires, 4/4 negative no-fires). (2 plans, completed 2026-05-23)
- Phase 4: Live Validation — pushed 64 commits to `github.com/SpencerPresley/hack-skills-marketplace`; verified live `marketplace.json` (14 plugins) + fresh-session install + SessionStart payload landing verbatim in a post-install session. Closed inline (no PLAN/SUMMARY) — SC #5 nudge behavior carried from Phase 3 UAT against byte-identical artifacts on the remote. (1 evidence file, completed 2026-05-23)

**Shipped artifacts:**
- `plugins/hack-skills-router/` — sidecar plugin tree (skill + 2 hooks + 3 progressive-disclosure sub-files)
- `.claude-plugin/marketplace.json` — 14 plugin entries (13 v1 topical + `hack-skills-router`)
- Public repo `github.com/SpencerPresley/hack-skills-marketplace` (default branch `main`, public)
- Install path unchanged from v1: `/plugin marketplace add SpencerPresley/hack-skills-marketplace` then `/plugin install hack-skills-router@hack-skills-marketplace`

**What we learned:**
- Sidecar architecture works cleanly — the v2 router plugin coexists with all 13 v1 plugins in the same marketplace.json without touching them.
- `${CLAUDE_PLUGIN_ROOT}` resolves correctly in hook scripts loaded from a cloned plugin (not just relative-path source).
- The same `session-start.sh` + `nudge.sh` + `hooks.json` files behave identically whether loaded from local relative-path source or from `git clone` of the published repo — source URL never affects cached bytes, so Phase 3's local UAT validly carried over to Phase 4 live validation.
- SessionStart payload tested at ~250 tok lands as ~390 always-on tok per `claude plugin details` (overhead beyond the literal payload string).
- Closing a phase inline (skipping PLAN/SUMMARY scaffold) works when the phase has no implementation work — Phase 4 was "push + verify," not "build." Trying to force it through the full discuss → plan → execute flow would have been ceremony for ceremony's sake.

---

*Last updated: 2026-05-23 at v2.0 milestone close.*
