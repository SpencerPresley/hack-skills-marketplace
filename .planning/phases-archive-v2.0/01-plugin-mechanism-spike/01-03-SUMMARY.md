---
phase: 01-plugin-mechanism-spike
plan: 03
subsystem: infra
tags: [plugin, marketplace, hooks, session-start, user-prompt-submit, uat, cli, claude-plugin-validate]

# Dependency graph
requires:
  - phase: 01-plugin-mechanism-spike
    provides: plugin tree (Plan 01) + marketplace catalog entry (Plan 02)
provides:
  - End-to-end UAT evidence that the sidecar plugin shell installs, registers, coexists with v1 plugins, and emits both stub hook injects at the documented session boundaries.
  - Direct quoted observation of `[Phase 1 stub] SessionStart hook fired.` and `[Phase 1 stub] UserPromptSubmit hook fired.` from a fresh Claude Code session (Option B — separate-terminal `claude` invocation).
  - Closure of ROADMAP Phase 1 Success Criteria #4 (install + `claude plugin details` shape) and #5 (coexistence + observable SessionStart inject).
  - Marketplace currently registered as local-path source (handoff note for Phase 4).
affects:
  - Phase 2 (router content authoring — starts from a verified-working plugin shell)
  - Phase 3 (real hook payload rewrite — stub-marker observability proves the wiring is sound)
  - Phase 4 (live validation — must re-register marketplace as GitHub source before publish)

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "Marketplace re-registration pattern: `remove <name> && add ./` switches a GitHub-sourced marketplace to local-path mode for iterative spike without round-tripping through git push (mirrors v1 Phase 1 pattern)"
    - "Hook observability via direct-mention channel: when a fresh `claude` session starts with stub hooks installed, Claude visibly references the unusual stub banners in its first response — observation channel (i) per plan §how-to-verify (channels ii `--debug` and iii `/transcript` not required)"
    - "Session boundary mechanism Option B: fresh `claude` invocation in a separate terminal preserves the orchestrator session AND fires SessionStart with matcher=startup (RESEARCH §Pitfall 1 — SessionStart does NOT fire on install)"

key-files:
  created:
    - .planning/phases/01-plugin-mechanism-spike/01-03-SUMMARY.md
  modified: []

key-decisions:
  - "Used Option B (fresh `claude` invocation in separate terminal) for the session-boundary trigger rather than Option A (`/clear` in current session) — Option B keeps the orchestrator session intact and proves matcher=startup also fires the hook (the most common real-world boundary)"
  - "Did not run the optional cleanup uninstalls at the end — both plugins remain enabled at user scope. Plan 03's `<verification>` block accounts for either choice; leaving them installed enables continued local development without re-running Tasks 2–3"
  - "`claude plugin validate` (CLI v2.1.148) was available — both Task 1 sub-checks #7 (plugin) and #8 (marketplace catalog) ran and returned `Validation passed`. The plan's `skipped if absent` clause did not apply"

patterns-established:
  - "End-to-end UAT structure for plugin-shell spikes: pre-flight artifact validation → CLI-side schema validate → marketplace re-registration → install + coexistence install → in-session human-verify of hook injects"
  - "Six-file /tmp evidence capture pattern: marketplace-list-{before,after}, install, plugin-list, plugin-details, coexist-install, plugin-list-after-coexist — gives the SUMMARY author concrete artifact quotes without re-running the CLI"
  - "Plan-level UAT verification grep anchors: `SessionStart hook fired` and `UserPromptSubmit hook fired` literal substrings in the SUMMARY itself serve as the contract that the human-verify observation actually happened (per `<verification>` block)"

requirements-completed: [PLUGIN-01, PLUGIN-02]

# Metrics
duration: ~20m (Tasks 1–3 automated + checkpoint pause for user verification + continuation finalization)
completed: 2026-05-22
---

# Phase 1 Plan 03: UAT — Install + coexistence + in-session hook observation Summary

**End-to-end UAT of the sidecar plugin shell: `claude plugin validate` PASS on plugin and catalog, marketplace re-registered local-path, `hack-skills-router` installs from local catalog (`~138 tok always-on`, `Skills (1)` + `Hooks (2) SessionStart, UserPromptSubmit`), coexists with `hack-skills-auth-bypass`, and a fresh `claude` session visibly references both `[Phase 1 stub] SessionStart hook fired.` and `[Phase 1 stub] UserPromptSubmit hook fired.` banners — ROADMAP Phase 1 SC #1–#5 all closed.**

## Performance

- **Duration:** ~20m end-to-end (Tasks 1–3 by prior agent + checkpoint pause + continuation SUMMARY by this agent)
- **Started:** 2026-05-22T15:45Z (approximate — Tasks 1–3 by prior agent acd0151eb0278f87d after Plan 02 completion at 15:41Z)
- **Completed:** 2026-05-22T16:00Z
- **Tasks:** 4 (3 automated + 1 human-verify checkpoint)
- **Files created:** 1 (this SUMMARY)
- **Files modified:** 0 (Plan 03 by design produces no repo file changes — `files_modified: []`)

## Accomplishments

- **End-to-end install path proven from local marketplace.** `claude plugin install hack-skills-router@hack-skills-marketplace` exited 0 against the local-path-registered marketplace; the install resolved through `.claude-plugin/marketplace.json` (Plan 02) → `./plugins/hack-skills-router/` (Plan 01) → `~/.claude/plugins/cache/hack-skills-marketplace/hack-skills-router/`.
- **`claude plugin details hack-skills-router` shows the canonical Phase 1 shape** — `Skills (1)  hack-skills-router` and `Hooks (2)  SessionStart, UserPromptSubmit  (harness-only — no model context cost)`, with `Always-on: ~138 tok`. This is exactly the shape ROADMAP SC #4 requires (skill + both hooks declared).
- **Coexistence with v1 topical plugin confirmed.** `claude plugin install hack-skills-auth-bypass@hack-skills-marketplace` succeeded against the same local marketplace; `claude plugin list` shows both `hack-skills-router` AND `hack-skills-auth-bypass` enabled at user scope. The mixed-source-form catalog (13 git-subdir + 1 relative-path entries, per Plan 02) installs polyglot-source plugins cleanly into adjacent cache subdirs.
- **Both stub hooks fire on session boundary and prompt submit.** A fresh `claude` invocation in a separate terminal (Option B session boundary) caused Claude to explicitly reference the SessionStart stub banner AND the UserPromptSubmit stub banner in its very first response — direct observation via channel (i) (Claude mentioning the unusual stub text). Channels (ii) `--debug` and (iii) `/transcript` were not required.
- **`claude plugin validate` CLI v2.1.148 passes on both plugin and marketplace catalog.** Task 1 sub-checks #7 (`./plugins/hack-skills-router`) and #8 (marketplace root `.`) both returned `Validation passed`. The "skipped if absent" clause from the plan did not apply.

## Task Commits

Each task was committed atomically (or, for human-verify, observation-recorded only):

1. **Task 1: Pre-flight artifact + JSON + chmod + CLI validate checks** — no commit (read-only verification per plan `files_modified: []`)
2. **Task 2: Re-register marketplace as local path for spike iteration** — no commit (CLI state change, no repo file change)
3. **Task 3: Install router + coexistence install + capture CLI evidence** — no commit (CLI state change, captured to /tmp; no repo file change)
4. **Task 4: Human verification — observe SessionStart + UserPromptSubmit stub markers** — this SUMMARY is the artifact

**Plan metadata commit:** to follow this SUMMARY commit (per execute-plan.md ordering — SUMMARY + STATE + ROADMAP updates land in subsequent commits)

_Note: Plan 03 is intentionally a verification plan — its `files_modified` frontmatter is `[]` and no per-task code commits are expected. The acceptance gates are CLI exit codes, /tmp evidence capture, and the in-session observation quoted below._

## Files Created/Modified

- `.planning/phases/01-plugin-mechanism-spike/01-03-SUMMARY.md` (this file) — UAT evidence record per Plan 03 `<output>` block, containing direct quotes of observed marker text.

No repo files modified. All state changes are CLI-side (marketplace registration form, plugin cache contents) and are captured in the `/tmp/01-03-*.txt` evidence files referenced below.

## Pre-flight Result (Task 1)

All 8 pre-flight checks PASSED. Specifically:

| # | Check | Result |
|---|-------|--------|
| 1 | Directory layout (3 dirs exist) | PASS |
| 2 | All five Plan 01 files present | PASS |
| 3 | `jq empty` on both JSON files | PASS |
| 4 | `test -x` on both `.sh` scripts | PASS |
| 5 | Marketplace entry resolves to `./plugins/hack-skills-router` | PASS |
| 6 | `.plugins | length == 14` | PASS |
| 7 | `claude plugin validate ./plugins/hack-skills-router` | PASS (`Validation passed`) — CLI v2.1.148 |
| 8 | `claude plugin validate .` (marketplace catalog) | PASS (`Validation passed`) — CLI v2.1.148 |

The "skipped if CLI version absent" clause from the plan did not apply — `claude plugin validate` is present on CLI v2.1.148 and both invocations returned clean.

## Marketplace Re-registration Evidence (Task 2)

The marketplace was registered with the GitHub-source form pre-Plan-03 (per RESEARCH §"Runtime State Inventory"). Task 2 re-registered it as a local path.

**Before (`/tmp/01-03-marketplace-list-before.txt`):**
```
  ❯ hack-skills-marketplace
    Source: GitHub (SpencerPresley/hack-skills-marketplace)
```

**After (`/tmp/01-03-marketplace-list-after.txt`):**
```
  ❯ hack-skills-marketplace
    Source: Directory (/Users/spencerpresley/code/hack-skills-wip/hack-skills-marketplace)
```

The `Source:` line flipped from `GitHub (SpencerPresley/hack-skills-marketplace)` → `Directory (/Users/spencerpresley/code/hack-skills-wip/hack-skills-marketplace)`. This is the acceptance form per Plan 03 Task 2 (`accept any local-form indicator … or absence of `Source: GitHub`); the literal `Source: Directory (...)` indicator is the clearest signal CLI v2.1.148 emits.

**Handoff note:** This re-registration is reversible. Phase 4 (live validation against published marketplace) will need to switch back to the GitHub form: `claude plugin marketplace remove hack-skills-marketplace && claude plugin marketplace add SpencerPresley/hack-skills-marketplace`.

## Install Transcript Highlights (Task 3)

**Install (`/tmp/01-03-install.txt`):**
```
Installing plugin "hack-skills-router@hack-skills-marketplace"...✔ Successfully installed plugin: hack-skills-router@hack-skills-marketplace (scope: user)
```
Exit code: 0.

**`claude plugin details hack-skills-router` (`/tmp/01-03-plugin-details.txt`):**
```
hack-skills-router 0.1.0
  Routing + scaffolding for hack-skills topical plugins.
  Source: hack-skills-router@hack-skills-marketplace

Component inventory
  Skills (1)  hack-skills-router
  Agents (0)
  Hooks (2)  SessionStart, UserPromptSubmit  (harness-only — no model context cost)
  MCP servers (0)
  LSP servers (0)

Projected token cost
  Always-on:   ~138 tok   added to every session

Per-component (rounded)
  component           always-on  on-invoke
  hack-skills-router       ~140       ~490

  On-invoke cost is paid each time a skill or agent fires.
  Token counts are estimates and may differ from actual usage.
```

Key shape facts (each acceptance criterion validated):
- `Skills (1)  hack-skills-router` — the SKILL.md from Plan 01 is registered.
- `Hooks (2)  SessionStart, UserPromptSubmit` — both hooks from hooks.json are registered with their event names visible. The literal substring `Hooks (0)` does NOT appear (the hard-failure case).
- `(harness-only — no model context cost)` annotation confirms hooks do NOT add always-on tokens — the `~138 tok always-on` cost comes from the skill itself.
- `0.1.0` version comes from `plugin.json` (Plan 01), validating Pitfall 4 single-source-of-truth posture (Plan 02 marketplace entry omits version).

**Coexistence install (`/tmp/01-03-coexist-install.txt`):**
```
Installing plugin "hack-skills-auth-bypass@hack-skills-marketplace"...✔ Successfully installed plugin: hack-skills-auth-bypass@hack-skills-marketplace (scope: user)
```
Exit code: 0. No install errors, no marketplace conflicts.

**Coexistence in `claude plugin list` (`/tmp/01-03-plugin-list-after-coexist.txt`):**
```
  ❯ hack-skills-auth-bypass@hack-skills-marketplace
    Version: c6f732befcae-32c1cf49
    Scope: user
    Status: ✔ enabled

  ❯ hack-skills-router@hack-skills-marketplace
    Version: 0.1.0
    Scope: user
    Status: ✔ enabled
```
Both plugins from the same `hack-skills-marketplace` source, both enabled at user scope, no error rows.

**Cache layout (`/tmp/01-03-cache.txt`):**
```
drwxr-xr-x  3 spencerpresley  staff   96 May 22 11:52 hack-skills-auth-bypass
drwxr-xr-x  3 spencerpresley  staff   96 May 22 09:25 hack-skills-mobile
drwxr-xr-x  3 spencerpresley  staff   96 May 22 04:34 hack-skills-recon
drwxr-xr-x  3 spencerpresley  staff   96 May 22 11:51 hack-skills-router
```
Per-plugin cache subdirs under `~/.claude/plugins/cache/hack-skills-marketplace/` — `hack-skills-router/` (this UAT) and `hack-skills-auth-bypass/` (coexistence install) sit alongside two previously-installed v1 plugins (`hack-skills-mobile`, `hack-skills-recon`). This demonstrates the multi-plugin-shared-source caching model from CLAUDE.md ("Multiple plugin entries share one `source`") works in practice.

## Hook Observation Evidence (Task 4)

**Session boundary mechanism used:** Option B (fresh `claude` invocation in a separate terminal). This is the cleanest option per Plan 03 — the orchestrator session (where this very plan was running) is preserved, and matcher=startup is the most realistic real-world trigger for SessionStart.

**Observation channel used:** Channel (i) — Claude explicitly referenced the stub banner text in its very first response without prompting. Channels (ii) `claude --debug` trace grep and (iii) `/transcript` inspection were NOT required.

**The user reported the following direct quote from a fresh `claude` session:** in a separate terminal, the user started `claude` and typed "are you ready?". Claude's first response was:

> "Ready. Phase 1 stubs fired cleanly (SessionStart + UserPromptSubmit hooks both posted their stub banners), router skill is registered, and the auth-bypass plugin skills are loaded. What's next?"

This single response confirms ALL of:

1. **SessionStart hook fired** — Claude explicitly references the SessionStart stub banner. The fresh `claude` invocation triggered SessionStart with matcher=startup; the session-start.sh script ran; its stdout (`[Phase 1 stub] SessionStart hook fired.`) was injected as a system reminder above the user's prompt, and Claude saw it.
2. **UserPromptSubmit hook fired** — Claude explicitly references the UserPromptSubmit stub banner. Even though the typed prompt was "are you ready?" (no `XSS` keyword), the matcher is silently ignored per RESEARCH §Pitfall 3, so nudge.sh fired and emitted `[Phase 1 stub] UserPromptSubmit hook fired.` into context.
3. **Router skill registered** — Claude refers to "router skill is registered", which it can only know from the SKILL.md frontmatter being loaded into the always-on context (~138 tok).
4. **Coexistence works in-session** — Claude refers to "the auth-bypass plugin skills are loaded", confirming both plugins are active simultaneously without conflict.

**ROADMAP SC #5 closure:** the load-bearing requirement is "stub SessionStart inject is observable in Claude's session context (via Claude's behavior or a visible system-reminder excerpt)". The above quote satisfies the "via Claude's behavior" form of that requirement — Claude explicitly mentions both stub banners in its initial response, which is only possible if both hook stdouts reached Claude's context.

**Coexistence sanity (already automated in Task 3):** `/tmp/01-03-plugin-list-after-coexist.txt` shows both plugins enabled. The fresh session confirms in-session — "the auth-bypass plugin skills are loaded" — that the two plugins coexist not just at install-list level but also at runtime skill-loading level.

**Hook stdout grep anchors for downstream UAT plans (Phase 3):** `[Phase 1 stub] SessionStart hook fired.` and `[Phase 1 stub] UserPromptSubmit hook fired.` are the literal stub stdout markers from Plan 01's session-start.sh and nudge.sh. Phase 3 will replace these with the real ~250 tok and ~75 tok payloads, but the wiring shape proven here (script → stdout → system-reminder inject → Claude's response) is identical to what Phase 3 will rely on.

## Phase 1 Traceability — All Success Criteria Closed

ROADMAP Phase 1 has five success criteria. This plan closes the final two (#4 and #5); the prior plans closed #1–#3. Cross-reference:

| SC | Requirement | Closed by | Evidence |
|----|-------------|-----------|----------|
| #1 | Marketplace entry for `hack-skills-router` with `source: "./plugins/hack-skills-router"` alongside 13 v1 entries, none removed/altered | Plan 02 (commit `5fdce53`) | Plan 02 AC1–AC13 PASS; `jq '.plugins | length'` == 14; v1 entries byte-identical |
| #2 | `plugin.json` declares valid `name`, `description`, `version` (0.1.0), `author` | Plan 01 Task 1 (commit `e2939ae`) | `jq empty` PASS; Plan 01 SUMMARY documents 4-field minimal manifest |
| #3 | `SKILL.md` stub (≤30 line body) + `hooks.json` declaring both hooks with stub `.sh` scripts; UserPromptSubmit matcher is placeholder OK | Plan 01 Tasks 2+3 (commits `6ef1d68`, `726e6ba`) + Task 4 chmod (`a48e6a6`) | Plan 01 SUMMARY documents 25-line SKILL.md body, hooks.json with both hooks, both `.sh` mode 0755 |
| #4 | From local marketplace: `/plugin install hack-skills-router@hack-skills-marketplace` succeeds AND `claude plugin details` lists skill + both hook declarations | **This plan Tasks 3+4** | Install exit 0 (`/tmp/01-03-install.txt`); `claude plugin details` shows `Skills (1)  hack-skills-router` and `Hooks (2)  SessionStart, UserPromptSubmit` (`/tmp/01-03-plugin-details.txt`) |
| #5 | Coexistence: both router + a v1 topical plugin (e.g., auth-bypass) installed; stub SessionStart inject observable in Claude's session context; both plugins coexist in `claude plugin marketplace list` without conflict | **This plan Tasks 3+4** | Coexistence install exit 0 (`/tmp/01-03-coexist-install.txt`); both plugins enabled in `claude plugin list` (`/tmp/01-03-plugin-list-after-coexist.txt`); fresh-session quote above where Claude mentions BOTH stub banners + router skill registered + auth-bypass skills loaded |

**Phase 1 status:** ALL FIVE SUCCESS CRITERIA CLOSED. Phase 1 acceptance gate fully satisfied. Phase 2 (router content authoring) starts from a verified-working plugin shell.

## Decisions Made

- **Used Option B (fresh `claude` invocation, separate terminal) for the session-boundary trigger.** The plan offered Option A (`/clear` in the current session) as the "cheapest" option, but Option A would have wiped the orchestrator's session context where this very plan was running. Option B is also cleaner from an evidence standpoint: matcher=startup is the more realistic real-world trigger (most users open `claude` fresh rather than `/clear` mid-session), and the observation is unambiguous because the session has no prior content for Claude to confuse the banner text with.
- **Did not run the optional cleanup uninstalls.** Both `hack-skills-router` and `hack-skills-auth-bypass` remain enabled at user scope. The plan's `<verification>` block explicitly accounts for either choice ("If the user opted to run the cleanup uninstalls at the end, this check is expected to fail"). Leaving them installed enables continued local development without re-running Plan 03 Tasks 2–3. Phase 4 cleanup is the natural off-ramp before publishing the GitHub-source marketplace.
- **Treated the `claude plugin validate` CLI subcommand as available.** Plan 03 included a fallback "skipped if absent" clause; CLI v2.1.148 has the subcommand and both invocations (`./plugins/hack-skills-router` and `.`) returned `Validation passed`. The fallback did not apply — checks 7 and 8 are recorded as PASS, not SKIPPED.

## Deviations from Plan

None — plan executed exactly as written. The plan's 4 tasks (Task 1 pre-flight, Task 2 marketplace re-register, Task 3 install + coexistence install, Task 4 human-verify) all completed in order. The user signaled `approved` at the Task 4 resume-signal with strong evidence (direct quote from a fresh session).

The plan's `<acceptance_criteria>` block on each task all passed. The plan's `<verification>` block grep anchors (`SessionStart hook fired` and `UserPromptSubmit hook fired`) appear in this SUMMARY (specifically: the user-quoted phrases "SessionStart + UserPromptSubmit hooks both posted their stub banners" and the standalone marker substrings `SessionStart hook fired` and `UserPromptSubmit hook fired` in the headings and inline references throughout this document).

## Issues Encountered

None. All four tasks completed at first attempt:
- Task 1: All 8 pre-flight checks PASS (including the optional `claude plugin validate` checks 7 and 8).
- Task 2: Marketplace re-registration cleanly flipped from `Source: GitHub` to `Source: Directory`.
- Task 3: Install exit 0; `claude plugin details` shape matched RESEARCH §"Code Examples"; coexistence install exit 0; both plugins enabled.
- Task 4: User observed both stub banners in the very first response of a fresh `claude` session — no diagnostic fallback (`claude --debug` or `/transcript`) was needed.

No deferred items added. No CLAUDE.md directives required adjustment. No threat-model surface introduced beyond what RESEARCH and Plan 03's `<threat_model>` already anticipated.

## User Setup Required

None — Plan 03 is a UAT plan and does not introduce external service configuration. The only "configuration change" is the local marketplace re-registration (Task 2), which the SUMMARY documents as reversible.

## Verification

**Plan-level `<verification>` block (all pass):**

1. SUMMARY file exists with both grep anchors:
   - `test -f .planning/phases/01-plugin-mechanism-spike/01-03-SUMMARY.md` → PASS (this file)
   - `grep -q 'SessionStart hook fired' …01-03-SUMMARY.md` → PASS (anchor appears multiple times: stub-marker text, traceability rows, Task 4 narrative)
   - `grep -q 'UserPromptSubmit hook fired' …01-03-SUMMARY.md` → PASS (same — anchor appears in stub-marker text, traceability rows, Task 4 narrative)
2. All six /tmp evidence files exist and are non-empty:
   - `/tmp/01-03-marketplace-list-before.txt` (472 bytes) — pre-reregistration
   - `/tmp/01-03-marketplace-list-after.txt` (503 bytes) — post-reregistration
   - `/tmp/01-03-install.txt` (157 bytes) — install transcript
   - `/tmp/01-03-plugin-list.txt` (2323 bytes) — list after install
   - `/tmp/01-03-plugin-details.txt` (629 bytes) — Skills(1) + Hooks(2) shape
   - `/tmp/01-03-coexist-install.txt` (167 bytes) — auth-bypass install transcript
   - `/tmp/01-03-plugin-list-after-coexist.txt` (2453 bytes) — both plugins listed
   - (Bonus) `/tmp/01-03-cache.txt` (773 bytes) — cache subdir layout
3. `claude plugin list 2>&1 | grep -q 'hack-skills-router'` → PASS (plugins remain installed; user opted not to run cleanup)

## Self-Check: PASSED

- This SUMMARY file exists at `.planning/phases/01-plugin-mechanism-spike/01-03-SUMMARY.md`.
- Both grep anchors (`SessionStart hook fired`, `UserPromptSubmit hook fired`) appear in this file.
- All 7 referenced /tmp evidence files exist and are non-empty (verified above).
- `claude plugin list` still shows `hack-skills-router` (verified pre-write).
- ROADMAP Phase 1 SC #1–#5 all have closure evidence rows in the traceability table above.
- Prior task commits referenced in the traceability table (Plan 01: `e2939ae`, `6ef1d68`, `726e6ba`, `a48e6a6`; Plan 02: `5fdce53`) are all reachable from HEAD (verified via `git log --oneline`).

## Threat Flags

None. The threat register entries from Plan 03's `<threat_model>` all held:
- **T-03-01 (Tampering, plugin cache):** Cache populated only via `claude plugin install`; no manual writes. Cache layout in `/tmp/01-03-cache.txt` shows clean per-plugin subdirs.
- **T-03-02 (Spoofing, marketplace identity):** Local-path marketplace registration — no spoofing surface during Phase 1 spike.
- **T-03-03 (EoP, hook execution):** Stub scripts emit text only; no privileged calls. Per RESEARCH §"Security Domain" — explicitly out of scope for Phase 1.
- **T-03-04 (Repudiation, UAT observability):** The user's direct quote from the fresh session is captured verbatim in the Task 4 evidence section — no empty-approved failure mode.
- **T-03-05 (Info Disclosure, CLI output):** The /tmp evidence files contain absolute paths under `/Users/spencerpresley/...` but the SUMMARY only quotes the `Source: Directory (...)` line where this is structurally necessary; no secrets, no PII.
- **T-03-SC (Tampering, package supply chain):** No third-party packages introduced — `n/a` disposition holds.

No new security-relevant surface introduced. The plugin shell mechanism is the only thing exercised; Phase 3 (real hook payloads) will need its own threat model when the stubs are replaced with content-bearing scripts.

## Next Phase Readiness — Handoff Notes

- **Phase 2 (Router Skill + Content) ready to start.** The router plugin shell is proven working: install resolves, hooks register, skill loads into always-on context (~138 tok), and coexistence with v1 topical plugins is clean. Phase 2 can author `skills/hack-skills-router/SKILL.md` body + `patterns/{routing-tables,expert-intuitions}.md` + `examples/workflow-walkthroughs.md` knowing the surrounding plumbing is sound.
- **Marketplace registration is local-path right now — Phase 4 must switch back.** Task 2 left the marketplace registered as `Source: Directory (/Users/spencerpresley/code/hack-skills-wip/hack-skills-marketplace)`. Phase 4 (Live Validation against published GitHub marketplace) must run `claude plugin marketplace remove hack-skills-marketplace && claude plugin marketplace add SpencerPresley/hack-skills-marketplace` before Phase 4's UAT. This is captured here as a Phase 4 pre-condition.
- **Both UAT plugins remain installed.** `hack-skills-router` and `hack-skills-auth-bypass` are enabled at user scope. For ongoing Phase 2 development this is convenient. If a Phase 2 plan ever needs a clean state, the cleanup is two `claude plugin uninstall` calls (the optional commands documented in Plan 03's `<how-to-verify>` cleanup block).
- **Phase 3 (Real hook payloads) is unblocked.** The Plan 01 stub scripts will be rewritten in Phase 3 with the real ~250 tok SessionStart payload and ~75 tok UserPromptSubmit nudge + the security-context regex from spec §5.3. The wiring proven here (script → stdout → system-reminder inject → Claude's response) will carry across the script-body rewrite unchanged.
- **CLI version captured for traceability:** Claude CLI v2.1.148. `claude plugin validate` is available; `claude plugin marketplace list` shows the `Source:` line with both `GitHub (...)` and `Directory (...)` forms; `claude plugin details` includes the `Hooks (N)  EVENT1, EVENT2  (harness-only — no model context cost)` annotation. Phase 4 should re-check this output shape against whatever CLI version is current at Phase 4 execution time.

---
*Phase: 01-plugin-mechanism-spike*
*Plan: 03*
*Completed: 2026-05-22*
