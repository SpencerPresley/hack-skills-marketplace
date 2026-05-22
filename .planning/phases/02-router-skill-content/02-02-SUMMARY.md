---
phase: 02-router-skill-content
plan: 02
subsystem: content-authoring
tags: [expert-intuitions, boundary-conditions, paraphrase, attribution, progressive-disclosure, router]

# Dependency graph
requires:
  - phase: 01-plugin-mechanism-spike
    provides: parent skill directory `plugins/hack-skills-router/skills/hack-skills-router/` with stub SKILL.md
provides:
  - patterns/expert-intuitions.md (8 paraphrased boundary-condition intuitions with file-level attribution)
  - First progressive-disclosure sub-file in this repo (paragraph-style content with H3 entries)
  - Source-of-truth for the 8 Lede strings that SKILL.md body (Plan 02-04) will reuse verbatim inline
affects: [02-04 (SKILL.md body boundary-conditions section reuses these Ledes), 03 (nudge.sh references "expert-intuitions" by name)]

# Tech tracking
tech-stack:
  added: []
  patterns: [progressive-disclosure-sub-file, file-level-attribution-header, paragraph-style-pattern-doc]

key-files:
  created:
    - plugins/hack-skills-router/skills/hack-skills-router/patterns/expert-intuitions.md
  modified: []

key-decisions:
  - "Used blockquote (`>`) form for the attribution header for visual distinction — D-09 permits paragraph form too, but blockquote is the form 02-PATTERNS.md §Pattern 3 modeled (line 431)"
  - "Adapted upstream verbatim ledes into clean single-sentence summaries by replacing the upstream's colon-separated `:` form with em-dash `—` form; this keeps phrasing identical in spirit while reading more naturally as a prose summary that SKILL.md body can reuse inline (per D-13)"
  - "Used the cleaner `**Lede:** / **Mechanism:** / **Example:**` field labels (per PLAN action item 'NO `**Lede (one-sentence summary, matches the body's boundary-condition line):**` style label'); researcher's headings in 02-RESEARCH.md are scaffolding, not production labels"
  - "Copied Mechanism + Example bodies from 02-RESEARCH.md lines 905-941 with no semantic changes — only removed researcher-side meta-labels per PLAN action instructions"

patterns-established:
  - "Pattern: file-level attribution blockquote at top of progressive-disclosure sub-files — `> These ... are paraphrased from yaklang/hack-skills's hack SKILL.md (MIT-licensed). ...` form. Sibling sub-files in this phase will reuse this shape."
  - "Pattern: H3-keyed entries with `**Lede:** / **Mechanism:** / **Example:**` field labels (no compound labels). Each entry ~6-10 lines."

requirements-completed: [ROUTER-03]

# Metrics
duration: 7min
completed: 2026-05-22
---

# Phase 2 Plan 02: Expert Intuitions — Boundary Conditions Summary

**8 paraphrased boundary-condition intuitions with file-level MIT attribution at `patterns/expert-intuitions.md`, ready for on-demand load from the router body's "Boundary conditions" section.**

## Performance

- **Duration:** 7 min
- **Started:** 2026-05-22T17:27:00Z
- **Completed:** 2026-05-22T17:34:12Z
- **Tasks:** 1
- **Files created:** 1

## Accomplishments

- Created `plugins/hack-skills-router/skills/hack-skills-router/patterns/expert-intuitions.md` (67 lines, within D-10's ~80-100 line target band and the plan's 60-200 acceptance window).
- Authored 8 H3 entries (`### Intuition 1:` … `### Intuition 8:`) in strict upstream order (D-08 — no reordering, no additions, no removals).
- Each entry contains: a single-sentence **Lede** (adapted from the upstream verbatim line into clean prose that SKILL.md body can reuse inline), a 3–5 sentence **Mechanism** paragraph paraphrased from upstream + researcher's pre-draft (02-RESEARCH.md lines 905–941), and a concrete **Example** copied from the researcher's pre-drafted example slots.
- Added file-level attribution blockquote citing `yaklang/hack-skills`, the MIT license, and the design-spec §11 attribution chain (D-09 + D-15).
- Honored all critical constraints: English only (no CJK carry-over from upstream's bilingual original), no per-entry attribution annotations (attribution is file-level only), zero clickable markdown links to sibling sub-files (Pitfall 5 — `patterns/routing-tables.md` and `examples/workflow-walkthroughs.md` are not linked).

## Task Commits

1. **Task 1: Author patterns/expert-intuitions.md — 8 entries (Lede + Mechanism + Example) in upstream order with file-level attribution** — `c3f819a` (feat)

Atomic commit; no TDD splits.

## Files Created/Modified

- `plugins/hack-skills-router/skills/hack-skills-router/patterns/expert-intuitions.md` — created (67 lines). Progressive-disclosure sub-file with file-level attribution header + 8 H3 entries (Lede + Mechanism + Example fields per entry).

## Decisions Made

- **Attribution header is a blockquote** (`>`), not a plain paragraph. D-09 says "header paragraph" without specifying blockquote vs plain; 02-PATTERNS.md §Pattern 3 (line 431) modeled the blockquote form, and that's what shipped — the `>` glyph makes the attribution visually distinct from the first H3 entry, which helps when the file is rendered in Markdown viewers.
- **Lede phrasing adapted from upstream's colon form to em-dash form.** Upstream ledes are `"<short-form claim>: <expansion>"` (e.g., "BOLA is fundamentally 'authenticated but unauthorized': replaying with account A/B switching is critical."). The Lede field needs to read as a single-sentence prose summary that SKILL.md body can lift verbatim inline (D-13). Replaced `:` with `—` to produce a single-em-dash sentence (e.g., "BOLA is fundamentally 'authenticated but unauthorized' — replaying with account A/B switching is critical."). Semantic content is preserved; only punctuation changes. This makes the Ledes inline-friendly without losing fidelity to upstream.
- **Field labels use the cleaner `**Lede:** / **Mechanism:** / **Example:**` form** (per PLAN action item). 02-RESEARCH.md uses compound labels like `**Upstream lede (verbatim):**` and `**Example slot (concrete):**` as research scaffolding; the production file drops the meta-language per the PLAN's explicit instruction (line 166 of the plan: "NO `**Lede (one-sentence summary, matches the body's boundary-condition line):**` style label").
- **Mechanism and Example bodies copied from researcher's pre-draft with no semantic changes.** The researcher pre-paraphrased every Mechanism and authored every Example concrete in 02-RESEARCH.md lines 905-941; the executor's job per the plan was to drop those in, not re-paraphrase. Only the meta-label scaffolding was removed.

## Deviations from Plan

None — plan executed exactly as written. All 10 acceptance probes passed on first run.

## Issues Encountered

None.

## User Setup Required

None — no external service configuration required.

## Verification — All 10 Probes PASS

| # | Probe | Result |
|---|-------|--------|
| 1 | File exists at canonical sidecar path | PASS |
| 2 | H1 title `# Expert Intuitions ...` present | PASS |
| 3 | Attribution header cites yaklang/hack-skills, MIT, design spec §11 (3 markers) | PASS |
| 4 | Exactly 8 `### Intuition N:` H3 entries | PASS (count=8) |
| 5 | Each of 1..8 appears exactly once (no duplicates) | PASS |
| 6 | 8 Lede + 8 Mechanism + 8 Example field labels (24 total) | PASS |
| 7 | No clickable markdown links to `routing-tables.md` or `workflow-walkthroughs.md` | PASS |
| 8 | No CJK / Chinese characters (English-only constraint) | PASS (Perl Han probe) |
| 9 | File length 60–200 lines (D-10 target ~80–100) | PASS (67 lines) |
| 10 | Intuitions in upstream order 1..8 (D-08) | PASS |

## Self-Check: PASSED

Created file verified to exist:
- `/Users/spencerpresley/code/hack-skills-wip/hack-skills-marketplace/.claude/worktrees/agent-a037e27a8fe766233/plugins/hack-skills-router/skills/hack-skills-router/patterns/expert-intuitions.md` — FOUND

Task commit verified to exist:
- `c3f819a` (feat(02-02): author patterns/expert-intuitions.md) — FOUND in `git log`

All claims in this summary are backed by on-disk artifacts and committed history.

## Next Phase Readiness

**Within Phase 2:**
- Plan 02-04 (SKILL.md body) can now reference `patterns/expert-intuitions.md` from the "Boundary conditions" section. Each of the 8 inline one-sentence summaries the body will use should be byte-identical to the corresponding `**Lede:**` line in this file (cross-file consistency check in `<verification>` block of this plan).
- Plan 02-01 (routing-tables.md) is unaffected — these are sibling progressive-disclosure files with no link dependencies between them (Pitfall 5 prohibition is satisfied on this end).

**Cross-phase:**
- Phase 3's `nudge.sh` will mention the "expert-intuitions" file by name (per design spec §5.5). The router body will surface 2–3 of these 8 boundary conditions on relevant prompts; the sub-file content is now in place to back that surfacing.

No blockers, no concerns.

---
*Phase: 02-router-skill-content*
*Completed: 2026-05-22*
