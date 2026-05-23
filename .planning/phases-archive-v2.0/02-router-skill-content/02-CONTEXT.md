# Phase 2: Router Skill + Content - Context

**Gathered:** 2026-05-22
**Status:** Ready for planning

<domain>
## Phase Boundary

**What this phase delivers:** the content layer of the `hack-skills-router` sidecar plugin. Specifically:

1. **Replace** the Phase 1 stub `plugins/hack-skills-router/skills/hack-skills-router/SKILL.md` (frontmatter + ~80-line body) with the production router brain.
2. **Create** `plugins/hack-skills-router/skills/hack-skills-router/patterns/routing-tables.md` — signal → topic-skill mappings (~30 high-signal rows organized as 13 plugin-keyed sections) + dual-load rules + plugin-recommendation template.
3. **Create** `plugins/hack-skills-router/skills/hack-skills-router/patterns/expert-intuitions.md` — 8 high-value boundary-condition paragraphs sourced from upstream `yaklang/hack-skills` `hack` SKILL.md with attribution.
4. **Create** `plugins/hack-skills-router/skills/hack-skills-router/examples/workflow-walkthroughs.md` — 4 end-to-end traces (admin-panel + JWT cookie; GraphQL with introspection; `.env` in webroot; coupon-reuse business flow).

**What this phase does NOT deliver:**
- Real SessionStart / UserPromptSubmit hook payloads — Phase 3 owns the script bodies + security-context regex. (Phase 2's router body content informs what those hook payloads reference, but the script files are not touched here.)
- Marketplace entry changes — `.claude-plugin/marketplace.json` already has the 14th entry from Phase 1 Plan 02. Untouched in Phase 2.
- Live validation against published marketplace — Phase 4 owns the publish + fresh-install flow.

**Requirements covered:** ROUTER-01, ROUTER-02, ROUTER-03, ROUTER-04, ROUTER-05 (per `.planning/REQUIREMENTS.md`).

</domain>

<decisions>
## Implementation Decisions

### Workflow Walkthroughs (`examples/workflow-walkthroughs.md`)

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

### Routing Tables (`patterns/routing-tables.md`)

- **D-03: Density — ~30 rows organized as 13 plugin-keyed sections (one section per v1 topical plugin), 2–3 rows per section.** Each section is keyed by the plugin name (`hack-skills-<topic>`) and starts with the install command at the top, doubling as the plugin-recommendation surface. NOT one giant flat table — sectioning by destination plugin makes scanning easier and embeds the install path next to the signals it serves.

- **D-04: Row shape.** Each row inside a section is `| Signal terms | Deep skill (in this plugin) |`. Signals are comma-separated synonyms (3–6 terms typical). Deep skill is the upstream skill directory name (e.g., `xss-cross-site-scripting`, `jwt-oauth-token-attacks`).

- **D-05: Section-level install command at top of every section.** Format:
  ```
  ### hack-skills-<topic>
  **Install:** `/plugin install hack-skills-<topic>@hack-skills-marketplace`
  ```
  This means: every row's "plugin not installed" recommendation is one scroll-up away in the same file, and the router's body can reference the section by name instead of repeating install commands.

- **D-06: Dual-load rules — 5–7 rules as a separate section after the per-plugin sections.** Each rule states the trigger pattern and the cross-plugin / cross-skill pair to load. Examples:
  - Recon + auth context → `recon-and-methodology` + `api-auth-and-jwt-abuse`
  - SSRF + payment/business flow → `ssrf-server-side-request-forgery` + `business-logic-vulnerabilities`
  - API testing + auth → `api-recon-and-docs` + `api-auth-and-jwt-abuse`
  - Web target, unclear → `recon-and-methodology` + category
  - Auth bypass + JWT/OAuth → `authbypass-authentication-flaws` + `jwt-oauth-token-attacks`
  Researcher should propose the final 5–7 with rationale; planner locks the set.

- **D-07: Plugin-recommendation template — locked as a separate "template" section at the bottom of the file.** Two-line block format (NOT one-line):
  ```
  **Recommended deep skill:** <skill> (in `hack-skills-<plugin>`, not currently installed)
  **Install:** `/plugin install hack-skills-<plugin>@hack-skills-marketplace`
  ```
  When multiple plugins are missing (dual-load case), output two stacked two-line blocks — do NOT compress into one comma-list.

### Expert Intuitions (`patterns/expert-intuitions.md`)

- **D-08: All 8 upstream intuitions, in upstream order.** No additions, no reordering, no editorializing beyond paraphrase + one concrete example per. The 8 are: (1) filter logic reuse across pages, (2) parameter names as attack surface, (3) second-order vulns, (4) BOLA = authenticated-but-unauthorized, (5) older API versions miss patches, (6) business-logic flaws bring highest impact, (7) race conditions on one-time ops, (8) JWT key/algorithm context before payload spray. Verbatim list at design spec §5.4 and source at upstream `hack` SKILL.md.

- **D-09: Attribution — file header paragraph at the top.** Standard form: "These 8 intuitions are paraphrased from `yaklang/hack-skills` `hack` SKILL.md (MIT-licensed). See `.planning/specs/2026-05-22-v2-router-design.md` §11 for the full attribution chain." No per-paragraph attribution — file-level only.

- **D-10: Paragraph shape per intuition.** Each entry: (a) the lede (one-sentence summary, matches what router body uses), (b) one short paragraph (3–5 sentences) explaining the mechanism, (c) one concrete example. Total per entry: ~6–10 lines. File total: ~80–100 lines. On-demand load — not always-on.

### Router SKILL.md — Body + Frontmatter

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

### Router-Wide Cross-Cutting

- **D-15: Source attribution — appears in 4 files.** Already locked by design spec §11, restated here for clarity:
  1. Router `SKILL.md` body header — one-line "Adapted from upstream `yaklang/hack-skills` `hack` SKILL.md."
  2. `patterns/expert-intuitions.md` header paragraph (per D-09).
  3. `patterns/routing-tables.md` header paragraph — "Signal-to-category mappings derived from upstream `hack` SKILL.md Signal/Priority table, expanded to address our 13-plugin topical structure."
  4. `plugin.json` description (already in place from Phase 1: "Adapted from yaklang/hack-skills upstream router.")
  No per-row, per-skill, or per-paragraph attribution. File-level only.

- **D-16: Catch-all bucket routing.** The two themed catch-all plugins (`hack-skills-ai-and-supply-chain` with 3 skills; `hack-skills-forensics-and-misc-recovery` with 3 skills) get their own sections in `patterns/routing-tables.md` with signals that route to their specific skills (e.g., "prompt injection" → `llm-prompt-injection`; "supply chain confusion" → `dependency-confusion`; "memory dump" → `memory-forensics-volatility`). They are first-class routing destinations, not afterthoughts.

- **D-17: Phase 2 does NOT modify hook scripts.** `plugins/hack-skills-router/hooks/scripts/{session-start.sh,nudge.sh}` remain Phase 1 stubs until Phase 3. Phase 2 may *reference* what those payloads will contain (because the router body should be consistent with what SessionStart eventually injects), but the script files themselves are out of scope.

### Claude's Discretion

User explicitly delegated all 4 surfaced gray areas to Claude (workflow walkthroughs, routing table density, plugin recommendation tone, boundary conditions in body). All decisions above (D-01 through D-17) are Claude's calls. Rationale is captured per-decision; researcher and planner are free to challenge any of them with evidence but should treat them as defaults.

Specifically open for researcher/planner refinement (NOT to be re-asked of user):
- Final wording of the 5–7 dual-load rules (D-06 lists 5 starter candidates; researcher proposes final set with rationale).
- Exact signal terms for each row in routing-tables.md (D-03/D-04 set the shape; researcher mines upstream skill descriptions from `02-CLASSIFICATION.json` and the cached upstream skills for the actual term list).
- Exact frontmatter description length if Claude Code has a cap (D-11 starting point is spec §5.6 verbatim; researcher confirms cap).

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Design source of truth (LOCKED — supersedes ad-hoc decisions)
- `.planning/specs/2026-05-22-v2-router-design.md` §5.6 — Router SKILL.md frontmatter shape (keyword-stuffed description)
- `.planning/specs/2026-05-22-v2-router-design.md` §5.7 — Router SKILL.md body section list
- `.planning/specs/2026-05-22-v2-router-design.md` §5.8 — `patterns/routing-tables.md` structure + plugin-recommendation template
- `.planning/specs/2026-05-22-v2-router-design.md` §5.9 — `patterns/expert-intuitions.md` structure
- `.planning/specs/2026-05-22-v2-router-design.md` §5.10 — `examples/workflow-walkthroughs.md` structure + 4 suggested traces
- `.planning/specs/2026-05-22-v2-router-design.md` §11 — Source attribution requirements (4-file attribution chain)
- `.planning/specs/2026-05-22-v2-router-design.md` §3 — Locked decisions (sidecar, redefined-middle hooks, hybrid routing, progressive disclosure, additive to v1)

### Requirements & roadmap
- `.planning/REQUIREMENTS.md` §ROUTER-01..ROUTER-05 — phase requirements with acceptance criteria
- `.planning/ROADMAP.md` §"Phase 2: Router Skill + Content" — phase goal + 5 success criteria
- `.planning/PROJECT.md` §Constraints + §"Key Decisions" sidecar row — source immutability, sidecar pattern

### Phase 1 (immediate predecessor) — verifies what Phase 2 replaces in place
- `.planning/phases/01-plugin-mechanism-spike/01-VERIFICATION.md` — all 5 SCs passed; stub SKILL.md, stub hooks, marketplace entry all live
- `.planning/phases/01-plugin-mechanism-spike/01-01-SUMMARY.md` — frontmatter constraints (no `name`, no `user-invocable`, no `disable-model-invocation`); SKILL.md body cap = 30 lines for STUB (Phase 2 rewrites this; ~95–105 line target)
- `.planning/phases/01-plugin-mechanism-spike/01-PATTERNS.md` — sidecar plugin layout pattern
- `.planning/phases/01-plugin-mechanism-spike/01-RESEARCH.md` — Phase 1 research (hooks.json shape, `${CLAUDE_PLUGIN_ROOT}`, etc.) for cross-reference if hook content questions come up during router body authoring

### Source content (upstream, MIT-licensed)
- `/Users/spencerpresley/.claude/plugins/cache/hack-skills-marketplace/hack-skills-recon/c6f732befcae-32c1cf49/hack/SKILL.md` — upstream `hack` SKILL.md (PRIMARY source for D-08 the 8 intuitions, D-12 the 3-step operating model, D-03 signal→category table). Cache path `hack-skills-recon` prefix is a v1 plugin name artifact; the file content itself is the upstream router.
- Per-skill upstream descriptions for routing-table signals (~95 skills): mined from cached plugin caches at `/Users/spencerpresley/.claude/plugins/cache/hack-skills-marketplace/<plugin-name>/<sha-hash>/<skill-dir>/SKILL.md` — researcher consolidates signal terms from these for D-04. Alternatively, the v1 milestone artifact `.planning/phases-archive-v1.0/02-skill-classification-taxonomy/02-CLASSIFICATION.json` `skill_metadata` key contains all 102 upstream descriptions in one place — prefer this consolidated source over per-cache reads.

### Current state of write targets
- `plugins/hack-skills-router/skills/hack-skills-router/SKILL.md` — current Phase 1 stub (28 lines, `description: STUB —...` frontmatter); Phase 2 replaces frontmatter + body in place
- `plugins/hack-skills-router/skills/hack-skills-router/patterns/` — does NOT exist yet; Phase 2 creates
- `plugins/hack-skills-router/skills/hack-skills-router/examples/` — does NOT exist yet; Phase 2 creates
- `.claude-plugin/marketplace.json` — UNTOUCHED in Phase 2 (14 plugin entries already correct from Phase 1 Plan 02; do not modify)
- `plugins/hack-skills-router/hooks/scripts/{session-start.sh,nudge.sh}` — UNTOUCHED in Phase 2 (Phase 3 owns)
- `plugins/hack-skills-router/hooks/hooks.json` — UNTOUCHED in Phase 2 (Phase 3 owns the regex matcher swap)

### Downstream phase awareness
- `.planning/ROADMAP.md` §"Phase 3: Hook Scripts + Regex" — Phase 3 nudge content references router body. Coordinate: router body's plugin-availability section must be consistent with what nudge.sh eventually says.

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- **Phase 1 stub `SKILL.md`** (`plugins/hack-skills-router/skills/hack-skills-router/SKILL.md`): the file exists with correct YAML structure and parent directory layout. Phase 2 rewrites the `description` field and body content in place — no new file creation needed for this target.
- **`plugins/hack-skills-router/skills/hack-skills-router/` directory** exists from Phase 1. The two new sub-directories (`patterns/`, `examples/`) need to be created as children before writing their files.
- **`02-CLASSIFICATION.json`** in `.planning/phases-archive-v1.0/02-skill-classification-taxonomy/` (from v1 milestone) — consolidated source of all 102 upstream skill descriptions + the 14-bucket topical classification. Use this to mine signal terms for routing-tables.md rather than reading 95 individual cached SKILL.md files. **Key reusable asset.**
- **Upstream `hack` SKILL.md** at `/Users/spencerpresley/.claude/plugins/cache/hack-skills-marketplace/hack-skills-recon/c6f732befcae-32c1cf49/hack/SKILL.md` — primary content source for paraphrase work (8 intuitions, operating model, signal table).

### Established Patterns
- **Sidecar plugin layout** (from Phase 1 `01-PATTERNS.md`): `plugins/<name>/{.claude-plugin/plugin.json, skills/<name>/SKILL.md, hooks/hooks.json, hooks/scripts/*.sh}`. Phase 2 extends this with `skills/<name>/patterns/*.md` and `skills/<name>/examples/*.md` — the progressive-disclosure pattern from the rust-skills reference (per design spec §5).
- **Atomic commits per file** (from Phase 1 execution): each `.md` file lands as its own commit with `feat(02): ...` or `feat(phase-02): ...` message. No mega-commits.
- **STUB → FINAL boundary** (from Phase 1 `01-01-SUMMARY.md`): Phase 1's SKILL.md frontmatter description starts with literal text "STUB —"; Phase 2 must remove that marker and any "Phase 1 stub" language from the file. Verification probe should grep for residual `STUB` / `stub` markers in the rewritten file.

### Integration Points
- **Plugin-name references must match `marketplace.json` exactly.** The 13 v1 plugin names in routing-tables.md and the workflow-walkthroughs install commands must be character-for-character identical to `.claude-plugin/marketplace.json` entries (already verified in Phase 1 — see plugin list at `marketplace.json` lines 9–258). Researcher should produce a quick check script comparing routing-tables.md plugin names against marketplace.json `.plugins[].name`.
- **Deep-skill names must match upstream directory names.** The skills column in routing-tables.md uses upstream dir names like `xss-cross-site-scripting`, `jwt-oauth-token-attacks` — these match the `./` paths in marketplace.json `skills` arrays. Spelling drift is a high-risk failure mode (a typo means the router recommends a non-existent skill).
- **Phase 3 will reference router body content from `nudge.sh`.** Specifically, the nudge mentions "load Skill(hack-skills-router) for category selection" and "surface 2–3 boundary conditions... the router's `expert-intuitions` tables cover these" (per design spec §5.5). Phase 2's router body must be consistent — the section names and file paths the nudge cites by name must exist in Phase 2's output.

</code_context>

<specifics>
## Specific Ideas

- The router body's "When to use this skill" section should mirror upstream's bullet list (per design spec §5.7) but tweaked to mention the marketplace specifically: "New target, unclear where to start", "Multiple signals could route to multiple categories", "Need methodology rigor, not payload guessing", "Want the boundary conditions baseline AI misses".
- The workflow-walkthrough trace for "GraphQL endpoint, introspection enabled" should mention introspection queries and `graphql-and-hidden-parameters` (which is in `hack-skills-recon` per marketplace.json — note this is in recon, not a separate GraphQL plugin).
- The coupon-reuse walkthrough should be explicit that BOTH `business-logic-vulnerabilities` AND `race-condition` live in `hack-skills-web-client-attacks` — same-plugin dual-load is interesting because there's no missing-plugin recommendation needed, just signal that two skills together are stronger than either alone.
- The "Operating model 3-step" section in the router body is paraphrase + compression of upstream's 4-step ("Recon and context validation FIRST → Route by observed behavior → Apply testing in typical order"). Compression to 3 steps (Phase ID → Signal route → Dual-load) per design spec §5.7 is intentional — do not expand to 4 to match upstream.

</specifics>

<deferred>
## Deferred Ideas

- **SYNC-01 / SYNC-02** (refresh process for new upstream skills) — already in `REQUIREMENTS.md` Future. When upstream adds new skills, routing-tables.md needs updating; not Phase 2's job.
- **ROUTER-FUT-01** (hook kill-switch env var) — Phase 3 or later.
- **ROUTER-FUT-03** (multi-language router triggers) — upstream's `hack` SKILL.md is bilingual (Chinese + English); v2 stays English-only per `REQUIREMENTS.md` Out of Scope.
- **DISC-01** (README listing each plugin's skill set) — orthogonal; not router-related.
- **Per-skill row density (~60+ rows in routing-tables.md)** — D-03 went with cluster-level ~30 rows. If post-publish feedback shows a missing high-frequency signal, add a row in a v2.x update.
- **Frontmatter description trimming** — D-11 says spec §5.6 verbatim is the starting point. If Claude Code has a hard frontmatter length cap that the spec text exceeds, researcher proposes trimmed version; current discussion does not pre-commit a shorter draft.

</deferred>

---

*Phase: 2-router-skill-content*
*Context gathered: 2026-05-22*
