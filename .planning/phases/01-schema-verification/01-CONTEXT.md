# Phase 1: Schema Verification - Context

**Gathered:** 2026-05-22
**Status:** Ready for planning

<domain>
## Phase Boundary

Build a minimal 2-group test `marketplace.json`, install it locally, and answer the three open schema questions from `docs/PLAN.md` (VERIFY-01 individual-skill addressing, VERIFY-02 session-context isolation, VERIFY-03 per-plugin cache behavior) with documented evidence. Capture a pivot policy for any "no" outcome before Phase 2 can start.

**In scope:** authoring the test `marketplace.json`, installing it via local path, observing session/cache state, writing the verification artifact.
**Out of scope:** github push + public install (Phase 4), classification of all 102 skills (Phase 2), full ~8-group build-out (Phase 3).

</domain>

<decisions>
## Implementation Decisions

### Test Marketplace Composition
- **D-01:** Two test groups, both real candidate buckets from `PROJECT.md` (not throwaways):
  - `hack-skills-recon` → `./skills/api-recon-and-docs` (1 skill)
  - `hack-skills-auth-bypass` → `./skills/401-403-bypass-techniques`, `./skills/api-auth-and-jwt-abuse` (2 skills)
- **D-02:** Three skill paths total across the two groups. Picks two specific individual paths in one group (auth-bypass) — that is what directly exercises VERIFY-01. Topically distant groups make VERIFY-02 isolation easy to eyeball.
- **D-03:** Both groups use `strict: false` and `{ "source": "github", "repo": "yaklang/hack-skills" }` per the PROJECT.md key decisions. No `plugin.json` is added to the source repo.

### Install Source
- **D-04:** Local-path install only for Phase 1: `/plugin marketplace add ./hack-skills-marketplace` (or absolute path to this repo). No git push, no GitHub install during verification.
  - Rationale: Phase 4 owns end-to-end published-repo validation. Duplicating it here would muddy phase boundaries and slow iteration. If a local-path test passes, a github-install test is incremental.

### Verification Artifact
- **D-05:** Verification output goes to `.planning/phases/01-schema-verification/01-VERIFICATION.md` — phase-local, matches GSD's per-phase artifact convention. Keeps `docs/` reserved for longer-lived user-facing plan documents.
- **D-06:** Artifact contains one section per VERIFY question (01/02/03) with: a yes/no answer, the install command used, the exact observation evidence (system-reminder excerpt, `/plugin` output, `ls ~/.claude/plugins/cache/` listing), and a one-line conclusion. Plus a "Pivot Policy" section (see D-09).

### Context-Isolation Measurement Method (for VERIFY-02)
- **D-07:** Use BOTH measurements, with the system-reminder excerpt as ground truth:
  - Primary evidence: a fresh Claude Code session after install, capturing the `# available-skills` system-reminder block — that IS the context the model sees.
  - Secondary evidence: `/plugin` command output (or equivalent) snapshotted as a sanity check on enabled state.
  - Both go in the verification artifact for VERIFY-02 specifically. VERIFY-01 and VERIFY-03 don't need the dual measurement.

### Pivot Policy (Roadmap Success Criterion #5)
- **D-08:** Record the pivot decision for each "no" outcome in the verification artifact BEFORE Phase 2 starts, even if every answer is "yes" (in which case each entry reads "N/A — answer was yes").
- **D-09:** Pre-decided pivot stances:
  - **VERIFY-01 (individual paths) "no":** Halt before Phase 2. Symlinks are rejected by PROJECT.md; restructuring/forking upstream is also out of scope. A "no" here forces a separate decision conversation about whether to abandon the strategy or accept parent-only grouping with a redesigned bucket model — not auto-executed.
  - **VERIFY-02 (context isolation) "no":** Halt. The whole value proposition is selective context activation; if curated `skills` arrays still leak the full source repo, the marketplace concept collapses for this use case.
  - **VERIFY-03 (cache collision) "no":** Document the actual collision behavior and decide whether a workaround (e.g., dedupe by hash, separate sources) is viable. Likely allows continuation if VERIFY-01/02 pass.

### Test Hygiene
- **D-10:** Between verification sub-tests, uninstall the previous test plugin(s) and remove the test marketplace (`/plugin marketplace remove` + `/plugin uninstall`) to keep `~/.claude/plugins/cache/` observable. Final VERIFY-03 step requires both groups installed concurrently — that's the one case where cleanup is deferred until after evidence is captured.

### Claude's Discretion
- Filename/structure inside `01-VERIFICATION.md` (headings, table vs prose for evidence) — planner picks readable conventions.
- Whether to keep the test `.claude-plugin/marketplace.json` after verification or scrub it for Phase 3 to author cleanly — planner can decide based on whether the test config is forward-compatible with the eventual full set.
- Exact wording of the install/observation commands documented in the artifact — must be reproducible, format is open.

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Project context
- `.planning/PROJECT.md` — Core value, constraints (`strict: false`, no `@branch`, group sizing 8–15, group-by-purplehaze-surface), key decisions table.
- `.planning/REQUIREMENTS.md` §Schema Validation — VERIFY-01/02/03 exact wording and acceptance.
- `.planning/ROADMAP.md` §Phase 1 — Goal, dependencies, 5 success criteria (#5 = pivot decision required if any "no").

### Pre-existing plan documents
- `docs/PLAN.md` — Marketplace skeleton (lines 88–119), the three Open Questions (lines 146–181), Build Order (lines 184–195), Why Not Other Approaches (lines 198–211). This is THE source spec for what the test marketplace should look like and what the verification answers.
- `docs/PR-PLAN.md` — Sibling upstream PR effort. Out of scope for this phase but referenced for context on why upstream stays unmodified.

### Claude Code platform docs (external)
- https://code.claude.com/docs/en/plugin-marketplaces — Full marketplace schema. Read before authoring the test `marketplace.json`.
- https://code.claude.com/docs/en/plugin-marketplaces#strict-mode — `strict: false` behavior. Validates D-03.
- https://code.claude.com/docs/en/plugins-reference — Plugin component fields (including `skills`).

### Local artifacts under verification
- `.claude-plugin/marketplace.json` — Currently empty placeholder. The test marketplace is authored INTO this file.
- `~/.claude/plugins/cache/` — Inspection target for VERIFY-03 (per-plugin cache behavior). Exists on this machine.
- `~/code/hack-skills-wip/hack-skills/` — Local sibling clone of `yaklang/hack-skills` upstream. 102 skills under `skills/`. Convenient for sanity-checking skill paths but the marketplace install still pulls from github per the `source` descriptor.

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- `docs/PLAN.md` "Marketplace Skeleton" block (lines 92–119) — copy-paste-ready JSON for the test marketplace; only the skill paths need to be the ones picked in D-01.
- Empty `.claude-plugin/marketplace.json` is already present and tracked — no scaffolding needed, just write into it.

### Established Patterns
- None yet — this is the first executable phase. The patterns established here (artifact location, evidence format) will set precedent for later phases.
- GSD convention: phase artifacts live under `.planning/phases/${padded_phase}-${slug}/`. D-05 follows this.

### Integration Points
- `.claude-plugin/marketplace.json` is the only file modified for the test marketplace itself.
- The verification artifact at `01-VERIFICATION.md` is the integration point with Phase 2 — Phase 2 won't start until that artifact records a "yes"-or-documented-pivot for all three VERIFY questions.

</code_context>

<specifics>
## Specific Ideas

- Use PLAN.md's exact suggested skills (`api-recon-and-docs`, `401-403-bypass-techniques`, `api-auth-and-jwt-abuse`) verbatim. The user has already mentally signed off on those as illustrative; using them removes a decision point and keeps the test mapped 1:1 to existing documentation.
- Capture system-reminder evidence as a verbatim quote block in the verification artifact, not paraphrased. The exact text is the evidence.
- Cache-collision check (VERIFY-03) should also note the on-disk size of each cache entry — confirms that "small for a text-only repo" assumption from PROJECT.md Key Decisions.

</specifics>

<deferred>
## Deferred Ideas

- **Github-install validation** — explicitly deferred to Phase 4 (PUB-02, PUB-03, PUB-04). Not a substitute for the local-path test in Phase 1.
- **Full skill classification / final taxonomy** — Phase 2 (GROUP-01..04). Phase 1's two test buckets are placeholders for verification, not the final list.
- **All ~8 marketplace entries** — Phase 3 (BUILD-01..03). Phase 1 stays at 2 groups regardless of how easy the build-out looks.
- **Sync / refresh process for upstream changes** — v2 (SYNC-01, SYNC-02).
- **README listing every group's skill set** — v2 (DISC-01).

</deferred>

---

*Phase: 01-Schema Verification*
*Context gathered: 2026-05-22*
