# Phase 3: Hook Scripts + Regex - Discussion Log

> **Audit trail only.** Do not use as input to planning, research, or execution agents.
> Decisions are captured in CONTEXT.md — this log preserves the alternatives considered.

**Date:** 2026-05-22
**Phase:** 03-hook-scripts-regex
**Areas discussed:** Gray area selection, Regex content scope, SessionStart payload alignment with Phase 2, Hook output format

---

## Gray Area Selection (multi-select)

Four candidate gray areas were surfaced after analyzing the phase boundary, Phase 1 critical findings, and Phase 2 content.

| Option | Description | Selected |
|--------|-------------|----------|
| Regex content scope | Spec §5.3 verbatim vs evolve with Phase 2 routing-tables signal terms | ✓ |
| SessionStart payload alignment with Phase 2 | Phase 2 router-body D-13 wording verbatim vs spec §5.4 wording vs compression | ✓ |
| Hook output format | Plain stdout heredoc vs JSON envelope vs exit-code-2/stderr (raised by user) | ✓ |
| Non-match behavior in nudge.sh | Silent exit 0 vs minimal debug marker | (skipped — user pre-locked) |

**User's choice:** "Regex content scope, SessionStart payload alignment with Phase 2, Hook output format, keep the thing non nudge id say. for hook format you can also dumb exit with error code 2 and it gets dumped back in. See ~/code/simple-but-powerful/plugins/claude-md-discovery-extended/hooks/, not sure if that would make sense here but figured id bring it up so we're thorough."

**Notes:**
- User pre-locked **non-match = silent exit 0, no nudge** ("keep the thing non nudge"). This is captured as D-01 in CONTEXT.md.
- User raised the **exit-code-2 + stderr** pattern as a third option for hook output format (referencing `simple-but-powerful/plugins/claude-md-discovery-extended/hooks/scripts/check_claude_md.py` which uses it for PostToolUse). Investigated via context7 against `code.claude.com/docs/en/hooks`: for `UserPromptSubmit` the exit-2 path BLOCKS AND ERASES the prompt (catastrophic for a passive nudge); for `SessionStart` stderr is shown to the user but NOT to Claude (defeats the purpose). Exit-2 + stderr is documented as PostToolUse-specific; not applicable here. Captured in D-08 of CONTEXT.md.

---

## Regex content scope

| Option | Description | Selected |
|--------|-------------|----------|
| Spec §5.3 verbatim | Use the design spec regex unchanged. Pro: locked design intent. Con: misses Phase 2 deep-signal terms. | |
| Spec §5.3 + Phase 2 signals | Take §5.3 as base, add high-value terms from routing-tables.md signal columns (innerHTML, DOM sink, UNION, blind SQL, introspection, kid, JWKS, etc.). Pro: better coverage. Con: more regex to maintain. | |
| You decide | Delegate to Claude. | ✓ |

**User's choice:** You decide

**Notes:**
- Locked: spec §5.3 base + planner/researcher refines with high-value Phase 2 signal terms, per-term rationale required. Candidate list captured in CONTEXT.md D-02: `introspection`, `host header`, `alg=none`, `JWKS`, `parameter pollution`, `type juggling`, `NoSQL`, `WAF bypass`, `file upload`, `business logic`. All appear in the router body description (`SKILL.md` frontmatter `Triggers:` field) but are missing from the §5.3 base regex.
- Constraint preserved: design spec's "accepted false positives" framing ("hack a quick script", "exploit the feature flag", "vuln scanner CI") stays — do not chase 100% specificity. Refinement happens post-publish in v2.x based on observed noise.

---

## SessionStart payload alignment with Phase 2

| Option | Description | Selected |
|--------|-------------|----------|
| Copy Phase 2 router-body ledes verbatim | Use exact one-sentence wording from router body Boundary Conditions section. Pro: single source of truth, drift-detectable. Con: same bytes inject twice if router body loads in same session. | |
| Use design spec §5.4 wording | Use spec wording (very close to Phase 2 ledes but not byte-identical). Pro: spec is the original source. Con: two near-duplicate sources of truth. | |
| Compress: name-only list + pointer to router | Just name the 8 intuitions (one-or-two-word labels), tell Claude to load Skill(hack-skills-router) for full ledes. Pro: ~150 tok savings. Con: loses standalone usefulness. | |
| You decide | Delegate to Claude. | ✓ |

**User's choice:** You decide

**Notes:**
- Locked as a **mixed-source** approach (D-04/D-05/D-06 in CONTEXT.md):
  - **Trust model + 3-step operating model**: use design spec §5.4 wording (terse, fits the ~250 tok SessionStart budget). The router body has the fuller decision-sequence form — intentionally different views (cold-start primer vs operational reference). Drift acceptable here because the two serve different purposes.
  - **8 intuition ledes**: VERBATIM from Phase 2 router body `SKILL.md` lines 84–91. The ledes are the router's core value (per spec §2.3 + Phase 2 D-13); byte-identical between the two locations means drift is detectable by `diff` or `grep`. Exact source lines captured in D-06.
- "Compress to names-only" rejected because:
  - ~100-150 tok savings is negligible against a 100K-200K context window
  - SessionStart fires once per session (one-time cost, not per-prompt)
  - Cold-start Claude needs actual insight, not labels
  - SessionStart is the safety net for sessions where Claude never invokes Skill(hack-skills-router) — many security questions route directly to a deep skill without going through the router

---

## Hook output format

| Option | Description | Selected |
|--------|-------------|----------|
| Plain stdout heredoc (Recommended) | `cat <<'EOF' ... EOF` + exit 0. Phase 1 verified. Matches rust-skills + oh-my-claudecode references. No script-level jq dep (jq only needed in nudge.sh for stdin parse). | ✓ |
| JSON envelope | `jq -n '{hookSpecificOutput:{hookEventName:..., additionalContext:...}}'` for explicit `additionalContext` framing. More 'canonical' per docs but multi-line escape pain. | |
| You decide | Delegate to Claude. | |

**User's choice:** Plain stdout heredoc (Recommended)

**Notes:**
- Phase 1 already proved stdout heredoc works (Plan 03 UAT observed both SessionStart and UserPromptSubmit markers in Claude's context).
- JSON envelope is the documented alternative for both events on exit 0 but adds complexity for no behavioral gain in this use case.
- Exit-code-2/stderr is **NOT** a viable third option for either of these hook events (verified via context7 against Claude Code docs): UserPromptSubmit exit-2 blocks+erases the prompt; SessionStart exit-2 stderr is user-visible only, not Claude-visible. Captured in CONTEXT.md D-08 with citation.
- Both `session-start.sh` and `nudge.sh` use the same pattern: `#!/bin/bash`, single-quoted heredoc, `exit 0`. nudge.sh adds a `jq -r '.prompt' | grep -qiE "<regex>" || exit 0` filter at the top BEFORE the heredoc.

---

## Closing gate

| Option | Description | Selected |
|--------|-------------|----------|
| Ready for context | Write 03-CONTEXT.md + 03-DISCUSSION-LOG.md and commit. | ✓ |
| Explore more gray areas | Identify additional gray areas (UAT mechanics, JSON envelope on session-start only, false-positive tuning, etc.). | |

**User's choice:** Ready for context

---

## Claude's Discretion

Areas delegated to Claude (user explicitly chose "You decide"):

1. **Regex content scope** (D-02) — Claude proposes the specific Phase 2 signal additions to the §5.3 base, with per-term rationale.
2. **SessionStart payload alignment with Phase 2** (D-04/D-05/D-06) — Claude locked the mixed-source approach: spec wording for trust model + operating model, Phase 2 verbatim for 8 ledes.

Areas where the user pre-locked:

3. **Non-match behavior** — silent exit 0 (locked before discussion started).
4. **Hook output format** — user selected the recommended Plain stdout heredoc option after seeing the trade-off table.

---

## Deferred Ideas

Ideas raised during discussion that belong in future phases (full list in CONTEXT.md `<deferred>` section):

- JSON envelope output upgrade if Phase 4 surfaces framing issues with plain stdout.
- Hook kill-switch env var (`HACK_SKILLS_SKIP_HOOK=1`) — ROUTER-FUT-01.
- Lifecycle hooks beyond SessionStart + UserPromptSubmit (PreCompact, Stop, SubagentStop) — ROUTER-FUT-02.
- Multi-language regex (Chinese signals) — ROUTER-FUT-03.
- Token-cost telemetry / observability tracking.
- v2.x regex refinement based on observed false positives.
- Migration plan if Claude Code starts honoring UserPromptSubmit matcher in a future version (the in-script grep would become redundant).

---

## Discussion artifacts

Verification work done during discussion:
- Inspected `~/code/simple-but-powerful/plugins/claude-md-discovery-extended/hooks/` (user-referenced) to understand the exit-2/stderr pattern in context.
- Dispatched a research agent to verify Claude Code hook output contract via context7 against `code.claude.com/docs/en/hooks` — confirmed the exit-2-stderr pattern is PostToolUse-specific and would break UserPromptSubmit / SessionStart use cases.
- Confirmed `jq 1.8.1` is installed at `/opt/homebrew/bin/jq` (v1 Phase 3 already depended on jq).
- Read prior CONTEXT.md (`02-router-skill-content/02-CONTEXT.md`) to confirm Phase 2 D-13 wording for the 8 intuition ledes.
- Read Phase 1 RESEARCH §Pitfall 3 to confirm the canonical `nudge.sh` implementation pattern (jq + grep + early exit).

---

*Phase: 03-hook-scripts-regex*
*Discussion completed: 2026-05-22*
