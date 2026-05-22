---
plan: 01-02
phase: 01-schema-verification
status: completed-via-research-detour
completed: 2026-05-22
supersedes_via: 01-VERIFICATION.md
---

# Plan 01-02 Summary: Install + Capture VERIFY-01/02 Evidence

## What this plan was originally for

Install `hack-skills-auth-bypass` from the test marketplace via local path, observe runtime behavior of `strict: false` + curated `skills` array, and capture VERIFY-01 (`claude plugin details` Skills line) + VERIFY-02 (system reminder excerpt) evidence into `01-VERIFICATION.md`.

## What actually happened

Task 1 of this plan (install + `claude plugin details` capture) produced FAIL evidence under the original D-03 source descriptor (`source: github`): `Skills (102)` with ~10,503 always-on tokens, not the curated 2 with ~200 tok. Per the plan's explicit FAIL acceptance criterion and CONTEXT.md D-09's "halt before Phase 2" pivot stance, the executor returned a checkpoint to the orchestrator instead of proceeding to Task 2.

The orchestrator and user then triggered a mid-phase research detour rather than abandoning the project strategy. That detour:

1. Re-read the official Claude Code plugin marketplace docs (`~/code/hack-skills-wip/reference/cc-docs-plugin-marketplace-page-content.md`).
2. Re-read the pre-execution `01-RESEARCH.md` and surfaced Pitfall 5's framing (cache materialization vs runtime exposure are distinct surfaces — the cache will always show all 102, the runtime should show only the curated subset).
3. Tested three working real-world marketplaces (`wondelai-skills`, `claude-plugins-official/box`, `claude-plugins-official/netsuite-suitecloud`) on the user's machine to triangulate the failure.
4. Identified the structural difference: all working patterns have skill dirs at the source root, ours had them nested under `./skills/`.
5. Hypothesized that `git-subdir` source with `path: "skills"` would sparse-clone only the `skills/` subdir, lifting skill dirs to the clone root.
6. Tested the hypothesis: PASS. `Skills (2) 401-403-bypass-techniques, api-auth-and-jwt-abuse`, ~205 tok.

VERIFY-01 evidence (corrected) and VERIFY-02 evidence (fresh `claude -p` session system reminder) were both captured against the fixed mechanism. See `01-VERIFICATION.md` for the full evidence sections and the Pivot Policy entries that document why D-09's "halt" was de-escalated to a mid-phase mechanism correction rather than a strategy pivot.

## Files modified or created

- `.claude-plugin/marketplace.json` — replaced original github+nested-skills shape with corrected git-subdir+root-level-skills shape (Committed: see `fix(01): correct marketplace.json source descriptor`)
- `.planning/phases/01-schema-verification/01-VERIFICATION.md` — authoritative output for this plan's scope (all three VERIFY answers)
- `.planning/phases/01-schema-verification/.task01-evidence-after-fix.txt` — verbatim shell output capturing the corrected-state evidence
- `.planning/phases/01-schema-verification/.task02-system-reminder.txt` — verbatim system reminder capture (VERIFY-02 PRIMARY evidence)

## Files NOT modified (intentional)

- `~/code/hack-skills-wip/hack-skills/` (the user's local fork of yaklang/hack-skills) — confirmed unmodified, 102 skill subdirs intact, source immutability preserved.
- Upstream `yaklang/hack-skills` GitHub repository — never touched.

## Cleanup performed at plan close

- Uninstalled research-only test plugins (`team-motivation@wondelai-skills`, `product-strategy@wondelai-skills`, `box@claude-plugins-official`, `netsuite-suitecloud@claude-plugins-official`) — installed only as triangulation tooling, no ongoing use.
- Removed Wave 2 worktree (`agent-aeb5ab90940820ed3`) and deleted its branch — its evidence (`.task01-evidence.txt` capturing the failed-state output) was lost with the worktree; the equivalent failed-state evidence is summarized in this SUMMARY and the RESEARCH.md appendix instead.
- Removed the stale `~/.claude/plugins/cache/hack-skills-marketplace/hack-skills-auth-bypass/c6f732befcae/` cache leftover from the failed github-source attempt.

## Outstanding items: NONE

Both VERIFY-01 (SECONDARY via `claude plugin details`) and VERIFY-02 (PRIMARY via fresh `claude -p` system reminder, plus SECONDARY via `claude plugin details`) evidence captured. No deferred human verification.
