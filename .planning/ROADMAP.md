# Roadmap: hack-skills-marketplace (v2.0)

## Overview

Build a sidecar `hack-skills-router` plugin that layers routing intelligence + methodology scaffolding + trust gating on top of v1's 13 topical plugins, without modifying v1. The journey starts with a cheap mechanism spike (verify the sidecar plugin shell loads and stub hooks fire), proceeds through authoring the router skill's terse-frontmatter + body + progressive-disclosure sub-files, then fills in the real SessionStart and UserPromptSubmit hook payloads with the security-context regex, and closes with end-to-end live validation against the published v2 marketplace.

Design source: `.planning/specs/2026-05-22-v2-router-design.md`. v1.0 (shipped) history: `.planning/MILESTONES.md`.

## Phases

**Phase Numbering:** Continues from milestone v1.0 (which used 1–4); v2.0 resets to start at Phase 1 since the v1 phase dirs are archived under `.planning/phases-archive-v1.0/`.

- [x] **Phase 1: Plugin Mechanism Spike** — Stand up the sidecar plugin shell (`plugins/hack-skills-router/`), add the marketplace.json entry, declare hook configs with stub scripts, and verify the whole structure installs and fires from the local marketplace.
- [x] **Phase 2: Router Skill + Content** — Author the router `SKILL.md` (frontmatter + body), populate `patterns/routing-tables.md` (full v1-plugin coverage), `patterns/expert-intuitions.md` (8 boundary conditions + attribution), and `examples/workflow-walkthroughs.md` (3–4 end-to-end traces). (completed 2026-05-22)
- [ ] **Phase 3: Hook Scripts + Regex** — Replace the Phase 1 stub hook scripts with the real SessionStart payload (~250 tok trust + ops + intuitions) and UserPromptSubmit nudge (~75 tok) + the security-context regex matcher.
- [ ] **Phase 4: Live Validation** — Push v2 marketplace to GitHub, verify a fresh user can install the router from the live published repo and that all hook + routing flows work end-to-end.

## Phase Details

### Phase 1: Plugin Mechanism Spike

**Goal**: De-risk the entire v2 architecture cheaply by verifying that an in-repo authored plugin (referenced via relative-path `source`) with hook configs actually loads and fires from the marketplace — before investing in real content.

**Depends on**: Nothing (first v2.0 phase)
**Requirements**: PLUGIN-01, PLUGIN-02

**Success Criteria** (what must be TRUE):

1. `.claude-plugin/marketplace.json` contains a new entry for `hack-skills-router` with `source: "./plugins/hack-skills-router"` (the relative-path form, NOT git-subdir), alongside the existing 13 v1 topical plugin entries — no v1 entries removed or altered.
2. `plugins/hack-skills-router/.claude-plugin/plugin.json` exists declaring valid `name`, `description`, `version` (`0.1.0`), and `author`.
3. `plugins/hack-skills-router/skills/hack-skills-router/SKILL.md` exists as a STUB (frontmatter description + ≤30 lines of body — final body lands in Phase 2). `plugins/hack-skills-router/hooks/hooks.json` declares both SessionStart and UserPromptSubmit hooks with STUB shell scripts (e.g., `echo "[stub] SessionStart fired"` and `echo "[stub] UserPromptSubmit fired"`). The UserPromptSubmit `matcher` can be a placeholder (a single keyword like `XSS` is fine — full regex lands in Phase 3).
4. From the local marketplace: `/plugin install hack-skills-router@hack-skills-marketplace` succeeds and `claude plugin details hack-skills-router` lists the skill + both hook declarations.
5. With `hack-skills-router` AND a v1 topical plugin (e.g., `hack-skills-auth-bypass`) BOTH installed in the same session: stub SessionStart inject is observable in Claude's session context (via Claude's behavior or a visible system-reminder excerpt), and both plugins coexist in `claude plugin marketplace list` without conflict.

**Plans**: 3 plans

Plans:
**Wave 1**

- [x] 01-01-PLAN.md — Create the `plugins/hack-skills-router/` plugin tree (plugin.json, SKILL.md stub, hooks.json, both stub `.sh` scripts, chmod +x)
- [x] 01-02-PLAN.md — Append the 14th marketplace entry (`hack-skills-router`) to `.claude-plugin/marketplace.json` with relative-path source, leaving the 13 v1 entries untouched

**Wave 2** *(blocked on Wave 1 completion)*

- [x] 01-03-PLAN.md — UAT: pre-flight validate artifacts, re-register marketplace as local path, install + coexistence install, observe SessionStart/UserPromptSubmit stub markers after session boundary

---

### Phase 2: Router Skill + Content

**Goal**: Make the router skill the intelligence layer. Body of router `SKILL.md` carries the hybrid routing strategy + dual-load + availability handling; progressive-disclosure sub-files carry the full routing tables, intuitions, and walkthroughs that the router cites by name.

**Depends on**: Phase 1
**Requirements**: ROUTER-01, ROUTER-02, ROUTER-03, ROUTER-04, ROUTER-05

**Success Criteria** (what must be TRUE):

1. Router `SKILL.md` body (per spec §5.7) provides: (a) when-to-use bullets, (b) trust model, (c) hybrid routing strategy (static table primary + reasoning fallback), (d) 3-step operating model, (e) plugin-availability handling instructions, (f) boundary-conditions quick reference, (g) workflow examples cross-reference.
2. `plugins/hack-skills-router/skills/hack-skills-router/patterns/routing-tables.md` provides a signal → topic-skill table with at least one row per v1 topical plugin (13 plugins minimum; ~30 high-signal rows typical), plus a Dual-load Rules section (≥5 rules), plus the plugin-recommendation template per spec §5.8.
3. `patterns/expert-intuitions.md` documents all 8 upstream `hack` SKILL.md expert intuitions (BOLA semantics, JWT pre-payload checks, race-condition targets, parameter-name attack surface, second-order vulns, reused filter logic, older API versions, business-logic impact) with one-paragraph explanations each and clear attribution to upstream yaklang/hack-skills (MIT-licensed).
4. `examples/workflow-walkthroughs.md` contains ≥3 end-to-end traces (suggested: admin panel + JWT cookie, GraphQL with introspection, .env in webroot, coupon reuse). Each trace shows: prompt → testing phase identified → signal route → dual-load if any → boundary conditions surfaced → next-test recommendation.
5. Manual smoke check: against a representative security query (e.g., "test JWT alg=none on this API"), the router is loadable via `Skill(hack-skills-router)` and its body content references both the patterns/ and examples/ sub-files. When the recommended topical plugin is not installed, the router's content guides Claude to output the specific `/plugin install ...` command.

**Plans**: 4 plans

Plans:
**Wave 1** *(parallel — no inter-plan dependencies; all 3 ground out at marketplace.json)*

- [x] 02-01-PLAN.md — Author `patterns/routing-tables.md` (13 plugin-keyed sections, 35 routing rows, 6 dual-load rules, plugin-recommendation template) → ROUTER-02, ROUTER-05
- [x] 02-02-PLAN.md — Author `patterns/expert-intuitions.md` (8 paraphrased intuitions: Lede + Mechanism + Example each, file-level attribution to yaklang/hack-skills MIT) → ROUTER-03
- [x] 02-03-PLAN.md — Author `examples/workflow-walkthroughs.md` (4 worked traces: admin/JWT, GraphQL, .env, coupon-reuse) → ROUTER-04, ROUTER-05

**Wave 2** *(blocked on Wave 1 — body cross-references all 3 sub-files; cross-file lede consistency check requires expert-intuitions.md present)*

- [x] 02-04-PLAN.md — Rewrite `SKILL.md` in place: production frontmatter (dual-cap respected) + 7-section body (D-12) + cross-refs to all 3 sub-files + inline cross-plugin dual-load example → ROUTER-01, ROUTER-05

---

### Phase 3: Hook Scripts + Regex

**Goal**: Replace Phase 1's stub hooks with the real payloads + the security-context regex matcher, so the hook layer actually does its job (trust gating once per session, light nudge on security-context prompts).

**Depends on**: Phase 2 (so the hook nudges can reference real router content)
**Requirements**: HOOKS-01, HOOKS-02, HOOKS-03, HOOKS-04

**Success Criteria** (what must be TRUE):

1. `plugins/hack-skills-router/hooks/scripts/session-start.sh` outputs the full SessionStart payload per spec §5.4 (~250 tok: trust model + 3-step operating model + 8-entry expert-intuitions snapshot). Script is `bash`, uses `${CLAUDE_PLUGIN_ROOT}` if any path is needed, exits 0, completes within the 5s timeout declared in hooks.json.
2. `plugins/hack-skills-router/hooks/scripts/nudge.sh` outputs the full UserPromptSubmit nudge per spec §5.5 (~75 tok: confirm-scope + load-router + surface-boundary-conditions instructions). Same constraints as above (bash, CLAUDE_PLUGIN_ROOT, exit 0, 3s timeout).
3. `plugins/hack-skills-router/hooks/hooks.json` UserPromptSubmit `matcher` field contains the security-context regex from spec §5.3 (case-insensitive; vulnerability acronyms, security verb stems, security tool names, CVE pattern, security-recon file artifacts). JSON validates with `jq` and the regex parses without error in Claude Code.
4. Manual verification with the now-real hooks installed: SessionStart fires once on session start and the trust+ops+intuitions content is visibly present in Claude's context. UserPromptSubmit fires on at least 5 representative security prompts (XSS, SQLi, JWT, CVE-2024-NNNN, ".env exposure") and does NOT fire on 3 representative non-security prompts ("what's the weather", "refactor this helper", "explain Promise.all").

**Plans**: 2 plans

Plans:
**Wave 1**

- [x] 03-01-PLAN.md — Rewrite session-start.sh + nudge.sh in place; edit hooks.json UserPromptSubmit matcher to final regex; run automated probes (drift 4a/4b/4c, token-count, JSON validity, chmod, functional shell smoke) → HOOKS-01, HOOKS-02, HOOKS-03, HOOKS-04

**Wave 2** *(blocked on Wave 1 — needs files written before cache refresh + UAT runs)*

- [x] 03-02-PLAN.md — Plugin cache refresh + manual UAT (SessionStart Option B, 6 positive prompts, 4 negative prompts including D-02 file-upload exclusion check); evidence captured to 03-UAT-EVIDENCE.md → HOOKS-01, HOOKS-02, HOOKS-03, HOOKS-04 ✓ All 11 prompts PASS (5/5 SessionStart markers; 6/6 pos; 4/4 neg); D-02 EXCLUSION confirmed. 2026-05-23.

---

### Phase 4: Live Validation

**Goal**: Prove the v2 architecture works end-to-end against the published marketplace — not just the local clone. Closes v2.0.

**Depends on**: Phase 3
**Requirements**: VAL-01, VAL-02, VAL-03, VAL-04, VAL-05

**Success Criteria** (what must be TRUE):

1. v2 marketplace (commits from Phases 1–3) is pushed to default branch `main` of `github.com/SpencerPresley/hack-skills-marketplace` and the new `hack-skills-router` plugin entry is visible in the public marketplace.json on GitHub.
2. From a fresh `/plugin marketplace add SpencerPresley/hack-skills-marketplace` (or `update` if already added in a prior session), the marketplace picks up the new `hack-skills-router` entry alongside the existing 13. No `@branch` suffix required.
3. `/plugin install hack-skills-router@hack-skills-marketplace` from the live published marketplace works without errors. `claude plugin details hack-skills-router@hack-skills-marketplace` lists the router skill + both hook declarations + the source = git clone of this repo.
4. SessionStart hook injection lands in a fresh post-install session — verified by Claude referencing the operating model / expert intuitions when asked a security question, OR via a hook debug trace if Claude Code exposes one.
5. UserPromptSubmit hook fires on a real security prompt (e.g., "How do I test for JWT alg=none confusion?"), and a cross-topic prompt (e.g., "doing recon on this REST API, want to test JWT auth and look for IDOR") triggers the router's dual-skill loading + multi-plugin install recommendations.

---

## Progress

**Execution Order:**
Phases execute in numeric order: 1 → 2 → 3 → 4.

Phase 3 depends conceptually on Phase 2 (hook nudge text references router content), but the dependency is loose — Phase 3 could start in parallel once Phase 2 outlines the router body.

| Phase | Plans Complete | Status | Completed |
|-------|----------------|--------|-----------|
| 1. Plugin Mechanism Spike | 3/3 | Complete | 2026-05-22 |
| 2. Router Skill + Content | 4/4 | Complete   | 2026-05-22 |
| 3. Hook Scripts + Regex | 1/2 | In Progress|  |
| 4. Live Validation | 0/TBD | Not started | - |

## Coverage check

- v2.0 requirements: 16 total
- Mapped to phases: 16 (PLUGIN-01..02 → P1; ROUTER-01..05 → P2; HOOKS-01..04 → P3; VAL-01..05 → P4)
- Unmapped: 0 ✓

---

*Roadmap created: 2026-05-22 at v2.0 milestone open*
*v1.0 roadmap history: see `.planning/MILESTONES.md` (Phase 1–4 of v1.0 completed; phase artifacts archived to `.planning/phases-archive-v1.0/`)*
