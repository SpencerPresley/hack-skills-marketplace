# Phase 2: Router Skill + Content - Discussion Log

> **Audit trail only.** Do not use as input to planning, research, or execution agents.
> Decisions are captured in `02-CONTEXT.md` — this log preserves the alternatives considered.

**Date:** 2026-05-22
**Phase:** 02-router-skill-content
**Areas surfaced:** Workflow walkthroughs, Routing table density, Plugin-recommendation tone, Boundary conditions in body

---

## Gray Area Identification

After loading PROJECT.md, REQUIREMENTS.md, ROADMAP.md, STATE.md, `.planning/specs/2026-05-22-v2-router-design.md`, `.planning/HANDOFF-v2-router-exploration.md`, Phase 1 artifacts (`01-VERIFICATION.md`, `01-01-SUMMARY.md`), the current Phase 1 stub `SKILL.md`, the upstream `hack` SKILL.md (cached at `/Users/spencerpresley/.claude/plugins/cache/...`), and `.claude-plugin/marketplace.json` — the design spec was found to lock the vast majority of structural decisions (file layout, section list, attribution chain, hybrid routing pattern, the 8 specific intuitions, the 14-plugin marketplace shape). The remaining gray areas were narrow content/density/tone choices, not architectural ones.

Four were surfaced as a single multiSelect AskUserQuestion.

---

## Areas Presented to User

| Area | Description |
|---|---|
| Workflow walkthroughs | Which 3-4 scenarios + depth (terse outline vs. multi-paragraph) for `examples/workflow-walkthroughs.md` |
| Routing table density | `patterns/routing-tables.md` row count: ~30 high-signal cluster rows (spec default) vs. ~60+ per-skill rows |
| Plugin-recommendation tone | When router routes to a skill whose plugin isn't installed (ROUTER-05): terse-imperative ("Run: /plugin install ...") vs. softer/helpful phrasing |
| Boundary conditions in body | Router SKILL.md body quick-ref: names-only bullet list (link out for detail) vs. one-sentence summaries inline |

## User's Choice

**"Honestly really dont have anything too opinionated here, i welcome you to think through and design it"**

User delegated all 4 areas to Claude's discretion. No specific preferences expressed; no follow-up clarifications.

---

## Claude's Discretion — Decisions Made

For each delegated area, Claude made an explicit decision with rationale and recorded it in `02-CONTEXT.md` so downstream agents (researcher, planner) have unambiguous marching orders and do NOT re-ask the user. Summary:

| Area | Claude's Decision | Decision ID in CONTEXT.md |
|---|---|---|
| Workflow walkthroughs — scenario set | Keep all 4 spec-suggested scenarios (admin+JWT, GraphQL+introspection, .env webroot, coupon-reuse). Together they exercise dual-load within one plugin, cross-plugin chain, single-plugin focus, same-plugin multi-category — full pattern coverage. | D-01 |
| Workflow walkthroughs — depth | Medium structured, ~20–25 lines/trace with fixed section headers (Prompt → Phase → Route → Dual-load → Boundary conditions → Next test). NOT terse 5-line outlines (lose teaching value); NOT multi-paragraph narratives (file bloats). | D-02 |
| Routing table density | ~30 rows organized as 13 plugin-keyed sections (one section per v1 topical plugin), 2–3 rows per section. NOT one giant flat table — sectioning by destination plugin makes scanning easier AND embeds the install path next to the signals it serves. | D-03 |
| Routing table — row shape | `\| Signal terms (comma-separated synonyms) \| Deep skill (upstream dir name) \|` inside each section. Section header includes the install command. | D-04, D-05 |
| Routing table — dual-load rules | 5–7 rules as a separate section at the bottom of the file, after per-plugin sections. 5 starter candidates listed in CONTEXT.md D-06 (Recon+auth, SSRF+business, API+auth, web target unclear, auth bypass + JWT/OAuth). Researcher refines. | D-06 |
| Plugin-recommendation tone | Two-line block: `**Recommended deep skill:** <skill> (in `hack-skills-<plugin>`, not currently installed)` + `**Install:** /plugin install hack-skills-<plugin>@hack-skills-marketplace`. NOT one-liner. NOT softer "consider installing" phrasing — directness fits security work. Multiple missing plugins → stacked two-line blocks (NOT comma-list). | D-07 |
| Boundary conditions in body | One-sentence summaries inline for all 8 intuitions (NOT names-only, NOT full paragraphs). Link to `patterns/expert-intuitions.md` for paragraphs + examples. Rationale: intuitions are the router's *core value* per design spec §2.3 — burying them behind a click defeats the purpose; full paragraphs bloat the body. | D-13 |
| Router body voice | Soft heuristic, NOT strict algorithm. Per design spec §3 decision 2 (no forced output template). Phrase as guidance, not as numbered code. | D-14 |
| Catch-all bucket routing | `hack-skills-ai-and-supply-chain` (3 skills) and `hack-skills-forensics-and-misc-recovery` (3 skills) get their own sections in routing-tables.md — first-class destinations, not afterthoughts. Specific signals route to LLM-prompt-injection, ai-ml-security, dependency-confusion, memory-forensics-volatility, etc. | D-16 |

### Decisions also reaffirmed (not strictly delegated but locked for downstream clarity)

| Area | Decision | Source |
|---|---|---|
| Frontmatter shape | Use design spec §5.6 verbatim as starting point. Keyword-stuffed. No `name`/`user-invocable`/`disable-model-invocation` keys (Phase 1 forbid). | D-11 |
| Body section list | Follow design spec §5.7 with boundary-conditions block expanded to one-sentence summaries. ~95–105 line target. | D-12 |
| Attribution chain | 4 file-level attributions (SKILL.md header, expert-intuitions.md header, routing-tables.md header, plugin.json description). NO per-row, per-skill, or per-paragraph attribution. | D-15 |
| Phase 2 scope boundary | Hook scripts (session-start.sh, nudge.sh) and `hooks.json` are NOT touched in Phase 2 — Phase 3 owns. `.claude-plugin/marketplace.json` is also NOT touched — Phase 1 Plan 02 already wrote the 14th entry. | D-17 |
| Expert intuitions order/count | All 8 upstream intuitions, in upstream order, paraphrased + one example each. No additions, no reordering. | D-08 |
| Expert intuitions attribution | File header paragraph only — no per-paragraph attribution. | D-09 |
| Expert intuitions paragraph shape | Lede sentence + 3-5 sentence mechanism explanation + one concrete example per intuition. ~6-10 lines/entry, ~80-100 lines total. | D-10 |

---

## Deferred Ideas

Captured in `02-CONTEXT.md` `<deferred>` section:

- SYNC-01 / SYNC-02 — refresh process for new upstream skills (already in REQUIREMENTS.md Future)
- ROUTER-FUT-01 — hook kill-switch env var (Phase 3 or later)
- ROUTER-FUT-03 — multi-language router triggers (out of scope per REQUIREMENTS.md)
- DISC-01 — README listing each plugin's skill set (orthogonal)
- Per-skill row density (~60+ rows in routing-tables.md) — D-03 went with ~30; revisit post-publish if a missing signal surfaces
- Frontmatter description trimming — researcher confirms Claude Code's frontmatter cap; current default is spec §5.6 verbatim

---

## Areas Open for Researcher/Planner Refinement

Listed in `02-CONTEXT.md` `<decisions>` "Claude's Discretion" subsection. NOT to be re-asked of the user:

- Final wording of the 5–7 dual-load rules (5 starter candidates in D-06)
- Exact signal terms for each row in routing-tables.md (D-03/D-04 set shape; researcher mines `02-CLASSIFICATION.json` `skill_metadata` + cached upstream descriptions for actual terms)
- Exact frontmatter description length if Claude Code has a hard cap (D-11 starting point: spec §5.6 verbatim)

---

*Discussion ended: 2026-05-22 — single user response delegating all surfaced areas; Claude made and recorded explicit decisions in CONTEXT.md*
