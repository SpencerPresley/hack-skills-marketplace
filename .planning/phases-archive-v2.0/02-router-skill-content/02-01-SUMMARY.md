---
phase: 02-router-skill-content
plan: 01
subsystem: routing
tags: [routing, signal-table, dual-load, plugin-recommendation, content-authoring, markdown, attribution]

# Dependency graph
requires:
  - phase: 01-plugin-mechanism-spike
    provides: hack-skills-router sidecar plugin scaffolding (plugins/hack-skills-router/ directory + SKILL.md stub at the canonical sidecar path) + canonical marketplace.json with 13 topical plugin entries that this file's section headings and install commands mirror byte-exact
provides:
  - patterns/routing-tables.md sidecar sub-file at the router skill's canonical path
  - 13 plugin-keyed H3 sections covering every v1 topical plugin (one section per marketplace plugin), each with the canonical /plugin install ...@hack-skills-marketplace command embedded as the discovery surface
  - 35 signal -> deep-skill routing rows total (9 sections x 3 rows + 4 sections x 2 rows) sourcing the highest-value routing targets per plugin
  - 6 dual-load rules in Trigger / Load both / Rationale shape, covering recon+auth, API+auth+IDOR, SSRF+business-flow, auth-bypass+JWT/OAuth, business-logic+race-condition, and recon-first fallback for unclear web targets
  - Plugin-recommendation template at the file bottom (single-plugin form + stacked dual-load form) that the router body will reference for the missing-plugin case
affects:
  - 02-02 (router SKILL.md body, which cross-references this file for the routing strategy + plugin-availability sections)
  - 02-03 (workflow-walkthroughs.md, whose scenario rationales reference deep-skill names that must also appear in this file's per-section tables)
  - 02-04 (expert-intuitions.md indirect — both sub-files load on demand from the same router body)
  - 03 (Hook Scripts + Regex — nudge.sh references "the router's routing tables" by name)
  - 04 (Live Validation — install command shape verified here is the exact shape Phase 4 publishes)

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "Progressive-disclosure sub-file pattern: patterns/*.md is loaded on demand from the parent SKILL.md body; no clickable links back to other sub-files (Pitfall 5 — one-level-deep links only)"
    - "Plugin-keyed section structure: H3 heading = byte-exact plugin name, immediate Install line in canonical /plugin install <name>@hack-skills-marketplace shape, two-column Signal terms / Deep skill table — establishes the routing-table shape for any future per-plugin reference document"
    - "File-level attribution: header blockquote names yaklang/hack-skills (MIT) once; no per-row or per-rule attribution annotations (per D-15)"
    - "Dual-load rule shape: H3 'Rule N: <short name>' with three labeled fields (Trigger / Load both / Rationale) — uniform across all 6 rules so the router body can reference them by number"
    - "Plugin-recommendation template: two-line blockquote (Recommended deep skill + Install) with explicit stacked-block form for dual-load cases — never compressed into a comma-line"

key-files:
  created:
    - "plugins/hack-skills-router/skills/hack-skills-router/patterns/routing-tables.md (176 lines) — the signal -> deep-skill routing surface for the router skill"
  modified: []

key-decisions:
  - "Plugin section ordering: alphabetical / marketplace.json order (not by row density or by topic priority) — matches the canonical jq -r '.plugins[].name' output, making future drift checks trivial"
  - "Header attribution uses blockquote (> prefix) rather than plain paragraph — visually distinguishes the file-level provenance line from regular body prose, consistent with patterns/expert-intuitions.md (per the 02-PATTERNS.md §Shared Patterns header text guidance which marks the blockquote form as preferred-but-not-required)"
  - "Adjusted the attribution header to name `yaklang/hack-skills` explicitly alongside the `hack` SKILL.md identifier (interfaces block had only the latter) — the must_haves contains list and key_links pattern grep both require the canonical repo identifier in the file"
  - "Deep-skill column cells are bare directory names (no backticks) per D-04; identifier marking via backticks is reserved for the Install line, dual-load rule skill identifiers, and template examples"
  - "Rule 2 (API testing + auth + IDOR) keeps the rule shape to a 2-skill dual-load and mentions the optional third skill (api-authorization-and-bola) in the Rationale prose rather than as a fourth named field — preserves the uniform Trigger/Load both/Rationale shape across all 6 rules"

patterns-established:
  - "Routing-table sub-file pattern: every section is keyed by a marketplace plugin name and starts with that plugin's install command; signal -> deep-skill rows live below; no relative markdown links to sibling sub-files"
  - "Byte-exact name mirroring: every plugin name and deep-skill name is a direct copy of marketplace.json plugins[].name or plugins[].skills[] (with leading ./ stripped) — verified by jq + comm -23 probes embedded in the task"
  - "Canonical install command shape: /plugin install <plugin-name>@hack-skills-marketplace with no @branch / @main / @v2 suffix anywhere in the file (CLAUDE.md constraint)"

requirements-completed: [ROUTER-02, ROUTER-05]

# Metrics
duration: 3min
completed: 2026-05-22
---

# Phase 2 Plan 01: Routing Tables Sub-File Summary

**patterns/routing-tables.md authored with 13 plugin-keyed sections (35 routing rows), 6 dual-load rules, and the two-line plugin-recommendation template — every plugin/skill name verified byte-exact against marketplace.json**

## Performance

- **Duration:** 3 min
- **Started:** 2026-05-22T17:32:08Z
- **Completed:** 2026-05-22T17:34:50Z
- **Tasks:** 1
- **Files modified:** 1 (created)

## Accomplishments

- Created `plugins/hack-skills-router/skills/hack-skills-router/patterns/routing-tables.md` (176 lines) at the canonical sidecar path — the file the router body will cross-reference from its "Routing strategy" and "Plugin availability" sections
- Authored 13 plugin-keyed H3 sections covering every v1 topical plugin (`hack-skills-active-directory-and-windows` through `hack-skills-web-protocol-attacks` in alphabetical/marketplace.json order); each section starts with the canonical `/plugin install <name>@hack-skills-marketplace` install line so the file doubles as the plugin-discovery surface
- Populated 35 signal -> deep-skill rows total (9 sections × 3 rows + 4 sections × 2 rows for binary-exploitation, crypto-attacks, linux-and-post-exploit, and mobile) — every Deep-skill column entry is a byte-exact copy of a `marketplace.json .plugins[].skills[]` entry (with leading `./` stripped)
- Authored 6 dual-load rules in uniform `Rule N: <name>` / Trigger / Load both / Rationale shape, covering: (1) Recon + auth context, (2) API testing + auth + IDOR, (3) SSRF + business-flow, (4) Auth bypass + JWT/OAuth (same-plugin), (5) Business logic + race condition (same-plugin), (6) Web target signals unclear (recon-first fallback)
- Authored the bottom-of-file `## Plugin-recommendation template` H2 section with both the single-plugin form (using `jwt-oauth-token-attacks` / `hack-skills-auth-bypass`) and the stacked dual-load form (using `business-logic-vulnerabilities` / `hack-skills-web-client-attacks` and `ssrf-server-side-request-forgery` / `hack-skills-server-side-execution`) — both forms verbatim from RESEARCH §"Example 5"
- All 10 verification probes from the plan pass: file existence, attribution header (yaklang/hack-skills + MIT), 13 section count, byte-exact plugin-name diff, 13 install lines in canonical shape, byte-exact deep-skill diff, 35 row count, 6 dual-load rule count, plugin-recommendation template presence with all 3 named examples, zero clickable links to sibling sub-files

## Task Commits

Each task was committed atomically:

1. **Task 1: Author patterns/routing-tables.md with 13 plugin-keyed sections, 6 dual-load rules, and plugin-recommendation template** — `078d371` (feat)

_No metadata commit produced by this executor — the orchestrator commits SUMMARY.md after all worktree agents in the wave complete (parallel execution mode)._

## Files Created/Modified

- `plugins/hack-skills-router/skills/hack-skills-router/patterns/routing-tables.md` — new sub-file (176 lines): header attribution blockquote → 13 plugin-keyed H3 sections (each with install line + 2/3-row signal table) → `## Dual-load rules` H2 with 6 H3 rule blocks → `## Plugin-recommendation template` H2 with single-plugin and stacked dual-load blockquote examples
- `plugins/hack-skills-router/skills/hack-skills-router/patterns/` — new directory created as a child of the existing router skill directory (no `.gitkeep` needed since the directory contains a committed file)

## Decisions Made

- **Attribution header explicitly names `yaklang/hack-skills`.** The verbatim interfaces text in the plan said "upstream `hack` SKILL.md" (matching PATTERNS.md §"Shared Patterns" wording), but the plan's `must_haves.contains` list and `key_links` pattern grep both require the canonical repo identifier `yaklang/hack-skills` to appear in the file. Added it to the attribution header alongside the `hack` SKILL.md identifier — both probes now pass and the attribution chain to upstream is unambiguous.
- **Section ordering follows marketplace.json (alphabetical).** Alphabetical = marketplace.json order in this repo; this is the order any future jq/comm drift check will emit, so matching it eliminates one source of false positives in cross-checks.
- **Deep-skill cells are bare names (no backticks).** Per D-04 — readability-over-formatting in dense tables. Identifier-marking backticks are reserved for the Install line, dual-load rule skill references, and the template examples, where prose is mixed with identifiers.
- **Rule 2 keeps 2-skill shape with optional-third in prose.** RESEARCH proposed "+ optional third" as a separate field; chose to embed it in the Rationale prose to keep all 6 rules visually parallel (Trigger / Load both / Rationale only). Trade-off accepted: the optional third skill is documented less prominently but still discoverable.

## Deviations from Plan

None — plan executed exactly as written. The one in-flight content adjustment (adding `yaklang/hack-skills` to the attribution header alongside the `hack` SKILL.md mention) was driven by the plan's own verification probes / must_haves invariants, not a deviation from intent. The plan's `<interfaces>` block paraphrased the header from PATTERNS.md but the plan's `must_haves.contains` and `key_links.via` lock the canonical-repo identifier explicitly, so resolving the inter-plan discrepancy in favor of the more specific invariant (the must_haves) was the correct read.

## Issues Encountered

None — the file landed first-try modulo the attribution-header adjustment above, which was caught by Probe 2 on the first verification run and fixed with a single Edit (no rewrite). All 10 probes pass.

## User Setup Required

None — content authoring only, no external service configuration.

## Next Phase Readiness

- **Plan 02-02 (router SKILL.md body):** Ready. This file is now the cross-reference target for the body's "Routing strategy" and "Plugin availability handling" sections (per D-12 sections 4 and 6). The body can link to `patterns/routing-tables.md` and trust that the 13 sections, 6 rules, and template all exist at the locked structure.
- **Plan 02-03 (examples/workflow-walkthroughs.md):** Ready. The 4 scenario rationales need to mention deep-skill names that this file's per-section tables also contain; this file commits the canonical wording (e.g., `401-403-bypass-techniques`, `jwt-oauth-token-attacks`, `graphql-and-hidden-parameters`, `insecure-source-code-management`, `business-logic-vulnerabilities`, `race-condition`) so the walkthroughs file can be authored without re-deriving them.
- **Plan 02-04 (expert-intuitions.md):** No direct dependency, but both sub-files share the patterns/ directory now created.
- **Phase 3 (Hook Scripts + Regex):** The canonical install command shape (`/plugin install <name>@hack-skills-marketplace`, no `@branch` suffix) is now committed in 13 places — Phase 3's nudge.sh references "the router's routing tables" by name; this file is the named target.

## Self-Check: PASSED

- File exists: `plugins/hack-skills-router/skills/hack-skills-router/patterns/routing-tables.md` — confirmed via `ls`
- Commit exists: `078d371` (feat(02-01): add patterns/routing-tables.md with 13 plugin-keyed sections) — confirmed via `git log --oneline -1`
- All 10 verification probes from the plan return PASS (re-run after final edit):
  1. File exists at canonical path
  2. Attribution header cites `yaklang/hack-skills` and `MIT`
  3. Exactly 13 plugin-keyed H3 sections
  4. Zero drift vs `jq -r '.plugins[].name'` (no extras, no missing)
  5. Exactly 13 Install lines in canonical shape; no `@branch` suffix
  6. Every column-2 deep-skill matches `jq -r '.plugins[].skills[]?'` (35 rows, zero drift)
  7. Exactly 35 data rows across per-plugin sections
  8. Exactly 6 dual-load rules under `## Dual-load rules`
  9. `## Plugin-recommendation template` present with `jwt-oauth-token-attacks`, `business-logic-vulnerabilities`, and `ssrf-server-side-request-forgery` named examples
  10. Zero clickable links to `expert-intuitions.md` or `workflow-walkthroughs.md`

---
*Phase: 02-router-skill-content*
*Completed: 2026-05-22*
