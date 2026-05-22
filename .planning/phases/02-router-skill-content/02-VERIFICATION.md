---
phase: 02-router-skill-content
verified: 2026-05-22T18:30:00Z
status: human_needed
score: 4/5 must-haves verified
overrides_applied: 0
human_verification:
  - test: "Load router via Skill(hack-skills-router) and run a representative security query (e.g., 'How do I test JWT alg=none on this API?')"
    expected: "Router body loads; SKILL.md content is visible; body references patterns/routing-tables.md and examples/workflow-walkthroughs.md by name; router provides a specific deep-skill recommendation; if the recommended plugin is not installed, Claude outputs a /plugin install ...@hack-skills-marketplace command"
    why_human: "Requires Claude Code runtime — the skill load path, description-match auto-invocation, and install-command surfacing behavior cannot be verified with grep/file checks alone"
---

# Phase 2: Router Skill + Content Verification Report

**Phase Goal:** Make the router skill the intelligence layer. Body of router SKILL.md carries the hybrid routing strategy + dual-load + availability handling; progressive-disclosure sub-files carry the full routing tables, intuitions, and walkthroughs that the router cites by name.

**Verified:** 2026-05-22T18:30:00Z
**Status:** human_needed
**Re-verification:** No — initial verification

## Goal Achievement

### Observable Truths

| # | Truth | Status | Evidence |
|---|-------|--------|----------|
| 1 | Router SKILL.md body provides all 7 D-12 sections (when-to-use, trust model, hybrid routing strategy, 3-step operating model, plugin-availability handling, boundary conditions quick reference, workflow examples cross-ref) | VERIFIED | SKILL.md body: 7 H2 sections confirmed by grep, all 7 titles match D-12 order. H1 present. Attribution one-liner present. Body 89 lines (within 80-130 acceptance band). |
| 2 | routing-tables.md has 13 plugin-keyed sections, >=30 high-signal rows, >=5 dual-load rules, plus plugin-recommendation template | VERIFIED | 13 H3 plugin sections confirmed; 35 rows confirmed via Python count (per-section: 9 sections x 3 rows + 4 sections x 2 rows); 6 dual-load rules; plugin-recommendation template present with single-plugin and stacked dual-load examples. All 35 deep-skill names byte-exact vs marketplace.json. |
| 3 | expert-intuitions.md documents all 8 upstream intuitions with one-paragraph explanations and MIT attribution to yaklang/hack-skills | VERIFIED | 8 H3 entries (Intuition 1-8) in upstream order; each has Lede+Mechanism+Example fields (24 total labels); attribution header cites yaklang/hack-skills (MIT) + design-spec §11; 67 lines total. |
| 4 | workflow-walkthroughs.md contains >=3 end-to-end traces with the specified structure (prompt, testing phase, signal route, dual-load, boundary conditions, next-test) | VERIFIED | 4 scenarios in locked D-01 order; every scenario has all 6 required section labels (24 total label occurrences); 7 intuition #N references; 4 install commands in canonical shape. |
| 5 | Manual smoke check: router loadable via Skill(hack-skills-router) and body cross-references both patterns/ and examples/ sub-files | UNCERTAIN — needs human | All 3 sub-files exist on disk; body has 3 clickable relative links confirmed. Runtime load behavior requires Claude Code session. |

**Score:** 4/5 truths verified (SC-5 deferred to human UAT per ROADMAP.md explicit deferral)

### Required Artifacts

| Artifact | Expected | Status | Details |
|----------|----------|--------|---------|
| `plugins/hack-skills-router/skills/hack-skills-router/SKILL.md` | Production router skill: keyword-dense frontmatter + 7-section body | VERIFIED | 101 lines total (12 frontmatter + 89 body). Frontmatter: 224-char first paragraph (<=250 cap), 844-char total (<=1024 cap). No STUB/TBD/FIXME/XXX markers. No forbidden keys (name, user-invocable, disable-model-invocation). |
| `plugins/hack-skills-router/skills/hack-skills-router/patterns/routing-tables.md` | 13 plugin-keyed sections, >=30 rows, >=5 dual-load rules, plugin-recommendation template | VERIFIED | 176 lines. 13 H3 sections (alphabetical/marketplace.json order). 35 data rows (Python-verified). 6 dual-load rules. Plugin-recommendation template at bottom. Zero clickable links to sibling sub-files. |
| `plugins/hack-skills-router/skills/hack-skills-router/patterns/expert-intuitions.md` | 8 paraphrased intuitions with file-level attribution | VERIFIED | 67 lines. 8 H3 entries in upstream order. 8 Lede + 8 Mechanism + 8 Example fields. Attribution cites yaklang/hack-skills, MIT, design-spec §11. |
| `plugins/hack-skills-router/skills/hack-skills-router/examples/workflow-walkthroughs.md` | >=3 end-to-end traces with 6-label structure | VERIFIED | 80 lines. 4 scenarios in locked D-01 order. All 6 section labels present in every scenario (24 total). 7 intuition references. 4 canonical install commands. |

### Key Link Verification

| From | To | Via | Status | Details |
|------|----|-----|--------|---------|
| SKILL.md body | patterns/routing-tables.md | clickable `[patterns/routing-tables.md](patterns/routing-tables.md)` links | WIRED | Multiple occurrences in Routing strategy + Operating model + Plugin availability sections |
| SKILL.md body | patterns/expert-intuitions.md | clickable `[patterns/expert-intuitions.md](patterns/expert-intuitions.md)` link | WIRED | Present in Boundary conditions closing line |
| SKILL.md body | examples/workflow-walkthroughs.md | clickable `[examples/workflow-walkthroughs.md](examples/workflow-walkthroughs.md)` link | WIRED | Present in Workflow examples section |
| routing-tables.md | marketplace.json | every plugin name + deep-skill name is byte-exact copy | WIRED | 13 plugin names verified; all 35 deep-skill names confirmed present in marketplace.json with zero drift |
| expert-intuitions.md | SKILL.md Boundary conditions | 8 Lede strings byte-identical in both files | WIRED | All 8 lede strings confirmed byte-identical via direct comparison |
| workflow-walkthroughs.md | marketplace.json | 6 key deep-skill + 3 plugin names byte-exact | WIRED | All 9 names confirmed in marketplace.json |

### Data-Flow Trace (Level 4)

Not applicable. All four artifacts are markdown content files — they are the data source, not components that render from a dynamic data source. There is no upstream API or database; the content IS the deliverable. The relevant cross-file consistency check (lede byte-matching between expert-intuitions.md and SKILL.md) was verified in Key Links above.

### Behavioral Spot-Checks

| Behavior | Command | Result | Status |
|----------|---------|--------|--------|
| routing-tables.md has 13 plugin sections byte-exact | `grep -c '^### hack-skills-'` | 13 | PASS |
| routing-tables.md has 35 data rows | Python count per section | 35 (9x3 + 4x2 distribution) | PASS |
| routing-tables.md has 6 dual-load rules | `grep -cE '^### Rule [1-6]:'` | 6 | PASS |
| SKILL.md has no STUB markers | `grep -E 'STUB\|TBD\|FIXME\|XXX'` | 0 matches | PASS |
| SKILL.md body has 7 H2 sections | `grep -c '^## '` | 7 | PASS |
| SKILL.md frontmatter first-para cap | `wc -c` on first paragraph | 224 chars (<=250) | PASS |
| SKILL.md frontmatter total cap | `wc -c` on full description | 844 chars (<=1024) | PASS |
| All 8 lede strings byte-match | Direct string comparison | All 8 match exactly | PASS |
| No @branch suffix on any install command | `grep -E '@hack-skills-marketplace@'` | 0 matches across all files | PASS |
| No clickable sub-file-to-sub-file links (Pitfall 5) | `grep -E '\]\(.*routing-tables\|expert-intuitions\|workflow-walkthroughs'` | 0 matches in sub-files | PASS |
| expert-intuitions.md line count within range | `wc -l` | 67 (within 60-200) | PASS |
| workflow-walkthroughs.md line count within range | `wc -l` | 80 (within 80-180) | PASS |
| Router loadable via Skill(hack-skills-router) | Claude Code session required | Not run | SKIP — human UAT |

### Probe Execution

No dedicated probe scripts were declared for this phase in PLAN frontmatter or SUMMARY files. The PLAN verification blocks contained inline shell probes (run during execution) not as standalone .sh files. The executor's SUMMARY files report all probes passed.

### Requirements Coverage

| Requirement | Source Plan | Description | Status | Evidence |
|-------------|------------|-------------|--------|----------|
| ROUTER-01 | 02-04-PLAN.md | Router invocable via Skill(hack-skills-router); body provides hybrid routing + dual-load + availability | SATISFIED | SKILL.md exists with 7-section body, cross-refs to all 3 sub-files, inline dual-load example, plugin-availability guidance |
| ROUTER-02 | 02-01-PLAN.md | routing-tables.md signal->topic-skill table, ~30 high-signal rows, dual-load rules, plugin-recommendation template | SATISFIED | 35 rows (>=30), 13 plugin sections, 6 dual-load rules (>=5), plugin-recommendation template present |
| ROUTER-03 | 02-02-PLAN.md | expert-intuitions.md documents 8 boundary conditions with attribution | SATISFIED | 8 intuitions with Lede+Mechanism+Example each, MIT attribution to yaklang/hack-skills |
| ROUTER-04 | 02-03-PLAN.md | workflow-walkthroughs.md provides 3-4 end-to-end traces | SATISFIED | 4 traces with 6-label structure each |
| ROUTER-05 | 02-01-PLAN.md + 02-03-PLAN.md + 02-04-PLAN.md | Router doubles as discovery surface (install commands surface) | SATISFIED | 13 install lines in routing-tables.md (one per plugin), 4 install commands in workflow-walkthroughs.md, 2 install commands in SKILL.md Plugin availability section |

All 5 ROUTER requirements (ROUTER-01 through ROUTER-05) are covered by Plans 02-01 through 02-04. No orphaned requirements found.

### Anti-Patterns Found

| File | Line | Pattern | Severity | Impact |
|------|------|---------|----------|--------|
| SKILL.md:52 | 52 | "compresses upstream's 4-step operating model" — upstream has 3 steps, not 4 | WARNING | Factually wrong claim sourced from erroneous 02-CONTEXT.md entry (WR-01 from code review) |
| patterns/routing-tables.md:135,140-141,150 | 135, 140-141, 150 | 4 canonical skills referenced in dual-load rules (`api-auth-and-jwt-abuse`, `api-recon-and-docs`, `api-authorization-and-bola`, `authbypass-authentication-flaws`) have no row in the per-plugin sections | WARNING | Dual-load section presupposes table coverage that doesn't exist; reader introduced to skills without a routing-table entry (WR-02 from code review) |
| SKILL.md:5-11 | 5-11 | 13 frontmatter triggers (`LFI`, `RFI`, `CORS`, `prototype pollution`, `deserialization`, `type juggling`, `NoSQL injection`, `WAF bypass`, `file upload`, `parameter pollution`, `SAML assertion`, `OAuth misconfiguration`, `BFLA`) advertised but have no routing-table row | WARNING | Contract gap between auto-invoke surface and routing surface; model falls back to reasoning with no table to consult; noted as BLOCKER in 02-REVIEW.md CR-01 but marked advisory per the verification brief |
| routing-tables.md:5,15,...121 | multiple | 13 plugin H3 sections have no H2 parent — TOC outline shows H3s as H1 children, then H2 siblings appear after (WR-03) | INFO | Structural markdown heading irregularity; does not affect content correctness |
| expert-intuitions.md:65, workflow-walkthroughs.md:21 | 65, 21 | `/.well-known/jwks.json` presented as the JWKS endpoint — this is one common path but providers vary (Auth0, Microsoft, Google, Okta, Cognito all differ) (WR-04) | INFO | Over-claim in operational example; could mislead during real audit |
| SKILL.md:44 | 44 | Double "over" in routing strategy ("prefer reasoning over deep-skill descriptions over force-fitting") — ambiguous parsing (IN-01) | INFO | Prose clarity issue only |
| SKILL.md:56 | 56 | "bilateral JWT context" — non-standard jargon (IN-02) | INFO | Clarity issue; no security impact |

No `TBD`, `FIXME`, or `XXX` markers found in any phase file (STUB removal confirmed via grep across all 4 artifacts).

### Human Verification Required

#### 1. Router Runtime Load and Auto-Invocation

**Test:** In a Claude Code session with `hack-skills-router` installed, send a security query such as "How do I test JWT alg=none confusion on this API?" and observe whether the router skill is loaded automatically via description-match and whether the body's routing guidance and boundary conditions appear in the response.

**Expected:** The router is auto-invoked; Claude references the routing strategy and recommends a specific deep skill (e.g., `jwt-oauth-token-attacks` in `hack-skills-auth-bypass`); if `hack-skills-auth-bypass` is not installed, Claude outputs `/plugin install hack-skills-auth-bypass@hack-skills-marketplace`.

**Why human:** Requires Claude Code runtime — description-match auto-invocation, skill load path, and install-command surfacing behavior cannot be verified with static file analysis.

---

#### 2. Sub-file Progressive Disclosure

**Test:** In a Claude Code session, explicitly invoke `Skill(hack-skills-router)`, then ask Claude to show routing tables by referencing `patterns/routing-tables.md` and expert intuitions by referencing `patterns/expert-intuitions.md`.

**Expected:** Claude can load and display content from both sub-files via the clickable cross-reference links in SKILL.md body; the progressive-disclosure chain (SKILL.md body -> patterns/*.md, examples/*.md) functions as a one-level-deep load.

**Why human:** Requires Claude Code runtime — the actual file-loading behavior of clickable relative links in skill bodies is only observable in a live session.

---

## Notes on Code Review Advisory Findings

The code review (02-REVIEW.md) identified 1 BLOCKER advisory, 5 warnings, and 5 info items. Per the verification brief, these are advisory and do not block the verdict. However, the three most impactful items are flagged here for the user's attention before Phase 3:

**CR-01 (most important):** 13 trigger terms in the SKILL.md frontmatter (`LFI`, `CORS`, `prototype pollution`, `NoSQL injection`, `WAF bypass`, `OAuth misconfiguration`, etc.) have no routing-table row. When the model is auto-invoked on a prompt containing these terms, the static table cannot route and the model falls back to reasoning with no deep-skill description to ground the reasoning. Options: (a) expand routing-tables.md with rows for the missing skills (preferred — adds ~10-12 rows, stays within D-03's 2-3 per section guideline for most sections), or (b) prune the frontmatter trigger list to match actual table coverage.

**WR-01:** SKILL.md:52 states "The router compresses upstream's 4-step operating model into 3 considerations." Upstream `hack` SKILL.md has 3 steps, not 4. The "4-step" claim originated in an error in 02-CONTEXT.md. A single line edit fixes this.

**WR-02:** 4 canonical skills (`api-auth-and-jwt-abuse`, `api-recon-and-docs`, `api-authorization-and-bola`, `authbypass-authentication-flaws`) are referenced in dual-load rules but have no per-plugin routing-table row. Fixing CR-01 (Option A) resolves WR-02 automatically.

---

## Gaps Summary

No gaps blocking goal achievement. All 4 programmatically-verifiable success criteria (SC-1 through SC-4) are met. SC-5 (manual smoke check) is explicitly deferred to human UAT per ROADMAP.md. The phase goal — "Make the router skill the intelligence layer. Body of router SKILL.md carries the hybrid routing strategy + dual-load + availability handling; progressive-disclosure sub-files carry the full routing tables, intuitions, and walkthroughs that the router cites by name" — is achieved in the codebase. The advisory items from 02-REVIEW.md are quality improvements, not goal-achievement failures.

---

_Verified: 2026-05-22T18:30:00Z_
_Verifier: Claude (gsd-verifier)_
