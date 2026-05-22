---
phase: 02-skill-classification-taxonomy
plan: 01
subsystem: classification-taxonomy
type: execute
autonomous: false
wave: 1
tags: [extraction, first-pass-classification, mid-phase-checkpoint, d-16, taxonomy]
dependency-graph:
  requires:
    - .planning/phases/02-skill-classification-taxonomy/02-CONTEXT.md (D-01 through D-16)
    - .planning/phases/02-skill-classification-taxonomy/02-PATTERNS.md (extraction-tooling + checkpoint procedural patterns)
    - .planning/phases/01-schema-verification/01-VERIFICATION.md (D-03-REVISED root-level skill paths, carried forward for Plan 02-02 JSON output)
    - /Users/spencerpresley/code/hack-skills-wip/hack-skills/skills/ (102 SKILL.md files, read-only)
  provides:
    - 102-skill verbatim description corpus (re-derivable via the extraction script)
    - 14-bucket first-pass taxonomy with explicit sizing-status per bucket
    - User-approved checkpoint signal (status: checkpoint_approved) — the structural precondition for Plan 02-02
    - 11 documented borderline assignments with D-09 reasoning and alternate candidates
  affects:
    - .planning/phases/02-skill-classification-taxonomy/.first-pass-classification.md (the load-bearing intermediate dotfile, evolved across all three tasks)
    - .planning/phases/02-skill-classification-taxonomy/02-extract-descriptions.sh (the repeatable extraction tool)
tech-stack:
  added:
    - Bash + awk extraction pipeline (POSIX-standard, no new packages)
  patterns:
    - Phase-1-precedent: verbatim-source-fenced-evidence convention (re-applied for SKILL.md descriptions per D-14)
    - Phase-1-precedent: dotfile naming for intermediate/non-deliverable artifacts (`.first-pass-classification.md`)
    - Phase-2-specific NEW: mid-phase user-review checkpoint as a planned pause point (D-16) — first instance in this project
key-files:
  created:
    - .planning/phases/02-skill-classification-taxonomy/02-extract-descriptions.sh
    - .planning/phases/02-skill-classification-taxonomy/.first-pass-classification.md
    - .planning/phases/02-skill-classification-taxonomy/02-01-SUMMARY.md
  modified: []
decisions:
  - "14-bucket taxonomy (11 primary topical + 3 themed catch-alls per D-06) covers all 102 skills with zero duplicates and zero misfits-dropped"
  - "Split D-01 starter `injection` into four sub-buckets (web-injection / web-protocol-attacks / web-client-attacks / server-side-execution) along the natural subtopic axis — the unsplit cluster would have been ~35 skills, well above the D-02 >15 split threshold"
  - "Merge D-01 starter `payloads` (only 2 candidate skills) into adjacent buckets per D-02 <5 threshold — no standalone payloads bucket survives"
  - "Rename + scope-expand D-01 starters: crypto→crypto-attacks (+blockchain), binary→binary-exploitation, ad→active-directory-and-windows (+broader Windows post-exploit)"
  - "D-06 preferred shape applied: 3 themed catch-alls (ai-and-supply-chain, forensics-and-misc-recovery, hack-skills-routers) rather than single-misc fallback — the misfit set did cluster"
  - "5 buckets flagged sized-with-reason (web-protocol-attacks 7, crypto-attacks 7, active-directory-and-windows 7, recon 6, mobile 3) — sizing exceptions explicitly justified rather than forced into bad merges that would violate D-04 (skill-content topicality)"
  - "User approved first-pass taxonomy as-is on the first D-16 checkpoint surfacing; zero edit iterations"
metrics:
  duration: "~30 minutes total executor time across three tasks"
  completed-date: 2026-05-22
  iterations: 1
  commits: 3
---

# Phase 2 Plan 1: Extract + First-Pass Classification Summary

## One-liner

Extracted 102 verbatim SKILL.md descriptions via a Bash/awk pipeline, produced a 14-bucket first-pass taxonomy (D-01 → D-02 → D-06), surfaced it at the mandatory D-16 mid-phase checkpoint, and captured user approval as the structural precondition for Plan 02-02.

## Objective Recap

Phase 2's load-bearing procedural pattern is the **mid-phase user-review checkpoint** (CONTEXT.md D-16). Plan 02-01's job is the first-pass-then-pause workflow: extract the corpus, produce the proposed bucket shape, surface it to the user, and capture explicit approval before the final committed artifacts (`02-CLASSIFICATION.md` + `02-CLASSIFICATION.json`) get written. Plan 02-02 then writes those finals from the approved state.

The two-plan split (this plan = first-pass + checkpoint; Plan 02-02 = finalize after approval) makes the user-approval gate **structural** — Plan 02-02's `depends_on: ['02-01']` chain plus its frontmatter `checkpoint_approval_signal` check are the enforcement mechanism, not a soft convention.

## What Was Built

### Task 1: 02-extract-descriptions.sh (the repeatable extraction tool)

A Bash + awk pipeline that reads `/Users/spencerpresley/code/hack-skills-wip/hack-skills/skills/<name>/SKILL.md` for every one of the 102 skill directories, extracts the YAML frontmatter `description` field, unfolds folded YAML scalars (`description: >-`) per scalar resolution rules (join continuation lines with single space, collapse whitespace runs, trim edges), and emits one TSV row per skill to stdout.

**Coverage:** Handles both single-line (78 of 102 skills) and multi-line (24 of 102 skills) folded forms. Verified verbatim against `401-403-bypass-techniques` (canonical sample from 02-CONTEXT.md code_context block).

**Source-immutability invariant** (PROJECT.md + CLAUDE.md): script writes only to stdout, never to any path under `/Users/spencerpresley/code/hack-skills-wip/hack-skills/skills/`. Verified via `find ... -name "*.tsv" -o -name "*.json" -o -name "*.classification*" | wc -l == 0`.

**Hard invariants:** script exits non-zero if (a) the source directory doesn't exist, (b) any SKILL.md is missing, (c) any extracted description is empty, or (d) the row count is not exactly 102.

### Task 2: .first-pass-classification.md (the intermediate dotfile)

The single load-bearing intermediate consumed by Plan 02-02 after the D-16 checkpoint. Lifecycle is tracked via the frontmatter `status` field:

1. `corpus_extracted` (Task 1 commit `b67dee7`) — frontmatter + Extracted Corpus table embedding all 102 (skill-name, verbatim-description) pairs alphabetically.
2. `first_pass_complete` (Task 2 commit `a1870ba`) — adds the 6 required sections: First-Pass Buckets (14 subsections), Merge/Split Moves, Emergent Buckets (D-03, none triggered), Catch-all Shape (D-06 multiple themed), Borderline List (11 documented), D-07 Invariant Check.
3. `checkpoint_approved` (Task 3, this commit) — adds the `## Checkpoint Approval` section capturing the verbatim user response and the approval metadata.

### Task 3: D-16 checkpoint approval recorded

The mid-phase user-review checkpoint surfaced a compact summary message (bucket overview table, merge/split moves, emergent-bucket statement, catch-all shape, borderline list) to the user via the orchestrator. The user approved as-is — zero edit iterations. The verbatim user response is captured in the `## Checkpoint Approval` section of `.first-pass-classification.md`, the frontmatter status is advanced to `checkpoint_approved`, and Plan 02-02 is unblocked structurally.

## Final 14-Bucket Layout

11 primary topical buckets + 3 themed catch-alls per D-06 preferred shape. Total 102 skills, zero duplicates, zero unassigned (D-07 invariant verified independently against `ls hack-skills/skills/`).

| bucket-name | count | sizing-status | proposed marketplace description |
|---|---|---|---|
| binary-exploitation | 12 | within 8-15 | Binary exploitation and reverse engineering |
| web-injection | 10 | within 8-15 | Web-layer injection and input-driven attacks |
| web-client-attacks | 10 | within 8-15 | Client-side and browser-context web vulnerabilities |
| linux-and-post-exploit | 10 | within 8-15 | Linux/macOS post-exploitation and network pivoting |
| auth-bypass | 9 | within 8-15 | Authentication and authorization bypass |
| server-side-execution | 8 | within 8-15 | Server-side code execution and trust-boundary chains |
| web-protocol-attacks | 7 | sized-with-reason | HTTP protocol-layer attacks and request flow abuse |
| hack-skills-routers | 7 | catch-all per D-06 | Category routing and skill-selection entry points |
| crypto-attacks | 7 | sized-with-reason | Cryptography attacks and blockchain/DeFi exploits |
| active-directory-and-windows | 7 | sized-with-reason | Active Directory and Windows endpoint attacks |
| recon | 6 | sized-with-reason | Reconnaissance and attack-surface enumeration |
| mobile | 3 | sized-with-reason | Mobile platform pentesting |
| forensics-and-misc-recovery | 3 | catch-all per D-06 | Forensics, memory analysis, and steganographic recovery |
| ai-and-supply-chain | 3 | catch-all per D-06 | AI/ML security and software supply chain attacks |
| **TOTAL** | **102** | **14 buckets** | |

## Notable Decisions

### The D-01 → D-02 → D-06 path

The D-01 starter scaffold (8 buckets: recon, auth-bypass, injection, payloads, mobile, binary, ad, crypto) reshaped substantially under first-pass:

- **`injection` exploded to ~35 skills** if unsplit — every web vuln pulled toward it. Per D-02 `>15 splits along natural subtopic axis`, this is the canonical split case. The four-way split (`web-injection` / `web-protocol-attacks` / `web-client-attacks` / `server-side-execution`) corresponds to four genuinely different threat models for real-world security sessions: input-data shape, HTTP message-framing shape, browser/client-policy shape, and server-side execution chain shape. Each lands at 7-10 skills.

- **`payloads` collapsed to 2 candidate skills** (`reverse-shell-techniques`, `unauthorized-access-common-services`). Below D-02's <5 merge threshold by a wide margin. The two skills had different natural neighbors (post-exploit vs recon), so they split rather than merging into a single new bucket. No standalone `payloads` bucket survives.

- **`ad`, `crypto`, `binary` scope-expanded** to absorb adjacent thin clusters that would otherwise have triggered their own sub-5 merges. `ad` → `active-directory-and-windows` (absorbed Windows lateral/priv-esc/AV); `crypto` → `crypto-attacks` (absorbed blockchain/DeFi); `binary` → `binary-exploitation` (made the reverse-engineering-tooling component explicit).

### Sized-with-reason vs catch-all distinction

Five buckets land below the 8-target with `sized-with-reason` (recon 6, mobile 3, crypto-attacks 7, active-directory-and-windows 7, web-protocol-attacks 7) and three with `catch-all per D-06` (ai-and-supply-chain 3, forensics-and-misc-recovery 3, hack-skills-routers 7). The split:

- **sized-with-reason** = a primary topical bucket where the natural merge candidate would violate D-04 (skill-content topicality). The bucket is coherent; it just landed small because of the upstream coverage shape.
- **catch-all per D-06** = a themed bucket holding misfits that don't fit any primary topical bucket. Same shape on disk (each is still a bucket with a description and would become a marketplace plugin), but the catch-all flag signals "this exists to give misfits a home" rather than "this is a load-bearing topical decomposition."

The plan's `must_haves.truths` explicitly allow both sizing-exception forms ("`catch-all per D-06`, or `sized-with-reason` per D-02"). Honoring the distinction matters for downstream curation: a Phase 3 author can treat sized-with-reason buckets as "first-class small topical plugins" and catch-all buckets as "opt-in safety net for skills that didn't fit elsewhere."

### Borderline list scope discipline

11 borderline assignments are documented (with D-09 reasoning and alternate candidates), out of 102 total assignments — a ~11% borderline rate, well below "every assignment with tangential overlap." Per CONTEXT.md SPECIFICS bullet 5 (`also_relevant_to` should be rare, not pervasive), this is the focused set the user should review, not an exhaustive cross-reference list. Most pivotal calls:

- `type-juggling` → `auth-bypass` (not `web-injection`): D-09 primary signal is the description's explicit "authentication, HMAC/signature checks, or token validation" framing.
- `unauthorized-access-common-services` → `recon` (not `auth-bypass`): "exposed without authentication" framing reads as enumeration, not auth-defeat.
- `subdomain-takeover` → `recon` (not `web-injection`): detection-first framing in the description.
- `ghost-bits-cast-attack` → `web-injection` (not `server-side-execution`): WAF-bypass meta-technique that enables injection primitives.
- `defi-attack-patterns` + `smart-contract-vulnerabilities` → `crypto-attacks` (not a standalone `blockchain` bucket): 2-skill standalone would violate D-02 <5 threshold; combined under shared "crypto" terminology as commonly used in the security community.

### The `hack-skills-routers` catch-all and its Phase 3 question

The 7 router/entry skills (`hack`, `api-sec`, `auth-sec`, `business-logic-vuln`, `file-access-vuln`, `injection-checking`, `recon-for-sec`) are categorically different from topical playbooks — they're meta-navigation indices that route between topic skills. Per D-05(b) they're "too generic/redundant" misfits. The plan groups them into `hack-skills-routers` to satisfy the D-07 invariant (every skill assigned exactly once), but flags a Phase 3 question: should these be exposed as their own marketplace plugin, OR excluded from marketplace.json entirely? The Plan 02-01 / 02-02 boundary is the wrong place to settle that — it's a curation decision that depends on whether the user wants the meta-routing layer always-on, opt-in, or absent. Plan 02-02 will inherit this open question.

## D-07 Invariant Verification

Verified independently in Task 2 (and re-confirmed at approval since the user requested zero edits):

- Total bucket-membership assignments: 102
- Unique skill-name count across all buckets: 102 (no duplicates)
- Set equality with `ls /Users/spencerpresley/code/hack-skills-wip/hack-skills/skills/ | sort`: PASS

**Verification commands embedded in `.first-pass-classification.md` `## D-07 Invariant Check` section**, with bucket cardinality table.

## Hand-off to Plan 02-02

Plan 02-02 consumes `.first-pass-classification.md` (`status: checkpoint_approved`, `bucket_count: 14`, `total_skills: 102`) as its load-bearing precondition. The handoff has three structural anchors:

1. **Frontmatter status flag** — Plan 02-02 Task 1's first action verifies `status: checkpoint_approved` exists in this file; if it doesn't, Plan 02-02 cannot start.
2. **`## Checkpoint Approval` section** — Plan 02-02's frontmatter `checkpoint_approval_signal` field references this section as the audit trail for "the user approved this exact taxonomy."
3. **`## First-Pass Buckets` member lists** — these become the per-bucket `skills` arrays in `02-CLASSIFICATION.json` after the `./` path prefix is applied per Phase 1 D-03-REVISED (root-level `./<skill-name>` form, NOT `./skills/<skill-name>` nested).

The verbatim 102-skill corpus in the Extracted Corpus section is what Plan 02-02 lifts into `02-CLASSIFICATION.md`'s per-bucket member lists AND the master 102-row lookup table, per CONTEXT.md D-12 + D-14 (verbatim source convention).

## Roadmap Requirements Progress (Phase 2)

This plan completes the first half of Phase 2's GROUP-01 through GROUP-04 requirements:

- **GROUP-01** (102 verbatim descriptions): corpus complete, embedded in `.first-pass-classification.md` Extracted Corpus section, re-derivable via `02-extract-descriptions.sh`.
- **GROUP-02** (bucket taxonomy with rationale): 14 per-bucket subsections with descriptions, sizing-status flags, and origin codes (D-01-kept / D-01-renamed / D-02-split / D-02-merge / D-06-themed-catch-all). Merge/split rationale captured in the dedicated section.
- **GROUP-03** (8-15 sizing with documented exceptions): 6 buckets within 8-15; 5 sized-with-reason with explicit reasons; 3 catch-all per D-06.
- **GROUP-04** (misfit routing to themed catch-alls): 3 themed catch-alls (`ai-and-supply-chain`, `forensics-and-misc-recovery`, `hack-skills-routers`) cover all misfits; D-05 per-member reason tags (`standalone` / `redundant`) populated.

These requirements are **not fully closed** until Plan 02-02 writes the final `02-CLASSIFICATION.md` and `02-CLASSIFICATION.json` from this approved state. Plan 02-01 produces the verified, user-approved INPUT that Plan 02-02 finalizes.

## Deviations from Plan

**None — plan executed exactly as written.**

- Task 1 acceptance criteria all met on first run (102 TSV rows, verbatim 401-403 match, source tree untouched).
- Task 2 acceptance criteria all met on first run (all 6 required sections, D-07 invariant PASS, independent count verification PASS).
- Task 3 (D-16 checkpoint) reached on schedule; user approved as-is on the first surfacing, no edit-iteration cycle needed.

## Threat Surface Scan

Reviewed all files created/modified in this plan against the plan's `<threat_model>` register. No new security-relevant surface introduced beyond what the register already documents:

- T-02-01 (source-tree write tampering): mitigated — `find ... | wc -l == 0` confirms zero derived files in source tree.
- T-02-02 (verbatim leak): accepted as planned — skill descriptions are already public on github.com/yaklang/hack-skills.
- T-02-03 (repudiation of approval): mitigated — `## Checkpoint Approval` section captures verbatim response + ISO date + approved-by + bucket/skill counts at approval.
- T-02-SC (npm/pip installs): not triggered — zero new package-manager installs; tooling is POSIX-standard Bash + awk only.

**No threat_flags found.** The plan's threat register accurately captured this plan's surface.

## Self-Check: PASSED

### Files exist

- [x] `/Users/spencerpresley/code/hack-skills-wip/hack-skills-marketplace/.claude/worktrees/agent-a4f2e0e6c99252c27/.planning/phases/02-skill-classification-taxonomy/02-extract-descriptions.sh` — FOUND, executable
- [x] `/Users/spencerpresley/code/hack-skills-wip/hack-skills-marketplace/.claude/worktrees/agent-a4f2e0e6c99252c27/.planning/phases/02-skill-classification-taxonomy/.first-pass-classification.md` — FOUND, status: checkpoint_approved
- [x] `/Users/spencerpresley/code/hack-skills-wip/hack-skills-marketplace/.claude/worktrees/agent-a4f2e0e6c99252c27/.planning/phases/02-skill-classification-taxonomy/02-01-SUMMARY.md` — FOUND (this file)

### Commits exist

- [x] `b67dee7` — `feat(02-01): extract 102 verbatim SKILL.md descriptions` (Task 1)
- [x] `a1870ba` — `feat(02-01): first-pass bucket assignment for 102 skills` (Task 2)
- [ ] (this commit, Task 3) — will be added when this SUMMARY is committed alongside the approval section

### must_haves.truths (from plan frontmatter)

- [x] All 102 SKILL.md description fields extracted verbatim — Task 1 verification PASS, 401-403 verbatim match confirmed.
- [x] Every one of the 102 skills assigned to exactly one bucket — D-07 invariant PASS (102 / 0 / 0).
- [x] Each bucket within 8-15 OR explicitly flagged sizing-exception — bucket cardinality table populated with sizing-status per bucket.
- [x] Misfits clustered into themed catch-all bucket(s) per D-06 preferred shape — 3 themed catch-alls, no single-misc fallback triggered.
- [x] Proposed taxonomy surfaced to user in compact checkpoint message before plan completes — surfaced in the executor's pre-approval message via the orchestrator.
- [x] User approval captured in writing before Plan 02-02 may begin — `## Checkpoint Approval` section with verbatim user response + approval metadata.

### Acceptance Criteria (Tasks 1-3)

- [x] Task 1 acceptance criteria: extraction script exists + executable + 102 TSV rows + 401-403 verbatim + intermediate frontmatter status: corpus_extracted + alphabetical corpus embedded + zero derived files in source tree.
- [x] Task 2 acceptance criteria: status advanced to first_pass_complete + bucket_count present + all 6 required sections present + D-07 invariant verified + every D-01 starter accounted for (kept/renamed/split/merged) + every misfit routed to catch-all + borderline list focused + source tree unchanged.
- [x] Task 3 acceptance criteria: status advanced to checkpoint_approved + `## Checkpoint Approval` section present with verbatim user response + D-07 invariant still holds (re-check by construction since zero edits requested) + source tree unchanged.
