---
phase: 03-marketplace-build-out
plan: 01
status: complete
completed: 2026-05-22
files_changed:
  - .claude-plugin/marketplace.json (rewritten: 2-plugin Phase 1 test shape → 13-plugin full taxonomy)
  - .planning/phases/03-marketplace-build-out/03-01-PLAN.md (added)
  - .planning/phases/03-marketplace-build-out/03-01-SUMMARY.md (this file)
  - .planning/phases/03-marketplace-build-out/03-VERIFICATION.md (added)
requirements_addressed: [BUILD-01, BUILD-02, BUILD-03]
---

# Plan 03-01 Summary

## What was built

`.claude-plugin/marketplace.json` was rewritten from the Phase 1 2-plugin test shape into the full marketplace manifest covering all 13 non-excluded topical buckets from `02-CLASSIFICATION.json`.

The file was generated programmatically (`jq` filter against the classification JSON) so the result is purely derived from Phase 2's locked taxonomy — no hand-edited fields, no copy-paste drift surface.

## Plugins shipped

13 plugins, alphabetical by bucket key:

| # | Plugin name | Skills | Notes |
|---|-------------|--------|-------|
| 1 | `hack-skills-active-directory-and-windows` | 7 | sized-with-reason per Phase 2 D-02 |
| 2 | `hack-skills-ai-and-supply-chain` | 3 | catch-all per Phase 2 D-06 |
| 3 | `hack-skills-auth-bypass` | 9 | primary (within 8–15) |
| 4 | `hack-skills-binary-exploitation` | 12 | primary (within 8–15) |
| 5 | `hack-skills-crypto-attacks` | 7 | sized-with-reason per Phase 2 D-02 |
| 6 | `hack-skills-forensics-and-misc-recovery` | 3 | catch-all per Phase 2 D-06 |
| 7 | `hack-skills-linux-and-post-exploit` | 10 | primary (within 8–15) |
| 8 | `hack-skills-mobile` | 3 | sized-with-reason per Phase 2 D-02 |
| 9 | `hack-skills-recon` | 6 | sized-with-reason per Phase 2 D-02 |
| 10 | `hack-skills-server-side-execution` | 8 | primary (within 8–15) |
| 11 | `hack-skills-web-client-attacks` | 10 | primary (within 8–15) |
| 12 | `hack-skills-web-injection` | 10 | primary (within 8–15) |
| 13 | `hack-skills-web-protocol-attacks` | 7 | sized-with-reason per Phase 2 D-02 |

**Total skills exposed:** 95 (= 102 upstream skills − 7 routers).

Every plugin uses the locked Phase 1 schema:
```json
{
  "source": { "source": "git-subdir", "url": "https://github.com/yaklang/hack-skills.git", "path": "skills" },
  "strict": false,
  "skills": [ "./<root-level-skill>", ... ]
}
```

## Phase 3 decision: `hack-skills-routers` excluded

Phase 2's `02-CLASSIFICATION.md` flagged this for Phase 3 (§ `hack-skills-routers`):
> *Whether this bucket should be exposed as its own marketplace plugin OR excluded from `marketplace.json` entirely is a Phase 3 question.*

**Decision: exclude.** Rationale anchored in PROJECT.md:
> *Grouping axis: Group by skill-content topicality, NOT by yaklang's own categorization. Skills that don't map to any topical bucket probably shouldn't have a group at all.*

The router skills (`api-sec`, `auth-sec`, `business-logic-vuln`, `file-access-vuln`, `hack`, `injection-checking`, `recon-for-sec`) are the upstream's own categorization layer — meta-navigation entry points, not topical playbooks. They had a home in `02-CLASSIFICATION.json` for Phase 2's D-07 every-skill-assigned invariant; that home does not earn a marketplace plugin.

A future maintainer who wants router-style entry-point access can install multiple topical plugins or revisit this decision in a follow-up phase.

## Evidence (per-task acceptance criteria)

### Task 03-01-01 — generate manifest

```
$ jq '. | {plugin_count: (.plugins | length)}' .claude-plugin/marketplace.json
{ "plugin_count": 13 }

$ jq '.plugins | all(...)' .claude-plugin/marketplace.json   # invariant check
true
```

No `hack-skills-hack-skills-routers` plugin appears (routers correctly excluded).

### Task 03-01-02 — validate + register

```
$ claude plugin validate .claude-plugin/marketplace.json
✔ Validation passed

$ claude plugin marketplace update hack-skills-marketplace
✔ Successfully updated marketplace: hack-skills-marketplace
```

### Task 03-01-03 — drift check (SC #5)

```
$ jq -n --slurpfile m .claude-plugin/marketplace.json \
       --slurpfile c .planning/phases/02-skill-classification-taxonomy/02-CLASSIFICATION.json \
       '... set-equal diff ...'
{
  "keys_match": true,
  "skills_match": true,
  "diff": []
}
```

Zero drift between every plugin's `skills` array and its source bucket in `02-CLASSIFICATION.json`.

### Task 03-01-04 — install smoke test (SC #4)

Picked `hack-skills-mobile` (smallest bucket, fresh name not used in Phase 1 test marketplace).

```
$ claude plugin install hack-skills-mobile@hack-skills-marketplace --scope user
✔ Successfully installed plugin: hack-skills-mobile@hack-skills-marketplace (scope: user)

$ claude plugin details hack-skills-mobile@hack-skills-marketplace
hack-skills-mobile
  Mobile platform pentesting
  Source: hack-skills-mobile@hack-skills-marketplace

Component inventory
  Skills (3)  android-pentesting-tricks, ios-pentesting-tricks, mobile-ssl-pinning-bypass
  ...

$ claude plugin uninstall hack-skills-mobile
✔ Successfully uninstalled plugin: hack-skills-mobile (scope: user)
```

Skills line matches the bucket's `skills` array character-for-character. Description matches the bucket's verbatim `description`. Phase 1's D-03-REVISED isolation pattern re-confirmed against the Phase 3 manifest.

## Out of scope (deferred to Phase 4)

- Publishing the manifest to GitHub's default branch
- Smoke-testing the install flow against the live remote (`/plugin marketplace add SpencerPresley/hack-skills-marketplace`)
- End-to-end isolation check against the live published repo

Phase 3 closes out local-install-only validation. Phase 4 handles the publish + live install loop.
