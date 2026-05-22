# Requirements: hack-skills-marketplace

**Defined:** 2026-05-22
**Core Value:** Selective topical activation of hacking-skill prompts so a session's context only carries skills relevant to whatever topical area is being worked on right now.

## v1 Requirements

### Schema Validation

Confirms the marketplace schema actually supports the planned approach. A "no" on any of these collapses the whole strategy and forces a redesign — so they ship first, in a minimal test marketplace.

- [x] **VERIFY-01**: User can address individual skill subdirectories in the `skills` array rather than being limited to parent directories. *Validated Phase 1 with mechanism correction: requires `source: git-subdir` with `path: "skills"` (NOT plain `source: github`). Working paths are root-level (`./skill-name`, not `./skills/skill-name`). Evidence: `claude plugin details` reports curated counts (`Skills (2)` for auth-bypass, `Skills (1)` for recon).*
- [x] **VERIFY-02**: After installing a single group plugin built with `strict: false` + curated `skills` array, the session's system reminder lists only the curated skills — not all skills present in the source repo. *Validated Phase 1 via fresh `claude -p` session: system reminder showed exactly 3 skills total across both installed plugins (2 from auth-bypass, 1 from recon), no leakage of the other 99 upstream skills.*
- [x] **VERIFY-03**: Multiple plugin entries sharing `yaklang/hack-skills` as their `source` produce separate cache entries in `~/.claude/plugins/cache/` and all install/enable cleanly without collision. *Validated Phase 1: with both plugins installed concurrently, `~/.claude/plugins/cache/hack-skills-marketplace/` contains parallel `hack-skills-recon/c6f732befcae-32c1cf49/` and `hack-skills-auth-bypass/c6f732befcae-32c1cf49/` subdirs. The shared SHA+path-hash version token does not collide (parent dirs partition by plugin name).*

### Grouping

Ensures the group taxonomy is grounded in actual skill content topicality — not arbitrary category names. This is the work that prevents groups from feeling random.

- [ ] **GROUP-01**: All 102 skills in `yaklang/hack-skills` are individually reviewed, with a one-line summary of what each skill covers captured in a classification artifact
- [ ] **GROUP-02**: A final topical group taxonomy is derived from skill-content topicality, with documented rationale for each bucket explaining what unifies its skills
- [ ] **GROUP-03**: Each proposed group contains 8–15 skills — within the sizing constraint from PROJECT.md (or is explicitly flagged as catch-all / sized-with-reason)
- [ ] **GROUP-04**: Skills that don't map cleanly to any topical bucket are explicitly enumerated in the classification artifact (in a catch-all bucket) with reasoning

### Build-Out

Implements the verified, classified groups as actual marketplace entries.

- [ ] **BUILD-01**: `.claude-plugin/marketplace.json` declares ~8 plugin entries, one per topical group (final count derived from GROUP outcomes)
- [ ] **BUILD-02**: Each plugin entry has a clear name (`hack-skills-<topic>`), a one-line description aligned to its scope, and a `skills` array referencing specific upstream paths
- [ ] **BUILD-03**: Every plugin entry uses `strict: false` and a `git-subdir` source descriptor `{ "source": "git-subdir", "url": "https://github.com/yaklang/hack-skills.git", "path": "skills" }`. Skill paths in the `skills` array are root-level (e.g. `./api-recon-and-docs`), NOT nested under `./skills/`. *(Originally specified `source: github` — corrected during Phase 1 research; see PROJECT.md Key Decisions and `.planning/phases/01-schema-verification/01-VERIFICATION.md`.)*

### Publish & Live Validation

Confirms the marketplace works end-to-end against a real GitHub install — not just locally — and matches the install commands users will actually run.

- [ ] **PUB-01**: The marketplace is pushed to the default branch of `github.com/SpencerPresley/hack-skills-marketplace` (public)
- [ ] **PUB-02**: `/plugin marketplace add SpencerPresley/hack-skills-marketplace` succeeds for a fresh user (no `@branch` suffix needed)
- [ ] **PUB-03**: `/plugin install <group>@hack-skills-marketplace` succeeds for each defined group
- [ ] **PUB-04**: After installing any group, the session's system reminder lists only that group's curated skills — verified end-to-end against the live published marketplace (not just local path install)

## v2 Requirements

Deferred. Acknowledged but not in this milestone.

### Sync / Maintenance

- **SYNC-01**: Documented process for refreshing groups when `yaklang/hack-skills` adds new skills (manual snapshot review, decide which group(s) absorb new skills)
- **SYNC-02**: Tooling or script to surface "new upstream skills since last review" to make the manual snapshot step low-friction

### Discoverability

- **DISC-01**: README in this repo lists every group with its skill set, so users browsing the GitHub page can see what each group contains without inspecting marketplace.json

## Out of Scope

| Feature | Reason |
|---------|--------|
| Upstream PR to `yaklang/hack-skills` | Sibling effort tracked in `docs/PR-PLAN.md`. Different repo, different audience, different goals. |
| Modifying upstream skill files | `yaklang/hack-skills` is read-only inspiration. All curation lives in `marketplace.json`. |
| Auto-sync / live tracking from upstream | Snapshot consumption is fine. Live tracking is unnecessary complexity. |
| Forking and physically regrouping upstream | Defeated by `strict: false` + `skills` arrays. Whole partitioning lives in `marketplace.json`. |
| Symlink trees or alternative layouts | Workarounds rejected — if individual-skill addressing fails verification, the plan changes rather than gets hacked. |
| Non-skill components (hooks, agents, MCP, commands) in groups | Groups are skill-only curations. Other component types aren't the focus. |
| Versioning groups independently | Default-ref install per PROJECT.md constraint. No per-group versioning. |
| Group plugins that combine multiple `source` repos | Each group's source is exactly `yaklang/hack-skills`. Multi-source curation isn't the model. |

## Traceability

Which phases cover which requirements. Updated during roadmap creation.

| Requirement | Phase | Status |
|-------------|-------|--------|
| VERIFY-01 | Phase 1 | ✓ Validated |
| VERIFY-02 | Phase 1 | ✓ Validated |
| VERIFY-03 | Phase 1 | ✓ Validated |
| GROUP-01 | Phase 2 | Pending |
| GROUP-02 | Phase 2 | Pending |
| GROUP-03 | Phase 2 | Pending |
| GROUP-04 | Phase 2 | Pending |
| BUILD-01 | Phase 3 | Pending |
| BUILD-02 | Phase 3 | Pending |
| BUILD-03 | Phase 3 | Pending |
| PUB-01 | Phase 4 | Pending |
| PUB-02 | Phase 4 | Pending |
| PUB-03 | Phase 4 | Pending |
| PUB-04 | Phase 4 | Pending |

**Coverage:**
- v1 requirements: 14 total
- Mapped to phases: 14 ✓
- Unmapped: 0

---
*Requirements defined: 2026-05-22*
*Last updated: 2026-05-22 after roadmap creation*
