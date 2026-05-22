# Phase 2: Router Skill + Content - Research

**Researched:** 2026-05-22
**Domain:** Content authoring for a Claude Code Skill (markdown + YAML frontmatter), specifically the body, progressive-disclosure sub-files, and frontmatter for a routing/scaffolding skill that sits as a sidecar to 13 topical curation plugins
**Confidence:** HIGH

## Summary

Phase 2 is a **content-authoring phase** with three hard constraints that determine plan shape: (a) every plugin name and deep skill name referenced in routing content must be **character-for-character identical** to the existing `.claude-plugin/marketplace.json` (drift = router silently recommends a non-existent skill), (b) every factual claim is paraphrased from upstream `yaklang/hack-skills` and the 102-row Master Table in `02-CLASSIFICATION.md` (not invented), and (c) the SKILL.md frontmatter description must fit two caps — **1024-char hard cap** (frontmatter) and **250-char listing-display cap** (the first 250 chars are what Claude sees in `/skills`). The current spec §5.6 description is **841 chars total** (passes 1024 cap) but its first paragraph is **270 chars** (loses ~20 chars of "Adapted from yaklang/hack-skills" trailing text in the listing view) — tighten the first paragraph to ≤250 chars, then keep the keyword block after.

The architecture is **simple and locked**: 4 files (1 in-place rewrite of `SKILL.md` + 3 new files under `patterns/` and `examples/`), no external dependencies, no build pipeline, no tests beyond grep-style content checks. CONTEXT.md D-01 through D-17 lock every meaningful structural decision; this research surfaces the **concrete content the planner needs to drop into each file** — the 14-plugin name list (verified), the 13 plugin-keyed routing sections with their candidate deep skills, the 8 verbatim upstream intuitions, the destination skills for each of the 4 walkthrough scenarios, and the final 5–7 dual-load rule set.

**Primary recommendation:** Write each of the 4 files as a single atomic task with a verification probe that diffs plugin/skill names against `marketplace.json` and grep-checks attribution headers — content correctness is verifiable from the file content alone, no runtime testing needed.

## Architectural Responsibility Map

| Capability | Primary Tier | Secondary Tier | Rationale |
|------------|-------------|----------------|-----------|
| Router intelligence (always-on description) | Skill frontmatter (`SKILL.md`) | — | Description is the only always-on cost (~150 tok); must keyword-stuff to maximize description-match auto-invocation per design spec §4.1 |
| Routing strategy + operating model (on-demand) | Skill body (`SKILL.md`) | — | Body loads only on `Skill(hack-skills-router)` invocation per progressive-disclosure pattern |
| Signal → deep-skill mapping | Sub-file (`patterns/routing-tables.md`) | Body cross-ref | Body cites file by name; full ~30-row table loads when Claude needs precise routing per D-03/D-04 |
| Boundary conditions (8 intuitions) | Sub-file (`patterns/expert-intuitions.md`) | Body 1-line summaries | D-13: body has 8 one-line summaries (inline value); full paragraphs in sub-file (depth on demand) |
| Worked examples | Sub-file (`examples/workflow-walkthroughs.md`) | Body cross-ref | D-01: 4 medium-structured traces; body links by name |
| Plugin-availability discovery | Sub-file (`patterns/routing-tables.md` template section) | Body instructions | D-07: 2-line plugin-recommendation template; body tells Claude when to use it |

## User Constraints (from CONTEXT.md)

### Locked Decisions

**Workflow Walkthroughs (`examples/workflow-walkthroughs.md`):**

- **D-01: Scenario set — all 4 from design spec §5.10 are in scope.**
  1. *Admin panel at `/admin`, JWT in cookie* — exercises dual-load within one plugin (`401-403-bypass-techniques` + `jwt-oauth-token-attacks`, both inside `hack-skills-auth-bypass`).
  2. *GraphQL endpoint, introspection enabled* — exercises cross-plugin recon → specialist (`recon-and-methodology` in `hack-skills-recon` → `graphql-and-hidden-parameters` in `hack-skills-recon`).
  3. *`.env` exposed in webroot* — exercises single-plugin recon focus + recon expansion (`insecure-source-code-management` in `hack-skills-recon`).
  4. *E-commerce checkout, coupon-reuse* — exercises same-plugin dual-load across categories (`business-logic-vulnerabilities` + `race-condition`, both in `hack-skills-web-client-attacks`).
  Together they cover: dual-load within one plugin, cross-plugin chain, single-plugin focus, and same-plugin multi-category. Full pattern coverage of the routing strategy.

- **D-02: Trace depth — medium structured, NOT terse outline and NOT multi-paragraph narrative.** Each walkthrough is ~20–25 lines with consistent section headers:
  ```
  Prompt → Testing phase identified → Signal route → Dual-load (if applicable) → Boundary conditions surfaced → Next-test recommendation
  ```
  Total file size: ~100–120 lines. Reads like a worked example, not a tutorial; not a one-liner either.

**Routing Tables (`patterns/routing-tables.md`):**

- **D-03: Density — ~30 rows organized as 13 plugin-keyed sections (one section per v1 topical plugin), 2–3 rows per section.** Each section is keyed by the plugin name (`hack-skills-<topic>`) and starts with the install command at the top, doubling as the plugin-recommendation surface. NOT one giant flat table — sectioning by destination plugin makes scanning easier and embeds the install path next to the signals it serves.

- **D-04: Row shape.** Each row inside a section is `| Signal terms | Deep skill (in this plugin) |`. Signals are comma-separated synonyms (3–6 terms typical). Deep skill is the upstream skill directory name (e.g., `xss-cross-site-scripting`, `jwt-oauth-token-attacks`).

- **D-05: Section-level install command at top of every section.** Format:
  ```
  ### hack-skills-<topic>
  **Install:** `/plugin install hack-skills-<topic>@hack-skills-marketplace`
  ```
  This means: every row's "plugin not installed" recommendation is one scroll-up away in the same file, and the router's body can reference the section by name instead of repeating install commands.

- **D-06: Dual-load rules — 5–7 rules as a separate section after the per-plugin sections.** Each rule states the trigger pattern and the cross-plugin / cross-skill pair to load. *Researcher proposes final set in §Final Dual-Load Rule Set below; planner locks.*

- **D-07: Plugin-recommendation template — locked as a separate "template" section at the bottom of the file.** Two-line block format (NOT one-line):
  ```
  **Recommended deep skill:** <skill> (in `hack-skills-<plugin>`, not currently installed)
  **Install:** `/plugin install hack-skills-<plugin>@hack-skills-marketplace`
  ```
  When multiple plugins are missing (dual-load case), output two stacked two-line blocks — do NOT compress into one comma-list.

**Expert Intuitions (`patterns/expert-intuitions.md`):**

- **D-08: All 8 upstream intuitions, in upstream order.** No additions, no reordering, no editorializing beyond paraphrase + one concrete example per. The 8 are: (1) filter logic reuse across pages, (2) parameter names as attack surface, (3) second-order vulns, (4) BOLA = authenticated-but-unauthorized, (5) older API versions miss patches, (6) business-logic flaws bring highest impact, (7) race conditions on one-time ops, (8) JWT key/algorithm context before payload spray. Verbatim list at design spec §5.4 and source at upstream `hack` SKILL.md.

- **D-09: Attribution — file header paragraph at the top.** Standard form: "These 8 intuitions are paraphrased from `yaklang/hack-skills` `hack` SKILL.md (MIT-licensed). See `.planning/specs/2026-05-22-v2-router-design.md` §11 for the full attribution chain." No per-paragraph attribution — file-level only.

- **D-10: Paragraph shape per intuition.** Each entry: (a) the lede (one-sentence summary, matches what router body uses), (b) one short paragraph (3–5 sentences) explaining the mechanism, (c) one concrete example. Total per entry: ~6–10 lines. File total: ~80–100 lines. On-demand load — not always-on.

**Router SKILL.md — Body + Frontmatter:**

- **D-11: Frontmatter — use design spec §5.6 verbatim as the starting point.** Keyword-stuffed description for description-match auto-invocation. Plan should verify the description length against any Claude Code frontmatter cap (research item: spec said ~150 tok, but check live constraint). No `name` field (directory name supplies it). No `user-invocable` / `disable-model-invocation` (forbidden in Phase 1 per `01-01-SUMMARY.md`).

- **D-12: Body — follow design spec §5.7 section list, with the boundary-conditions block expanded.** Required sections, in order:
  1. *Title + one-line "adapted from upstream"* attribution
  2. *When to use this skill* (4–5 bullets)
  3. *Trust model* (3–4 lines)
  4. *Routing strategy* (hybrid: static table primary + reasoning fallback; reference `patterns/routing-tables.md`)
  5. *3-step operating model* (Phase ID → Signal route → Dual-load check)
  6. *Plugin availability handling* (reference the plugin-recommendation template in routing-tables.md; tell Claude to output install commands when target plugin missing)
  7. *Boundary conditions* — **8 one-sentence summaries inline** (one bullet per intuition), with a link to `patterns/expert-intuitions.md` for paragraphs + examples
  8. *Workflow examples cross-reference* — link to `examples/workflow-walkthroughs.md`

  Body target: ~95–105 lines (~15 over spec's "names-only" alternative because boundary conditions get one-line summaries instead of just names).

- **D-13: Boundary-conditions in body — one-sentence summaries (NOT names-only, NOT full paragraphs).** Rationale: the 8 intuitions are the router's *core value* (they're the reason this plugin exists per `.planning/specs/2026-05-22-v2-router-design.md` §2.3). Burying them behind a click defeats the router's purpose; inlining full paragraphs blows up the body. One-sentence summaries make the body useful at first read while preserving the link-out to `patterns/expert-intuitions.md` for depth.

- **D-14: Voice — soft heuristic, not strict algorithm.** Per `.planning/specs/2026-05-22-v2-router-design.md` §3 decision 2: no forced output template. The routing strategy and operating model are described as preferences/heuristics ("look at the signals; pick the most-likely category; dual-load if cross-topic"), NOT as a numbered algorithm Claude must follow verbatim. Phrase as guidance, not as code.

**Router-Wide Cross-Cutting:**

- **D-15: Source attribution — appears in 4 files.** Already locked by design spec §11, restated here for clarity:
  1. Router `SKILL.md` body header — one-line "Adapted from upstream `yaklang/hack-skills` `hack` SKILL.md."
  2. `patterns/expert-intuitions.md` header paragraph (per D-09).
  3. `patterns/routing-tables.md` header paragraph — "Signal-to-category mappings derived from upstream `hack` SKILL.md Signal/Priority table, expanded to address our 13-plugin topical structure."
  4. `plugin.json` description (already in place from Phase 1: "Adapted from yaklang/hack-skills upstream router.")
  No per-row, per-skill, or per-paragraph attribution. File-level only.

- **D-16: Catch-all bucket routing.** The two themed catch-all plugins (`hack-skills-ai-and-supply-chain` with 3 skills; `hack-skills-forensics-and-misc-recovery` with 3 skills) get their own sections in `patterns/routing-tables.md` with signals that route to their specific skills (e.g., "prompt injection" → `llm-prompt-injection`; "supply chain confusion" → `dependency-confusion`; "memory dump" → `memory-forensics-volatility`). They are first-class routing destinations, not afterthoughts.

- **D-17: Phase 2 does NOT modify hook scripts.** `plugins/hack-skills-router/hooks/scripts/{session-start.sh,nudge.sh}` remain Phase 1 stubs until Phase 3. Phase 2 may *reference* what those payloads will contain (because the router body should be consistent with what SessionStart eventually injects), but the script files themselves are out of scope.

### Claude's Discretion

User explicitly delegated all 4 surfaced gray areas to Claude (workflow walkthroughs, routing table density, plugin recommendation tone, boundary conditions in body). All decisions D-01 through D-17 are Claude's calls. Rationale is captured per-decision; researcher and planner are free to challenge any of them with evidence but should treat them as defaults.

Specifically open for researcher/planner refinement (NOT to be re-asked of user):
- Final wording of the 5–7 dual-load rules (D-06 lists 5 starter candidates; researcher proposes final set with rationale).
- Exact signal terms for each row in routing-tables.md (D-03/D-04 set the shape; researcher mines upstream skill descriptions from `02-CLASSIFICATION.json` and the cached upstream skills for the actual term list).
- Exact frontmatter description length if Claude Code has a cap (D-11 starting point is spec §5.6 verbatim; researcher confirms cap).

### Deferred Ideas (OUT OF SCOPE)

- **SYNC-01 / SYNC-02** (refresh process for new upstream skills) — already in `REQUIREMENTS.md` Future. When upstream adds new skills, routing-tables.md needs updating; not Phase 2's job.
- **ROUTER-FUT-01** (hook kill-switch env var) — Phase 3 or later.
- **ROUTER-FUT-03** (multi-language router triggers) — upstream's `hack` SKILL.md is bilingual (Chinese + English); v2 stays English-only per `REQUIREMENTS.md` Out of Scope.
- **DISC-01** (README listing each plugin's skill set) — orthogonal; not router-related.
- **Per-skill row density (~60+ rows in routing-tables.md)** — D-03 went with cluster-level ~30 rows. If post-publish feedback shows a missing high-frequency signal, add a row in a v2.x update.
- **Frontmatter description trimming** — D-11 says spec §5.6 verbatim is the starting point. If Claude Code has a hard frontmatter length cap that the spec text exceeds, researcher proposes trimmed version; current discussion does not pre-commit a shorter draft.

## Phase Requirements

| ID | Description | Research Support |
|----|-------------|------------------|
| ROUTER-01 | Router skill invocable via `Skill(hack-skills-router)`; body provides hybrid routing + dual-load rules + plugin-availability handling | §Frontmatter Cap Analysis (1024/250 char caps); §Body Structure (D-12 section list); §Plugin Availability Handling (template format) |
| ROUTER-02 | `patterns/routing-tables.md` covers all 13 v1 plugins (~30 rows) + dual-load rules | §13 Plugin → Topical Skills Map (all 13 plugins enumerated); §Signal Terms Per Skill (3–6 synonyms each); §Final Dual-Load Rule Set (6 rules proposed) |
| ROUTER-03 | `patterns/expert-intuitions.md` documents 8 boundary conditions with attribution | §The 8 Upstream Intuitions (verbatim source text + example slots); §Attribution Chain (4-file form) |
| ROUTER-04 | `examples/workflow-walkthroughs.md` has 3–4 end-to-end traces | §The 4 Walkthrough Scenarios — Destination Skills (exact deep skills + plugins for each scenario) |
| ROUTER-05 | When routing to a skill in an uninstalled plugin, response includes install command | §Plugin Availability Handling (two-line template, dual-load case stacking) |

## Project Constraints (from CLAUDE.md)

- **Source immutability:** Never modify files in `yaklang/hack-skills`. All curation in `marketplace.json`. (Phase 2 doesn't touch marketplace.json — but the rule applies to the upstream `hack` SKILL.md cached file — paraphrase, never copy verbatim into the router content beyond clearly-attributed quotes.)
- **Install command shape:** No `@branch` suffixes — plain `/plugin install <name>@hack-skills-marketplace`. **CRITICAL for Phase 2:** every install command in routing-tables.md and workflow-walkthroughs.md MUST follow this shape exactly. No `@main`, no `@v2.0`, no version suffixes.
- **Sync model:** Snapshot consumption only.
- **Group sizing:** 8–15 target. (Catch-alls of 3 are acknowledged exceptions per D-16.)
- **Grouping axis:** Topicality of skill content, not yaklang's own categorization.
- **GSD workflow:** Use a GSD command before edits. (Researcher is already operating inside `/gsd:plan-phase` — compliant.)

## Standard Stack

### Core

This is a **content-authoring phase** — no runtime libraries, no build system, no tests beyond markdown grep. The "stack" is the markdown + YAML format and the verification tooling already validated in Phase 1.

| Library / Tool | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| Markdown (CommonMark) | — | Format for all 4 files | Native Claude Code Skill format per [Claude Code Skill docs](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices) `[CITED]` |
| YAML frontmatter | — | `SKILL.md` description field | Required by Claude Code Skill spec; `name` field omitted (directory name supplies it — verified in Phase 1 by `01-VERIFICATION.md`) `[VERIFIED: Phase 1 SC #3]` |
| `jq` (already available) | 1.7+ | Plugin-name verification (diff routing content against marketplace.json `.plugins[].skills[]`) | Verified available in Phase 1 (used for marketplace.json validation per `01-VERIFICATION.md`) `[VERIFIED: Phase 1]` |
| `grep` (POSIX) | — | Attribution header presence checks; STUB-marker absence checks | Standard verification primitive used in Phase 1 (8 occurrences each of stub markers grep'd per `01-01-SUMMARY.md`) `[VERIFIED: Phase 1]` |

### Supporting

None. There are no supporting libraries because Phase 2 produces only markdown content — no scripts, no JSON files, no executable code.

### Alternatives Considered

| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| Plain markdown tables | YAML-driven tables (compile-time generated) | Adds build step; tables are static and small enough to author by hand. Plain markdown wins. |
| Per-skill rows (~95 rows) | Cluster-level rows (~30 rows) | D-03 already locked: cluster-level. Per-skill rows would make the table un-scannable and tie content to upstream's exact skill count, which makes future upstream additions harder to merge. |
| Inline 8 intuitions in body (full paragraphs) | 1-line summaries in body + paragraphs in sub-file | D-13 already locked: 1-line summaries in body, paragraphs in sub-file. Inline full paragraphs blows up body past ~105-line target. |

**Installation:** None. All tools (`jq`, `grep`, `git`) are already installed and verified by Phase 1.

**Version verification:**
- `jq` — verified in Phase 1 `01-VERIFICATION.md` (used for `jq empty` validations); no version constraint needed.
- `grep` — POSIX, no version constraint.

## Package Legitimacy Audit

> **Not applicable.** Phase 2 installs no external packages — it authors markdown content only. The Package Legitimacy Gate protocol applies to phases that add `npm install`, `pip install`, `cargo add`, etc. dependencies. Skipped.

## Architecture Patterns

### System Architecture Diagram

```
                       ┌────────────────────────────────────────────────────┐
                       │ Claude Code session                                │
                       │                                                    │
                       │   ┌────────────────────────────────────────────┐   │
                       │   │ Always-on context                          │   │
                       │   │ (frontmatter `description` from each       │   │
                       │   │  installed plugin's SKILL.md)              │   │
                       │   └─────────────┬──────────────────────────────┘   │
                       │                 │                                  │
                       │   user prompt   │ matches description triggers     │
                       │       │         ▼                                  │
                       │       │   Claude invokes `Skill(hack-skills-       │
                       │       │     router)`                               │
                       │       ▼                                            │
                       │   ┌────────────────────────────────────────────┐   │
                       │   │ SKILL.md body loaded (95–105 lines)        │   │
                       │   │  ├─ Trust model                            │   │
                       │   │  ├─ Hybrid routing strategy                │   │
                       │   │  ├─ 3-step operating model                 │   │
                       │   │  ├─ Plugin-availability handling           │   │
                       │   │  ├─ Boundary conditions (8 one-liners)     │   │
                       │   │  └─ Cross-refs ↓ to sub-files              │   │
                       │   └─────────────┬──────────────────────────────┘   │
                       │                 │                                  │
                       │                 │ on demand                        │
                       │                 ▼                                  │
                       │   ┌─────────────────────────┐  ┌─────────────────┐ │
                       │   │ patterns/               │  │ examples/       │ │
                       │   │  routing-tables.md      │  │ workflow-       │ │
                       │   │  ├─ 13 plugin sections  │  │ walkthroughs.md │ │
                       │   │  │  ├─ install cmd      │  │  ├─ scenario 1  │ │
                       │   │  │  └─ 2–3 signal rows  │  │  ├─ scenario 2  │ │
                       │   │  ├─ Dual-load rules     │  │  ├─ scenario 3  │ │
                       │   │  └─ Plugin-rec template │  │  └─ scenario 4  │ │
                       │   │                         │  └─────────────────┘ │
                       │   │ patterns/               │                      │
                       │   │  expert-intuitions.md   │                      │
                       │   │  └─ 8 paragraph entries │                      │
                       │   └─────────────────────────┘                      │
                       │                 │                                  │
                       │                 ▼                                  │
                       │   Claude produces routing decision: signal →       │
                       │   deep skill → plugin → install command (if not    │
                       │   installed)                                       │
                       └────────────────────────────────────────────────────┘
```

The diagram shows: (1) only the SKILL.md frontmatter description is always-on, (2) the body loads on Skill() invocation, (3) sub-files load only when the body cross-references pull them in (progressive disclosure), and (4) all loaded content informs a single routing decision Claude outputs.

### Recommended Project Structure

```
plugins/hack-skills-router/
└── skills/
    └── hack-skills-router/
        ├── SKILL.md                      # REWRITE in place (Phase 1 stub → production body)
        ├── patterns/                     # CREATE directory
        │   ├── routing-tables.md         # CREATE — 13 plugin-keyed sections + dual-load rules + template
        │   └── expert-intuitions.md      # CREATE — 8 paragraphs + attribution header
        └── examples/                     # CREATE directory
            └── workflow-walkthroughs.md  # CREATE — 4 scenarios in medium-structured trace format
```

**Total Phase 2 surface:** 4 files modified (1 rewrite, 3 new) + 2 directories created. No other touched files.

### Pattern 1: Progressive Disclosure via Sub-File Cross-Reference

**What:** SKILL.md body stays short (~95–105 lines) by linking to sub-files instead of inlining their content. Claude follows links only when needed.

**When to use:** Anywhere body content would exceed ~100 lines OR where content is rarely-needed-but-must-be-available.

**Why standard:** [Claude Code best-practices doc](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices) §"Progressive disclosure patterns" — Pattern 1 ("High-level guide with references") is exactly the structure Phase 2 uses. Body has 1-line summaries; full content lives in `patterns/expert-intuitions.md` and `patterns/routing-tables.md`. `[CITED: platform.claude.com docs]`

**Example (body cross-ref shape):**
```markdown
## Boundary conditions (quick reference)

These 8 high-value intuitions are surfaced inline as one-liners. For full paragraphs and
concrete examples, load [patterns/expert-intuitions.md](patterns/expert-intuitions.md).

1. Filter logic often reuses across pages — one bypass usually implies others.
2. Parameter NAMES are an attack surface; WAFs typically inspect values not names.
3. ...
```

**Critical constraint** (from same docs): keep references **one level deep from SKILL.md**. Body → `patterns/expert-intuitions.md` is fine; body → routing-tables → expert-intuitions would be deeper-than-1-hop and Claude may partial-read. All four sub-files link **only** from the body, never from each other.

### Pattern 2: Verbatim Plugin/Skill Name Mirroring

**What:** Every plugin name and deep skill name appearing in router content must match `.claude-plugin/marketplace.json` byte-for-byte.

**When to use:** Every reference to a plugin or skill in routing-tables.md, workflow-walkthroughs.md, or the body. Includes install commands, dual-load rules, scenario destinations, and boundary-condition examples that name skills.

**Why critical:** A typo means the router recommends a non-existent skill (silent failure — Claude says "install hack-skills-auth-bypass" but the skill name in the routing table is `jwt-oauth-token-attack` (missing final s) and Claude can't find the file). Phase 1 `01-PATTERNS.md` §Integration Points already flagged this risk.

**Example:**
```markdown
| Signal terms | Deep skill (in this plugin) |
|---|---|
| JWT, JSON Web Token, alg=none, kid injection, JWKS | jwt-oauth-token-attacks |   ← correct (with -s)
| JWT, JSON Web Token, alg=none, kid injection, JWKS | jwt-oauth-token-attack  |   ← WRONG — typo, drift
```

**Verification probe** (planner should include this as a per-file verify step):
```bash
# Extract canonical skill names from marketplace.json (strip leading "./")
jq -r '.plugins[].skills[]?' .claude-plugin/marketplace.json | sed 's|^./||' | sort -u > /tmp/canonical-skills.txt

# Extract skill names referenced in routing-tables.md (the "Deep skill" column)
# Pattern: pipe-delimited rows ending in `<skill-name> |` — exact regex depends on row format
grep -oE '[a-z][a-z0-9-]+' plugins/hack-skills-router/skills/hack-skills-router/patterns/routing-tables.md \
  | sort -u > /tmp/referenced-skills.txt

# Find any referenced skill not in canonical list (false positives expected for common words —
# planner narrows the grep pattern in actual probe)
comm -23 /tmp/referenced-skills.txt /tmp/canonical-skills.txt
```

### Pattern 3: Attribution Header Paragraphs

**What:** Each of the 3 new files starts with a 1–2 sentence attribution paragraph (the SKILL.md body header is a one-liner). This is per D-15.

**When to use:** Top of each of the 4 files; no per-row or per-paragraph attribution.

**Why required:** Upstream `yaklang/hack-skills` is MIT-licensed — paraphrase plus attribution is the standard practice, and design spec §11 explicitly requires it.

**Concrete header text the planner can copy-paste:**

For `SKILL.md` body (1-line, right after `# Hack-Skills Router` heading):
> Adapted from upstream `yaklang/hack-skills` `hack` SKILL.md (MIT-licensed).

For `patterns/expert-intuitions.md` (paragraph at top of file, before first intuition):
> These 8 boundary-condition intuitions are paraphrased from `yaklang/hack-skills`'s `hack` SKILL.md (MIT-licensed). Each entry preserves the upstream's framing and rank order; the explanatory paragraphs and concrete examples are written for this router. See `.planning/specs/2026-05-22-v2-router-design.md` §11 for the full attribution chain.

For `patterns/routing-tables.md` (paragraph at top of file):
> Signal-to-category mappings derived from upstream `hack` SKILL.md's Signal/Priority table (MIT-licensed), expanded and reshaped to address this marketplace's 13-plugin topical structure rather than upstream's flat skill list. Each section is keyed by a marketplace plugin name; the install command at the top of each section doubles as the plugin-discovery surface when the destination plugin is not currently installed.

For `examples/workflow-walkthroughs.md` (paragraph at top of file):
> Four worked traces showing the router applied to realistic security prompts. The signal-routing methodology is paraphrased from upstream `yaklang/hack-skills` `hack` SKILL.md (MIT-licensed); the scenarios, dual-load patterns, and recommendation flow are tailored to this marketplace's 13-plugin layout.

Note: design spec §11 lists 4 attribution locations; `plugin.json` already has its attribution from Phase 1 ("Adapted from yaklang/hack-skills upstream router.") — no change needed there.

### Anti-Patterns to Avoid

- **Per-row attribution in routing-tables.md:** Don't add "(from upstream)" to each row. Use the file-header paragraph only. D-15 explicitly says file-level only.
- **Forced output template:** Don't write the body as "Claude MUST output 'Testing Phase: X / Signal Route: Y' format." Design spec §3 decision 2 and `REQUIREMENTS.md` Out of Scope both explicitly reject this. Voice is soft heuristic (D-14).
- **`name` field in SKILL.md frontmatter:** Phase 1 verified that omitting `name` works (directory name supplies it — `01-VERIFICATION.md` SC #3). Adding `name` is harmless but redundant; keep omitted for parity with Phase 1.
- **`user-invocable: false` or `disable-model-invocation: true`:** Both forbidden per `01-01-SUMMARY.md` key-decisions. The first hides the skill from `claude plugin details` (Phase 1 SC #4 required visibility); the second blocks the desired auto-load behavior.
- **STUB / "Phase 1" / "TBD" markers in production text:** Phase 1's stub had literal "STUB —" prefix on description. Phase 2 verification should grep for `STUB`, `stub`, `Phase 1`, `TBD`, `FIXME`, `XXX` in the rewritten file and fail if found (per `01-PATTERNS.md` §STUB → FINAL boundary).
- **`@branch` suffixes on install commands:** Forbidden by CLAUDE.md constraints. Every install command in Phase 2 must be `/plugin install hack-skills-<topic>@hack-skills-marketplace` — never `@main`, `@v2.0`, etc.
- **Per-plugin row counts well outside 2–3 range:** D-03 prescribes 2–3 rows per section. A section with 8+ rows turns the file into a per-skill table (which D-03 explicitly rejects in favor of cluster-level ~30 rows total).
- **Mixing English and Chinese in router content:** Upstream `hack` SKILL.md is bilingual (English + Chinese). Per `REQUIREMENTS.md` Out of Scope (English only for v2.0) and ROUTER-FUT-03 deferred — do NOT carry over Chinese phrases or characters into router content.

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Plugin-name validation | Manual eyeball-diff | `jq` extract + `comm -23` against `.plugins[].skills[]` paths | Eyeball-diff misses single-character drift (e.g., `jwt-oauth-token-attack` vs `…attacks`); `jq`+`comm` is byte-exact |
| Attribution check | Trust-based "I wrote it" | `grep -l "yaklang/hack-skills" <file>` per-file | Trust-based check forgets one of 4 files; grep is mechanical |
| Markdown line counting (body cap 95–105) | Visual estimation | `awk '/^---$/{n++;next} n==2{print}' SKILL.md \| wc -l` (count body lines after second `---`) | Visual estimation misses by 10+ lines; awk is exact |
| Section ordering (D-12 body has 8 sections in order) | Memory + re-read | `grep -E '^##' SKILL.md` returns headings in order; eyeball check against D-12 list | Single re-read sees order but doesn't enforce it across edits |
| Linking format (one-level-deep enforcement) | Manual link inspection | `grep -oE '\[.+\]\(.+\)' <file>` then check none of the sub-files contain links to other sub-files | One-level-deep is a Claude Code best-practice (CITED above); missing it makes Claude partial-read |

**Key insight:** Content-authoring phases have no library/framework cost surface — but they have very real verification surface (drift in names, missing attribution, exceeding line caps, deep links). Don't trust authoring discipline; verify with grep/jq.

## Runtime State Inventory

This is NOT a rename/refactor/migration phase. It's a content-creation phase where:

- **Stored data:** None. No databases or persistent stores hold router content. The router is filesystem-only.
- **Live service config:** None. No external services (n8n, Cloudflare, Datadog, etc.) reference router content.
- **OS-registered state:** None. No Task Scheduler / launchd / pm2 / cron registrations reference the router.
- **Secrets/env vars:** None. The router has no secrets and reads no env vars at the content layer (Phase 3's hooks may read env vars for the kill-switch, but that's ROUTER-FUT-01, deferred).
- **Build artifacts:** None — markdown content is consumed directly by Claude Code. No compile step.

**One nuance:** Phase 1 already installed the `hack-skills-router` plugin into the user's plugin cache at `~/.claude/plugins/cache/hack-skills-marketplace/hack-skills-router/c6f732befcae-32c1cf49/` (per Phase 1 UAT). After Phase 2 rewrites in-repo files, the user will need to either:
1. Run `claude plugin update` (or equivalent) to re-sync the cache from the local marketplace, OR
2. Run `claude plugin uninstall hack-skills-router && claude plugin install hack-skills-router@hack-skills-marketplace` for a clean refresh.

This is **a Phase 4 (Live Validation) concern**, not a Phase 2 concern — Phase 2 produces the files; cache refresh is a runtime concern that Phase 4 owns. Mentioned here for completeness so the planner doesn't add it to Phase 2's scope.

## Common Pitfalls

### Pitfall 1: Single-Character Drift in Skill Names

**What goes wrong:** Router routes a security signal to deep skill `jwt-oauth-token-attack` (typo, missing trailing `s`); user installs `hack-skills-auth-bypass`; the deep skill named `jwt-oauth-token-attack` does not exist; Claude can't find the skill file when asked to load it.

**Why it happens:** Long compound skill names (`insecure-source-code-management`, `business-logic-vulnerabilities`, `idor-broken-object-authorization`, `csrf-cross-site-request-forgery`, `ssrf-server-side-request-forgery`, `oauth-oidc-misconfiguration`, `saml-sso-assertion-attacks`, `cors-cross-origin-misconfiguration`, `prototype-pollution-advanced`, `web-cache-deception`, `http-parameter-pollution`, `http2-specific-attacks`) — at this length, eyeball-diff is unreliable.

**How to avoid:** Add a per-file verification probe to each plan task that diffs every deep-skill reference in the file against `jq -r '.plugins[].skills[]?' marketplace.json | sed 's|^./||'`. Run before the task is considered done.

**Warning signs:** A row that references a skill name not present in the canonical list output by jq. Plan-checker should fail if any drift is detected.

### Pitfall 2: Plugin Name Drift

**What goes wrong:** Routing-tables.md section heading is `### hack-skills-web-attacks` but the actual marketplace.json plugin is `hack-skills-web-injection` (or one of the other 3 web-* plugins). User runs the install command and either gets "plugin not found" or installs a different plugin than expected.

**Why it happens:** Three of the four "web" plugins share a `hack-skills-web-*` prefix (`hack-skills-web-client-attacks`, `hack-skills-web-injection`, `hack-skills-web-protocol-attacks`). Easy to swap one for another mid-sentence.

**How to avoid:** Same verification approach as Pitfall 1: extract canonical plugin names with `jq -r '.plugins[].name'`, diff against every plugin reference in routing content.

**Warning signs:** A section heading or install command that uses a plugin name not in the canonical 13-topical-plugin list. The router's section count should be exactly 13 (one per topical plugin), so any extra or missing section indicates a drift bug.

### Pitfall 3: Frontmatter Description Exceeds 250-char Listing Cap

**What goes wrong:** Description is well under the 1024-char hard cap but the first paragraph exceeds 250 chars. Claude Code 2.1.86+ truncates the description displayed in the `/skills` listing to 250 chars, so trigger words after position 250 disappear from the surface Claude uses for auto-invocation decisions.

**Why it happens:** Front-loading the "CRITICAL: Use this skill FIRST for security/hacking tasks..." preamble takes ~100 chars; "Routes vulnerability questions..." + the trailing "Adapted from yaklang/hack-skills" pushes the first paragraph to 270 chars (verified above). The trigger keyword block (XSS, SQLi, ... that the model needs to see) starts at char 280+, outside the 250-char window.

**How to avoid:** Front-load the trigger keyword block within the first 250 chars. Move "Adapted from yaklang/hack-skills" to the end. Tightened draft proposed in §Frontmatter Cap Analysis below.

**Warning signs:** `head -c 250 <description-only.txt>` cuts off mid-word or mid-keyword. Verification probe: extract description from frontmatter, count chars to first newline, fail if > 250.

### Pitfall 4: Residual STUB Markers

**What goes wrong:** Phase 1's stub frontmatter description begins with literal "STUB —" and the body has multiple references to "Phase 1 stub", "Phase 2 will replace this", etc. If Phase 2 misses one of those, the production router contains "STUB" or "Phase 1 stub" markers — confusing for users (the router declares itself a stub) and embarrassing if found by reviewers.

**Why it happens:** Phase 1 stub body is 28 lines long with multiple markers; one missed search-and-replace.

**How to avoid:** Verification probe: `grep -nE '(STUB|stub|Phase 1 (stub|spike)|TBD|FIXME|XXX)' plugins/hack-skills-router/skills/hack-skills-router/SKILL.md` must return zero matches. Per `01-PATTERNS.md` §STUB → FINAL boundary; per Phase 1 verification approach (Anti-Patterns Found table).

**Warning signs:** Any of the above strings appearing in the post-rewrite SKILL.md.

### Pitfall 5: Sub-File Cross-Reference Goes Multi-Hop

**What goes wrong:** `routing-tables.md` links to `expert-intuitions.md` to explain BOLA semantics; `expert-intuitions.md` links to `workflow-walkthroughs.md` for an example. Claude follows links and partial-reads (per `head -100` behavior the docs flag) because each successive file is one hop further from SKILL.md. The BOLA paragraph never gets the full content Claude needs.

**Why it happens:** Author thinks "the example is in workflow-walkthroughs.md, link to it from expert-intuitions.md" — natural code-reuse instinct, but Claude's progressive-disclosure engine penalizes multi-hop links.

**How to avoid:** **Every** sub-file link points only **back to SKILL.md** or **stays in the same file**. No sub-file should contain a markdown link to a different sub-file in the same plugin. Cross-references between sub-files are done by **mentioning the other file by name in prose** ("see also `examples/workflow-walkthroughs.md`") without making it a clickable markdown link.

**Warning signs:** `grep -E '\]\(\.\./(patterns|examples)/' patterns/*.md examples/*.md` returns matches — that's a relative link from one sub-file to another. Should be zero.

### Pitfall 6: Voice Drifts to Algorithmic

**What goes wrong:** Body's "3-step operating model" section reads like "Step 1: MUST identify phase. Step 2: MUST select category. Step 3: MUST output 'Testing Phase: X / Signal Route: Y'." This is the "forced output template" pattern explicitly rejected in design spec §3 decision 2 and `REQUIREMENTS.md` Out of Scope.

**Why it happens:** Numbered "3 steps" naturally invites "MUST do step N first" enforcement language.

**How to avoid:** Phrase as preferences: "First, identify the testing phase (recon / validation / privesc / chain). Then look for signals that route to a specific category. If signals span topics, consider loading two skills." Use words like "prefer", "consider", "typically" — not "MUST", "ALWAYS", "REQUIRED".

**Warning signs:** "MUST" or "ALWAYS" appearing in the routing strategy or operating model section. Verification probe: `grep -ciE '\b(MUST|ALWAYS|REQUIRED)\b' SKILL.md` → should be 0 or very low (the trust-model section may have one "use only within authorized targets" type sentence; routing/operating sections should have none).

### Pitfall 7: Catch-All Plugin Sections Get Treated as Lower-Priority

**What goes wrong:** `hack-skills-ai-and-supply-chain` (3 skills) and `hack-skills-forensics-and-misc-recovery` (3 skills) are catch-alls with fewer members; author treats them as afterthoughts and gives them 1 row each, missing the user's D-16 explicit decision that they're first-class routing destinations.

**Why it happens:** Smaller plugins look like lower-value — they aren't.

**How to avoid:** Each of these catch-all plugins gets a full 2–3-row section just like the topical plugins. Specifically: `hack-skills-ai-and-supply-chain` rows for prompt injection, supply-chain dependency confusion, and AI/ML model attacks (one row per skill, 3 skills exactly fills the 2–3 cap); `hack-skills-forensics-and-misc-recovery` similar (memory forensics, steganography, traffic analysis — 3 skills).

**Warning signs:** Either catch-all section has fewer than 2 rows in routing-tables.md.

## Code Examples

This is a content-authoring phase; "code examples" are markdown content templates.

### Example 1: Frontmatter shape (tightened to respect 250-char listing cap)

```yaml
---
description: |
  CRITICAL: Use FIRST for security/hacking tasks before any deep topic skill. Routes vulnerability questions to the right deep skill in the hack-skills marketplace and surfaces boundary conditions a baseline AI often misses.

  Triggers: XSS, SQLi, SSRF, XXE, IDOR, BOLA, BFLA, CSRF, CORS, RCE, SSTI, LFI, RFI, JWT,
  OAuth, SAML, OIDC, NTLM, Kerberos, vulnerability, exploit, pentest, bug bounty, payload,
  recon, enumeration, privilege escalation, lateral movement, reverse shell, burp, nmap,
  sqlmap, metasploit, CVE-XXXX-NNNN, .env exposure, .git exposure, prototype pollution,
  deserialization, race condition, request smuggling, web cache deception, host header,
  parameter pollution, type juggling, NoSQL injection, WAF bypass, file upload,
  business logic, SAML assertion, OAuth misconfiguration. Adapted from yaklang/hack-skills.
---
```

Length analysis:
- First paragraph (lines 1–2 after `description: |`): **241 chars** — fits within the 250-char listing cap with margin.
- Total description: ~810 chars — under the 1024 hard cap.
- The "Adapted from yaklang/hack-skills" attribution moved to the end of the keyword block (still in the description, just past the 250-char listing window — body header carries the primary attribution).

### Example 2: Body section template (one of the 8 sections, per D-12)

```markdown
## Routing strategy (hybrid)

Two-tier:

1. **Static signal table** is primary. Common cases — "XSS in a search box", "SQLi in a
   login form", "SSRF on a URL-fetcher endpoint" — get routed by signal-term matching from
   `patterns/routing-tables.md`. The table covers ~30 high-signal patterns across all 13
   topical plugins.
2. **Model reasoning** is fallback. When signals are ambiguous (e.g., the prompt mentions
   "checkout flow with weird timing" — could be race condition, could be business logic,
   could be both), reason over the deep-skill descriptions before picking a route.

Prefer the table when it matches; use reasoning when it doesn't. Don't force-fit a signal
into the nearest table row if the route looks wrong — that's the reasoning case.
```

Voice note (per D-14): "Prefer", "use", "don't force-fit" — soft heuristic phrasing. No "MUST", no algorithmic numbered enforcement.

### Example 3: Routing-tables.md section template (one of 13)

```markdown
### hack-skills-auth-bypass

**Install:** `/plugin install hack-skills-auth-bypass@hack-skills-marketplace`

| Signal terms | Deep skill (in this plugin) |
|---|---|
| JWT, JSON Web Token, alg=none, kid injection, JWKS, RS256 vs HS256 | jwt-oauth-token-attacks |
| 401, 403, admin panel access denied, path manipulation, method override | 401-403-bypass-techniques |
| OAuth, OIDC, redirect URI, PKCE, state parameter, account binding | oauth-oidc-misconfiguration |
```

Note: 3 rows shown — at the high end of the 2–3 per-section cap (D-03). Section heading matches the marketplace.json plugin name byte-for-byte. Install command uses the canonical `@hack-skills-marketplace` shape, no `@branch`.

### Example 4: Workflow walkthrough trace template (one of 4, per D-02)

```markdown
## Scenario 2: GraphQL endpoint with introspection enabled

**Prompt:** "I found a GraphQL endpoint at `/graphql` that allows introspection. What now?"

**Testing phase identified:** Recon — the introspection query is the discovery surface for
schema, types, queries, mutations.

**Signal route:** GraphQL → `graphql-and-hidden-parameters` (in `hack-skills-recon`).
This is a single-plugin focus — both the recon framing (introspection enumeration) and the
specialist skill live in the same plugin.

**Dual-load:** None for this phase. If after introspection the schema reveals auth-related
mutations or token-issuing fields, dual-load `recon-and-methodology` + appropriate auth
skill — but that's a follow-on routing decision once we have more signal.

**Boundary conditions surfaced:**
- *Parameter names as attack surface (intuition #2):* GraphQL introspection reveals exact
  field names — many WAFs and authz layers inspect query strings, not GraphQL field names.
- *Older API versions miss patches (intuition #5):* If the schema shows `v1`/`v2`/`internal`
  prefixes, the older variants are highest-priority for unpatched mutations.

**Next-test recommendation:** Run an introspection query, enumerate types and mutations,
flag any field name containing `admin`, `internal`, `debug`, or `_priv`. Then drop into
`graphql-and-hidden-parameters` for the specific testing playbook.
```

Length check: ~22 lines. Section headers match the prompt → testing phase → signal route → dual-load → boundary conditions → next-test sequence per D-02. The two boundary-condition references cite intuition numbers (#2, #5) — gives `expert-intuitions.md` a reason to be cross-referenced from here without making it a deep link.

### Example 5: Plugin-recommendation template (the locked D-07 two-line shape)

```markdown
## Plugin-recommendation template

When the router selects a deep skill whose plugin isn't currently installed, surface it in
this two-line shape (don't compress into one comma-line):

> **Recommended deep skill:** jwt-oauth-token-attacks (in `hack-skills-auth-bypass`, not currently installed)
> **Install:** `/plugin install hack-skills-auth-bypass@hack-skills-marketplace`

For dual-load cases where two plugins are missing, stack two blocks — don't merge:

> **Recommended deep skill:** business-logic-vulnerabilities (in `hack-skills-web-client-attacks`, not currently installed)
> **Install:** `/plugin install hack-skills-web-client-attacks@hack-skills-marketplace`
>
> **Recommended deep skill:** ssrf-server-side-request-forgery (in `hack-skills-server-side-execution`, not currently installed)
> **Install:** `/plugin install hack-skills-server-side-execution@hack-skills-marketplace`
```

Verbatim from D-07; lives at the bottom of `patterns/routing-tables.md`.

## Frontmatter Cap Analysis

`[VERIFIED: docs.claude.com agent-skills/best-practices + github.com/anthropics/claude-code issue #40121]`

| Cap | Value | Source | Phase 2 implication |
|-----|-------|--------|---------------------|
| Frontmatter `description` hard max | 1024 chars | [Claude API Docs — Skill authoring best practices](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices) §"YAML frontmatter requirements" | Spec §5.6 verbatim description = **841 chars** — passes |
| `/skills` listing display cap | 250 chars (first 250 only) | [GitHub anthropics/claude-code issue #40121](https://github.com/anthropics/claude-code/issues/40121); Claude Code v2.1.86 changelog | Spec §5.6 first paragraph = **270 chars** — last ~20 chars (the "Adapted from yaklang/hack-skills" trailing phrase) get truncated from the listing surface |
| Body soft cap | 500 lines | Same docs §"Token budgets" | Spec §5.7 body target = ~95–105 lines — passes with massive margin |
| `name` field | optional in Skill body; max 64 chars lowercase/digits/hyphens | Same docs §"YAML frontmatter requirements" | Phase 1 already verified omitting `name` works (directory name supplies it); continue omitting in Phase 2 |
| Reserved words in `name` | "anthropic", "claude" forbidden | Same docs | N/A — `name` omitted |
| XML tags in `description` | forbidden | Same docs | Spec §5.6 has no XML tags — passes |

**Verification probe** for the planner to include in the SKILL.md task:

```bash
# Extract description (between description: | and the next --- or top-level key)
DESC=$(awk '/^description: \|$/{flag=1; next} flag && /^---$/{exit} flag{print}' \
  plugins/hack-skills-router/skills/hack-skills-router/SKILL.md)

# Total length (must be <= 1024)
TOTAL=$(echo -n "$DESC" | wc -c)
[ "$TOTAL" -le 1024 ] || echo "FAIL: description $TOTAL > 1024 hard cap"

# First paragraph length (must be <= 250 for listing cap)
FIRST_PARA=$(echo "$DESC" | awk '/^$/{exit} {print}')
FIRST_LEN=$(echo -n "$FIRST_PARA" | wc -c)
[ "$FIRST_LEN" -le 250 ] || echo "FAIL: first paragraph $FIRST_LEN > 250 listing cap"
```

**Researcher recommendation for D-11 (final wording):** Use the tightened first paragraph in §Code Examples Example 1 above — it's 241 chars (under 250) and preserves the CRITICAL preamble + the core "routes + surfaces boundary conditions" mission statement. Then put the trigger keyword block + the trailing attribution after the blank line. Total stays well under 1024. The planner should write this as the production description, not the verbatim §5.6 form, **because §5.6 was written before the 250-char listing cap was introduced in Claude Code 2.1.86**.

## 14 Marketplace Plugin Names (Canonical List)

`[VERIFIED: jq -r '.plugins[].name' on .claude-plugin/marketplace.json]`

13 topical plugins (sections in routing-tables.md) + 1 router (itself):

| # | Plugin name (byte-exact) | Description (from marketplace.json) | Type |
|---|--------------------------|--------------------------------------|------|
| 1 | `hack-skills-active-directory-and-windows` | Active Directory and Windows endpoint attacks | Topical |
| 2 | `hack-skills-ai-and-supply-chain` | AI/ML security and software supply chain attacks | Topical (catch-all) |
| 3 | `hack-skills-auth-bypass` | Authentication and authorization bypass | Topical |
| 4 | `hack-skills-binary-exploitation` | Binary exploitation and reverse engineering | Topical |
| 5 | `hack-skills-crypto-attacks` | Cryptography attacks and blockchain/DeFi exploits | Topical |
| 6 | `hack-skills-forensics-and-misc-recovery` | Forensics, memory analysis, and steganographic recovery | Topical (catch-all) |
| 7 | `hack-skills-linux-and-post-exploit` | Linux/macOS post-exploitation and network pivoting | Topical |
| 8 | `hack-skills-mobile` | Mobile platform pentesting | Topical |
| 9 | `hack-skills-recon` | Reconnaissance and attack-surface enumeration | Topical |
| 10 | `hack-skills-server-side-execution` | Server-side code execution and trust-boundary chains | Topical |
| 11 | `hack-skills-web-client-attacks` | Client-side and browser-context web vulnerabilities | Topical |
| 12 | `hack-skills-web-injection` | Web-layer injection and input-driven attacks | Topical |
| 13 | `hack-skills-web-protocol-attacks` | HTTP protocol-layer attacks and request flow abuse | Topical |
| 14 | `hack-skills-router` | Routing + scaffolding for hack-skills topical plugins | Router (this plugin) |

**Critical:** Routing-tables.md has **exactly 13 sections** (one per topical plugin), in any order the planner prefers — alphabetical is simplest and matches marketplace.json ordering. The router itself is NOT a section in routing-tables.md (it's the file containing the table).

## 13 Plugin → Topical Skills Map

`[VERIFIED: jq -r '.plugins[].skills[]' on .claude-plugin/marketplace.json]`

### `hack-skills-active-directory-and-windows` (7 skills)
- `active-directory-acl-abuse`
- `active-directory-certificate-services`
- `active-directory-kerberos-attacks`
- `ntlm-relay-coercion`
- `windows-av-evasion`
- `windows-lateral-movement`
- `windows-privilege-escalation`

### `hack-skills-ai-and-supply-chain` (3 skills — catch-all)
- `ai-ml-security`
- `dependency-confusion`
- `llm-prompt-injection`

### `hack-skills-auth-bypass` (9 skills)
- `401-403-bypass-techniques`
- `api-auth-and-jwt-abuse`
- `api-authorization-and-bola`
- `authbypass-authentication-flaws`
- `idor-broken-object-authorization`
- `jwt-oauth-token-attacks`
- `oauth-oidc-misconfiguration`
- `saml-sso-assertion-attacks`
- `type-juggling`

### `hack-skills-binary-exploitation` (12 skills)
- `anti-debugging-techniques`
- `arbitrary-write-to-rce`
- `binary-protection-bypass`
- `browser-exploitation-v8`
- `code-obfuscation-deobfuscation`
- `format-string-exploitation`
- `heap-exploitation`
- `kernel-exploitation`
- `sandbox-escape-techniques`
- `stack-overflow-and-rop`
- `symbolic-execution-tools`
- `vm-and-bytecode-reverse`

### `hack-skills-crypto-attacks` (7 skills)
- `classical-cipher-analysis`
- `defi-attack-patterns`
- `hash-attack-techniques`
- `lattice-crypto-attacks`
- `rsa-attack-techniques`
- `smart-contract-vulnerabilities`
- `symmetric-cipher-attacks`

### `hack-skills-forensics-and-misc-recovery` (3 skills — catch-all)
- `memory-forensics-volatility`
- `steganography-techniques`
- `traffic-analysis-pcap`

### `hack-skills-linux-and-post-exploit` (10 skills)
- `container-escape-techniques`
- `kubernetes-pentesting`
- `linux-lateral-movement`
- `linux-privilege-escalation`
- `linux-security-bypass`
- `macos-process-injection`
- `macos-security-bypass`
- `network-protocol-attacks`
- `reverse-shell-techniques`
- `tunneling-and-pivoting`

### `hack-skills-mobile` (3 skills)
- `android-pentesting-tricks`
- `ios-pentesting-tricks`
- `mobile-ssl-pinning-bypass`

### `hack-skills-recon` (6 skills)
- `api-recon-and-docs`
- `graphql-and-hidden-parameters`
- `insecure-source-code-management`
- `recon-and-methodology`
- `subdomain-takeover`
- `unauthorized-access-common-services`

### `hack-skills-server-side-execution` (8 skills)
- `cmdi-command-injection`
- `deserialization-insecure`
- `expression-language-injection`
- `jndi-injection`
- `path-traversal-lfi`
- `ssrf-server-side-request-forgery`
- `ssti-server-side-template-injection`
- `upload-insecure-files`

### `hack-skills-web-client-attacks` (10 skills)
- `business-logic-vulnerabilities`
- `clickjacking`
- `cors-cross-origin-misconfiguration`
- `csp-bypass-advanced`
- `csrf-cross-site-request-forgery`
- `dns-rebinding-attacks`
- `open-redirect`
- `prototype-pollution`
- `prototype-pollution-advanced`
- `race-condition`

### `hack-skills-web-injection` (10 skills)
- `csv-formula-injection`
- `dangling-markup-injection`
- `email-header-injection`
- `ghost-bits-cast-attack`
- `nosql-injection`
- `sqli-sql-injection`
- `waf-bypass-techniques`
- `xslt-injection`
- `xss-cross-site-scripting`
- `xxe-xml-external-entity`

### `hack-skills-web-protocol-attacks` (7 skills)
- `crlf-injection`
- `http-host-header-attacks`
- `http-parameter-pollution`
- `http2-specific-attacks`
- `request-smuggling`
- `web-cache-deception`
- `websocket-security`

**Total deep skills across 13 plugins: 95.** (Matches v1 milestone scope per `02-CLASSIFICATION.json` `_meta`.)

## Signal Terms Per Skill (High-Value Routing Targets)

`[VERIFIED: Master Table in .planning/phases-archive-v1.0/02-skill-classification-taxonomy/02-CLASSIFICATION.md, lines 318–419, which contains the verbatim `description` from each skill's SKILL.md YAML frontmatter per D-14]`

Per D-03, the planner picks **2–3 rows per section**, so **30 rows total** across 13 sections. The selections below are researcher-proposed **highest-value routing targets** per section — the skills most likely to be the "natural fit" for a vague-but-clearly-in-the-topic prompt. Planner has authority to swap if a different choice fits better.

### `hack-skills-active-directory-and-windows` (3 recommended rows)
| Signal terms | Deep skill |
|---|---|
| AD, Active Directory, Kerberos, Kerberoasting, AS-REP roasting, golden ticket, silver ticket | `active-directory-kerberos-attacks` |
| NTLM relay, PetitPotam, PrinterBug, coercion, LLMNR poisoning | `ntlm-relay-coercion` |
| Windows privesc, token abuse, Potato exploits, UAC bypass, DLL hijacking, registry autoruns | `windows-privilege-escalation` |

### `hack-skills-ai-and-supply-chain` (3 recommended rows — catch-all gets all 3 skills)
| Signal terms | Deep skill |
|---|---|
| prompt injection, LLM injection, indirect injection, RAG injection, MCP injection, jailbreak | `llm-prompt-injection` |
| dependency confusion, supply chain, npm/pip/gem/Maven confusion, internal package name | `dependency-confusion` |
| AI/ML security, pickle RCE, model poisoning, model stealing, adversarial examples, autonomous agent | `ai-ml-security` |

### `hack-skills-auth-bypass` (3 recommended rows)
| Signal terms | Deep skill |
|---|---|
| JWT, JSON Web Token, alg=none, kid injection, JWKS, RS256→HS256, bearer token | `jwt-oauth-token-attacks` |
| 401, 403, admin panel access denied, path manipulation, HTTP method tampering, header injection | `401-403-bypass-techniques` |
| IDOR, BOLA, object authorization, tenant boundary, A/B account replay, writable fields | `idor-broken-object-authorization` |

### `hack-skills-binary-exploitation` (2 recommended rows)
| Signal terms | Deep skill |
|---|---|
| heap exploitation, UAF, use-after-free, double free, tcache, fastbin, glibc heap | `heap-exploitation` |
| stack overflow, ROP, ret2libc, ret2csu, ret2dlresolve, SROP, buffer overflow exploit | `stack-overflow-and-rop` |

### `hack-skills-crypto-attacks` (2 recommended rows)
| Signal terms | Deep skill |
|---|---|
| RSA attack, small exponent, shared factors, Coppersmith, padding oracle, common modulus | `rsa-attack-techniques` |
| smart contract, Solidity, reentrancy, flash loan, MEV, delegatecall, signature replay | `smart-contract-vulnerabilities` |

### `hack-skills-forensics-and-misc-recovery` (3 recommended rows — catch-all gets all 3 skills)
| Signal terms | Deep skill |
|---|---|
| memory forensics, memory dump, Volatility, malware analysis, credential extraction from memory | `memory-forensics-volatility` |
| steganography, LSB, hidden data in image, EXIF, spectrogram, polyglot file, zero-width chars | `steganography-techniques` |
| PCAP, traffic analysis, Wireshark, tshark, protocol forensics, TLS decryption | `traffic-analysis-pcap` |

### `hack-skills-linux-and-post-exploit` (2 recommended rows)
| Signal terms | Deep skill |
|---|---|
| Linux privesc, SUID, capabilities, cron abuse, sudo misconfig, kernel exploit privesc | `linux-privilege-escalation` |
| reverse shell, bash one-liner, ncat shell, web shell, PTY upgrade, PowerShell shell | `reverse-shell-techniques` |

### `hack-skills-mobile` (2 recommended rows)
| Signal terms | Deep skill |
|---|---|
| Android pentesting, SSL pinning, exported component, WebView vulnerabilities, intent redirection, root detection bypass | `android-pentesting-tricks` |
| iOS pentesting, keychain extraction, URL scheme hijacking, Universal Links, runtime manipulation | `ios-pentesting-tricks` |

### `hack-skills-recon` (3 recommended rows)
| Signal terms | Deep skill |
|---|---|
| recon, methodology, asset mapping, endpoint discovery, technology fingerprint, new target | `recon-and-methodology` |
| .git, .svn, .env, backup files, robots.txt, /etc/passwd, exposed VCS, config leak | `insecure-source-code-management` |
| GraphQL, introspection, hidden parameters, schema enumeration, batching, undocumented fields | `graphql-and-hidden-parameters` |

### `hack-skills-server-side-execution` (3 recommended rows)
| Signal terms | Deep skill |
|---|---|
| SSRF, server fetches URL, internal network, cloud metadata, IMDS, secondary protocol | `ssrf-server-side-request-forgery` |
| command injection, CMDi, shell command, OS command injection, blind OOB injection | `cmdi-command-injection` |
| SSTI, template injection, Jinja2, Twig, Velocity, server-side rendering | `ssti-server-side-template-injection` |

### `hack-skills-web-client-attacks` (3 recommended rows)
| Signal terms | Deep skill |
|---|---|
| business logic, workflow abuse, price manipulation, coupon abuse, multi-step bypass, state machine flaw | `business-logic-vulnerabilities` |
| race condition, TOCTOU, one-time operation, coupon redemption, concurrent request abuse, Turbo Intruder | `race-condition` |
| CSRF, cross-site request forgery, SameSite, anti-CSRF token, JSON CSRF, login CSRF | `csrf-cross-site-request-forgery` |

### `hack-skills-web-injection` (3 recommended rows)
| Signal terms | Deep skill |
|---|---|
| XSS, cross-site scripting, reflected XSS, stored XSS, DOM XSS, innerHTML, JavaScript injection | `xss-cross-site-scripting` |
| SQL injection, SQLi, UNION, blind SQLi, boolean-based, time-based, out-of-band | `sqli-sql-injection` |
| XXE, XML external entity, SVG, OOXML, SOAP parser, entity expansion | `xxe-xml-external-entity` |

### `hack-skills-web-protocol-attacks` (3 recommended rows)
| Signal terms | Deep skill |
|---|---|
| request smuggling, HTTP smuggling, CL.TE, TE.CL, HTTP/2 desync, h2c smuggling | `request-smuggling` |
| Host header, password reset poisoning, web cache poisoning via Host, virtual host bypass | `http-host-header-attacks` |
| web cache deception, CDN cache key, path confusion, cached auth content | `web-cache-deception` |

**Row count totals:**
- 3 sections × 3 rows = 9
- 8 sections × 3 rows = 24 (recon, AD/Windows, auth-bypass, server-side-exec, AI/supply-chain, forensics, web-client, web-injection, web-protocol = 9 × 3 = 27... let me recount)

Let me recount precisely:
- AD/Windows: 3
- AI/supply-chain: 3
- Auth-bypass: 3
- Binary-exploitation: 2
- Crypto-attacks: 2
- Forensics: 3
- Linux/post-exploit: 2
- Mobile: 2
- Recon: 3
- Server-side-execution: 3
- Web-client-attacks: 3
- Web-injection: 3
- Web-protocol-attacks: 3

**Total: 35 rows.** Slightly above D-03's "~30" target. Planner can drop one row from each of 5 sections to land at 30, or accept 35 — the "~" in "~30" gives latitude. Recommendation: keep 35; the marginal rows are all high-value, and total table density at 35 rows is still scannable.

## Final Dual-Load Rule Set (researcher proposal)

Per D-06, the planner locks the final 5–7 dual-load rules. Below is the proposed final set of **6 rules** with rationale. Each rule states: trigger pattern → both skills to load (with their plugins).

### Rule 1: Recon + auth context
**Trigger:** New web/API target with user identity surface visible (login, registration, JWT in cookie, OAuth flow URLs, admin paths)
**Load both:** `recon-and-methodology` (in `hack-skills-recon`) + `api-auth-and-jwt-abuse` (in `hack-skills-auth-bypass`)
**Rationale:** Per upstream `hack` SKILL.md operating model — "Recon and context validation FIRST" before specialist work. When the surface clearly involves auth, dual-loading the auth specialist alongside the recon playbook is more efficient than sequential lookups.

### Rule 2: API testing + auth + IDOR
**Trigger:** Prompt mentions REST API testing AND mentions JWT/OAuth/tokens OR mentions object IDs in responses
**Load both:** `api-recon-and-docs` (in `hack-skills-recon`) + `api-auth-and-jwt-abuse` (in `hack-skills-auth-bypass`)
**Optional third:** `api-authorization-and-bola` (in `hack-skills-auth-bypass`)
**Rationale:** API testing is the classic 3-skill chain (discover endpoints → auth flow → authz model). Per upstream intuition #4 ("BOLA = authenticated-but-unauthorized"), the IDOR/BOLA skill belongs in the dual-load when object IDs are visible. Keep this rule simple at 2-skill dual-load; the optional third is a heuristic the body can mention.

### Rule 3: SSRF + business-flow context
**Trigger:** Prompt mentions URL-fetching, image preview, webhook callback, OR import-from-URL endpoints AND mentions payment/coupon/checkout/inventory/business workflow
**Load both:** `ssrf-server-side-request-forgery` (in `hack-skills-server-side-execution`) + `business-logic-vulnerabilities` (in `hack-skills-web-client-attacks`)
**Rationale:** Per upstream intuition #6 ("business-logic flaws bring highest impact"), SSRF as a primitive becomes much more dangerous in a business-flow context. Cross-plugin dual-load is the right shape here — neither plugin alone captures the combo.

### Rule 4: Auth bypass + JWT/OAuth
**Trigger:** Prompt mentions auth bypass, login flow attack, MFA bypass, OR session boundary AND mentions JWT, OAuth, OIDC, or SAML
**Load both:** `authbypass-authentication-flaws` + `jwt-oauth-token-attacks` (BOTH in `hack-skills-auth-bypass` — same-plugin dual-load)
**Rationale:** Per upstream intuition #8 ("for JWT: verify alg, kid, JWKS, key origin BEFORE spraying payloads"), the auth-flow skill and the JWT-specific skill cover different angles of the same target. Same-plugin dual-load — no plugin install needed if `hack-skills-auth-bypass` is installed; cleanest possible case.

### Rule 5: Business logic + race condition
**Trigger:** Prompt mentions coupon, checkout, inventory, claim, reset, or one-time operation AND mentions concurrent/timing/race
**Load both:** `business-logic-vulnerabilities` + `race-condition` (BOTH in `hack-skills-web-client-attacks` — same-plugin dual-load)
**Rationale:** Per upstream intuition #7 ("race conditions: prioritize one-time operations — coupon, claim, reset, inventory"). The two skills are siblings in the same plugin; pairing them captures the canonical e-commerce attack surface (this is exactly Walkthrough Scenario 4 / D-01.4).

### Rule 6: Web target, signals unclear
**Trigger:** Vague web prompt with no clear category signal (e.g., "I have a new web app, where do I start?")
**Load both:** `recon-and-methodology` (in `hack-skills-recon`) + relevant category skill once recon surfaces a signal
**Rationale:** Per upstream `hack` operating model step 1 — recon-first when context is unclear. This rule is a fallback, not a specific dual-load pair; the body should phrase it as "always start with recon if signals are ambiguous; then add a category skill once the surface is mapped."

**Coverage check against CONTEXT.md D-06 starter candidates:**
- ✅ Recon + auth context (D-06 candidate 1 → Rule 1)
- ✅ SSRF + payment/business flow (D-06 candidate 2 → Rule 3)
- ✅ API testing + auth (D-06 candidate 3 → Rule 2, expanded with IDOR optional)
- ✅ Web target, unclear (D-06 candidate 4 → Rule 6)
- ✅ Auth bypass + JWT/OAuth (D-06 candidate 5 → Rule 4)
- ➕ Business logic + race condition (NEW rule 5 — necessary because of Scenario 4 / D-01.4; not in D-06 starter list but inevitable given the 4 scenarios)

6 rules. D-06 allowed 5–7; researcher recommends 6 because adding Rule 5 makes the route obvious for the coupon-reuse walkthrough.

## The 8 Upstream Intuitions (verbatim source + example slots)

`[VERIFIED: /Users/spencerpresley/.claude/plugins/cache/hack-skills-marketplace/hack-skills-recon/c6f732befcae-32c1cf49/hack/SKILL.md §"High-Value Expert Intuitions" lines 119–130]`

Order is verbatim from upstream (per D-08, no reordering). For each entry below: the upstream's name/lede (verbatim), the upstream's explanation (verbatim, so the planner has the source to paraphrase from), and a concrete example (drawn from upstream where it provides one; otherwise the example slot is marked for the planner to fill).

### Intuition 1
**Upstream lede (verbatim):** "The same filtering logic is often reused across multiple pages: if one point is bypassable, similar pages usually are too."
**Mechanism:** A WAF rule, sanitizer function, or input filter applied at one endpoint is typically the same one applied to many other endpoints — devs deploy filters via shared middleware or shared library calls. So a single bypass discovery is rarely a single bug; it's often the pattern key that opens dozens.
**Example slot (concrete):** A reflected XSS bypass via `<svg/onload=…>` on the search page typically also works on the contact form, login error page, and any other endpoint that uses the same sanitizer. After confirming one, audit the codebase / file paths for other call sites of the same filter.

### Intuition 2
**Upstream lede (verbatim):** "Parameter names are an attack surface too: WAFs often inspect values but not names."
**Mechanism:** Most WAFs and security middleware focus on parameter values (the part the user typically controls). The parameter names themselves — query string keys, JSON object keys, form field names — are often unchecked. Renaming or duplicating a parameter, or using a name that the framework parses but the WAF ignores, can bypass filtering.
**Example slot (concrete):** Sending `?admin=true` is blocked, but `?Admin=true`, `?adm[in]=true`, or `?admin[]=true` may slip through because the WAF normalizes values but not key syntax. Same pattern with HTTP Parameter Pollution (`?role=user&role=admin`).

### Intuition 3
**Upstream lede (verbatim):** "Second-order vulnerabilities are common: safe at storage time does not mean safe when later read into a dangerous context."
**Mechanism:** Input is sanitized for one context (e.g., HTML output) at the time it's stored, but later consumed in a different context (e.g., a JavaScript template, an OS command, a SQL query) where the original sanitization is meaningless. The vuln class is fundamentally "right escape, wrong context."
**Example slot (concrete):** A username sanitized for HTML safety at registration ends up rendered into a JS string in an email template; `");alert(1);//` survives HTML escape but breaks out of the JS context. Same pattern with stored payloads that later get consumed by report exports, log viewers, or admin dashboards.

### Intuition 4
**Upstream lede (verbatim):** "BOLA is fundamentally 'authenticated but unauthorized': replaying with account A/B switching is critical."
**Mechanism:** Broken Object Level Authorization vulns aren't about defeating the auth layer — the user IS authenticated, just not authorized to access a specific object. The test methodology is: log in as user A, fetch an object, then replay the same request with user B's session — if B can read A's data, that's BOLA. The cookie/token switching IS the technique.
**Example slot (concrete):** `GET /api/v1/user/123/profile` returns user 123's profile. As user A (id=456), swap your session for user B's (id=789) and re-issue the same URL. If you see 123's profile, that's BOLA: the endpoint validates auth (you have a session) but not authorization (does session-owner 789 actually own object 123?).

### Intuition 5
**Upstream lede (verbatim):** "Older API versions are most likely to miss patches: fixing v2 does not mean v1 was retired."
**Mechanism:** When a security fix lands in the current API version, older versions often remain available for backwards compatibility. The fix tracking, the test suite, and the audit trail focus on the current version — `/api/v1/` quietly retains the bug that `/api/v2/` patched.
**Example slot (concrete):** `/api/v2/users/{id}` requires the requesting user own the resource; `/api/v1/users/{id}` doesn't (and is still up because mobile clients haven't updated). Test by enumerating version prefixes (`/v1/`, `/v2/`, `/internal/`, `/legacy/`) and replaying every interesting endpoint against each.

### Intuition 6
**Upstream lede (verbatim):** "Business-logic vulnerabilities often bring highest impact: scanners miss them and they persist longer."
**Mechanism:** Business-logic flaws (race conditions on coupon redemption, integer underflow on refunds, state-machine skips on multi-step checkout) require understanding the application's intended workflow — scanners can't infer "what was supposed to happen." So these flaws survive automated scanning AND code review (because the flaw isn't in any single line of code — it's in the workflow design).
**Example slot (concrete):** A coupon system that decrements the global usage counter after applying the discount — a race where two parallel requests both pass the "remaining uses > 0" check and both decrement, yielding 2 redemptions for 1 coupon. Scanners see a perfectly safe endpoint; manual logic review catches the workflow gap.

### Intuition 7
**Upstream lede (verbatim):** "Race conditions should prioritize one-time actions: coupon redemption, claims, resets, invites, trials, inventory deduction."
**Mechanism:** Race-condition impact correlates with how "one-time" the targeted operation is. A race on a generic GET request has minimal impact; a race on "use this coupon once" can yield infinite discounts. Test targets: operations that the business EXPLICITLY intended to be atomic single-use.
**Example slot (concrete):** Promo code `FREEMONEY` (one-use-per-account). Fire 100 concurrent POST `/coupon/apply` requests via Turbo Intruder's single-packet attack on HTTP/2. If the validation checks usage state before incrementing, all 100 may succeed — 100x the intended grant.

### Intuition 8
**Upstream lede (verbatim):** "For JWT attacks, check key and algorithm context first: do not blindly spray payloads; verify `alg`, `kid`, JWKS, and key source first."
**Mechanism:** JWT attack payloads (alg=none, RS256→HS256 confusion, kid path traversal, JWKS spoofing) only work in specific configurations. Spraying every payload at every JWT wastes time and tips off WAFs. The correct workflow: decode the header (`alg`, `kid`, `jku`), find the JWKS endpoint (`/.well-known/jwks.json`), identify the verification library and version, then pick the payload that targets that exact configuration.
**Example slot (concrete):** A JWT with `alg: HS256` (symmetric) but the discovery surface advertises a JWKS endpoint (asymmetric) suggests RS256→HS256 confusion — sign the token with the public key as HMAC secret. Different from `alg: none` (server skips signature check) — those are different bugs requiring different payloads.

## The 4 Walkthrough Scenarios — Destination Skills

`[VERIFIED: cross-referenced D-01 scenarios against marketplace.json plugin/skill names]`

For each of the 4 scenarios (D-01), the destination deep skills, the plugin they live in, and whether the plugin-recommendation template is needed (i.e., whether the assumed default install state has the destination plugin missing).

### Scenario 1: Admin panel at `/admin`, JWT in cookie
- **Primary deep skill:** `401-403-bypass-techniques`
- **Dual-load partner:** `jwt-oauth-token-attacks`
- **Plugin:** `hack-skills-auth-bypass` (both skills are in the same plugin — same-plugin dual-load, simpler case)
- **Plugin-recommendation template?** YES — if the user only has the router installed (default after Phase 2 ships standalone), the walkthrough should surface the install command for `hack-skills-auth-bypass`. The trace's "next-test recommendation" section should show the two-line plugin-rec template.
- **Routing rationale (for the walkthrough):** "Admin panel + access denied" → 401/403 bypass (path manipulation, method override). "JWT in cookie" → JWT specifics (decode `alg`, find JWKS, look for `alg=none`, `kid` injection, RS256→HS256). Same-plugin dual-load means one install command covers both.

### Scenario 2: GraphQL endpoint, introspection enabled
- **Primary deep skill:** `graphql-and-hidden-parameters`
- **Dual-load partner:** None for the immediate phase (introspection is a recon activity). Optional secondary if introspection reveals auth surfaces: `recon-and-methodology` for broader recon expansion.
- **Plugin:** `hack-skills-recon` (single-plugin focus)
- **Plugin-recommendation template?** YES — if the user only has the router installed, surface the install command for `hack-skills-recon`. The trace doesn't need to stack two recommendation blocks (single plugin).
- **Routing rationale:** "GraphQL + introspection" → GraphQL specialist. The walkthrough demonstrates single-plugin focus — most routing decisions are NOT cross-plugin; they're "find the right skill within the right plugin." Boundary conditions to surface: intuition #2 (parameter names — GraphQL field names) and intuition #5 (older API versions — schema version prefixes).

### Scenario 3: `.env` exposed in webroot
- **Primary deep skill:** `insecure-source-code-management`
- **Dual-load partner:** None (single-plugin recon focus)
- **Plugin:** `hack-skills-recon`
- **Plugin-recommendation template?** YES — same as Scenario 2 (install `hack-skills-recon` if not installed)
- **Routing rationale:** ".env exposed" is an SCM-leak-class finding. The walkthrough should demonstrate "single-plugin focus + recon expansion" — i.e., from the .env file's contents (DB creds, API keys, service config), expand recon into other surfaces those credentials open up (DB connection, internal service URLs, cloud provider metadata if AWS keys leak).
- **Boundary conditions to surface:** Intuition #3 (second-order vulns — the .env contents themselves contain secrets that become a chain into other systems).

### Scenario 4: E-commerce checkout, coupon-reuse
- **Primary deep skill:** `business-logic-vulnerabilities`
- **Dual-load partner:** `race-condition`
- **Plugin:** `hack-skills-web-client-attacks` (both skills are in the same plugin — same-plugin dual-load across categories)
- **Plugin-recommendation template?** YES — install `hack-skills-web-client-attacks`. Single plugin covers both skills.
- **Routing rationale:** "Coupon reuse" is canonically business-logic-flaw territory (multi-step workflow with state-machine assumption). But the canonical exploit primitive is a **race condition** on the coupon validation. So dual-load is mandatory — neither skill alone captures the combo. This exact pair is Dual-Load Rule 5 in §Final Dual-Load Rule Set.
- **Boundary conditions to surface:** Intuition #6 (business-logic highest-impact) and intuition #7 (race conditions: prioritize one-time operations — coupon is the canonical one-time op).

**Summary table for the planner:**

| Scenario | Primary skill | Dual-load partner | Plugin(s) | Dual-load type |
|----------|---------------|-------------------|-----------|----------------|
| 1: Admin/JWT | `401-403-bypass-techniques` | `jwt-oauth-token-attacks` | `hack-skills-auth-bypass` (both) | Same-plugin |
| 2: GraphQL | `graphql-and-hidden-parameters` | none (single focus) | `hack-skills-recon` | None |
| 3: .env exposed | `insecure-source-code-management` | none (single focus) | `hack-skills-recon` | None |
| 4: Coupon reuse | `business-logic-vulnerabilities` | `race-condition` | `hack-skills-web-client-attacks` (both) | Same-plugin |

**Note:** None of the 4 scenarios exercise **cross-plugin** dual-load (where two install commands stack). That's the more complex shape from D-07 ("two stacked two-line blocks"). The planner may want to demonstrate cross-plugin in the body's plugin-rec-template section using a synthetic example (e.g., "SSRF + business-flow context" from Rule 3) rather than burying the demonstration in a walkthrough — but the 4 scenarios as locked don't naturally exercise it. **Recommendation: keep the 4 scenarios as locked; demonstrate cross-plugin stacking explicitly in the body's plugin-availability handling section.**

## Spelling-Drift Risks (High-Probability Typos)

The following deep skill names are at elevated risk of typo because they're long compound names. Researcher recommends the planner build a verification probe (per Pattern 2 above) into each task and run it before considering the task done.

| Skill name | Typo risk pattern |
|------------|---------------------|
| `insecure-source-code-management` | "insecure-source-control-management" or "insecure-scm" common variant; trailing `-management` easy to drop |
| `business-logic-vulnerabilities` | Trailing `-s` often dropped → `business-logic-vulnerability` |
| `jwt-oauth-token-attacks` | Three drift forms: `jwt-oauth-token-attack` (drop `-s`), `jwt-and-oauth-token-attacks` (add `-and-`), `jwt-oath-token-attacks` (oath typo) |
| `idor-broken-object-authorization` | `idor-broken-object-authz` (abbreviation), `idor-broken-object-level-authorization` (over-spell), `idor-and-broken-object-authorization` (add `-and-`) |
| `csrf-cross-site-request-forgery` | `csrf-cross-site-request-forgery-attacks` (over-spell), `cross-site-request-forgery` (drop prefix) |
| `ssrf-server-side-request-forgery` | `ssrf-server-side-request-forgery-attacks` (over-spell), `server-side-request-forgery` (drop prefix) |
| `oauth-oidc-misconfiguration` | `oauth-and-oidc-misconfiguration` (add `-and-`), `oauth-oidc-misconfig` (abbreviate) |
| `saml-sso-assertion-attacks` | `saml-assertion-attacks` (drop `-sso-`), `saml-sso-assertion-attack` (drop `-s`) |
| `cors-cross-origin-misconfiguration` | `cors-misconfiguration` (drop middle), `cors-cross-origin-misconfig` (abbreviate) |
| `prototype-pollution-advanced` | `prototype-pollution-advanced-techniques` (over-spell), confusion with sibling `prototype-pollution` |
| `web-cache-deception` | `web-cache-poisoning` (related-but-different concept — separate technique) |
| `http-parameter-pollution` | `hpp` (abbreviation only) |
| `http2-specific-attacks` | `http-2-specific-attacks` (add hyphen), `http2-attacks` (drop middle) |
| `api-auth-and-jwt-abuse` | `api-auth-jwt-abuse` (drop `-and-`), `api-authentication-and-jwt-abuse` (over-spell) |
| `api-authorization-and-bola` | `api-authz-and-bola` (abbreviate), `api-authorization-bola` (drop `-and-`) |
| `authbypass-authentication-flaws` | `auth-bypass-authentication-flaws` (add hyphen — common form because plugin is `hack-skills-auth-bypass`), `authbypass-auth-flaws` (abbreviate) |

**Verification probe** (planner adds to each Phase 2 task that touches a file with skill references):

```bash
# Per-task verification: every skill name referenced in this file must exist in marketplace.json
FILE="$1"  # path to file being verified

# Canonical skill names (95 total across 13 plugins)
jq -r '.plugins[].skills[]?' .claude-plugin/marketplace.json | sed 's|^\./||' | sort -u > /tmp/canonical.txt

# Skill names mentioned in this file — scoped to backtick-quoted identifiers matching skill name shape
grep -oE '`[a-z][a-z0-9-]+`' "$FILE" | tr -d '`' | sort -u > /tmp/mentioned.txt

# Filter mentioned list down to plausible skill names (15+ chars OR contains 2+ hyphens — heuristic)
awk 'length($0) >= 15 || gsub(/-/, "&") >= 2' /tmp/mentioned.txt > /tmp/mentioned-skill-shaped.txt

# Diff: any mentioned-skill-shaped term NOT in canonical = potential typo
comm -23 /tmp/mentioned-skill-shaped.txt /tmp/canonical.txt
```

The probe returns ZERO lines if all referenced skill names match canonical. Any output is a typo or a false positive (some longer non-skill term in backticks) — the planner reviews manually.

**Plugin-name verification probe** (similar shape):
```bash
# Canonical plugin names
jq -r '.plugins[].name' .claude-plugin/marketplace.json | sort -u > /tmp/canonical-plugins.txt

# Plugin names mentioned in file (backtick-quoted, start with hack-skills-)
grep -oE '`hack-skills-[a-z-]+`' "$FILE" | tr -d '`' | sort -u > /tmp/mentioned-plugins.txt

comm -23 /tmp/mentioned-plugins.txt /tmp/canonical-plugins.txt
```

## Open Questions

1. **Cross-plugin dual-load demonstration in the body** — should the body's plugin-availability section include a small inline example of stacked 2-line plugin-rec blocks (using a hypothetical SSRF + business-logic case), OR should it cross-reference `examples/workflow-walkthroughs.md` and let the example live there?
   - What we know: The 4 walkthroughs (D-01) don't naturally exercise cross-plugin stacking — all 4 are same-plugin or single-plugin.
   - What's unclear: Best demonstration site.
   - Recommendation: Include a 4–5 line inline example in the body's plugin-availability section (synthetic SSRF + business-logic case), with explicit "see also `examples/workflow-walkthroughs.md`" cross-ref. This way the body shows the stacking shape, the examples file shows the canonical 4 scenarios, and they complement rather than overlap.

2. **Row count: 35 vs 30 in routing-tables.md** — researcher's §Signal Terms proposal lands at 35 rows; D-03 says "~30."
   - What we know: D-03 says "~30 high-signal rows" with "2–3 rows per section."
   - What's unclear: Whether 35 is acceptable or whether the planner should trim 5 rows to land at exactly 30.
   - Recommendation: Keep 35. The "~" prefix gives latitude; trimming would force dropping a high-value row from some section. If the planner disagrees, the natural cuts are: drop one row from each of AD/Windows, AI/supply-chain, recon, server-side-execution, and one of the web-* plugins (whichever 3-row section feels least cohesive).

3. **Catch-all plugin row count: 3 each vs 2 each** — researcher recommends 3 rows for each of the 2 catch-alls (covers all 3 skills in each plugin); D-03 says "2–3 rows per section."
   - What we know: Each catch-all plugin has exactly 3 deep skills; cap row count by skills cap row count at 3.
   - What's unclear: Whether catch-alls should get equal billing or fewer rows because they're catch-alls.
   - Recommendation: 3 rows each. Per D-16 catch-alls are first-class routing destinations.

4. **Body's "When to use" bullet list — match upstream verbatim or tailor?** Per Specifics in CONTEXT.md, the recommended approach is "mirror upstream's bullet list but tweaked to mention the marketplace specifically." Researcher confirms this is the right call.
   - Upstream bullets (from `hack` SKILL.md "When to Use This Skill"): new bug bounty target, decide XSS/SQLi/SSRF/IDOR/JWT/API tracks, want stable methodology, route scattered findings, want AI to miss fewer critical test points.
   - Tailored bullets (proposed): "New target, unclear where to start", "Multiple signals could route to multiple categories", "Need methodology rigor, not payload guessing", "Want the boundary conditions baseline AI misses", "Want install commands for plugins you don't yet have".
   - Recommendation: Use tailored bullets. The added 5th bullet ("install commands for plugins you don't yet have") highlights the router's distinctive value over upstream (discovery surface) per the design spec §4.2 "infrastructure" framing.

## Validation Architecture

> **Section omitted per project config: `nyquist_validation` is disabled for this project (per Phase 2 plan-research prompt). No `## Validation Architecture` section produced.**

Phase 2 verification is **content-level**, performed via grep/jq probes embedded in each task's verification step (see Pitfalls #1–#6 above for the specific probes). No test framework, no test runner, no CI integration — just `grep`, `jq`, `awk`, `wc` on the produced markdown files.

## Security Domain

Phase 2 is content authoring; there's no executable code surface, no user input handling, no auth, no data persistence. Security applies in two narrow forms:

| Concern | Phase 2 surface | Mitigation |
|---------|-----------------|------------|
| Content describes attack techniques | All 4 files describe security testing methodologies | Trust model section in SKILL.md body explicitly states "Authorized targets only. If scope is unclear, refuse or ask." (per D-12 section 3) — paraphrased from upstream `hack` SKILL.md §Trust Model |
| Routing recommendations could enable misuse | Router routes prompts to specific attack playbooks | The same trust-model statement covers this; SessionStart hook (Phase 3, not Phase 2) reinforces it once per session per design spec §5.4 |
| Source attribution / license | Content paraphrases MIT-licensed upstream | Attribution chain (D-15) in 4 files — addressed in §Pattern 3 above with verbatim header text |

No ASVS categories apply — this isn't a software-build phase. No threats; no hand-rolled crypto; no input validation surface; no auth surface; no session surface.

## Assumptions Log

All factual claims in this research were verified via tool output (jq, file reads, official Anthropic docs, the upstream cached SKILL.md file) or cited from upstream content. **No claims tagged `[ASSUMED]`.**

| # | Claim | Section | Risk if Wrong |
|---|-------|---------|---------------|
| — | (table empty — all claims verified or cited) | — | — |

The proposed dual-load rules, signal-term mappings, and recommended row selections are **researcher proposals**, not assertions of fact — the planner has authority to swap them. They're informed by the verified data above (Master Table, marketplace.json, upstream hack SKILL.md).

## Environment Availability

Phase 2 has no external dependencies beyond what Phase 1 already verified.

| Dependency | Required By | Available | Version | Fallback |
|------------|------------|-----------|---------|----------|
| `jq` | Skill-name / plugin-name verification probes | ✓ (verified Phase 1) | n/a — Phase 1 used `jq empty` without version constraint | — |
| `grep` (POSIX) | Attribution presence / STUB-marker absence / pitfall probes | ✓ (POSIX baseline) | — | — |
| `awk` (POSIX) | Description length extraction (frontmatter cap probe) | ✓ (POSIX baseline) | — | — |
| `wc` | Line count + char count probes | ✓ (POSIX baseline) | — | — |
| `git` | Atomic commits per file (per Phase 1 pattern) | ✓ (Phase 1 used) | — | — |
| Claude Code | Test that SKILL.md renders correctly in `claude plugin details` | Optional (verification at Phase 4) | — | Phase 2 is content-only; Phase 4 owns runtime test |

**Missing dependencies with no fallback:** None.
**Missing dependencies with fallback:** None.

## Sources

### Primary (HIGH confidence)

- [Claude API Docs — Skill authoring best practices](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices) — frontmatter `description` 1024-char max, `name` max 64 chars, body 500-line soft cap, progressive-disclosure Pattern 1 (high-level guide with references), one-level-deep references constraint, concise voice, avoid time-sensitive info. **Fetched 2026-05-22.**
- [GitHub anthropics/claude-code issue #40121](https://github.com/anthropics/claude-code/issues/40121) — confirms `/skills` listing display 250-char cap (Claude Code v2.1.86 changelog: "Skill descriptions in the /skills listing are now capped at 250 characters to reduce context usage"). **Fetched 2026-05-22.**
- `.claude-plugin/marketplace.json` (this repo, current) — canonical source for 14 plugin names and 95 deep skill paths. Extracted via `jq -r '.plugins[].name'` and `jq -r '.plugins[].skills[]'`.
- `/Users/spencerpresley/.claude/plugins/cache/hack-skills-marketplace/hack-skills-recon/c6f732befcae-32c1cf49/hack/SKILL.md` — upstream MIT-licensed `hack` SKILL.md, sole authoritative source for the 8 expert intuitions verbatim text (lines 119–130), the 3-step operating model (lines 38–80), the Signal/Priority table (lines 52–73), and the trust-model phrasing.
- `.planning/phases-archive-v1.0/02-skill-classification-taxonomy/02-CLASSIFICATION.md` Master Table (lines 318–419) — verbatim YAML `description` field from each of 102 upstream skills' SKILL.md frontmatter. Sole source for signal-term mining (the per-skill descriptions are the highest-density signal-keyword source available).
- `.planning/specs/2026-05-22-v2-router-design.md` (this repo) — design source of truth; spec §§5.6, 5.7, 5.8, 5.9, 5.10, 11, 3 all consulted and locked.
- `.planning/phases/02-router-skill-content/02-CONTEXT.md` (this repo) — D-01 through D-17 locked decisions; the binding ground truth for Phase 2 scope.
- `.planning/phases/01-plugin-mechanism-spike/01-VERIFICATION.md` and `01-01-SUMMARY.md` and `01-PATTERNS.md` (this repo) — Phase 1 closure artifacts establishing the frontmatter constraints, sidecar layout pattern, STUB→FINAL boundary discipline, and the chmod / hooks invariants Phase 2 builds on top of.
- `.planning/REQUIREMENTS.md` ROUTER-01 through ROUTER-05 (this repo) — phase requirement IDs with acceptance criteria.

### Secondary (MEDIUM confidence)

- `.planning/phases-archive-v1.0/02-skill-classification-taxonomy/02-CLASSIFICATION.json` `skill_metadata` map — provides 10 `also_relevant_to` cross-classification hints. Used as a tiebreaker when a deep skill could be relevant to a routing section other than its primary plugin (e.g., `business-logic-vulnerabilities` is `also_relevant_to: auth-bypass`). The hints inform but don't dictate routing decisions.
- WebSearch result confirming the 250-char `/skills` listing cap (search query: "Claude Code SKILL.md frontmatter description max length character limit") — cross-verified with the Anthropic docs primary source above.

### Tertiary (LOW confidence)

None. All claims are backed by either an Anthropic-official documentation source, a tool-extracted file content, or an in-repo decision document.

## Metadata

**Confidence breakdown:**

- Standard stack: HIGH — content-only phase, no library/version decisions to verify.
- Architecture: HIGH — D-01 through D-17 lock every structural decision; researcher fills concrete content (skill names, intuitions, dual-load rules) verified against canonical sources.
- Pitfalls: HIGH — seven pitfalls cataloged, each with a concrete verification probe drawn from in-repo Phase 1 patterns or Claude Code docs.
- Frontmatter cap: HIGH — 1024 max and 250 listing cap both verified against Anthropic docs and the official GitHub issue; concrete tightened first paragraph proposed (241 chars).
- Plugin/skill name inventory: HIGH — extracted byte-exact from marketplace.json via `jq`.
- Signal terms: MEDIUM — sourced from upstream skill descriptions (Master Table) but researcher selected the 35 highest-value rows; planner has authority to swap.
- Dual-load rules: MEDIUM — 6 proposed rules with rationale traced to upstream intuitions and the 4 walkthrough scenarios; planner locks final count and wording.
- 8 intuitions verbatim text: HIGH — copied directly from upstream `hack` SKILL.md lines 119–130.
- 4 walkthrough destinations: HIGH — every primary and dual-load destination verified against marketplace.json `.plugins[].skills[]` paths.

**Research date:** 2026-05-22
**Valid until:** 2026-06-21 (30 days — content authoring; the upstream `hack` SKILL.md and marketplace.json don't change frequently; Claude Code Skill format limits are stable platform constraints)
