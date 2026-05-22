---
status: passed
phase: 01-schema-verification
verified: 2026-05-22
verify_questions: VERIFY-01, VERIFY-02, VERIFY-03
all_answers: yes
pivot_required: false
mechanism_correction_during_phase: yes
evidence_files:
  - .planning/phases/01-schema-verification/.task01-evidence-after-fix.txt
  - .planning/phases/01-schema-verification/.task02-system-reminder.txt
---

# Phase 1 Verification: Schema Verification

## Summary

All three open schema questions (VERIFY-01 individual-skill addressing, VERIFY-02 context isolation, VERIFY-03 per-plugin cache behavior) answered **YES** with evidence, **after a mid-phase mechanism correction**. Phase 2 can proceed.

The mechanism correction is the load-bearing finding of this phase: the original source descriptor (`{ "source": "github", "repo": "yaklang/hack-skills" }`) was found NOT to honor the `skills` array curation — Claude Code 2.1.148 reports all 102 upstream skills under that pattern. Switching to `{ "source": "git-subdir", "url": "https://github.com/yaklang/hack-skills.git", "path": "skills" }` with root-level skill paths (no `./skills/` prefix) makes curation work as documented. This decision is now locked in PROJECT.md and propagated to BUILD-03 / Phase 3 Success Criterion 3.

| Question | Answer | Evidence Source |
|---|---|---|
| **VERIFY-01** Individual-skill addressing works | YES | `claude plugin details` reports the curated count (`Skills (2)` for auth-bypass, `Skills (1)` for recon) |
| **VERIFY-02** Context isolation works | YES | Fresh `claude -p` session's system reminder lists only the 3 curated skills across both plugins; no leakage of the other 99 upstream skills |
| **VERIFY-03** Per-plugin cache, no collision | YES | Two parallel cache subdirs under `~/.claude/plugins/cache/hack-skills-marketplace/<plugin-name>/c6f732befcae-32c1cf49/`; clean concurrent install |

## VERIFY-01: Individual-skill addressing

**Question:** Can the `skills` array address individual skill subdirectories (e.g. `./401-403-bypass-techniques`) rather than being limited to parent directories?

**Answer:** YES — with the git-subdir source descriptor.

**Install commands used:**
```bash
claude plugin marketplace add /Users/spencerpresley/code/hack-skills-wip/hack-skills-marketplace --scope user
claude plugin install hack-skills-recon@hack-skills-marketplace --scope user
claude plugin install hack-skills-auth-bypass@hack-skills-marketplace --scope user
```

**Marketplace.json shape under test (post-correction):**
```json
{
  "name": "hack-skills-auth-bypass",
  "source": {
    "source": "git-subdir",
    "url": "https://github.com/yaklang/hack-skills.git",
    "path": "skills"
  },
  "strict": false,
  "description": "Authentication and authorization bypass",
  "skills": [
    "./401-403-bypass-techniques",
    "./api-auth-and-jwt-abuse"
  ]
}
```

**Evidence — `claude plugin details hack-skills-auth-bypass@hack-skills-marketplace`:**
```
hack-skills-auth-bypass
  Authentication and authorization bypass
  Source: hack-skills-auth-bypass@hack-skills-marketplace

Component inventory
  Skills (2)  401-403-bypass-techniques, api-auth-and-jwt-abuse
  Agents (0)
  Hooks (0)
  MCP servers (0)
  LSP servers (0)

Projected token cost
  Always-on:   ~205 tok   added to every session

Per-component (rounded)
  component                  always-on  on-invoke
  401-403-bypass-techniques       ~120      ~4.7k
  api-auth-and-jwt-abuse           ~90        ~1k
```

**Evidence — `claude plugin details hack-skills-recon@hack-skills-marketplace`:**
```
hack-skills-recon
  Reconnaissance and information gathering
  Source: hack-skills-recon@hack-skills-marketplace

Component inventory
  Skills (1)  api-recon-and-docs
  Agents (0)
  Hooks (0)
  MCP servers (0)
  LSP servers (0)

Projected token cost
  Always-on:   ~87 tok   added to every session
```

**Conclusion:** With the git-subdir source descriptor, `claude plugin details` reports exactly the curated subset. Individual-skill addressing works. The on-disk cache under `~/.claude/plugins/cache/hack-skills-marketplace/<plugin>/<version>/` materializes all 102 skill subdirs (the full sparse-cloned `skills/` directory of yaklang/hack-skills) — but the runtime correctly exposes only the curated subset, exactly matching the Pitfall 5 framing in 01-RESEARCH.md.

### VERIFY-01 corrective note: the original pattern FAILED

Before the correction, with `source: { source: "github", repo: "yaklang/hack-skills" }` and skill paths nested under `./skills/`:
```
Component inventory
  Skills (102)  401-403-bypass-techniques, active-directory-acl-abuse, ... (all 102 upstream skills)
  Projected token cost
  Always-on:   ~10,503 tok   added to every session
```
This was the failed state captured in the original Wave 2 worktree's `.task01-evidence.txt` (worktree deleted after correction). The failure mode appears to be Claude Code auto-discovering `./skills/*/SKILL.md` at the source root regardless of the explicit `skills` array. Working precedents (wondelai-skills, claude-plugins-official/box, claude-plugins-official/netsuite-suitecloud) all clone content such that skill directories land at the source root — none use `./skills/X` nested paths in the `skills` array against a default-shaped github source. The `git-subdir` path-prefix sparse-clones only `skills/` so each `./<skill-name>` lands at the clone root, matching the working precedents' structure.

## VERIFY-02: Context isolation

**Question:** After installing a single group plugin built with `strict: false` + curated `skills` array, does the session's system reminder list only the curated skills?

**Answer:** YES — verified end-to-end against a fresh non-interactive Claude Code session.

**Method (D-07):** Both PRIMARY and SECONDARY evidence captured.
- **PRIMARY:** Fresh `claude -p` session prompted to dump its system reminder's available-skills block verbatim. Captured in `.task02-system-reminder.txt`.
- **SECONDARY:** `claude plugin details` outputs above (already shown under VERIFY-01).

**Primary evidence — verbatim system reminder excerpt (hack-skills lines only, full block in `.task02-system-reminder.txt`):**
```
- hack-skills-auth-bypass:401-403-bypass-techniques: 401/403 bypass playbook. Use when encountering access-denied responses on admin panels, API endpoints, or restricted paths. Covers path manipulation, HTTP method tampering, header injection, protocol downgrade, and automated bypass tools.
- hack-skills-auth-bypass:api-auth-and-jwt-abuse: API authentication and JWT abuse playbook. Use when testing bearer tokens, API keys, claim trust, header spoofing, rate limits, and API auth boundary weaknesses.
- hack-skills-recon:api-recon-and-docs: API reconnaissance and documentation review playbook. Use when discovering endpoints, schemas, versions, OpenAPI specs, hidden docs, and surface area for API testing.
```

**Counts:**
- Curated skills exposed: 3 (1 from recon + 2 from auth-bypass)
- Non-curated upstream skills exposed: 0
- Description dropout (Pitfall 1 / issue #57515): 0 — all three entries have full descriptions

**Conclusion:** Context isolation works. The model's session context contains exactly the 3 curated skills, despite 102 skill directories being materialized in the on-disk cache. This is the load-bearing user-visible behavior the marketplace project depends on.

## VERIFY-03: Per-plugin cache, no collision

**Question:** Do multiple plugin entries sharing `yaklang/hack-skills` as their `source` produce separate cache entries in `~/.claude/plugins/cache/` without collision?

**Answer:** YES.

**Method:** Both plugins installed concurrently (the planned D-10 deferred-cleanup exception). Cache tree inspected via `find -maxdepth 3 -type d`.

**Evidence:**
```
~/.claude/plugins/cache/hack-skills-marketplace/
├── hack-skills-recon/
│   └── c6f732befcae-32c1cf49/      <-- separate subdir per plugin name
│       ├── 401-403-bypass-techniques/
│       ├── api-auth-and-jwt-abuse/
│       ├── api-recon-and-docs/
│       └── ... (102 skill subdirs total — full sparse-cloned `skills/`)
└── hack-skills-auth-bypass/
    └── c6f732befcae-32c1cf49/      <-- separate subdir per plugin name
        ├── 401-403-bypass-techniques/
        ├── api-auth-and-jwt-abuse/
        ├── api-recon-and-docs/
        └── ... (102 skill subdirs total — full sparse-cloned `skills/`)
```

**Observations:**
- Both plugin caches share the same version token (`c6f732befcae-32c1cf49` = `<source-SHA>-<path-hash>`) because they sparse-clone the same upstream `skills/` subdir at the same SHA. This is NOT a collision — the parent dirs `hack-skills-recon/` and `hack-skills-auth-bypass/` partition by plugin name.
- The path-hash suffix (`-32c1cf49`) is a Claude Code internal token distinguishing git-subdir partial clones from full-repo clones (under the failed-pattern `source: github`, the version slot was just `c6f732befcae` without the suffix).
- Concurrent enable check: `claude plugin list` shows both `hack-skills-recon` and `hack-skills-auth-bypass` with `Status: ✔ enabled` simultaneously, no errors.

**Disk cost note:** Each plugin's cache contains all 102 skill subdirs (sparse-clone fetches the entire `skills/` directory of yaklang/hack-skills, since `path: "skills"` is the only filter). Total cache size for both plugins ≈ 2× the upstream `skills/` size. Since yaklang/hack-skills is text-only and modest, this is acceptable per PROJECT.md ("storage is small for a text-only repo"). When ~8 groups are built out in Phase 3, expect ~8× duplication of the `skills/` directory in the cache — still acceptable, but worth noting in case future tooling wants to optimize via shared cache.

## Pivot Policy (D-08 / D-09)

Recording the pivot decision for each VERIFY question per D-08, even though all answers are yes:

| VERIFY | Answer | Pivot decision per D-09 | Outcome |
|---|---|---|---|
| VERIFY-01 | YES | "If no, halt before Phase 2 and force a separate decision conversation about whether to abandon the strategy or accept parent-only grouping." | **N/A — answer is YES.** No pivot needed. However, D-03's original source descriptor (plain `github`) did fail VERIFY-01; D-03-REVISED uses `git-subdir`. The pivot conversation effectively happened mid-phase against the source descriptor, not against the project strategy. |
| VERIFY-02 | YES | "If no, halt. The whole value proposition is selective context activation; if curated `skills` arrays still leak the full source repo, the marketplace concept collapses for this use case." | **N/A — answer is YES.** No pivot needed. |
| VERIFY-03 | YES | "If no, document the actual collision behavior and decide whether a workaround (e.g., dedupe by hash, separate sources) is viable. Likely allows continuation if VERIFY-01/02 pass." | **N/A — answer is YES.** No pivot needed. |

## Plan execution note

The original phase plan (4 plans across 4 sequential waves) was disrupted by the VERIFY-01 FAIL observed during Plan 01-02 execution. Rather than halt the entire phase per D-09's pre-decided pivot stance, the orchestrator and user pursued a mid-phase research detour to determine WHETHER the FAIL was strategy-collapsing OR mechanism-correctable. That detour found three working marketplace precedents using different source descriptors and constructed a hypothesis-driven fix (`git-subdir` instead of `github`), then validated it against the same VERIFY-01/02/03 questions. The result is that Plans 01-02, 01-03, and 01-04's intended verification work was completed in a more compressed but more rigorous form than the original sequential structure. Each of those plans has a brief SUMMARY.md documenting which evidence in this VERIFICATION.md was contributed by its scope.

## Roadmap Success Criteria (Phase 1)

Checking against the 5 success criteria listed in ROADMAP.md §Phase 1:

1. ✓ A 2-group test `marketplace.json` exists pointing at `yaklang/hack-skills` with each group's `skills` array listing 2–3 specific individual skill paths. (Mechanism updated: `git-subdir` + root-level paths, but the 2-group / 3-path composition matches D-01.)
2. ✓ After installing a test group, the session's system reminder lists only the curated skills from that group. (Verified via `claude -p` fresh session capture — see VERIFY-02.)
3. ✓ With both test groups installed concurrently, `~/.claude/plugins/cache/` contains two separate clean cache entries (one per plugin), and both groups enable without collision. (Verified — see VERIFY-03.)
4. ✓ The 3 open questions from `docs/PLAN.md` are explicitly answered (yes/no with evidence) in this verification artifact. (Sections VERIFY-01 / 02 / 03 above.)
5. ✓ If any answer is "no", a documented pivot decision exists before Phase 2 begins. (All answers YES — Pivot Policy section above documents the N/A status for each, and additionally captures the mid-phase mechanism correction that converted VERIFY-01 from a FAIL to a PASS by switching source descriptor from `github` to `git-subdir`.)

**All 5 success criteria met. Phase 1 unlocks Phase 2.**
