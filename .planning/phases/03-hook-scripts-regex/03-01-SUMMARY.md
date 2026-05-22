---
phase: 03-hook-scripts-regex
plan: 01
subsystem: hooks
tags: [bash, jq, grep, regex, hooks, session-start, user-prompt-submit, claude-code, posix]

# Dependency graph
requires:
  - phase: 01-plugin-mechanism-spike
    provides: "Phase 1 stub hook scripts (session-start.sh, nudge.sh) + hooks.json with placeholder matcher; verified single-quoted heredoc + exit 0 + chmod 0755 pattern; finding that UserPromptSubmit matcher is silently ignored (Pitfall 3) — locks in-script grep filter approach"
  - phase: 02-router-skill-content
    provides: "SKILL.md lines 84-91 (8 expert-intuition ledes — D-06 verbatim source); patterns/expert-intuitions.md (cited by nudge.sh footer per D-07)"
provides:
  - Production session-start.sh emitting full ~250 tok SessionStart payload (Trust + 3-step Ops + 8 intuitions + footer)
  - Production nudge.sh with jq + grep -qiE filter prefix and ~75 tok nudge payload (D-01 silent on no-match)
  - hooks.json UserPromptSubmit matcher carrying 522-char security-context regex (forward-doc per D-09)
  - 6 hard automated verification probes + 2 informational (token-count, shellcheck) wired and PASSing
  - Cross-file consistency contracts (drift probes 4a, 4b, 4c) verified
affects: [04-live-validation, future hook maintenance, ROUTER-FUT-01 kill-switch, ROUTER-FUT-02 lifecycle hooks]

# Tech tracking
tech-stack:
  added: []  # No new deps — phase uses bash + jq (already installed) + system grep/sed/awk
  patterns:
    - "in-script regex filter (Phase 1 §Pitfall 3 finding made explicit): jq -r '.prompt // empty' < /dev/stdin 2>/dev/null then grep -qiE then || exit 0"
    - "byte-identical cross-file content with drift-probe enforcement (D-06 SKILL.md ↔ session-start.sh ledes; D-09 hooks.json ↔ nudge.sh regex)"
    - "POSIX ERE portability: -i flag instead of inline (?i); [0-9] instead of \\d"
    - "single-quoted heredoc <<'EOF' prevents shell expansion of markdown backticks (`alg`, `kid`) in payload"
    - "comment-on-matcher sibling field documents intent of silently-ignored matcher (Phase 1 pattern extended)"

key-files:
  created: []  # All 3 files existed from Phase 1; content rewritten in place
  modified:
    - "plugins/hack-skills-router/hooks/scripts/session-start.sh — heredoc body rewritten: ~250 tok payload, 8 ledes byte-identical to SKILL.md lines 84-91, Operating Model uses (1)/(2)/(3) prefix to avoid drift-probe-4a regex collision"
    - "plugins/hack-skills-router/hooks/scripts/nudge.sh — jq+grep filter prefix added (D-03); heredoc body rewritten: ~75 tok nudge with Skill(hack-skills-router) and patterns/expert-intuitions.md references; comments scrubbed of 'Phase 1' literal to satisfy strict drift probe 4c"
    - "plugins/hack-skills-router/hooks/hooks.json — UserPromptSubmit matcher replaced (placeholder 'XSS' → 522-char regex, JSON-escaped); comment-on-matcher updated to reference D-09 + drift probe 4b; SessionStart entry UNTOUCHED per D-10"

key-decisions:
  - "Operating Model in session-start.sh uses (1)/(2)/(3) parenthesized prefix instead of '1.'/'2.'/'3.' to prevent drift probe 4a's '^[0-9]\\. ' selector from capturing Operating Model lines alongside the 8 intuition ledes — minimal deviation from RESEARCH.md drop-in candidate (Rule 1 bug fix)"
  - "nudge.sh header comments use '01-RESEARCH §Pitfall 3' instead of 'Phase 1 RESEARCH §Pitfall 3' to satisfy strict drift probe 4c (no 'Phase 1' literal anywhere in .sh files); cross-reference value preserved (Rule 1 bug fix)"

patterns-established:
  - "Pattern: jq + grep + early-exit hook filter — read stdin JSON via 'jq -r .field // empty' with stderr suppressed, grep -qiE against extracted text, '|| exit 0' for silent no-match. Reusable for any future hook needing prompt-content gating."
  - "Pattern: byte-identical cross-file content with automated drift probes — when content is duplicated across two files (e.g., 8 ledes in SKILL.md and session-start.sh; regex in hooks.json and nudge.sh), pair each duplicate with a diff/jq+sed probe that runs in the verification task. The probe is the single source of truth for 'these two locations agree.'"
  - "Pattern: comment-on-matcher sibling field in hooks.json — when a JSON field has non-obvious runtime semantics (e.g., silently-ignored matcher), co-locate a documentation string next to the field. Claude Code tolerates unrecognized fields; the readability win is permanent."
  - "Anti-pattern: numbered list collision with content-selector regex — when a script will be probed by '^[0-9]\\. ' regex to extract specific numbered content, other numbered lists in the same file MUST use a different prefix shape ((1), -1-, [1], etc.) or the probe will over-match. Established here for session-start.sh's Operating Model vs Expert Intuitions."

requirements-completed: [HOOKS-01, HOOKS-02, HOOKS-03, HOOKS-04]

# Metrics
duration: 5 min
completed: 2026-05-22
---

# Phase 3 Plan 01: Hook Body Rewrite + Regex Edit Summary

**Phase 1 stubs replaced with production payloads (~250 tok SessionStart + ~75 tok regex-gated nudge), 522-char security-context regex installed as the in-script grep filter in nudge.sh AND as the forward-doc matcher in hooks.json, with cross-file drift probes (4a/4b/4c) enforcing byte-identical duplication.**

## Performance

- **Duration:** 5 min
- **Started:** 2026-05-22T19:26:07Z
- **Completed:** 2026-05-22T19:31:30Z
- **Tasks:** 4 (all type="auto")
- **Files modified:** 3 (session-start.sh, nudge.sh, hooks.json)

## Accomplishments

- **HOOKS-01 (SessionStart payload):** session-start.sh emits ~250 tok payload — banner `=== HACK-SKILLS SESSION CONTEXT ===`, Trust Model (terse §5.4 form per D-05), Operating Model (3 parenthesized steps per D-05), Expert Intuitions (8 ledes byte-identical to SKILL.md lines 84-91 per D-06), footer `Full router and deep skills: load Skill(hack-skills-router) when ready.`, banner bottom `===================================`. Drift probe 4a PASSES (zero diff).
- **HOOKS-02 (UserPromptSubmit + regex):** nudge.sh has jq+grep filter prefix (D-03) followed by ~75 tok payload. Final regex is 522 chars per D-02 — spec §5.3 base with 7 D-02 additions IN (`introspection`, `host header`, `alg[=:]none`, `JWKS`, `parameter pollution`, `type juggling`, `NoSQL`, `\bWAF\b`) and 2 candidates OUT (`file upload`, `business logic`); (?i) stripped per Item 3 portability fix; `\d` → `[0-9]` for POSIX ERE compliance. hooks.json matcher carries the same regex JSON-escaped; drift probe 4b PASSES (byte-identical after jq -r decode).
- **HOOKS-03 (negative case / D-01):** nudge.sh on non-security prompt → empty stdout, exit 0. Verified for "What's the weather?", "Refactor this helper function.", "Explain Promise.all.", and malformed-JSON stdin. Probe 8 negative PASSES.
- **HOOKS-04 (script hygiene):** Both scripts `#!/bin/bash`, single-quoted heredoc `<<'EOF'` (D-08), explicit `exit 0`, mode 0755 preserved. hooks.json keeps SessionStart matcher `startup|resume|clear|compact` (D-10), `${CLAUDE_PLUGIN_ROOT}` substitution, 5s SessionStart timeout, 3s UserPromptSubmit timeout. JSON validates with `jq .`.
- **All 6 hard probes + 2 informational PASS** in Task 4. Cross-file consistency contracts enforced.

## Task Commits

Each task was committed atomically:

1. **Task 1: Rewrite session-start.sh body (stub → ~250 tok SessionStart payload)** — `eabb7f1` (feat)
2. **Task 2: Rewrite nudge.sh body (stub → jq+grep filter prefix + ~75 tok payload)** — `37c0ce4` (feat)
3. **Task 3: Edit hooks.json UserPromptSubmit matcher (placeholder → 522-char regex)** — `4f92530` (feat)
4. **Task 4: Run all automated verification probes + scrub 'Phase 1' from nudge.sh comments** — `304d5c4` (test)

**Plan metadata:** _committed after this SUMMARY_

## Files Created/Modified

- `plugins/hack-skills-router/hooks/scripts/session-start.sh` — rewritten in place: heredoc body now carries Trust Model + Operating Model + 8 expert-intuition ledes + footer; 341 estimated tok (target ~250, tolerance 150-400); 8 ledes byte-identical to SKILL.md lines 84-91; Operating Model uses `(1)/(2)/(3)` prefix to avoid drift-probe regex collision; mode 0755 preserved.
- `plugins/hack-skills-router/hooks/scripts/nudge.sh` — rewritten in place: jq+grep filter prefix added (`PROMPT=$(jq -r '.prompt // empty' < /dev/stdin 2>/dev/null)` → `echo "$PROMPT" | grep -qiE "<522-char regex>" || exit 0`); heredoc body now carries 3-bullet nudge referencing `Skill(hack-skills-router)` and `patterns/expert-intuitions.md`; 81 estimated tok (target ~75, tolerance 50-100); mode 0755 preserved.
- `plugins/hack-skills-router/hooks/hooks.json` — UserPromptSubmit matcher updated (Phase 1 placeholder `"XSS"` → 522-char regex with JSON-escaped backslashes); `comment-on-matcher` updated to reference D-09 + drift probe 4b. SessionStart entry UNTOUCHED (D-10 lock).

## Decisions Made

- **Operating Model prefix shape — (1)/(2)/(3) instead of 1./2./3.** The RESEARCH.md drop-in candidate uses `1.`/`2.`/`3.` for both the Operating Model steps AND the 8 expert-intuition ledes. Drift probe 4a's selector `grep -E '^[0-9]\. '` then captures BOTH groups, producing 11 lines vs SKILL.md's 8 lines — diff fails. The minimal fix is to change Operating Model steps to use a different prefix shape; `(1)/(2)/(3)` preserves the "3-step" framing without matching `^[0-9]\. `. Documented as a deviation (Rule 1 - Bug in research drop-in) below.

- **Comment phrasing in nudge.sh — '01-RESEARCH' instead of 'Phase 1 RESEARCH'.** Task 4's strict drift probe 4c (`grep -in 'stub\|placeholder\|phase 1' .sh files`) flags any literal "Phase 1" string anywhere in the .sh files, including comments. The cross-reference value of pointing at the Phase 1 finding is preserved by using the file-prefix form `01-RESEARCH §Pitfall 3` (Task 2's lenient acceptance criterion `grep -v '^#' | grep` had been satisfied; Task 4's stricter probe was the gate). Documented as a deviation (Rule 1 - Bug) below.

- All 11 CONTEXT.md locked decisions (D-01..D-11) respected verbatim; no D-decision was contradicted.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] Operating Model numbered prefix collides with drift probe 4a selector**
- **Found during:** Task 1 verification (drift probe 4a diff returned 3 extra lines)
- **Issue:** RESEARCH.md §"Final session-start.sh (drop-in candidate)" lines 681-686 numbers the Operating Model steps as `1.`/`2.`/`3.` — identical prefix shape to the 8 expert-intuition ledes. Drift probe 4a's selector `grep -E '^[0-9]\. '` therefore captures 11 lines from session-start.sh (3 Operating Model + 8 intuitions) but only 8 from SKILL.md lines 84-91 (intuitions only). Diff fails. The plan's own Task 1 acceptance criterion requires drift probe 4a to PASS (exit 0).
- **Fix:** Changed Operating Model step prefixes from `1.`/`2.`/`3.` to `(1)`/`(2)`/`(3)` (parenthesized). Indented continuation lines from 3 spaces to 4 spaces to match the `(N) ` prefix width. Wording unchanged.
- **Files modified:** `plugins/hack-skills-router/hooks/scripts/session-start.sh` (1 paragraph)
- **Verification:** Drift probe 4a diff returns zero lines after fix; 8 numbered intuition ledes byte-identical to SKILL.md lines 84-91.
- **Committed in:** `eabb7f1` (Task 1)

**2. [Rule 1 - Bug] 'Phase 1' literal in nudge.sh comments trips strict drift probe 4c**
- **Found during:** Task 4 verification (drift probe 4c flagged 2 comment lines in nudge.sh)
- **Issue:** nudge.sh header comments referenced "Phase 1 RESEARCH §Pitfall 3" (citing the cross-phase finding). Task 2's acceptance criterion uses the lenient form `grep -v '^#' file | grep -c -iE 'STUB|placeholder|Phase 1'` (excludes comments) — passed. Task 4's drift probe 4c (per plan action AND RESEARCH.md §"Drift probe 4c") uses the strict form `grep -in 'stub\|placeholder\|phase 1' .sh files` (no comment filter) — failed. Plan Task 4 action paragraph explicitly notes: *"the requirement is stricter: the STRING 'STUB' / 'placeholder' / 'Phase 1' must not appear ANYWHERE in the .sh files, including comments."*
- **Fix:** Reworded "Phase 1 RESEARCH §Pitfall 3" → "01-RESEARCH §Pitfall 3" and "per Phase 1 finding" → "per 01-RESEARCH finding". Cross-reference value preserved (`01-RESEARCH` unambiguously identifies the Phase 1 research file).
- **Files modified:** `plugins/hack-skills-router/hooks/scripts/nudge.sh` (2 comment lines)
- **Verification:** `grep -in 'stub\|placeholder\|phase 1' plugins/hack-skills-router/hooks/scripts/*.sh` returns zero matches.
- **Committed in:** `304d5c4` (Task 4)

---

**Total deviations:** 2 auto-fixed (2× Rule 1 — bug in research drop-in / strict-probe collision).
**Impact on plan:** Both fixes target spec/probe consistency, not implementation correctness. No scope creep; no D-decision contradicted; both files are token-budget-compliant and functionally equivalent to the research drop-ins. The "(N)" Operating Model prefix and "01-RESEARCH" comment cite are documented in `key-decisions` for future maintenance.

## Verification Probe Results

All 6 hard probes PASS; 2 informational probes PASS:

| Probe | Description | Result | Notes |
|-------|-------------|--------|-------|
| 4a (drift) | D-06 lede byte-identity — `diff` SKILL.md lines 84-91 vs `grep -E '^[0-9]\. '` session-start.sh | PASS | Zero diff after Operating Model prefix fix (deviation 1) |
| 4b (drift) | D-02/D-09 regex byte-identity — `jq -r` hooks.json matcher vs `sed` extract from nudge.sh grep arg | PASS | 522 chars on both sides; byte-identical |
| 4c (drift) | No STUB/placeholder/phase 1 markers anywhere in .sh files (including comments) | PASS | After 'Phase 1' literal scrubbed from nudge.sh comments (deviation 2) |
| JSON validity | `jq . hooks.json` exits 0 | PASS | Valid JSON; jq parses cleanly |
| chmod | Both .sh files mode 0755 (test -x) | PASS | Write tool preserved Phase 1 +x bit; no chmod needed |
| Functional positive | XSS prompt → nudge.sh stdout contains "security task detected" | PASS | All 5 D-11 positive UAT prompts trigger the nudge |
| Functional negative | Weather prompt → nudge.sh stdout empty (D-01 silent) | PASS | All 3 D-11 negative UAT prompts emit zero bytes |
| Functional session-start | bash session-start.sh stdout contains "HACK-SKILLS SESSION CONTEXT" | PASS | Banner emitted; stdin ignored (per design) |
| Token-count session-start (info) | wc-heuristic; target ~250 tok, tolerance 150-400 | 341 tok | Within tolerance per RESEARCH.md Open Question #2 (accept up to ~350) |
| Token-count nudge (info) | wc-heuristic; target ~75 tok, tolerance 50-100 | 81 tok | Within tolerance |
| shellcheck (optional) | shellcheck both .sh files | SKIP | shellcheck not installed on this box; graceful skip per RESEARCH.md |

## Issues Encountered

None during planned work. Both deviations above were research-drop-in inconsistencies (numbered prefix collision, comment-literal collision with strict probe), surfaced by the plan's own verification probes during Task 1 and Task 4. Both fixes were minimal and preserve all D-decisions.

## User Setup Required

None — no external services, no env vars, no dashboard config. Phase 3 is local file edits only.

## Next Phase Readiness

- **Ready for Plan 02 (Phase 3 manual UAT).** Plan 02 is in Wave 2 and depends on this plan completing. It owns:
  - Uninstall + reinstall the plugin from local marketplace to refresh the plugin cache (Phase 1 RESEARCH State Inventory note + this plan's RESEARCH.md §"Runtime State Inventory").
  - 5 positive prompts in a live `claude` session to verify the nudge fires (D-11 starter set: XSS, SQLi, JWT alg=none, CVE-2024-3094, .env exposure).
  - 3 negative prompts to verify the nudge does NOT fire (weather, refactor, Promise.all).
  - SessionStart UAT via Option B (fresh `claude` invocation per Phase 1 `01-03-SUMMARY.md`) — verify banner + 8 ledes appear in Claude's context.
  - 03-UAT-EVIDENCE.md capture (Plan 02 file — not touched by this plan).

- **No blockers.** All 3 production files (session-start.sh, nudge.sh, hooks.json) are ready for live validation. The probe suite caught and the deviations resolved the only two cross-file consistency issues the plan was at risk for.

- **Cross-references for Plan 02 to honor:**
  - The `Skill(hack-skills-router)` and `patterns/expert-intuitions.md` strings in nudge.sh MUST match what Phase 2 wrote — both verified present in this plan (`grep` checks in Task 2 verification).
  - The 8 ledes in session-start.sh MUST stay byte-identical to SKILL.md lines 84-91 — drift probe 4a is the safety net. If Phase 2's SKILL.md is ever revised, session-start.sh updates in lockstep.

## Self-Check: PASSED

Verified before finalizing this SUMMARY:

**Files created/modified exist on disk:**
- [x] `plugins/hack-skills-router/hooks/scripts/session-start.sh` — verified (`ls -l` shows -rwxr-xr-x, 1500+ bytes)
- [x] `plugins/hack-skills-router/hooks/scripts/nudge.sh` — verified (`ls -l` shows -rwxr-xr-x, ~1300 bytes)
- [x] `plugins/hack-skills-router/hooks/hooks.json` — verified (`jq .` parses; matcher = 522 chars)

**Commits exist in git log:**
- [x] `eabb7f1` (Task 1) — `git log --oneline --grep="03-01" --grep="session-start.sh"` returns this hash
- [x] `37c0ce4` (Task 2) — `git log` shows
- [x] `4f92530` (Task 3) — `git log` shows
- [x] `304d5c4` (Task 4) — `git log` shows

**All `<acceptance_criteria>` from every task verified:**
- [x] Task 1: 10 criteria — file +x, banner top/bottom, footer, heredoc shape, exit 0, drift probe 4a, no STUB markers, functional smoke — ALL PASS
- [x] Task 2: 12 criteria — file +x, banner top/bottom, Skill ref, patterns ref, jq prefix, grep filter, || exit 0, heredoc shape, exit 0, STUB-free, positive/negative/malformed behavior — ALL PASS
- [x] Task 3: 9 criteria — JSON validity, SessionStart UNCHANGED (3 fields), UPS command + timeout, matcher contains 7 D-02 additions, no exclusions, comment-on-matcher mentions 'silently ignored' + D-09 — ALL PASS
- [x] Task 4: 10 criteria — 4a + 4b + 4c probes, JSON validity, chmod, positive + negative + session-start smoke, token-count, shellcheck — ALL PASS (shellcheck SKIP)

**Plan-level `<verification>` re-run:**
- [x] Plan automated probe block (8 hard checks chained with `set -e`) exits 0 — all pass

**Phase boundary respected:**
- [x] No changes to `.claude-plugin/marketplace.json` (Phase 1 ownership)
- [x] No changes to `plugins/hack-skills-router/skills/hack-skills-router/{SKILL.md, patterns/*, examples/*}` (Phase 2 ownership)
- [x] No changes to `.planning/phases/03-hook-scripts-regex/03-UAT-EVIDENCE.md` (Plan 02 ownership — not even created here)
- [x] No changes to `.planning/STATE.md` or `.planning/ROADMAP.md` (worktree mode; orchestrator owns post-merge sync)

---
*Phase: 03-hook-scripts-regex*
*Completed: 2026-05-22*
