# Roadmap: hack-skills-marketplace

## Overview

Ship a personal Claude Code marketplace that curates `yaklang/hack-skills` (102 skills) into ~8 topically-grouped, individually-installable plugins. The journey starts with cheap schema verification against a 2-group test marketplace (because a "no" on individual-skill addressing collapses the strategy), proceeds through reading and classifying all 102 upstream skills against `purplehaze`'s feature surface, builds out the full `.claude-plugin/marketplace.json`, and finishes with end-to-end live validation against the published GitHub repo so anyone can run `/plugin marketplace add SpencerPresley/hack-skills-marketplace` and `/plugin install <group>@hack-skills-marketplace` for any defined group.

## Phases

**Phase Numbering:**
- Integer phases (1, 2, 3): Planned milestone work
- Decimal phases (2.1, 2.2): Urgent insertions (marked with INSERTED)

Decimal phases appear between their surrounding integers in numeric order.

- [x] **Phase 1: Schema Verification** - Build a minimal 2-group test marketplace and answer the 3 open schema questions (individual-skill addressing, context isolation, per-plugin cache behavior) before committing to the full plan (completed 2026-05-22)
- [ ] **Phase 2: Skill Classification & Taxonomy** - Read all 102 upstream `SKILL.md` files, capture a one-line summary per skill in a classification artifact, and derive the final topical group taxonomy grounded in `purplehaze`'s feature surface
- [ ] **Phase 3: Marketplace Build-Out** - Author the full `.claude-plugin/marketplace.json` with all ~8 group entries using `strict: false` + curated `skills` arrays cherry-picked from the classification artifact
- [ ] **Phase 4: Publish & Live Validation** - Push the marketplace to GitHub's default branch and verify the install flow works end-to-end for a fresh user against the live published repo

## Phase Details

### Phase 1: Schema Verification
**Goal**: Prove that `strict: false` + individual-skill paths in the `skills` array actually deliver curated, context-isolated, per-plugin-cached groups — before spending effort on classification and full build-out
**Depends on**: Nothing (first phase)
**Requirements**: VERIFY-01, VERIFY-02, VERIFY-03
**Success Criteria** (what must be TRUE):
  1. A 2-group test `marketplace.json` exists pointing at `yaklang/hack-skills` with each group's `skills` array listing 2–3 specific individual skill paths (e.g. `./skills/api-recon-and-docs`, not parent directories)
  2. After installing a test group locally, the session's system reminder lists only the curated skills from that group — no other skills from the upstream repo appear
  3. With both test groups installed concurrently, `~/.claude/plugins/cache/` contains two separate clean cache entries (one per plugin), and both groups enable without collision
  4. The 3 open questions from `docs/PLAN.md` are explicitly answered (yes/no with evidence) in a verification artifact captured in the repo
  5. If any answer is "no", a documented pivot decision exists before Phase 2 begins (e.g. switch to parent-directory grouping, abandon the approach, etc.)
**Plans**: 4 plans
  - [x] 01-01-PLAN.md — Author test `.claude-plugin/marketplace.json` (D-01 2-group composition) and validate it via `claude plugin validate`
  - [x] 01-02-PLAN.md — Install hack-skills-auth-bypass via local path, capture VERIFY-01 (`claude plugin details` Skills line) and VERIFY-02 (system-reminder excerpt + sanity check) evidence, write the first two VERIFY sections of 01-VERIFICATION.md, tear down install state
  - [x] 01-03-PLAN.md — Install both plugins concurrently (D-10 exception), capture VERIFY-03 cache-tree evidence via `find -mindepth 2 -maxdepth 2 -type d | wc -l`, append the VERIFY-03 section to 01-VERIFICATION.md, final teardown
  - [x] 01-04-PLAN.md — Append the Pivot Policy section per D-08/D-09 (one entry per VERIFY question), set frontmatter terminal status, validate all 5 Roadmap Phase 1 Success Criteria, update STATE.md

### Phase 2: Skill Classification & Taxonomy
**Goal**: Produce the data foundation that drives the marketplace — a per-skill classification of all 102 upstream skills plus a final topical group taxonomy grounded in `purplehaze`'s feature surface
**Depends on**: Phase 1
**Requirements**: GROUP-01, GROUP-02, GROUP-03, GROUP-04
**Success Criteria** (what must be TRUE):
  1. A classification artifact exists in the repo listing all 102 skills from `yaklang/hack-skills`, each with a one-line summary describing what the skill covers (sourced from its `SKILL.md`)
  2. A final topical group taxonomy is documented with one entry per proposed group, each entry stating its scope, its rationale for existing as its own group, and which `purplehaze` feature surface it serves
  3. Each proposed group's skill membership falls within the 8–15 skills-per-group sizing constraint from PROJECT.md
  4. Skills that don't map to any `purplehaze`-relevant bucket are explicitly listed in the classification artifact and tagged as intentionally excluded from groups, with the reason captured
  5. Every one of the 102 skills appears in the classification artifact exactly once — either assigned to a group or in the excluded list
**Plans**: 2 plans
  - [ ] 02-01-PLAN.md — Author `02-extract-descriptions.sh`, extract 102 verbatim SKILL.md descriptions, apply D-01 starter scaffold + D-02 resize + D-03 emergent + D-06 catch-all routing to produce first-pass bucket assignment in `.first-pass-classification.md`, surface compact taxonomy summary at the D-16 mid-phase user-review checkpoint, block on user approval (`status: checkpoint_approved`)
  - [ ] 02-02-PLAN.md — After user approval, verify precondition + re-run D-07 invariant, write final `02-CLASSIFICATION.md` per D-12 layout (per-bucket sections + catch-all + master 102-row table + decision log + Roadmap success criteria check) and final `02-CLASSIFICATION.json` per D-13 bucket-keyed shape (drop-in `skills` arrays for Phase 3 using Phase 1 D-03-REVISED root-level paths)

### Phase 3: Marketplace Build-Out
**Goal**: Translate the verified schema and the finalized taxonomy into a complete `.claude-plugin/marketplace.json` covering all defined groups
**Depends on**: Phase 2
**Requirements**: BUILD-01, BUILD-02, BUILD-03
**Success Criteria** (what must be TRUE):
  1. `.claude-plugin/marketplace.json` declares one plugin entry per group from the Phase 2 taxonomy (target ~8, final count derived from GROUP outcomes)
  2. Each plugin entry has a `name` matching the pattern `hack-skills-<topic>`, a one-line `description` aligned to the group's scope, and a `skills` array referencing the specific upstream paths assigned to that group in Phase 2
  3. Every plugin entry uses `strict: false` and has a `source` of `{ "source": "git-subdir", "url": "https://github.com/yaklang/hack-skills.git", "path": "skills" }` (originally specified as `source: github` — corrected during Phase 1 research after that pattern was found not to honor the `skills` array curation; see PROJECT.md Key Decisions)
  4. The marketplace passes a local install smoke test: `/plugin marketplace add ./<repo>` succeeds and every defined group is listed as installable
  5. The skill membership of each built plugin entry exactly matches the assignment captured in the Phase 2 classification artifact (no drift between taxonomy and implementation)
**Plans**: TBD

### Phase 4: Publish & Live Validation
**Goal**: Ship the marketplace to GitHub and prove the public install flow works for a fresh user — closing out v1.0
**Depends on**: Phase 3
**Requirements**: PUB-01, PUB-02, PUB-03, PUB-04
**Success Criteria** (what must be TRUE):
  1. The completed marketplace is committed and pushed to the default branch of `github.com/SpencerPresley/hack-skills-marketplace` and the repo is publicly visible
  2. From a fresh state (marketplace not previously added), `/plugin marketplace add SpencerPresley/hack-skills-marketplace` succeeds without requiring an `@branch` suffix
  3. From that fresh state, `/plugin install <group>@hack-skills-marketplace` succeeds for every group defined in the marketplace
  4. After installing any group against the live published marketplace, the session's system reminder lists only that group's curated skills — confirming the Phase 1 isolation result still holds end-to-end against the real GitHub install, not just local
  5. The install commands match the shape promised in PROJECT.md (plain `/plugin install <name>@hack-skills-marketplace`, no `@branch` suffix) with no per-group workarounds
**Plans**: TBD

## Progress

**Execution Order:**
Phases execute in numeric order: 1 → 2 → 3 → 4

| Phase | Plans Complete | Status | Completed |
|-------|----------------|--------|-----------|
| 1. Schema Verification | 4/4 | Complete   | 2026-05-22 |
| 2. Skill Classification & Taxonomy | 0/2 | Not started | - |
| 3. Marketplace Build-Out | 0/TBD | Not started | - |
| 4. Publish & Live Validation | 0/TBD | Not started | - |
</content>
</invoke>