---
phase: 01-plugin-mechanism-spike
plan: 02
subsystem: marketplace
tags: [marketplace, plugin, json, sidecar, relative-path-source]

requires:
  - phase: project-init
    provides: marketplace.json with 13 v1 entries (git-subdir source)
provides:
  - 14th marketplace entry (hack-skills-router) using relative-path source string
  - Wire-up between Plan 01's in-repo plugin tree and the marketplace catalog
affects: [01-03-PLAN.md, Phase 4 live validation]

tech-stack:
  added: []
  patterns:
    - "Relative-path source string form: source = './plugins/hack-skills-router' (resolves to marketplace root, not .claude-plugin/)"
    - "Single-source-of-truth versioning: version field omitted from marketplace entry; plugin.json owns version (Pitfall 4 fix)"
    - "Append-only edit pattern: all 13 pre-existing v1 entries remain byte-identical, no v1 entry touched"

key-files:
  created: []
  modified:
    - .claude-plugin/marketplace.json

key-decisions:
  - "Omit version field from the marketplace entry (Pitfall 4): plugin.json silently wins if both are set, so single-source-of-truth eliminates the bump-marketplace-but-forget-plugin.json failure mode; design spec §5.1 originally proposed version in both, RESEARCH §Pitfalls + Open Question 1 recommended dropping it from the marketplace entry"
  - "Use relative-path string form for source (not git-subdir object): the router is in-repo authored content, not upstream curation, so the v1 git-subdir pattern does not apply"
  - "Four-field shape (name, source, description, keywords) — no strict (only relevant for upstream-curating plugins with a skills array), no skills array (the plugin's own structure under plugins/hack-skills-router/ is the source of truth)"

patterns-established:
  - "Relative-path in-repo plugin reference: a marketplace entry can point at './plugins/<name>' to install authored content from the same repo as the marketplace catalog. Path starts with './', resolves to repo root (marketplace root), forbids '../'"
  - "Mixed-source-form catalog: 13 git-subdir entries (curating upstream) and 1 relative-path entry (in-repo authored) coexist in the same .plugins array — proves the schema accepts polyglot source forms"
  - "Pitfall 4 hygiene: version belongs in plugin.json only when both files are authored under our control"

requirements-completed: [PLUGIN-01, PLUGIN-02]

duration: <1 min
completed: 2026-05-22
---

# Phase 1 Plan 2: Marketplace catalog wire-up (14th entry) Summary

**Appended `hack-skills-router` as the 14th plugin entry to `.claude-plugin/marketplace.json` using the relative-path `source` string form (`./plugins/hack-skills-router`), omitting `version` per Pitfall 4 — pure append, all 13 v1 entries byte-identical.**

## Performance

- **Duration:** <1 min (82 seconds end-to-end including verification)
- **Started:** 2026-05-22T15:40:06Z
- **Completed:** 2026-05-22T15:41:28Z
- **Tasks:** 1 (of 1)
- **Files modified:** 1 (.claude-plugin/marketplace.json — 6 line insertions, 0 deletions)

## Accomplishments

- Marketplace catalog now declares 14 plugins (was 13). The new entry references the sidecar `hack-skills-router` plugin that Plan 01 is authoring under `plugins/hack-skills-router/` in parallel.
- All 13 v1 topical entries remain byte-identical: their `name`, `source` (git-subdir object form), `strict: false`, `description`, and `skills` arrays are preserved verbatim. Verified via jq assertions on entry count (13 non-router entries) and structural sample (first entry: `name=hack-skills-active-directory-and-windows`, `source.source=git-subdir`, `skills.length=7`).
- Pitfall 4 applied: the new entry has FOUR fields (`name`, `source`, `description`, `keywords`) — the design spec §5.1 originally proposed five (including `version`), but RESEARCH §"Common Pitfalls" §Pitfall 4 + §"Open Questions" §1 explicitly recommended dropping it from the marketplace entry because `plugin.json` silently wins when both are set, which becomes a maintenance trap. Single source of truth = `plugin.json` (authored by Plan 01) owns versioning.

## Task Commits

Each task was committed atomically:

1. **Task 1: Append the hack-skills-router entry to .claude-plugin/marketplace.json** — `5fdce53` (feat)

**Plan metadata commit:** _to follow this SUMMARY commit (per execute-plan.md ordering)_

## Files Created/Modified

- `.claude-plugin/marketplace.json` — Appended 14th entry (`hack-skills-router`) at the end of `.plugins` array. Diff: +6 lines, -0 lines.

## The 14th Entry's Final Shape

```json
{"name":"hack-skills-router","source":"./plugins/hack-skills-router","description":"Routing + scaffolding for hack-skills topical plugins. Adapted from yaklang/hack-skills upstream router.","keywords":["security","pentest","router","hooks","methodology"]}
```

Key shape facts (each verified by the acceptance-criteria jq pass):
- `source` is a **string** (not an object) starting with `./` (relative-path form, NOT git-subdir).
- `version` field is **absent** (Pitfall 4 — plugin.json is single source of truth).
- `strict` field is **absent** (only relevant for upstream-curating plugins with a `skills` array).
- `skills` array is **absent** (the plugin's own structure under `plugins/hack-skills-router/` is the source of truth for its components — Plan 01 authors that tree).
- `keywords` array is exactly `["security", "pentest", "router", "hooks", "methodology"]` (5 entries, matches design spec §5.1).

## Decisions Made

| Decision | Rationale |
|----------|-----------|
| **Omit `version` from the new entry (Pitfall 4)** | Design spec §5.1 set `version: "0.1.0"` in both the marketplace entry and `plugin.json`. Per RESEARCH §Pitfall 4 + Claude Code docs (`plugins-reference#version-management`), the `plugin.json` value silently wins when both are set. This creates a bump-one-forget-the-other failure mode. Dropping it from the marketplace entry leaves `plugin.json` (Plan 01) as the sole authority. The four canonical fields (name, source, description, keywords) match RESEARCH §"Open Questions" §1 recommendation. |
| **Use relative-path string form for `source`** | The 13 v1 entries use `source: { source: "git-subdir", url: ..., path: "skills" }` because they curate upstream `yaklang/hack-skills`. The router is in-repo authored content (no upstream URL), so the relative-path form (`"./plugins/hack-skills-router"`) is correct. Path resolves to marketplace root = repo root. Locked by design spec §3 decision 1 and Phase 1 SC #1. |
| **Four-field shape, in declared order** | `name → source → description → keywords` — matches RESEARCH §"Code Examples" canonical form and design spec §5.1 (minus the dropped `version` field). No `strict` (irrelevant for relative-path source), no `skills` array (the plugin's own structure is the source of truth). |

## Deviations from Plan

None — plan executed exactly as written. The Pitfall 4 fix (drop `version`) was *baked into the plan*, not a runtime deviation — the plan's `<objective>` explicitly states "we OMIT the `version` field from the marketplace entry" with full RESEARCH citation, and the task action enumerates the four required keys.

## Verification Results (all jq acceptance criteria)

| # | Criterion | Result |
|---|-----------|--------|
| AC1 | `jq empty .claude-plugin/marketplace.json` exits 0 (valid JSON) | PASS |
| AC2 | `.plugins \| length` outputs `14` | PASS |
| AC3 | hack-skills-router entry exists (non-empty) | PASS |
| AC4 | `source` = `./plugins/hack-skills-router` | PASS |
| AC5 | `source` field type is `string` (not object) | PASS |
| AC6 | No `version` field on the new entry (Pitfall 4) | PASS |
| AC7 | No `strict` field on the new entry | PASS |
| AC8 | No `skills` field on the new entry | PASS |
| AC9 | `description` starts with `Routing + scaffolding` | PASS |
| AC10 | `keywords` = `["security", "pentest", "router", "hooks", "methodology"]` (exact) | PASS |
| AC11 | 13 non-router (v1) entries still present | PASS |
| AC12 | First v1 entry byte-untouched (`hack-skills-active-directory-and-windows`, `source.source == "git-subdir"`, `skills.length == 7`) | PASS |
| AC13 | Top-level keys preserved exactly (`description, name, owner, plugins`) | PASS |

Plan-level verification (in addition to AC checks):
- `git diff --stat .claude-plugin/marketplace.json` → `1 file changed, 6 insertions(+)` — confirms pure addition.
- Diff insertion lines: 6. Diff deletion lines: 0.
- `plugins/hack-skills-router/` does not yet exist in THIS worktree (expected — Plan 01 runs in a parallel worktree; the orchestrator merges both worktrees before Plan 03's UAT install verification).

## Issues Encountered

None.

## User Setup Required

None — no external service configuration required by this plan. The marketplace catalog edit is a pure in-repo JSON modification.

## Handoff to Plan 03 (UAT install verification)

Plan 03's install resolution path is now wire-complete:
1. **(this plan owns)** CLI reads `.claude-plugin/marketplace.json` → finds entry with `name=hack-skills-router` → sees `source=./plugins/hack-skills-router`.
2. **(Plan 01 owns)** CLI resolves source path relative to repo root → reads `plugins/hack-skills-router/.claude-plugin/plugin.json`.

Plan 03 (UAT) will run, after marketplace re-registration as local path (`claude plugin marketplace remove hack-skills-marketplace; claude plugin marketplace add ./`):
```
/plugin install hack-skills-router@hack-skills-marketplace
```

Expected `claude plugin details hack-skills-router` output (shape, per RESEARCH §"Code Examples"):
```
hack-skills-router 0.1.0
  Routing + scaffolding for hack-skills topical plugins.
  Source: hack-skills-router@hack-skills-marketplace
Component inventory
  Skills (1)  hack-skills-router
  Hooks (2)   (harness-only — no model context cost)
```

The `0.1.0` comes from `plugin.json` (authored by Plan 01), not from the marketplace entry — which is exactly the Pitfall 4 single-source-of-truth posture.

## Self-Check: PASSED

Verification:
- `.claude-plugin/marketplace.json` exists and was modified (1 file, +6/-0 in `git diff --stat`).
- Task 1 commit `5fdce53` exists in `git log --oneline`: `5fdce53 feat(01-02): add hack-skills-router as 14th marketplace entry`.
- All 13 acceptance criteria PASS (full table above).
- All 6 plan-level `<verification>` checks PASS (JSON validity, plugin count = 14, new entry present, diff stat clean, insertions = 6, deletions = 0).
- Plan 01 directory check produced the expected informational warning (parallel wave; Plan 03 is the integration point).

## Threat Flags

None — this plan only modified the marketplace catalog itself, which is the file the threat register's T-02-* mitigations apply to. No new security-relevant surface introduced beyond what the design spec already anticipated. The append-only constraint protecting T-02-01 (tampering of v1 entries) and `jq empty` gate protecting T-02-02 (catalog DoS via malformed JSON) both held — verified by AC11/AC12 and AC1 respectively.

## Next Phase Readiness

- **Wave 1 of Phase 1 status:** This plan (01-02) is complete. Plan 01-01 (plugin tree creation) runs in a sibling worktree under the same wave.
- **Wave 2 readiness (Plan 01-03 UAT):** Once the orchestrator merges both wave-1 worktrees, the marketplace.json edit here will combine with Plan 01's plugin tree to make `/plugin install hack-skills-router@hack-skills-marketplace` a complete end-to-end resolution path. Plan 03 will perform the local-source re-registration + install + coexistence verification.
- **No blockers.** The append is final-shape for Phase 1 — no Phase 2 or Phase 3 follow-up modifies this entry's structure.

---
*Phase: 01-plugin-mechanism-spike*
*Plan: 02*
*Completed: 2026-05-22*
