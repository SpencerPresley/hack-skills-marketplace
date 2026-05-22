# Requirements: hack-skills-marketplace (v2.0)

**Defined:** 2026-05-22
**Milestone:** v2.0 — Router & Hooks (Sidecar)
**Core Value:** Selective topical activation of hacking-skill prompts, with optional routing and methodology scaffolding via the sidecar router plugin.
**Design source:** `.planning/specs/2026-05-22-v2-router-design.md`

*v1.0 requirements (VERIFY-*, GROUP-*, BUILD-*, PUB-*) shipped in milestone v1.0 — see `.planning/MILESTONES.md` and PROJECT.md Validated section. This file is scoped to v2.0.*

## v2.0 Requirements

Each requirement maps to a roadmap phase (see Traceability section, populated during roadmap creation).

### Plugin Shell (PLUGIN)

Sidecar plugin can be installed alongside v1 topical plugins.

- [ ] **PLUGIN-01**: User can install the sidecar `hack-skills-router` plugin via `/plugin install hack-skills-router@hack-skills-marketplace`. The marketplace.json entry uses relative-path `source: "./plugins/hack-skills-router"` (not git-subdir), and the plugin's `plugin.json` declares name, description, version, author.
- [ ] **PLUGIN-02**: User can install `hack-skills-router` and any v1 topical plugin (e.g., `hack-skills-auth-bypass`) in the same session without conflict. `claude plugin marketplace list` and `claude plugin details` show both as present and active.

### Hooks (HOOKS)

Both hooks fire as designed without forcing rigid output structure on Claude.

- [ ] **HOOKS-01**: SessionStart hook fires exactly once per session and injects the trust-model reminder + 3-step operating model + 8-entry expert-intuitions snapshot (~250 tok total; content per design spec §5.4).
- [ ] **HOOKS-02**: UserPromptSubmit hook fires on prompts matching the security-context regex (covering vulnerability acronyms, security verb stems, security tool names, CVE patterns, security-recon file artifacts per design spec §5.3) and injects the routing nudge (~75 tok; content per design spec §5.5).
- [ ] **HOOKS-03**: UserPromptSubmit hook does NOT fire on prompts containing no security keywords. Verified via at least one non-security prompt producing no injection.
- [ ] **HOOKS-04**: Both hook scripts are `bash`, use `${CLAUDE_PLUGIN_ROOT}` for path resolution, exit cleanly with status 0, and complete within their declared timeouts (5s SessionStart, 3s UserPromptSubmit).

### Router Skill + Content (ROUTER)

The router teaches Claude how to route security tasks and surfaces boundary conditions.

- [ ] **ROUTER-01**: User/Claude can invoke the router skill via `Skill(hack-skills-router)`. The body provides hybrid routing strategy (static signal table primary + model-reasoning fallback), dual-skill loading rules, and plugin-availability handling.
- [ ] **ROUTER-02**: Router's `patterns/routing-tables.md` provides a signal → topic-skill mapping with rows covering all 13 v1 topical plugins (~30 high-signal rows), plus a set of dual-load rules for cross-topic queries (e.g., recon + auth, SSRF + business-logic, API testing + auth).
- [ ] **ROUTER-03**: Router's `patterns/expert-intuitions.md` documents the 8 high-value boundary conditions from upstream `hack` SKILL.md (BOLA semantics, JWT pre-payload checks, race-condition target selection, parameter-name attack surface, second-order vulns, reused filter logic, older API versions, business-logic impact) with one-paragraph explanations each. Includes attribution to upstream.
- [ ] **ROUTER-04**: Router's `examples/workflow-walkthroughs.md` provides 3–4 end-to-end example traces showing the router applied to realistic prompts (admin panel + JWT cookie; GraphQL with introspection; `.env` in webroot; coupon-reuse business flow).
- [ ] **ROUTER-05**: When Claude routes to a skill whose containing topical plugin is not currently installed, Claude's response includes the specific install command (e.g., `Run: /plugin install hack-skills-auth-bypass@hack-skills-marketplace`) — the router doubles as discovery surface for v1's topical plugins.

### Live Validation (VAL)

End-to-end check against the published v2 marketplace.

- [ ] **VAL-01**: v2.0 marketplace is published to `github.com/SpencerPresley/hack-skills-marketplace` such that a fresh `/plugin marketplace add SpencerPresley/hack-skills-marketplace` picks up the new `hack-skills-router` plugin entry.
- [ ] **VAL-02**: Installing `hack-skills-router` from the live published marketplace works without errors. `claude plugin details hack-skills-router@hack-skills-marketplace` lists the router skill + the SessionStart/UserPromptSubmit hooks.
- [ ] **VAL-03**: SessionStart hook injection lands in a fresh post-install session — verified via Claude's behavior referencing the operating model / expert intuitions, OR via a hook debug trace if exposed by Claude Code.
- [ ] **VAL-04**: UserPromptSubmit hook fires on a real security prompt (e.g., "How do I test for JWT alg=none confusion?") and the routing nudge is reflected in Claude's response (Claude loads the router skill, surfaces 2-3 boundary conditions, recommends specific deep skill from the routing table).
- [ ] **VAL-05**: A cross-topic query (e.g., "doing recon on this REST API, want to test JWT auth and look for IDOR") triggers the router's dual-skill loading rules and yields a multi-skill recommendation with install commands for any plugins not currently installed.

## Future Requirements

Deferred to v2.1 or later. Tracked but not in v2.0 roadmap.

### Sync / Maintenance (from v1.0 deferred — still relevant)

- **SYNC-01**: Documented process for refreshing groups when `yaklang/hack-skills` adds new skills.
- **SYNC-02**: Tooling or script to surface "new upstream skills since last review" to make the manual snapshot step low-friction.

### Discoverability (from v1.0 deferred — still relevant)

- **DISC-01**: README in this repo lists every plugin with its skill set so users browsing the GitHub page can see what each plugin contains without inspecting marketplace.json.

### Router / Hook Enhancements (new in v2.0 planning)

- **ROUTER-FUT-01**: Hook kill-switch env var (`HACK_SKILLS_SKIP_HOOK=1`) for cases where hook fatigue manifests.
- **ROUTER-FUT-02**: Lifecycle hooks beyond SessionStart + UserPromptSubmit (PreCompact, Stop, etc.) for richer context management.
- **ROUTER-FUT-03**: Multi-language router triggers (Chinese upstream patterns from the upstream `hack` skill's bilingual descriptions).

## Out of Scope

Explicitly excluded from v2.0. Documented to prevent scope creep.

| Feature | Reason |
|---------|--------|
| Modifying upstream `yaklang/hack-skills` files | PROJECT.md hard constraint (source immutability) |
| Auto-sync with upstream | Snapshot consumption model per PROJECT.md |
| Restructuring v1's 13 topical plugin groupings | v2 is additive |
| Forced output template ("Testing Phase: X / Signal Route: Y" headers on every response) | Explicitly rejected during design (spec §3 decision 2) — performative, interferes with payload/checklist responses |
| Multi-language router triggers | English only for v2.0 (spec §10) |
| Lifecycle hooks beyond SessionStart + UserPromptSubmit | Future enhancement (spec §10) |
| Per-plugin bundle pattern (router + hook embedded in each v1 plugin) | Rejected during design — 13× duplication, cross-topic routing breaks (spec §12) |
| Mega-plugin (all 95 skills + router + hook in one) | Rejected during design — defeats Core Value at ~9.5K always-on tokens (spec §2.2) |

## Traceability

Phases mapped to requirements. Populated by the roadmapper agent.

| Requirement | Phase | Status |
|-------------|-------|--------|
| PLUGIN-01 | (TBD by roadmapper) | Pending |
| PLUGIN-02 | (TBD by roadmapper) | Pending |
| HOOKS-01 | (TBD by roadmapper) | Pending |
| HOOKS-02 | (TBD by roadmapper) | Pending |
| HOOKS-03 | (TBD by roadmapper) | Pending |
| HOOKS-04 | (TBD by roadmapper) | Pending |
| ROUTER-01 | (TBD by roadmapper) | Pending |
| ROUTER-02 | (TBD by roadmapper) | Pending |
| ROUTER-03 | (TBD by roadmapper) | Pending |
| ROUTER-04 | (TBD by roadmapper) | Pending |
| ROUTER-05 | (TBD by roadmapper) | Pending |
| VAL-01 | (TBD by roadmapper) | Pending |
| VAL-02 | (TBD by roadmapper) | Pending |
| VAL-03 | (TBD by roadmapper) | Pending |
| VAL-04 | (TBD by roadmapper) | Pending |
| VAL-05 | (TBD by roadmapper) | Pending |

**Coverage (pre-roadmap):**
- v2.0 requirements: 16 total
- Mapped to phases: 0 (pending roadmap)
- Unmapped: 16 ⚠ (will resolve at roadmap step)

---
*Requirements defined: 2026-05-22*
*Design source: `.planning/specs/2026-05-22-v2-router-design.md`*
