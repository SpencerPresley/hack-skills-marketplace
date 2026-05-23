# Phase 3: Hook Scripts + Regex - Context

**Gathered:** 2026-05-22
**Status:** Ready for planning

<domain>
## Phase Boundary

**What this phase delivers:** Replace Phase 1's stub hook scripts with the production payloads, and implement the security-context regex filter that gates `UserPromptSubmit` nudges. Three artifacts:

1. **Rewrite** `plugins/hack-skills-router/hooks/scripts/session-start.sh` in place — from Phase 1 stub (~5 lines of marker text) to the full SessionStart payload (~250 tok: trust model + 3-step operating model + 8 expert-intuition ledes).
2. **Rewrite** `plugins/hack-skills-router/hooks/scripts/nudge.sh` in place — from Phase 1 stub (~5 lines, fires unconditionally) to the production nudge (~75 tok: confirm-scope + load-router + surface-boundary-conditions instructions) gated by an **in-script** regex filter that reads `$PROMPT` from stdin JSON.
3. **Edit** `plugins/hack-skills-router/hooks/hooks.json` UserPromptSubmit `matcher` field — replace Phase 1's placeholder (`"XSS"`) with the design spec §5.3 security-context regex (refined per D-02). The matcher field is **silently ignored by Claude Code 2.1.x** (Phase 1 finding) so it functions as forward-doc only; the actual gating lives in `nudge.sh`. SessionStart matcher (`startup|resume|clear|compact`) is correct and stays.

**What this phase does NOT deliver:**
- Marketplace entry changes — `.claude-plugin/marketplace.json` already has the 14th entry from Phase 1 Plan 02. UNTOUCHED in Phase 3.
- Router skill content — Phase 2 already delivered the `SKILL.md` body + `patterns/*.md` + `examples/*.md`. UNTOUCHED in Phase 3 (Phase 3's hook payloads *reference* what Phase 2 wrote; do not modify it).
- Live validation against published marketplace — Phase 4 owns publish + fresh-install flow.

**Requirements covered:** HOOKS-01, HOOKS-02, HOOKS-03, HOOKS-04 (per `.planning/REQUIREMENTS.md`).

</domain>

<decisions>
## Implementation Decisions

### nudge.sh — regex filter

- **D-01: Non-match behavior — silent `exit 0`, no output.** When the in-script regex does not match `$PROMPT`, the script exits 0 immediately with no stdout. This means Claude Code injects nothing into context — Claude never sees the nudge banner unless the prompt actually triggers a security signal. The "non-nudgy on non-matches" requirement is explicit per user direction. *Rationale: minimizes hook fatigue on non-security work; matches the design spec §5.3 intent (regex was always meant to gate the nudge, not log every prompt).*

- **D-02: Regex content — design spec §5.3 verbatim as the base, planner/researcher selectively adds high-value Phase 2 signal terms with per-addition rationale.** Spec §5.3's 5 categories (vuln acronyms, verb stems, tool names, CVE pattern, recon file artifacts) are the design source of truth and are kept intact. Phase 2 authored `patterns/routing-tables.md` AFTER spec §5.3 was written, and it surfaced specific deep-signal terms that aren't covered by §5.3's acronyms — these are candidates for addition.

  **Candidate Phase 2 additions to evaluate (researcher proposes the final cut with rationale per term):**
  - `introspection` — Phase 2 scenario 2 (GraphQL walkthrough) uses this as the primary signal; not covered by §5.3.
  - `host header` — appears in router body description (`SKILL.md` frontmatter triggers) but missing from §5.3 regex.
  - `alg=none`, `alg:none` — specific JWT attack signal; Phase 2 expert-intuition #8 mechanism paragraph cites this.
  - `JWKS` — JWT verification context per Phase 2 expert-intuition #8; not in §5.3.
  - `parameter pollution` — in router body description; missing from §5.3.
  - `type juggling` — in router body description; missing from §5.3.
  - `NoSQL injection`, `NoSQL` — in router body description; missing from §5.3.
  - `WAF bypass` — in router body description; missing from §5.3.
  - `file upload` — in router body description; missing from §5.3. **Watch for false positives** (any generic file-upload bug discussion).
  - `business logic`, `business-logic` — appears in routing-tables.md as a routing target. **Watch for false positives** (term is generic).

  *Constraint:* additions should preserve the design spec's "accepted false positives" framing (§5.3 calls out "hack a quick script", "exploit the feature flag", "vuln scanner CI" as tolerable noise). Researcher should NOT chase 100% specificity — observed-noise refinement happens post-publish per the design spec.

- **D-03: nudge.sh structure — `jq -r '.prompt'` from stdin + `grep -qiE` + early exit on no-match.** Locked by Phase 1 RESEARCH §Pitfall 3. Canonical shape:
  ```bash
  #!/bin/bash
  PROMPT=$(jq -r '.prompt // empty' < /dev/stdin)
  echo "$PROMPT" | grep -qiE "<regex>" || exit 0
  cat <<'EOF'
  ...nudge payload...
  EOF
  exit 0
  ```
  `jq` is in `$PATH` (verified: `/opt/homebrew/bin/jq`, version 1.8.1); v1 Phase 3 already used jq for marketplace.json validation. The `// empty` fallback handles malformed/missing JSON gracefully. `grep -qiE` is BSD/GNU portable and case-insensitive.

### session-start.sh — payload structure and wording

- **D-04: SessionStart sections — Trust Model + 3-step Operating Model + 8 Expert-Intuition Ledes.** Three sections in this order, wrapped in a `=== HACK-SKILLS SESSION CONTEXT ===` banner per design spec §5.4. Budget: ~250 tok total per spec §5.4 — verify token count during execution against a tokenizer (e.g., `tiktoken` for an approximation, or visual scan against §5.4's sample). Sections END with a "Full router: load Skill(hack-skills-router) when ready" footer that points Claude at the on-demand content.

- **D-05: Trust model + operating model wording — use design spec §5.4 terse forms.** Spec §5.4's Trust Model (3 lines: "These skills are for authorized targets..." / "If a task doesn't have a clear authorization context, ask before proceeding.") and Operating Model (3 steps: "Recon and context validation FIRST" / "Route by observed behavior (signal → category)" / "Apply testing in this typical order: Recon → API/Auth/IDOR → XSS/SQLi/SSRF/SSTI/XXE → Logic/Race → Chains") are deliberately compressed for the SessionStart token budget. The Phase 2 router body has fuller versions (Trust Model with a 3rd "Surface the trust question early" line; Operating Model rewritten as a decision-sequence rather than task-order); the two forms are **intentionally different views** — SessionStart is the cold-start primer, router body is the operational reference. *Drift is acceptable here* because the two serve different purposes.

- **D-06: 8 intuition ledes — VERBATIM from Phase 2 router body `SKILL.md` lines 84–91.** The 8 ledes are the router's core value (per spec §2.3 + Phase 2 D-13). They appear in two places: SessionStart (always-on, ~250 tok session-start budget) and router body Boundary Conditions section (on-demand when router is invoked). These two locations MUST be byte-identical so drift can be detected by a single grep. Use the Phase 2 wording (slightly more polished than spec §5.4's earlier draft — e.g., "across pages" → "across multiple pages", "one is bypassable" → "one point is bypassable"). The Phase 2 source is canonical going forward.

  **Exact source lines** (`plugins/hack-skills-router/skills/hack-skills-router/SKILL.md` lines 84–91):
  ```
  1. The same filtering logic is often reused across multiple pages — if one point is bypassable, similar pages usually are too.
  2. Parameter names are an attack surface too — WAFs often inspect values but not names.
  3. Second-order vulnerabilities are common — safe at storage time does not mean safe when later read into a dangerous context.
  4. BOLA is fundamentally "authenticated but unauthorized" — replaying with account A/B switching is critical.
  5. Older API versions are most likely to miss patches — fixing v2 does not mean v1 was retired.
  6. Business-logic vulnerabilities often bring highest impact — scanners miss them and they persist longer.
  7. Race conditions should prioritize one-time actions — coupon redemption, claims, resets, invites, trials, inventory deduction.
  8. For JWT attacks, check key and algorithm context first — do not blindly spray payloads; verify `alg`, `kid`, JWKS, and key source first.
  ```

  Drift-detection probe (run during execution): `diff <(sed -n '84,91p' plugins/hack-skills-router/skills/hack-skills-router/SKILL.md) <(grep -A 0 '^[0-9]\.' plugins/hack-skills-router/hooks/scripts/session-start.sh)` — or equivalent. The two locations should produce byte-identical content for the 8 lede lines.

### nudge.sh — payload wording

- **D-07: Nudge payload — use design spec §5.5 wording.** ~75 tok: a 3-bullet instruction list inside a `=== HACK-SKILLS (security task detected) ===` banner. Bullets: (1) confirm scope is authorized, (2) load Skill(hack-skills-router) for category selection, (3) surface 2-3 boundary conditions a baseline AI tends to miss. The nudge MUST reference the router skill by name (`Skill(hack-skills-router)`) and the patterns file by path (`patterns/expert-intuitions.md`) — these are the integration points with Phase 2's content. Cross-reference Phase 2 router body to ensure the file paths the nudge cites exist with the names cited.

### hook output format (both scripts)

- **D-08: Plain stdout heredoc, `exit 0`.** Both `session-start.sh` and `nudge.sh` emit their payloads via `cat <<'EOF' ... EOF` (single-quoted heredoc — Phase 1 pattern). Exit code 0. NOT the JSON envelope (`{hookSpecificOutput:{additionalContext:...}}`) form — that's documented per Claude Code docs but the heredoc is simpler, matches Phase 1 verified pattern + rust-skills + oh-my-claudecode references, and avoids the multi-line escape pain of JSON.

  **NOT applicable to this phase: exit-code-2 + stderr pattern.** Confirmed via Claude Code docs (`code.claude.com/docs/en/hooks`): for `UserPromptSubmit`, exit 2 BLOCKS AND ERASES the prompt (catastrophic for a passive nudge); for `SessionStart`, exit-2 stderr is shown to the user but NOT to Claude (defeats the purpose). The exit-2-stderr pattern in `simple-but-powerful/plugins/claude-md-discovery-extended/hooks/scripts/check_claude_md.py` is for `PostToolUse` only, where it's the documented way to feed context back. Do not transfer that pattern to UserPromptSubmit or SessionStart hooks.

### hooks.json — matcher field disposition

- **D-09: Keep `matcher` field on UserPromptSubmit hook in hooks.json as forward-doc only.** Phase 1 RESEARCH §Pitfall 3 verified (citing Claude Code docs) that the `matcher` field is silently ignored for `UserPromptSubmit` events — the hook fires on every prompt regardless of the matcher value. Phase 3 replaces Phase 1's placeholder `"matcher": "XSS"` with the full security-context regex from spec §5.3 (+ D-02 additions). This serves as:
  - **Documentation of intent** — anyone reading `hooks.json` sees what the regex is meant to filter for.
  - **Forward-compatibility hedge** — if Claude Code adds UserPromptSubmit matcher support in a future version, the regex is already in place; only the in-script filter becomes redundant (would no-op silently).
  - **JSON validation surface** — `jq` should parse the matcher value as a string without error.

  *Add an inline JSON comment-equivalent field* (e.g., `"_comment": "Matcher silently ignored by Claude Code 2.1.x — actual gating happens in nudge.sh. Kept here for documentation/forward-compat. See .planning/phases/03-hook-scripts-regex/03-CONTEXT.md D-09."`) — Phase 1 already used a `comment-on-matcher` sibling field at the *hook entry* level; Phase 3 can keep that pattern or move the comment to a different location, planner's call.

- **D-10: SessionStart matcher stays as `startup|resume|clear|compact`.** Verified working in Phase 1 (`01-VERIFICATION.md` SC #3 + `01-03-SUMMARY.md` SessionStart fired with matcher=startup). This covers all 4 documented session-boundary triggers; do not change.

### Verification scope

- **D-11: Manual UAT — 5 positive + 3 negative prompts per ROADMAP Phase 3 SC #4.** Positive prompts to verify nudge fires: "How do I test for XSS in a search box?", "What's a SQLi payload for a login form?", "How do I attack a JWT with alg=none confusion?", "Trying to find CVE-2024-3094 on my target", "Found a `.env` exposed in webroot — what next?". Negative prompts to verify nudge does NOT fire: "What's the weather?", "Refactor this helper function.", "Explain `Promise.all`.". SessionStart fires once on session boundary (verify via fresh `claude` invocation, Phase 1 Plan 03's "Option B" — `01-03-SUMMARY.md` documents the technique). Token-count check: spot-check session-start.sh output via a tokenizer if available; visual scan against spec §5.4's reference text otherwise.

### Claude's Discretion

User explicitly delegated 2 of the 3 surfaced gray areas to Claude (regex content, SessionStart payload alignment); chose the recommended option for hook output format; and pre-locked non-match behavior. Decisions D-01 through D-11 are Claude's calls within the boundaries the user established. Rationale is captured per-decision; researcher and planner are free to challenge any of them with evidence but should treat them as defaults.

**Specifically open for researcher/planner refinement (NOT to be re-asked of user):**
- Exact list of regex additions from the D-02 candidate set, with per-term rationale (researcher proposes; planner locks).
- Exact `hooks.json` placement of the silently-ignored-matcher comment field (D-09; Phase 1 used a `comment-on-matcher` sibling — keep or move).
- Exact session-start.sh banner format / footer wording (D-04; spec §5.4 has a sample but planner can polish).
- Exact UAT prompt set (D-11 lists 5+3 starter prompts; planner can adjust if a more representative set exists).
- Token-count measurement technique (D-04 / D-11; spec says ~250 tok and ~75 tok — researcher proposes a measurement approach if one is needed beyond visual inspection).

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Design source of truth (LOCKED — supersedes ad-hoc decisions)
- `.planning/specs/2026-05-22-v2-router-design.md` §5.3 — `hooks.json` shape + UserPromptSubmit regex (the base for D-02)
- `.planning/specs/2026-05-22-v2-router-design.md` §5.4 — `session-start.sh` payload (Trust Model + Operating Model + 8 Intuitions — the source for D-05 wording; intuitions superseded by D-06 Phase 2 verbatim)
- `.planning/specs/2026-05-22-v2-router-design.md` §5.5 — `nudge.sh` payload (the source for D-07)
- `.planning/specs/2026-05-22-v2-router-design.md` §3 — Locked decisions (sidecar, redefined-middle hooks, regex matcher trigger, hybrid routing, additive to v1)
- `.planning/specs/2026-05-22-v2-router-design.md` §9 — Open implementation questions (most resolved in Phase 1; remaining ones inform Phase 3)
- `.planning/specs/2026-05-22-v2-router-design.md` §11 — Source attribution requirements

### Requirements & roadmap
- `.planning/REQUIREMENTS.md` §HOOKS-01..HOOKS-04 — phase requirements with acceptance criteria
- `.planning/ROADMAP.md` §"Phase 3: Hook Scripts + Regex" — phase goal + 4 success criteria (SC #4 = UAT prompts)
- `.planning/PROJECT.md` §Constraints + §"Key Decisions" sidecar row — source immutability, sidecar pattern, regex matcher trigger model

### Phase 1 (LOCKED critical findings — DO NOT re-litigate)
- `.planning/phases/01-plugin-mechanism-spike/01-RESEARCH.md` **§Pitfall 3** — UserPromptSubmit `matcher` silently ignored; in-script filter pattern prescribed. **This is the most consequential finding for Phase 3** and locks the implementation shape (jq + grep + exit 0).
- `.planning/phases/01-plugin-mechanism-spike/01-RESEARCH.md` §"SessionStart matcher" — `startup|resume|clear|compact` verified semantics; D-10 keeps this.
- `.planning/phases/01-plugin-mechanism-spike/01-RESEARCH.md` "JSON envelope vs plain stdout" trade-off — Phase 3 picks plain stdout per D-08; JSON envelope is the alternative.
- `.planning/phases/01-plugin-mechanism-spike/01-03-SUMMARY.md` — Phase 1 UAT technique (Option B fresh `claude` invocation for session-boundary trigger) — reuse for D-11 SessionStart verification.
- `.planning/phases/01-plugin-mechanism-spike/01-VERIFICATION.md` — Phase 1 SC #3 stub format constraints (single-quoted heredoc, `${CLAUDE_PLUGIN_ROOT}`, exit 0, chmod +x) — Phase 3 inherits all of these.
- `.planning/phases/01-plugin-mechanism-spike/01-PATTERNS.md` — sidecar plugin file-layout pattern; bash hook script pattern.

### Phase 2 (immediate content predecessor — D-06 verbatim source)
- `plugins/hack-skills-router/skills/hack-skills-router/SKILL.md` lines 84–91 — **THE 8 INTUITION LEDES** for D-06 verbatim copy into `session-start.sh`. Byte-identical between the two locations is a verification requirement.
- `plugins/hack-skills-router/skills/hack-skills-router/SKILL.md` "Trust model" section — for cross-reference to D-05 (terse session-start version vs fuller router body version; intentional divergence).
- `plugins/hack-skills-router/skills/hack-skills-router/SKILL.md` "Operating model (3 steps)" section — same cross-reference note.
- `plugins/hack-skills-router/skills/hack-skills-router/patterns/routing-tables.md` — source for D-02 candidate signal terms (researcher mines this for additions to the §5.3 base regex).
- `plugins/hack-skills-router/skills/hack-skills-router/patterns/expert-intuitions.md` — full ledes + mechanisms + examples. Phase 3's `nudge.sh` cites this file by name (D-07 footer); the file path MUST be correct.
- `.planning/phases/02-router-skill-content/02-CONTEXT.md` D-13 — "boundary conditions in body = one-sentence summaries" decision; informs why D-06 uses verbatim copy.
- `.planning/phases/02-router-skill-content/02-CONTEXT.md` D-15 — "source attribution in 4 files" — Phase 3's hook scripts do NOT add attribution (they reference the router skill, which carries attribution). Confirm during execution.

### Source content (upstream, MIT-licensed)
- `/Users/spencerpresley/.claude/plugins/cache/hack-skills-marketplace/hack-skills-recon/c6f732befcae-32c1cf49/hack/SKILL.md` — upstream `hack` SKILL.md. Phase 3's hook payloads do NOT directly source from upstream (Phase 2 already did the paraphrasing) — referenced here only as the original chain-of-source for the 8 intuitions.

### External documentation (verified Phase 3-relevant)
- `code.claude.com/docs/en/hooks` — Claude Code hook output contract. Verified during Phase 3 discussion: `stdout + exit 0` injects context for SessionStart and UserPromptSubmit; `stderr + exit 2` is blockable for UserPromptSubmit (erases prompt!) and shows-to-user-only for SessionStart (NOT visible to Claude). JSON envelope `{"hookSpecificOutput":{"hookEventName":"...","additionalContext":"..."}}` is documented for both events on exit 0 — D-08 picks plain stdout instead.

### Current state of write targets (what Phase 3 modifies)
- `plugins/hack-skills-router/hooks/scripts/session-start.sh` — current = Phase 1 stub (12 lines, banner + marker text). Phase 3 REPLACES in place with ~250 tok payload per D-04/D-05/D-06.
- `plugins/hack-skills-router/hooks/scripts/nudge.sh` — current = Phase 1 stub (15 lines, unconditional fire + marker text). Phase 3 REPLACES in place with regex-gated nudge per D-01/D-03/D-07.
- `plugins/hack-skills-router/hooks/hooks.json` — current = Phase 1 placeholder matcher `"XSS"` on UserPromptSubmit + comment field. Phase 3 EDITS the matcher value to spec §5.3 regex + D-02 additions per D-09. SessionStart matcher untouched (D-10).
- `.claude-plugin/marketplace.json` — UNTOUCHED in Phase 3.
- `plugins/hack-skills-router/skills/hack-skills-router/{SKILL.md,patterns/,examples/}` — UNTOUCHED in Phase 3 (Phase 2 owns).

### Downstream phase awareness
- `.planning/ROADMAP.md` §"Phase 4: Live Validation" — Phase 4 validates Phase 3's hook scripts against the published marketplace. Phase 3's nudge.sh and session-start.sh MUST produce stable, deterministic output (no timestamp, no machine-specific paths) so Phase 4's verification observation is reproducible.

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- **Phase 1 stub `session-start.sh`** (`plugins/hack-skills-router/hooks/scripts/session-start.sh`): file exists, executable (mode 0755), valid shebang, single-quoted heredoc, `exit 0`. Phase 3 rewrites the heredoc body in place — preserves the shell wrapper structure.
- **Phase 1 stub `nudge.sh`** (`plugins/hack-skills-router/hooks/scripts/nudge.sh`): same structural baseline. Phase 3 adds a `jq -r '.prompt'` + `grep -qiE` filter at the top before the heredoc.
- **`hooks.json`** (`plugins/hack-skills-router/hooks/hooks.json`): already declares both hooks with correct command paths, timeouts (5s SessionStart, 3s UserPromptSubmit). Phase 3 edits only the UserPromptSubmit `matcher` value.
- **Phase 2 router body** (`plugins/hack-skills-router/skills/hack-skills-router/SKILL.md`): source for D-06 verbatim copy of 8 intuition ledes (lines 84-91). Also the cross-reference target for D-07 nudge.sh's "load Skill(hack-skills-router)" instruction.
- **Phase 2 `expert-intuitions.md`** (`plugins/hack-skills-router/skills/hack-skills-router/patterns/expert-intuitions.md`): the nudge.sh footer (per D-07) cites this file path — must match exactly.
- **`jq` 1.8.1** at `/opt/homebrew/bin/jq`: confirmed installed. Used by `nudge.sh` for stdin JSON parsing. v1 Phase 3 already used jq for marketplace validation — known-good dependency.

### Established Patterns
- **Bash hook script** (Phase 1 `01-PATTERNS.md`): `#!/bin/bash` shebang, `cat <<'EOF' ... EOF` single-quoted heredoc, `exit 0`, mode 0755. Phase 3 preserves this exact shape with the regex-filter prefix added to nudge.sh.
- **STUB → FINAL boundary check** (Phase 2 D-13 + Phase 1 `01-01-SUMMARY.md`): Phase 3 must remove every residual "STUB" / "Phase 1 stub" / "[stub]" marker from both scripts. Verification probe: `grep -i 'stub\|placeholder\|phase 1' plugins/hack-skills-router/hooks/scripts/*.sh` should return zero lines after Phase 3.
- **Atomic commits per file** (Phase 1 + Phase 2 execution patterns): each `.sh` lands as its own commit with `feat(03): ...` message; the `hooks.json` matcher edit lands as its own commit. No mega-commits.
- **Single source of truth via verbatim copy** (new in Phase 3 D-06): when content appears in two locations (router body + SessionStart), make them byte-identical so drift is detectable by diff/grep. Plan a verification probe for the diff.
- **`comment-on-matcher` sibling field in hooks.json** (Phase 1 RESEARCH §"hooks.json placement"): Phase 1 added a benign unrecognized JSON field next to the matcher to document why the matcher is there. Phase 3 keeps or replaces the comment but the practice (annotating hooks.json with intent) is established.

### Integration Points
- **`session-start.sh` ↔ Phase 2 router body**: D-06 makes the 8 intuition ledes byte-identical. If Phase 2's `SKILL.md` lines 84-91 are ever rewritten, `session-start.sh` MUST be updated to match. Plan a verification probe.
- **`nudge.sh` footer ↔ Phase 2 file paths**: D-07's nudge body cites `Skill(hack-skills-router)` and `patterns/expert-intuitions.md` by name. The Phase 2 file at that path MUST exist with that name (verified — it does). If Phase 2's progressive-disclosure layout ever changes, `nudge.sh` updates too.
- **`hooks.json` matcher ↔ in-script regex**: D-02 + D-09. The regex in hooks.json (forward-doc) and the regex in nudge.sh (actual filter) MUST be the same string. Plan a verification probe that diffs them.
- **`hooks.json` SessionStart matcher ↔ Phase 1 UAT technique**: D-10. The matcher value `startup|resume|clear|compact` was verified to fire correctly via Phase 1's Option B (fresh `claude` invocation). D-11 reuses Option B for Phase 3's manual verification.

</code_context>

<specifics>
## Specific Ideas

- **Banner formats**: design spec §5.4 has `=== HACK-SKILLS SESSION CONTEXT ===` as the SessionStart banner top and `===================================` as the bottom. §5.5 has `=== HACK-SKILLS (security task detected) ===` and `============================================`. Phase 3 should use these exact banner strings — they're recognizable identifiers Claude can look for in its context to know what's been injected.
- **Footer guidance in session-start.sh**: per spec §5.4: `Full router and deep skills: load Skill(hack-skills-router) when ready.` Use this verbatim — establishes the "router is the entry point for deeper content" expectation up front.
- **`jq -r '.prompt // empty'` is intentional**: the `// empty` fallback yields empty string instead of "null" string when the prompt field is missing or null. This makes the subsequent `grep` reliably non-match on malformed input (= silent exit 0 per D-01).
- **`grep -qiE`**: `-q` quiet (no output), `-i` case-insensitive, `-E` extended regex (supports the design spec's `(?i)`, `\b`, `\d`, `|` alternation, character classes). Test the regex against macOS BSD grep and GNU grep before locking — the spec's regex uses `(?i)` which is PCRE syntax and may not work with all grep variants; consider rewriting the case-insensitive flag as `grep -qiE` (the `-i` flag) instead of inline `(?i)`.
- **Phase 1 `comment-on-matcher` field placement** (`hooks.json` line 249 of Phase 1's research draft): the comment field was at the hook-entry level (sibling to `matcher`). Phase 3 may move it to the description field or keep it as a sibling — either works; benign unrecognized fields are tolerated by Claude Code per Phase 1 verification.
- **The "5 positive + 3 negative" test prompts in D-11** are STARTER suggestions only. The Phase 3 SC #4 in ROADMAP.md is the official acceptance criterion ("UserPromptSubmit fires on at least 5 representative security prompts... and does NOT fire on 3 representative non-security prompts").

</specifics>

<deferred>
## Deferred Ideas

- **JSON envelope output format upgrade** (D-08 alternative not taken): if Phase 4 live-validation reveals that plain stdout has any quirky framing on specific Claude Code versions, the JSON envelope (`{"hookSpecificOutput":{"hookEventName":"UserPromptSubmit","additionalContext":"..."}}`) is the documented alternative. Not Phase 3's job; revisit if Phase 4 surfaces issues.
- **Hook kill-switch env var** (ROUTER-FUT-01, REQUIREMENTS.md Future): not Phase 3. If hook fatigue manifests in real use, add `HACK_SKILLS_SKIP_HOOK=1` env-var check at the top of each script.
- **Lifecycle hooks beyond SessionStart + UserPromptSubmit** (ROUTER-FUT-02, REQUIREMENTS.md Future): PreCompact, Stop, SubagentStop, etc. — not Phase 3's scope.
- **Multi-language router triggers** (ROUTER-FUT-03, REQUIREMENTS.md Future): upstream `hack` SKILL.md has bilingual Chinese descriptions; the regex stays English-only per `REQUIREMENTS.md` Out of Scope.
- **Token-cost telemetry / observability hook**: tracking how often the regex fires per session, how many tok/session the hooks add — not Phase 3's job. Could be a v2.x telemetry effort.
- **Refined regex from observed false-positive logs**: spec §5.3 says "refine over time by observation, not by trying to enumerate perfectly upfront." Phase 3's regex is the v0; v2.x can refine based on real-use logs.
- **Migration plan if Claude Code adds UserPromptSubmit matcher support**: D-09 hedges by keeping the regex in hooks.json. If a future Claude Code version starts honoring the matcher, the in-script grep becomes redundant. Removal is a small follow-up but not Phase 3's scope.

</deferred>

---

*Phase: 03-hook-scripts-regex*
*Context gathered: 2026-05-22*
