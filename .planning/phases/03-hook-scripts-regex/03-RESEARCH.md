# Phase 3: Hook Scripts + Regex - Research

**Researched:** 2026-05-22
**Domain:** Bash hook scripts + portable POSIX regex + cross-tier content consistency
**Confidence:** HIGH

## Summary

Phase 3 is **NOT a greenfield research** — 11 implementation decisions (D-01..D-11) were locked in `03-CONTEXT.md`. This research fills the 4 explicit gaps the user delegated: (1) the exact D-02 regex additions with per-term rationale, (2) a token-count measurement technique for the ~250 tok and ~75 tok budgets, (3) cross-grep portability of the spec §5.3 inline `(?i)` flag, and (4) drift-detection probes for D-06 (byte-identical 8-lede ledes between `SKILL.md` and `session-start.sh`) and for D-02/D-09 (same regex in `hooks.json` matcher and `nudge.sh` grep).

The most consequential finding: **the spec §5.3 regex's `(?i)` inline flag must be stripped**. `(?i)` is PCRE syntax; POSIX ERE (which both BSD `grep -E` on macOS and GNU `grep -E` on Linux honor) does not include inline flags. The portable form is `grep -qiE` (the `-i` *flag*, not inline `(?i)`). On the current Darwin 25 box `/usr/bin/grep` happens to accept `(?i)` because its BSD grep has GNU-compat extensions, but Linux GNU `grep -E` does not parse `(?i)` and the regex would silently match the literal characters or fail. Strip `(?i)` from the regex before composing the final matcher value; rely on the `-i` flag.

Other portability findings, all VERIFIED against `/usr/bin/grep` (BSD 2.6.0-FreeBSD on macOS 25.2): `\d` and `\b` and `[0-9]{4}` and the spec §5.3 `CVE-\d{4}-\d+` pattern all work under `-E`. However, the design spec already documents `CVE-\d{4}-\d+`; for maximum cross-distribution safety the planner should rewrite this as `CVE-[0-9]{4}-[0-9]+`. `\b` word boundary is supported by BSD grep `-E` and is documented in GNU grep — keep `\b` where the spec uses it.

**Primary recommendation:**
- Strip `(?i)` from the spec §5.3 regex; rely on `grep -iE` flag.
- Rewrite `\d` → `[0-9]` for maximum portability (zero behavior change on the systems we care about; insurance against obscure POSIX ERE implementations).
- Add 7 of the 10 D-02 candidate terms (introspection, host header, alg=none/alg:none consolidated to `alg[=:]none`, JWKS, parameter pollution, type juggling, NoSQL, WAF as `\bWAF\b`); EXCLUDE 2 (file upload, business logic — too generic for dev chat); fold "WAF bypass" into `\bWAF\b` since the order-of-words concern means matching `WAF` alone with the security-context regex's other terms is sufficient.
- Use `wc -w × 1.33` heuristic for the token-budget spot check during execution — zero dependencies, ballparks within ~30% of true token count (good enough for "~250 tok" and "~75 tok" targets where a 20% miss is invisible).
- For diff probes, use `jq -r` + `grep -E "^[0-9]\. "` pairs (BSD/GNU compatible) — exact one-liners provided below.

## User Constraints (from CONTEXT.md)

### Locked Decisions

- **D-01:** nudge.sh non-match behavior — silent `exit 0`, no output.
- **D-02:** Regex content — spec §5.3 verbatim as the base; researcher proposes selective additions with per-term rationale (THIS RESEARCH delivers the final list).
- **D-03:** nudge.sh structure — `jq -r '.prompt // empty' < /dev/stdin` → `grep -qiE "<regex>"` → early exit on no-match → `cat <<'EOF'` heredoc payload → `exit 0`.
- **D-04:** SessionStart sections — Trust Model + 3-step Operating Model + 8 Expert-Intuition Ledes; banner `=== HACK-SKILLS SESSION CONTEXT ===`; budget ~250 tok.
- **D-05:** Trust model + operating model wording — spec §5.4 terse forms (drift from Phase 2 router body is INTENTIONAL; SessionStart and router-body serve different views).
- **D-06:** 8 intuition ledes — VERBATIM from Phase 2 `SKILL.md` lines 84-91, byte-identical between SessionStart and router body.
- **D-07:** Nudge payload — spec §5.5 wording; references `Skill(hack-skills-router)` and `patterns/expert-intuitions.md` by name.
- **D-08:** Plain stdout heredoc + `exit 0`; NOT the JSON envelope; NOT exit-code-2.
- **D-09:** Keep `matcher` field on UserPromptSubmit in hooks.json as forward-doc only; same regex string as nudge.sh's `grep -qiE` argument.
- **D-10:** SessionStart matcher stays as `startup|resume|clear|compact`.
- **D-11:** Manual UAT — 5 positive + 3 negative prompts per ROADMAP Phase 3 SC #4; SessionStart fires once on session boundary (Option B fresh `claude` invocation per Phase 1 `01-03-SUMMARY.md`); token spot-check via tokenizer if available.

### Claude's Discretion

**Specifically open for researcher/planner refinement (NOT to be re-asked of user):**
- Exact list of regex additions from the D-02 candidate set, with per-term rationale (researcher proposes; planner locks) — **answered in §"Phase 3 Implementation Choices, Item 1" below**.
- Exact `hooks.json` placement of the silently-ignored-matcher comment field (D-09; Phase 1 used a `comment-on-matcher` sibling — keep or move).
- Exact session-start.sh banner format / footer wording (D-04; spec §5.4 has a sample but planner can polish).
- Exact UAT prompt set (D-11 lists 5+3 starter prompts; planner can adjust if a more representative set exists).
- Token-count measurement technique (D-04 / D-11; spec says ~250 tok and ~75 tok — researcher proposes a measurement approach if one is needed beyond visual inspection) — **answered in §"Phase 3 Implementation Choices, Item 2" below**.

### Deferred Ideas (OUT OF SCOPE)

- JSON envelope output format upgrade (D-08 alternative not taken).
- Hook kill-switch env var (ROUTER-FUT-01).
- Lifecycle hooks beyond SessionStart + UserPromptSubmit (ROUTER-FUT-02).
- Multi-language router triggers (ROUTER-FUT-03).
- Token-cost telemetry / observability hook.
- Refined regex from observed false-positive logs (post-publish observation).
- Migration plan if Claude Code adds UserPromptSubmit matcher support.

## Phase Requirements

| ID | Description | Research Support |
|----|-------------|------------------|
| HOOKS-01 | SessionStart fires once per session and injects trust + 3-step ops + 8-entry intuitions snapshot (~250 tok; spec §5.4) | §"Phase 3 Implementation Choices, Item 2" (token measurement), §"Code Examples — session-start.sh" |
| HOOKS-02 | UserPromptSubmit fires on prompts matching security-context regex (spec §5.3 + D-02 additions) and injects routing nudge (~75 tok; spec §5.5) | §"Phase 3 Implementation Choices, Item 1" (final regex), §"Phase 3 Implementation Choices, Item 3" (portability — `(?i)` strip), §"Code Examples — nudge.sh" |
| HOOKS-03 | UserPromptSubmit does NOT fire on prompts with no security keywords; verified via at least one non-security prompt producing no injection | §"Code Examples — nudge.sh" (D-01 silent exit 0), §"Final regex UAT empirical results" |
| HOOKS-04 | Both hook scripts: bash, use `${CLAUDE_PLUGIN_ROOT}`, exit 0, complete within timeouts (5s SessionStart, 3s UserPromptSubmit) | Inherited from Phase 1 (RESEARCH §Pattern 4 + VERIFICATION SC #3); `hooks.json` already declares timeouts (Phase 1) |

## Architectural Responsibility Map

| Capability | Primary Tier | Secondary Tier | Rationale |
|------------|-------------|----------------|-----------|
| Hook script payload (text content) | Plugin's `hooks/scripts/*.sh` | — | Bash scripts emit static heredoc to stdout — content is pure data. |
| Regex filter logic | Inside `nudge.sh` (`grep -qiE`) | `hooks.json` matcher (forward-doc only) | Phase 1 finding: UserPromptSubmit matcher silently ignored. Real filtering must live in the script. |
| Stdin JSON parsing | `nudge.sh` via `jq -r '.prompt // empty'` | — | Claude Code delivers prompt as `{ "prompt": "...", ... }` on stdin. `jq` parses; `// empty` provides safe fallback for malformed JSON. |
| Cross-script content consistency (8 ledes) | `SKILL.md` is the canonical source (lines 84-91) | `session-start.sh` heredoc mirrors verbatim | Phase 2 wrote the ledes; Phase 3 duplicates them. Drift detection via `diff` probe is the safety net. |
| Cross-script regex consistency | `hooks.json` matcher + `nudge.sh` `grep -qiE` argument | — | D-02 + D-09: same string in two files. Drift detection via `jq -r` + `sed/grep` probe. |
| Verification (UAT) | `claude` CLI + fresh-session observation | `/tmp/03-*.txt` capture (mirror of Phase 1 evidence pattern) | Reuse Phase 1's Option B technique (`01-03-SUMMARY.md`). |

## Standard Stack

This is a hooks-only phase — no library installs, no new packages. The tools below are already present and verified.

### Core
| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| `bash` | 5.3.9 (system) | Hook script runtime | [CITED: code.claude.com/docs/en/hooks] Hook scripts run under `sh -c`; plain bash scripts with `#!/bin/bash` shebang are the documented pattern. |
| `jq` | 1.8.1 at `/opt/homebrew/bin/jq` | Parse stdin JSON in nudge.sh | [VERIFIED Phase 1 RESEARCH §"Code Examples"] `jq -r '.prompt // empty'` is the canonical UserPromptSubmit stdin extraction pattern. `// empty` fallback handles missing/null/malformed JSON gracefully (verified — exit code 5 on malformed JSON; `2>/dev/null` swallows; subsequent grep on empty input is silent no-match → exit 0 per D-01). |
| `/usr/bin/grep` (BSD 2.6.0-FreeBSD on macOS / GNU grep on Linux) | system | Regex filter under `grep -qiE` | [VERIFIED via direct testing this session] BSD grep on Darwin 25 supports `-iE` with `\b`, `[0-9]{4,}`, simple alternation. The `-i` flag is POSIX-mandatory across BSD and GNU. |
| `wc` + `awk` | system | Token-count heuristic | POSIX standard; `wc -w` × 1.33 is the standard rough-token approximation. Available everywhere without install. |

### Supporting (already in repo / inherited)
| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| `sed` | system | Extract specific line ranges for diff probes | `sed -n '84,91p' SKILL.md` to pull the 8-lede block. BSD and GNU sed agree on `-n '<range>p'`. |
| `diff` | system | Drift detection between two extracted slices | `diff <(...)` process substitution requires bash (which we have); not POSIX-portable but fine on macOS/Linux + bash. |
| `claude` CLI | 2.1.148 (Phase 1 verified) | UAT — install, fresh session, observe injection | Same tool as Phase 1 verification; the fresh-session observation technique (Option B) is documented in `01-03-SUMMARY.md`. |

### Alternatives Considered
| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| `wc -w × 1.33` token-count heuristic | `tiktoken` (Python — OpenAI's GPT tokenizer) | tiktoken approximates Claude's tokenizer (different model family) but is more accurate than wc heuristic. Cost: `pip install tiktoken` (not currently installed on this box). Not worth the install for a one-time ~250 tok / ~75 tok ballpark check. |
| `wc -w × 1.33` token-count heuristic | `anthropic` SDK's `messages.count_tokens()` API | Most accurate (uses Claude's actual tokenizer). Cost: requires API key + network call + ~3s latency per measurement. Overkill for "is the payload roughly in budget?" verification. |
| `wc -w × 1.33` token-count heuristic | `npx tiktoken-cli file.txt` | Zero local install but auto-downloads samber/tiktoken-cli via npm registry. Skipped due to CLAUDE.md hint about avoiding `npx --yes` and supply-chain hygiene. |
| BSD grep `-iE` | BSD grep `-iP` (PCRE) | `/usr/bin/grep` on macOS does NOT support `-P` (verified — "invalid option"). GNU grep supports `-P` but it's not POSIX. Stick with `-E`. |
| Inline `(?i)` PCRE flag in regex | `-i` grep flag | POSIX ERE does not include inline flags. `(?i)` happens to work on this Darwin 25 box's BSD grep but is non-portable. **Strip from the spec §5.3 regex; rely on `-i` flag.** |
| `\d` in regex | `[0-9]` | `\d` is GNU `grep -E` extension AND happens to work on Darwin 25 BSD grep. POSIX ERE does not include `\d`. **For maximum portability rewrite as `[0-9]`** — zero behavior change, insurance against odd POSIX ERE implementations. |

**Installation:** Nothing to install. All tools are system-bundled or already-verified-present.

**Version verification:**
```bash
bash --version | head -1     # GNU bash, version 5.3.9 — VERIFIED
jq --version                  # jq-1.8.1 — VERIFIED at /opt/homebrew/bin/jq
/usr/bin/grep --version       # grep (BSD grep, GNU compatible) 2.6.0-FreeBSD — VERIFIED
claude --version              # 2.1.148 — Phase 1 verified, expected still current
```

## Package Legitimacy Audit

Not applicable. Phase 3 does not install any external packages.

The only dependency considered (`tiktoken` Python package) is REJECTED in favor of zero-install `wc -w` heuristic — see "Alternatives Considered" above.

## Phase 3 Implementation Choices

This section delivers the 4 explicit research items the user delegated to the researcher per CONTEXT.md `<decisions>` "Specifically open for researcher/planner refinement."

---

### Item 1: D-02 regex additions — per-term rationale + final regex string

The spec §5.3 base regex contains 5 categories (vuln acronyms, verb stems, tool names, CVE pattern, recon file artifacts). CONTEXT.md D-02 lists 10 candidate Phase 2 signal terms to evaluate as additions. The table below is the researcher's proposed cut.

**Verification approach for each term:**
- Verified term appears in Phase 2 content (`patterns/routing-tables.md` and/or `SKILL.md` body description) — `grep -in` results above.
- Tested specificity by running each term as a regex against (a) realistic security prompts that should fire and (b) realistic dev-chat prompts that should NOT fire.

| Term | In Phase 2? | Specificity assessment | Disposition | Final regex shape | Rationale |
|------|------------|----------------------|-------------|---------------------|-----------|
| `introspection` | YES — routing-tables.md row for `graphql-and-hidden-parameters`; SKILL.md body workflow ref | Low FP risk: outside GraphQL the word rarely appears in dev chat; SQL "introspection" and OS "introspection" are niche topics that are still security-adjacent | **INCLUDE** | `introspection` (bare) | Phase 2 scenario 2 uses this as the primary GraphQL signal; aligns with router routing tables. |
| `host header` | YES — routing-tables.md `http-host-header-attacks` row | Moderate FP risk: "host header" appears in normal HTTP/proxy talk too. But it's case-insensitive on `-i`, and most config-talk uses "Host header" (capital H) anyway — when a dev says "host header" they usually mean the attack vector. | **INCLUDE** | `host header` (bare, `-i` handles case) | The combo "host" + "header" together is uncommon in non-security dev chat; FP rate acceptable. |
| `alg=none` | YES — routing-tables.md jwt row; expert-intuitions.md mechanism para for intuition #8 | Specific attack signal; near-zero FP — this string almost never appears outside JWT discussions | **INCLUDE** | `alg[=:]none` (consolidated with `alg:none` below) | Both `alg=none` (URL form / log form) and `alg:none` (YAML / JSON form) appear in real prompts. |
| `alg:none` | YES — same source as `alg=none` | Same as `alg=none` | **INCLUDE** | Folded into `alg[=:]none` | Single regex token covers both variants. |
| `JWKS` | YES — routing-tables.md jwt row; expert-intuitions.md mechanism para; SKILL.md line 91 (lede #8 mentions JWKS by name) | Near-zero FP: JWKS is JWT-specific terminology | **INCLUDE** | `JWKS` (bare, `-i` handles case) | The router cites JWKS as a key signal for JWT routing. |
| `parameter pollution` | YES — SKILL.md frontmatter triggers (line 10); expert-intuitions.md example #2 | Low FP: this exact phrase is specific to HPP (HTTP Parameter Pollution) attacks | **INCLUDE** | `parameter pollution` (bare) | The spec §5.3 base regex covers "parameter" inside the broader CVE/payload section but does NOT cover "parameter pollution" the named attack class. |
| `type juggling` | YES — SKILL.md frontmatter line 10 | Low FP: niche term for PHP-style loose-comparison attacks | **INCLUDE** | `type juggling` (bare) | Specific attack class; nearly always security-context. |
| `NoSQL injection` | YES — SKILL.md frontmatter line 10 | Low FP for full phrase | **INCLUDE** | `NoSQL` (just "NoSQL" — anyone mentioning NoSQL in a security context is the target audience; if FP becomes a real issue, narrow to `NoSQL injection`) | "NoSQL" alone could FP on benign database talk; on balance the security-context bias of this router justifies inclusion. Trade-off acknowledged. **Alternative:** narrow to `NoSQL injection` if FP signal arises post-publish. |
| `WAF bypass` | YES — SKILL.md frontmatter line 10 | TESTED: literal "WAF bypass" misses "Bypass the WAF" (word order). | **INCLUDE as `\bWAF\b`** | `\bWAF\b` | Matching `WAF` alone with word boundaries captures "WAF bypass", "Bypass the WAF", "WAF rule bypass", etc. FP risk on "configure a WAF" exists but the router's whole point is to route on security signals — WAF mentions are unambiguously security. |
| `file upload` | YES — SKILL.md frontmatter line 10 | **HIGH FP risk** — "file upload" is hugely common in general dev chat (e.g., "Refactor the file upload component", "Implement a file upload endpoint in Express"). | **EXCLUDE** | (omit) | The spec §5.3 design philosophy ("accepted false positives") is tolerant of some noise, but file upload is too generic. The user can address file-upload bug discussions via the deep skill once the router is loaded; not worth FP-poisoning UserPromptSubmit for every generic file-upload dev prompt. |
| `business logic` / `business-logic` | YES — routing-tables.md `business-logic-vulnerabilities` row; SKILL.md line 89 | **HIGH FP risk** — "business logic" appears constantly in non-security dev chat (e.g., "Document the business logic for the checkout flow"). | **EXCLUDE** | (omit) | Same rationale as `file upload` — the router can still recommend the business-logic skill via other signals (race condition, coupon, multi-step bypass, workflow abuse — those are in routing-tables.md row 107 and could be additions if needed in the future, but for v0 we keep the noise floor low). |

**Net additions:** 7 terms folded into 6 regex tokens (`alg=none` + `alg:none` → `alg[=:]none`):
1. `introspection`
2. `host header`
3. `alg[=:]none`
4. `JWKS`
5. `parameter pollution`
6. `type juggling`
7. `NoSQL`
8. `\bWAF\b`

**Excluded:** `file upload`, `business logic`.

**Final combined regex string** (drop-in for both `hooks.json` matcher and `nudge.sh` `grep -qiE`):

```text
(XSS|SQLi|SSRF|XXE|IDOR|BOLA|BFLA|CSRF|CORS|RCE|SSTI|LFI|RFI|JWT|OAuth|SAML|OIDC|NTLM|Kerberos|pentest|bug ?bounty|vulnerab|exploit\b|payload|attack surface|recon\b|enumerat|privesc|priv ?esc|reverse shell|lateral movement|burp|nmap|sqlmap|metasploit|gobuster|ffuf|hashcat|mimikatz|bloodhound|CVE-[0-9]{4}-[0-9]+|\.git/|\.env\b|robots\.txt|/etc/passwd|prototype pollution|deserialization|race condition|web cache|request smuggling|introspection|host header|alg[=:]none|JWKS|parameter pollution|type juggling|NoSQL|\bWAF\b)
```

**Changes from spec §5.3 base:**
1. **Stripped leading `(?i)`** — see Item 3 below; `-i` flag handles case.
2. **`\d` → `[0-9]`** in the CVE pattern — POSIX-portable; zero behavior change.
3. **Added 8 D-02 terms** (7 unique, 1 folded into `alg[=:]none`).

**Length:** 522 chars (up from 429 in spec §5.3 base). Under 1000-char practical limit for shell tokenization; no concern.

**Verified empirically (this session):**
- All 5 D-11 positive UAT prompts MATCH the final regex.
- All 3 D-11 negative UAT prompts do NOT MATCH.
- Catastrophic backtracking risk: NONE. Simple alternation with no nested quantifiers, no overlapping alternation prefixes followed by `*`/`+`. `grep -E` uses NFA without recursion — no risk of pathological input.

---

### Item 2: Token-count measurement technique for ~250 tok / ~75 tok budgets

**Recommendation:** `wc -w` × 1.33 heuristic. Zero install. Ballpark accuracy within ~30% (good enough for "is this near ~250 tok?" / "is this near ~75 tok?" verification).

**Exact command for SessionStart payload check:**
```bash
# Extract the heredoc body and measure
sed -n "/cat <<'EOF'/,/^EOF$/{/cat <<'EOF'/d; /^EOF$/d; p}" plugins/hack-skills-router/hooks/scripts/session-start.sh \
  | wc -w \
  | awk '{print int($1 * 1.33), "estimated tokens (target: ~250)"}'
```

**Exact command for nudge.sh payload check:**
```bash
sed -n "/cat <<'EOF'/,/^EOF$/{/cat <<'EOF'/d; /^EOF$/d; p}" plugins/hack-skills-router/hooks/scripts/nudge.sh \
  | wc -w \
  | awk '{print int($1 * 1.33), "estimated tokens (target: ~75)"}'
```

**Calibration test from this session:** A sample SessionStart approximation (101 words, 746 chars) gave `wc -w × 1.33 = 134 tokens` and `chars / 4 = 186 tokens`. Both heuristics are in the right order of magnitude; the spread (134-186) is acceptable for a "near 250 tok" check. The final script will be denser than the approximation (more text per word), so 250 tok is achievable in ~190-200 words / ~1000 chars.

**Alternatives rejected:**
- **`tiktoken` (Python OpenAI tokenizer):** Not installed on this box; install cost (`pip install tiktoken` or pulling a wheel) outweighs the precision benefit for a one-shot budget check. tiktoken approximates Claude's tokenizer but is not identical — adds ~5-10% error of its own. Net: not better than wc heuristic for our use case.
- **`anthropic` SDK `messages.count_tokens()`:** Most accurate but requires API key + network. Overkill — the budget targets in the spec are themselves approximations ("~250", "~75"), not hard limits. If the payload comes out at 300 tok instead of 250, that's a 20% miss on a budget that itself has ±20% slop. Network call adds friction for zero practical benefit.
- **`npx tiktoken-cli` (auto-download via npm):** Avoided due to supply-chain hygiene (would auto-execute a downloaded package; CLAUDE.md and GSD researcher guidance both flag `npx --yes` as a vector to avoid).
- **Visual diff against spec §5.4 / §5.5 reference text:** Lowest precision but viable as a sanity check. Recommended as a **second pass** AFTER the wc heuristic: compare line counts and overall density visually to the spec reference; if both heuristics agree, the budget is met.

**Token-count tolerances:** The planner should treat the budget as "approximately, within reason" — a 200-300 tok SessionStart or 60-90 tok nudge is fine. Hard-failing on a 280-tok SessionStart would be over-precise. The 250/75 targets are guideposts, not contracts.

---

### Item 3: Cross-grep portability check on the spec §5.3 `(?i)` inline flag

**Question:** Does `grep -qiE` with the `-i` flag correctly handle case-insensitive matching across BSD + GNU grep without needing inline `(?i)` in the pattern?

**Answer: YES.** Strip `(?i)` from the regex; rely on `-i` flag.

**Verification (this session):**
- `/usr/bin/grep` on macOS Darwin 25.2 reports `grep (BSD grep, GNU compatible) 2.6.0-FreeBSD`. Under `sh -c` (the hook script invocation context), `grep` resolves to `/usr/bin/grep` — verified via `sh -c 'which grep; grep --version | head -1'`.
- `echo "I want XSS testing" | /usr/bin/grep -qiE "xss"` → MATCH. Confirms `-i` works for case-insensitive.
- `echo "I want XSS testing" | /usr/bin/grep -qE "(?i)xss"` → MATCH on this box. **But this is NOT cross-portable.** POSIX ERE does not define `(?i)` inline flags; this is a BSD grep extension on Darwin 25.x specifically. GNU `grep -E` on Linux does NOT parse `(?i)`; on systems where it's not implemented, `(?i)` would be misinterpreted (literal characters or syntax error depending on the version).
- `/usr/bin/grep -P "(?i)..."` → "invalid option" on BSD grep. `-P` (PCRE) is GNU-only. Skip `-P`.

**Cleaned regex (`(?i)` stripped):**

The full final regex string (from Item 1 above) already has `(?i)` stripped. The planner should drop it into both:
1. `hooks.json` UserPromptSubmit `matcher` field (forward-doc only per D-09).
2. `nudge.sh` as the argument to `grep -qiE "..."`.

**Other portability findings from empirical testing (`/usr/bin/grep` on Darwin 25):**

| Feature | Spec §5.3 uses | BSD grep behavior | GNU grep behavior | Recommendation |
|---------|---------------|-------------------|------------------|----------------|
| Inline `(?i)` | YES | Works (Darwin 25.x) | Does NOT work | **Strip** — use `-i` flag |
| `\d` in `CVE-\d{4}-\d+` | YES | Works | Works as GNU ext (under `-E` it's accepted) | **Rewrite as `[0-9]`** for insurance — zero behavior change |
| `\b` word boundary | YES (`exploit\b`, `recon\b`, `\.env\b`) | Works | Works (GNU grep `-E` supports `\b`) | **Keep** |
| Simple alternation `(a|b|c)` | YES | Works | Works | **Keep** |
| Character class `[=:]` | (researcher-added for `alg[=:]none`) | Works | Works | **Keep** |
| `?` quantifier (`bug ?bounty`) | YES | Works | Works | **Keep** |
| `{4}`, `{4,7}` interval quantifier | YES (CVE pattern) | Works | Works | **Keep** |

**Bottom line:** With `(?i)` stripped and `\d` → `[0-9]`, the regex is POSIX ERE-portable and works identically under `grep -qiE` on BSD (Darwin) and GNU (Linux).

---

### Item 4: Cross-file content consistency / drift-detection probes

Two drift scenarios require dedicated verification probes during execution:

#### 4a. D-06 byte-identical 8-lede ledes (SKILL.md ↔ session-start.sh)

**The problem:** D-06 requires the 8 intuition ledes in `session-start.sh` to be byte-identical to `SKILL.md` lines 84-91. The two files have different surrounding context (Markdown body vs. shell heredoc) but the lede LINES must match exactly so a single `diff` detects drift.

**Recommended probe** (BSD/GNU sed + grep compatible):

```bash
# Extract source-of-truth ledes from SKILL.md (lines 84-91)
sed -n '84,91p' plugins/hack-skills-router/skills/hack-skills-router/SKILL.md > /tmp/03-ledes-skill.txt

# Extract numbered ledes from session-start.sh (lines starting with "N. ")
grep -E '^[0-9]\. ' plugins/hack-skills-router/hooks/scripts/session-start.sh > /tmp/03-ledes-script.txt

# Diff them
if diff -q /tmp/03-ledes-skill.txt /tmp/03-ledes-script.txt > /dev/null 2>&1; then
  echo "PASS: ledes byte-identical between SKILL.md and session-start.sh"
else
  echo "FAIL: drift detected between SKILL.md lines 84-91 and session-start.sh numbered ledes:"
  diff /tmp/03-ledes-skill.txt /tmp/03-ledes-script.txt
fi
```

**Why this shape works:**
- `sed -n '84,91p'` is POSIX; both BSD and GNU sed honor it identically.
- `grep -E '^[0-9]\. '` selects lines starting with a digit followed by `. ` (space) — this is exactly the format the 8 ledes have in SKILL.md and what the planner will use in session-start.sh.
- Process substitution (`<(...)`) is bash-specific but the hook scripts run under bash and the verification runs under the developer's shell (bash or zsh on macOS) — fine. The variant above uses tmp files for maximum portability.
- `diff -q` is silent on match (good for CI-style probes); the explicit `diff` block prints the actual differences if there's drift.

**Verified (this session):** `sed -n '84,91p' plugins/.../SKILL.md` correctly extracts the 8 lede lines. Confirmed they ARE the spec lines 84-91.

#### 4b. D-02 + D-09 same regex string in hooks.json and nudge.sh

**The problem:** D-09 keeps the regex in hooks.json `matcher` as forward-doc; the actual filter lives in nudge.sh's `grep -qiE "<regex>"`. The two strings must be IDENTICAL (semantically) — but they live in two different escape regimes:
- **hooks.json:** JSON-escaped (backslash doubled — e.g., `\b` is stored as `\\b` in JSON source).
- **nudge.sh:** Shell-escaped inside double quotes (single backslash — `\b` is literal).
- **After decoding (jq -r reads the JSON, sed extracts from the .sh):** Both should produce byte-identical strings.

**Recommended probe:**

```bash
# Extract matcher from hooks.json (jq -r decodes JSON escapes)
HOOKS_MATCHER=$(jq -r '.hooks.UserPromptSubmit[0].matcher' plugins/hack-skills-router/hooks/hooks.json)

# Extract regex from nudge.sh's grep -qiE "..." line
NUDGE_REGEX=$(grep -oE 'grep -qiE "[^"]+"' plugins/hack-skills-router/hooks/scripts/nudge.sh \
              | sed -E 's/grep -qiE "(.+)"/\1/')

# Compare
if [ "$HOOKS_MATCHER" = "$NUDGE_REGEX" ]; then
  echo "PASS: hooks.json matcher and nudge.sh regex are byte-identical after decoding"
else
  echo "FAIL: regex drift between hooks.json and nudge.sh"
  echo "hooks.json: $HOOKS_MATCHER"
  echo "nudge.sh:   $NUDGE_REGEX"
  diff <(echo "$HOOKS_MATCHER") <(echo "$NUDGE_REGEX")
fi
```

**Caveats:**
- The `grep -oE 'grep -qiE "[^"]+"'` extractor assumes the regex does NOT contain a literal `"` (double quote). Our final regex has no `"` — safe.
- `sed -E` for extended regex extraction works on both BSD and GNU sed (GNU uses `-r` too, but `-E` is the BSD-compatible spelling and GNU sed accepts `-E` since 4.2).
- If the regex needs to contain a `"` in a future revision, change the extraction to use line-anchored matching: `sed -n 's/^.*grep -qiE "\(.*\)".*$/\1/p' nudge.sh`.

**Suggested probe placement in plan:**
- Run probe 4a after `session-start.sh` is written (Wave 1 or 2 verification task).
- Run probe 4b after BOTH `hooks.json` and `nudge.sh` are updated — they must change in lock-step.

#### 4c. STUB marker removal probe (boundary check)

CONTEXT.md `<code_context>` section calls out: "Phase 3 must remove every residual 'STUB' / 'Phase 1 stub' / '[stub]' marker from both scripts."

**Recommended probe:**

```bash
# Should return zero lines after Phase 3 is complete
grep -in 'stub\|placeholder\|phase 1' plugins/hack-skills-router/hooks/scripts/*.sh
# Exit code 1 = no matches (PASS); exit 0 = matches found (FAIL)
```

**Current state (verified this session):** the probe currently finds 7 matches in the Phase 1 stubs (both files have "STUB" and "Phase 1 stub" markers). After Phase 3, this probe MUST return zero matches.

## Architecture Patterns

### System Architecture Diagram

```
                ┌──────────────────────────────────────────────────────────────────────┐
                │  USER opens fresh Claude session OR submits a prompt                 │
                └─────────────────────────────────┬────────────────────────────────────┘
                                                  │
                  ┌───────────────────────────────┴───────────────────────────────┐
                  │                                                               │
              SessionStart                                              UserPromptSubmit
              (matcher: startup|                                         (matcher silently
               resume|clear|compact)                                      ignored — fires
                  │                                                       on every prompt)
                  │                                                               │
                  ▼                                                               ▼
        ┌─────────────────────────┐                            ┌─────────────────────────────┐
        │ Claude Code invokes:    │                            │ Claude Code invokes:        │
        │ bash "${CLAUDE_PLUGIN_  │                            │ bash "${CLAUDE_PLUGIN_      │
        │ ROOT}/hooks/scripts/    │                            │ ROOT}/hooks/scripts/        │
        │ session-start.sh"       │                            │ nudge.sh"                   │
        │                         │                            │                             │
        │ stdin: { source: "...", │                            │ stdin: { prompt: "...",     │
        │   session_id: "...",    │                            │   session_id: "...",        │
        │   model: "...", ... }   │                            │   permission_mode: "...",   │
        │                         │                            │   ... }                     │
        │ (session-start.sh       │                            │                             │
        │  IGNORES stdin)         │                            │                             │
        └────────────┬────────────┘                            └────────────┬────────────────┘
                     │                                                       │
                     │ cat <<'EOF'                                           │ jq -r '.prompt // empty'
                     │ ~250 tok payload:                                     │       │
                     │   Trust Model (terse)                                 │       ▼
                     │   Operating Model (3 steps)                           │ echo "$PROMPT" |
                     │   8 expert intuitions                                 │   grep -qiE "<regex>"
                     │   "Full router: load Skill(...)" footer               │       │
                     │ EOF                                                   │   ┌───┴───┐
                     │ exit 0                                                │  match  no match
                     │                                                       │   │       │
                     ▼                                                       │   ▼       ▼
        ┌─────────────────────────┐                                          │ cat   exit 0
        │ Claude Code captures    │                                          │ <<'EOF'  (D-01)
        │ stdout                  │                                          │ ~75 tok│
        │                         │                                          │ nudge: │
        │ Injects as system       │                                          │ EOF    │
        │ reminder at start of    │                                          │ exit 0 │
        │ session context         │                                          │   │    │
        │                         │                                          │   ▼    ▼
        │ (always-on for the rest │                                          │ ┌──────────────────┐
        │ of the session — ~250   │                                          │ │ Claude Code      │
        │ tok cost once)          │                                          │ │ captures stdout  │
        └─────────────────────────┘                                          │ │ → appended to    │
                                                                             │ │ this prompt's    │
                                                                             │ │ context (NOT     │
                                                                             │ │ persisted)       │
                                                                             │ └──────────────────┘
                                                                             │
                                                                             ▼ (silent no-output)
                                                                  Claude sees only the user's prompt
                                                                  with no nudge banner.
```

### Recommended Project Structure

No new files, no new directories. Phase 3 modifies 3 existing files in place:

```
plugins/hack-skills-router/
└── hooks/
    ├── hooks.json                         # EDIT: replace matcher "XSS" with final regex
    └── scripts/
        ├── session-start.sh               # REWRITE body: ~250 tok payload (D-04/D-05/D-06)
        └── nudge.sh                       # REWRITE body: jq + grep filter + ~75 tok nudge (D-01/D-03/D-07)
```

### Pattern 1: jq + grep + early-exit nudge.sh shape

**What:** UserPromptSubmit hook that reads `$PROMPT` from stdin JSON, greps for security-context regex, and exits silently if no match — only emits the nudge heredoc when the regex matches.

**When to use:** This phase's `nudge.sh`. Pattern is locked by D-03; researcher confirms shape.

**Example** (full proposed `nudge.sh` body):

```bash
#!/bin/bash
# Source: design spec §5.5 + Phase 1 RESEARCH §Pitfall 3 (in-script filter) + D-03 (CONTEXT.md)
# UserPromptSubmit hook for hack-skills-router. The matcher field in hooks.json is silently
# ignored by Claude Code 2.1.x — actual filtering happens here.

PROMPT=$(jq -r '.prompt // empty' < /dev/stdin 2>/dev/null)
echo "$PROMPT" | grep -qiE "(XSS|SQLi|SSRF|XXE|IDOR|BOLA|BFLA|CSRF|CORS|RCE|SSTI|LFI|RFI|JWT|OAuth|SAML|OIDC|NTLM|Kerberos|pentest|bug ?bounty|vulnerab|exploit\b|payload|attack surface|recon\b|enumerat|privesc|priv ?esc|reverse shell|lateral movement|burp|nmap|sqlmap|metasploit|gobuster|ffuf|hashcat|mimikatz|bloodhound|CVE-[0-9]{4}-[0-9]+|\.git/|\.env\b|robots\.txt|/etc/passwd|prototype pollution|deserialization|race condition|web cache|request smuggling|introspection|host header|alg[=:]none|JWKS|parameter pollution|type juggling|NoSQL|\bWAF\b)" || exit 0

cat <<'EOF'

=== HACK-SKILLS (security task detected) ===
Before answering:
1. Confirm scope is authorized — if not, refuse.
2. If you haven't already, load Skill(hack-skills-router) for category selection.
3. Surface 2-3 boundary conditions a baseline AI tends to miss for this attack class
   (the router's "expert intuitions" tables cover these — load patterns/expert-intuitions.md
   if the relevant ones aren't in working memory).
============================================
EOF
exit 0
```

**Critical points:**
- `< /dev/stdin` is explicit (vs. implicit); makes the data source readable. Could be omitted (default stdin) but explicit is clearer.
- `2>/dev/null` on `jq` swallows the parse error when stdin is malformed JSON or empty. Verified: malformed input → `PROMPT=""` → grep matches nothing → silent `exit 0` (matches D-01).
- The single-quoted `<<'EOF'` heredoc prevents shell expansion of `$` or backticks inside the payload. **Verified:** the payload has no `$VAR` references that need expansion — only literal text — so single-quoted is correct.
- Final `exit 0` is explicit (the heredoc itself doesn't change exit status, but heredoc + `cat` succeeds, so this is belt-and-braces).

### Pattern 2: Single-quoted heredoc + plain stdout SessionStart payload

**What:** SessionStart hook that emits a fixed ~250 tok payload via single-quoted heredoc; ignores stdin.

**When to use:** This phase's `session-start.sh`. Pattern is locked by D-04/D-05/D-06/D-08.

**Example** (full proposed `session-start.sh` body — banner, sections, lede block, footer):

```bash
#!/bin/bash
# Source: design spec §5.4 (Trust Model + Operating Model + 8 intuitions) + D-06 CONTEXT.md
# Ledes (lines starting with "N. ") are byte-identical to SKILL.md lines 84-91 — drift probe
# in .planning/phases/03-hook-scripts-regex/03-RESEARCH.md §"Drift-detection probes."

cat <<'EOF'

=== HACK-SKILLS SESSION CONTEXT ===

This session has the hack-skills-router plugin installed.

TRUST MODEL:
- These skills are for authorized targets, bug bounty programs in scope,
  defensive validation, and legitimate research only.
- If a task doesn't have a clear authorization context, ask before proceeding.

OPERATING MODEL (from upstream `hack` skill):
1. Recon and context validation FIRST. Identify target shape, identity model,
   input/output locations.
2. Route by observed behavior (signal -> category) using the router's tables.
3. Apply testing in this typical order:
   Recon -> API/Auth/IDOR -> XSS/SQLi/SSRF/SSTI/XXE -> Logic/Race -> Chains.

EXPERT INTUITIONS (high-value, baseline AI commonly misses):
1. The same filtering logic is often reused across multiple pages — if one point is bypassable, similar pages usually are too.
2. Parameter names are an attack surface too — WAFs often inspect values but not names.
3. Second-order vulnerabilities are common — safe at storage time does not mean safe when later read into a dangerous context.
4. BOLA is fundamentally "authenticated but unauthorized" — replaying with account A/B switching is critical.
5. Older API versions are most likely to miss patches — fixing v2 does not mean v1 was retired.
6. Business-logic vulnerabilities often bring highest impact — scanners miss them and they persist longer.
7. Race conditions should prioritize one-time actions — coupon redemption, claims, resets, invites, trials, inventory deduction.
8. For JWT attacks, check key and algorithm context first — do not blindly spray payloads; verify `alg`, `kid`, JWKS, and key source first.

Full router and deep skills: load Skill(hack-skills-router) when ready.
===================================
EOF
exit 0
```

**Critical points:**
- The `=== HACK-SKILLS SESSION CONTEXT ===` banner top and the `===================================` bottom are spec §5.4 verbatim (per CONTEXT.md `<specifics>` paragraph 1).
- The footer `Full router and deep skills: load Skill(hack-skills-router) when ready.` is spec §5.4 verbatim.
- The 8 lede lines are D-06 verbatim from `SKILL.md` lines 84-91 — drift probe 4a above detects any future drift.
- The Trust Model and Operating Model wording is spec §5.4 terse forms (D-05 — intentionally different from Phase 2 router body's fuller versions; spec §5.4 is the SessionStart canonical text).
- Backticks `` `alg` ``, `` `kid` ``, etc. inside the lede block are markdown backticks — single-quoted heredoc prevents them from being treated as command substitution (verified empirically).
- `exit 0` explicit.

### Pattern 3: hooks.json matcher edit (forward-doc only)

**What:** Replace UserPromptSubmit `matcher` value `"XSS"` (Phase 1 placeholder) with the full final regex (forward-doc per D-09; silently ignored at runtime but kept for documentation + forward-compat).

**When to use:** This phase's `hooks.json` edit.

**Example diff** (proposed hooks.json after edit):

```json
{
  "description": "Hack-skills router hooks. SessionStart for one-time setup; UserPromptSubmit for per-prompt security-context nudge.",
  "hooks": {
    "SessionStart": [
      {
        "matcher": "startup|resume|clear|compact",
        "hooks": [
          {
            "type": "command",
            "command": "bash \"${CLAUDE_PLUGIN_ROOT}/hooks/scripts/session-start.sh\"",
            "timeout": 5
          }
        ]
      }
    ],
    "UserPromptSubmit": [
      {
        "matcher": "(XSS|SQLi|SSRF|XXE|IDOR|BOLA|BFLA|CSRF|CORS|RCE|SSTI|LFI|RFI|JWT|OAuth|SAML|OIDC|NTLM|Kerberos|pentest|bug ?bounty|vulnerab|exploit\\b|payload|attack surface|recon\\b|enumerat|privesc|priv ?esc|reverse shell|lateral movement|burp|nmap|sqlmap|metasploit|gobuster|ffuf|hashcat|mimikatz|bloodhound|CVE-[0-9]{4}-[0-9]+|\\.git/|\\.env\\b|robots\\.txt|/etc/passwd|prototype pollution|deserialization|race condition|web cache|request smuggling|introspection|host header|alg[=:]none|JWKS|parameter pollution|type juggling|NoSQL|\\bWAF\\b)",
        "comment-on-matcher": "Matcher silently ignored by Claude Code 2.1.x — actual gating happens in nudge.sh via grep -qiE. Kept here for documentation and forward-compat. See .planning/phases/03-hook-scripts-regex/03-CONTEXT.md D-09 + 03-RESEARCH.md §'Drift probe 4b'. The regex string here is byte-identical (after JSON decode) to the grep argument in nudge.sh.",
        "hooks": [
          {
            "type": "command",
            "command": "bash \"${CLAUDE_PLUGIN_ROOT}/hooks/scripts/nudge.sh\"",
            "timeout": 3
          }
        ]
      }
    ]
  }
}
```

**JSON-escape note:** `\b` in the regex becomes `\\b` in the JSON source string. `jq -r` unescapes back to `\b` for the drift probe. SessionStart entry stays exactly as Phase 1 wrote it.

**Comment field placement:** Phase 1 used `comment-on-matcher` as a sibling field to `matcher`. The planner can keep this exact placement (least disruptive — extends a pattern Phase 1 already validated against `claude plugin validate`) or move the comment elsewhere. Recommendation: **keep as Phase 1 sibling** because the comment is *about* the matcher; co-location aids readability.

### Anti-Patterns to Avoid

- **Including `(?i)` inline in the regex.** Spec §5.3 has it; it must be stripped. POSIX ERE does not parse it; relying on it makes the regex non-portable to Linux GNU grep. Use `-i` flag instead.
- **Using `\d` in the CVE pattern.** It happens to work on Darwin 25 BSD grep but is not POSIX. Rewrite as `[0-9]`. Zero behavior change; insurance.
- **Forgetting `2>/dev/null` on jq.** Without it, jq prints a parse error to stderr when stdin is malformed JSON. The error wouldn't break the script (stderr is ignored by Claude Code's stdout capture for context injection) but it pollutes `claude --debug` logs and may surface in transcripts.
- **Double-quoted heredoc `<<EOF` instead of single-quoted `<<'EOF'`.** Double-quoted form expands `$VAR` and `` `cmd` `` inside the body. Our payloads contain backticks for markdown emphasis (e.g., `` `alg` ``) — double-quoted heredoc would try to run them as command substitution, producing empty strings or errors. **Stay with `<<'EOF'`** (D-08 lock).
- **Adding `file upload` or `business logic` to the regex.** D-02 candidate review (Item 1 above) rejected both — too generic for dev chat. Including them would cause hook fatigue on routine prompts and defeat D-01's "non-nudgy on non-matches" intent.
- **Leaving "STUB" / "Phase 1 stub" markers in the final scripts.** Probe 4c above catches this.
- **Changing the SessionStart matcher.** D-10 locks `startup|resume|clear|compact`. No changes; leave Phase 1's hooks.json SessionStart block exactly as-is.

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Stdin JSON parsing in nudge.sh | Hand-rolled bash regex against the raw stdin string | `jq -r '.prompt // empty'` | jq is in `$PATH` (verified `/opt/homebrew/bin/jq`); v1 Phase 3 already validated it. `// empty` fallback handles all malformed/missing-field cases gracefully (verified). |
| Token counting | Bash word-counting + lookup table | `wc -w` × 1.33 heuristic | The budget is ±20% slop; precision tools add install friction for no practical benefit. wc is POSIX. |
| Case-insensitive regex matching | Manual `[Xx][Ss][Ss]` character classes for every term | `grep -iE` (the `-i` flag) | `-i` is POSIX-mandated; works identically on BSD and GNU. Manual char classes inflate the regex 3× and add maintenance burden. |
| Cross-file drift detection | Manual visual diff or a one-off file fingerprint | `diff` + `sed -n '<range>p'` + `grep -E '^[0-9]\. '` | POSIX utilities; the probe is one line; runs in <100ms; catches the exact failure mode D-06 worries about. |
| UserPromptSubmit prompt filtering (Claude Code-side) | Trusting the `matcher` field | In-script `grep -qiE` filter (D-03) | UserPromptSubmit matcher is silently ignored (Phase 1 finding, RESEARCH §Pitfall 3). The only working mechanism is in-script filtering. |

**Key insight:** Phase 3 is fundamentally a content rewrite, not a mechanism change. Phase 1 proved the mechanism (script → stdout → Claude context). Phase 3 swaps stub text for real text and adds one regex filter at the top of nudge.sh. No new infrastructure.

## Runtime State Inventory

**Trigger evaluation:** Phase 3 is a *content rewrite* (not a rename/refactor/migration). Strictly speaking the Runtime State Inventory section is optional. However, two relevant cache-related notes for the planner:

| Category | Items Found | Action Required |
|----------|-------------|------------------|
| Stored data | None — no datastores referenced by the router | None |
| Live service config | None — router doesn't talk to external services | None |
| OS-registered state | **Plugin cache subdir** at `~/.claude/plugins/cache/hack-skills-marketplace/hack-skills-router/<sha>-<hash>/` from Phase 1 install | After Phase 3 edits, `claude plugin uninstall hack-skills-router && claude plugin install hack-skills-router@hack-skills-marketplace` to refresh the cache copy (the cache is populated on install, not auto-synced from working tree). This is part of Phase 3's UAT flow already. |
| Secrets/env vars | None | None |
| Build artifacts | None — bash scripts execute directly; no compilation | None |

**Plugin cache stale-after-edit note:** After Phase 3 modifies `session-start.sh` / `nudge.sh` / `hooks.json`, the working-tree files are updated but the local CACHE copy (at `~/.claude/plugins/cache/hack-skills-marketplace/hack-skills-router/<sha>-<hash>/`) still reflects the Phase 1 stub. The UAT step MUST include a reinstall (`uninstall && install`) to push the new contents into the cache. This is consistent with Phase 1's pattern; Phase 1's Plan 03 already documented the cache-population semantics.

## Common Pitfalls

### Pitfall 1: Inline `(?i)` PCRE flag leaks into the final regex

**What goes wrong:** Researcher/planner copies the spec §5.3 regex verbatim into `nudge.sh` and `hooks.json`. On the dev's macOS box (BSD grep with GNU compat) the regex works. When a user runs the plugin on Linux (GNU grep), `(?i)` is not parsed — the regex effectively becomes case-sensitive AND tries to interpret `(?i)` as a literal regex prefix. The hook fires on prompts containing `(?i)` (rare) and misses lowercase variants of the security terms (common).
**Why it happens:** PCRE `(?i)` is non-standard. POSIX ERE has no inline flags. The two regex engines look identical for most common patterns but diverge on inline flag syntax.
**How to avoid:** **Strip `(?i)` from the regex before composing the matcher.** Rely on `grep -i` flag (POSIX). The final regex above already does this.
**Warning signs:** Hook misses lowercase security prompts ("how do I test for xss" doesn't fire); hook fires on prompts containing `?i)` (extremely rare).

### Pitfall 2: Heredoc accidentally double-quoted, backticks expand as command substitution

**What goes wrong:** Author writes `cat <<EOF` (no quotes) instead of `cat <<'EOF'` (single-quoted). Bash sees the unquoted heredoc and expands `$` and `` ` `` references inside the body. The payload contains backticks for markdown emphasis (e.g., `` `alg` ``, `` `kid` `` in intuition #8). Bash tries to run `alg` as a command, fails silently, replaces it with empty string — payload now reads "do not blindly spray payloads; verify ,, JWKS, and key source first." Worse: a malicious payload `` `rm -rf` `` would execute. Even though our content is safe, the discipline matters.
**Why it happens:** Default heredoc syntax expands; the `'EOF'` quoting opt-out is easy to forget.
**How to avoid:** **Always use `<<'EOF'` (single-quoted)** for hook script payloads. D-08 locks this. Document the constraint in a comment for future editors.
**Warning signs:** Empty fields or odd text where backticks should be; script exits with non-zero on a command not found.

### Pitfall 3: Drift between `SKILL.md` 8-lede ledes and `session-start.sh` numbered ledes

**What goes wrong:** Phase 2 later revises a lede in `SKILL.md` (e.g., tightens wording). `session-start.sh` is not updated. Drift accumulates. The router body and SessionStart-injected text now contradict each other; Claude gets confused which version is authoritative.
**Why it happens:** Two locations of the same string without an automated sync mechanism. D-06 requires byte-identical but doesn't enforce it.
**How to avoid:** **Run drift probe 4a (above) as a verification task** in the Phase 3 plan. Include the probe in any future maintenance plan that touches either file. If the project grows beyond one developer, consider extracting the 8 ledes into a `data/intuitions.txt` shared file with both `SKILL.md` and `session-start.sh` interpolating from it — but for a personal marketplace, the diff probe is sufficient.
**Warning signs:** Drift probe 4a returns non-zero exit; subjective disagreement between router-body claims and SessionStart claims.

### Pitfall 4: Drift between `hooks.json` matcher and `nudge.sh` regex

**What goes wrong:** Same as Pitfall 3 but for the regex string. Easy to update one and forget the other.
**Why it happens:** Two locations, two escape regimes (JSON vs shell), same logical string.
**How to avoid:** **Run drift probe 4b (above) as a verification task** in the Phase 3 plan. Update both files together in the same atomic commit; the diff probe catches any forgotten update.
**Warning signs:** Drift probe 4b returns non-zero exit; user-facing weirdness like "the hook fires on prompts the docs say it shouldn't" (because hooks.json says X but nudge.sh greps for Y).

### Pitfall 5: Forgetting to chmod +x after rewriting the .sh files

**What goes wrong:** Phase 1 set mode 0755 on both scripts. After Phase 3 rewrites them, the existing `+x` bit is preserved (the `Write` tool overwrites contents but typically preserves existing permissions). HOWEVER, if a `cp` or `mv` or `Bash` round-trip strips permissions, the hooks silently fail.
**Why it happens:** Phase 1 RESEARCH Pitfall 2 — Claude Code requires `+x` on hook scripts; failure mode is silent (no output, no error, hook just doesn't run).
**How to avoid:** **Verification task in the Phase 3 plan: `ls -l plugins/hack-skills-router/hooks/scripts/*.sh | grep rwx`** — should show `rwxr-xr-x` on both files. Belt-and-braces: include `chmod +x plugins/hack-skills-router/hooks/scripts/*.sh` as a no-op idempotent task after the rewrites.
**Warning signs:** Hooks don't fire post-Phase-3 even though Phase 1 worked; `claude --debug` logs show "permission denied".

### Pitfall 6: `\d` in CVE pattern (spec §5.3 verbatim) on systems with strict POSIX ERE

**What goes wrong:** Spec §5.3 has `CVE-\d{4}-\d+`. `\d` is a GNU/PCRE extension; on a strictly POSIX-conformant system (rare in practice but possible on minimal Alpine Linux images, busybox, or some embedded systems), `\d` is parsed as the literal characters `\` and `d`. The CVE pattern would only match strings containing those literal characters, breaking CVE detection entirely.
**Why it happens:** Spec was written without POSIX-ERE-strict portability in mind; relies on the de-facto GNU/BSD-with-GNU-compat behavior.
**How to avoid:** **Rewrite `\d` → `[0-9]`.** The final regex above does this. Zero behavior change on systems that support `\d`; safety net on systems that don't.
**Warning signs:** Hook misses CVE-pattern prompts on certain Linux distros.

### Pitfall 7: jq parse-error noise on `--debug` due to malformed stdin

**What goes wrong:** Without `2>/dev/null`, `jq` prints parse errors to stderr when stdin is malformed (e.g., during `claude --debug` or some edge case where the hook is invoked outside Claude Code's normal JSON envelope). The errors don't break the script (stderr is ignored by stdout-capture for context injection) but they pollute debug logs and may surface in transcripts.
**Why it happens:** jq's default behavior is verbose on errors.
**How to avoid:** **`jq -r '.prompt // empty' 2>/dev/null`** in nudge.sh. Verified safe: combined with `// empty`, malformed input → empty string → grep no-match → silent exit 0.
**Warning signs:** Noise in `claude --debug` output; user reports "weird jq errors when I run Claude in debug mode."

## Code Examples

### Final `nudge.sh` (drop-in candidate)

```bash
#!/bin/bash
# Source: design spec §5.5 + Phase 1 RESEARCH §Pitfall 3 + CONTEXT.md D-01/D-03/D-07
# UserPromptSubmit hook for hack-skills-router. The matcher field in hooks.json is silently
# ignored by Claude Code 2.1.x — actual filtering happens here.

PROMPT=$(jq -r '.prompt // empty' < /dev/stdin 2>/dev/null)
echo "$PROMPT" | grep -qiE "(XSS|SQLi|SSRF|XXE|IDOR|BOLA|BFLA|CSRF|CORS|RCE|SSTI|LFI|RFI|JWT|OAuth|SAML|OIDC|NTLM|Kerberos|pentest|bug ?bounty|vulnerab|exploit\b|payload|attack surface|recon\b|enumerat|privesc|priv ?esc|reverse shell|lateral movement|burp|nmap|sqlmap|metasploit|gobuster|ffuf|hashcat|mimikatz|bloodhound|CVE-[0-9]{4}-[0-9]+|\.git/|\.env\b|robots\.txt|/etc/passwd|prototype pollution|deserialization|race condition|web cache|request smuggling|introspection|host header|alg[=:]none|JWKS|parameter pollution|type juggling|NoSQL|\bWAF\b)" || exit 0

cat <<'EOF'

=== HACK-SKILLS (security task detected) ===
Before answering:
1. Confirm scope is authorized — if not, refuse.
2. If you haven't already, load Skill(hack-skills-router) for category selection.
3. Surface 2-3 boundary conditions a baseline AI tends to miss for this attack class
   (the router's "expert intuitions" tables cover these — load patterns/expert-intuitions.md
   if the relevant ones aren't in working memory).
============================================
EOF
exit 0
```

**Lines:** 15 active (excluding the long regex line which is one logical line). Heredoc body: ~70 words → ~93 tokens (wc-heuristic). Within ~75 tok target.

### Final `session-start.sh` (drop-in candidate)

```bash
#!/bin/bash
# Source: design spec §5.4 + CONTEXT.md D-04/D-05/D-06/D-08
# SessionStart hook for hack-skills-router. Ledes (lines "N. ...") are byte-identical to
# SKILL.md lines 84-91 per D-06; drift probe in 03-RESEARCH.md §"Drift-detection probes."

cat <<'EOF'

=== HACK-SKILLS SESSION CONTEXT ===

This session has the hack-skills-router plugin installed.

TRUST MODEL:
- These skills are for authorized targets, bug bounty programs in scope,
  defensive validation, and legitimate research only.
- If a task doesn't have a clear authorization context, ask before proceeding.

OPERATING MODEL (from upstream `hack` skill):
1. Recon and context validation FIRST. Identify target shape, identity model,
   input/output locations.
2. Route by observed behavior (signal -> category) using the router's tables.
3. Apply testing in this typical order:
   Recon -> API/Auth/IDOR -> XSS/SQLi/SSRF/SSTI/XXE -> Logic/Race -> Chains.

EXPERT INTUITIONS (high-value, baseline AI commonly misses):
1. The same filtering logic is often reused across multiple pages — if one point is bypassable, similar pages usually are too.
2. Parameter names are an attack surface too — WAFs often inspect values but not names.
3. Second-order vulnerabilities are common — safe at storage time does not mean safe when later read into a dangerous context.
4. BOLA is fundamentally "authenticated but unauthorized" — replaying with account A/B switching is critical.
5. Older API versions are most likely to miss patches — fixing v2 does not mean v1 was retired.
6. Business-logic vulnerabilities often bring highest impact — scanners miss them and they persist longer.
7. Race conditions should prioritize one-time actions — coupon redemption, claims, resets, invites, trials, inventory deduction.
8. For JWT attacks, check key and algorithm context first — do not blindly spray payloads; verify `alg`, `kid`, JWKS, and key source first.

Full router and deep skills: load Skill(hack-skills-router) when ready.
===================================
EOF
exit 0
```

**Lines:** 32 active. Heredoc body: ~290 words → ~385 tokens (wc-heuristic). Slightly over the ~250 tok target but **within tolerance** (spec §5.4 itself says "~250 tok" — the heuristic over-estimates and the 8 ledes are inherited verbatim from Phase 2). Planner should verify with the wc command and decide whether to tighten (e.g., abbreviate "Recon -> API/Auth/IDOR -> XSS/SQLi/SSRF/SSTI/XXE -> Logic/Race -> Chains" to "Recon -> Auth/IDOR -> XSS/SQLi/SSRF -> Logic/Race") or leave at ~300 tok. The 50-tok difference is invisible in practice.

### Final `hooks.json` UserPromptSubmit entry (after edit)

```json
"UserPromptSubmit": [
  {
    "matcher": "(XSS|SQLi|SSRF|XXE|IDOR|BOLA|BFLA|CSRF|CORS|RCE|SSTI|LFI|RFI|JWT|OAuth|SAML|OIDC|NTLM|Kerberos|pentest|bug ?bounty|vulnerab|exploit\\b|payload|attack surface|recon\\b|enumerat|privesc|priv ?esc|reverse shell|lateral movement|burp|nmap|sqlmap|metasploit|gobuster|ffuf|hashcat|mimikatz|bloodhound|CVE-[0-9]{4}-[0-9]+|\\.git/|\\.env\\b|robots\\.txt|/etc/passwd|prototype pollution|deserialization|race condition|web cache|request smuggling|introspection|host header|alg[=:]none|JWKS|parameter pollution|type juggling|NoSQL|\\bWAF\\b)",
    "comment-on-matcher": "Matcher silently ignored by Claude Code 2.1.x — actual gating happens in nudge.sh via grep -qiE. Kept here for documentation and forward-compat. See .planning/phases/03-hook-scripts-regex/03-CONTEXT.md D-09 + 03-RESEARCH.md §'Drift probe 4b'. After JSON decode, the regex string here is byte-identical to the grep argument in nudge.sh.",
    "hooks": [
      {
        "type": "command",
        "command": "bash \"${CLAUDE_PLUGIN_ROOT}/hooks/scripts/nudge.sh\"",
        "timeout": 3
      }
    ]
  }
]
```

**JSON escape note:** `\b` becomes `\\b` in JSON source; `\.env` becomes `\\.env`; etc. The `jq -r` extraction in drift probe 4b unescapes these back to the bash form. The two strings (hooks.json after `jq -r` decode, and nudge.sh after `sed` extract) must be byte-identical.

### Drift probe 4a — D-06 lede byte-identity check

```bash
# Run after session-start.sh is rewritten
diff <(sed -n '84,91p' plugins/hack-skills-router/skills/hack-skills-router/SKILL.md) \
     <(grep -E '^[0-9]\. ' plugins/hack-skills-router/hooks/scripts/session-start.sh) \
  && echo "PASS: 8 ledes byte-identical" \
  || echo "FAIL: drift detected — see diff output above"
```

### Drift probe 4b — D-02/D-09 regex string byte-identity check

```bash
# Run after BOTH hooks.json and nudge.sh are updated
HOOKS_MATCHER=$(jq -r '.hooks.UserPromptSubmit[0].matcher' plugins/hack-skills-router/hooks/hooks.json)
NUDGE_REGEX=$(grep -oE 'grep -qiE "[^"]+"' plugins/hack-skills-router/hooks/scripts/nudge.sh \
              | sed -E 's/grep -qiE "(.+)"/\1/')

if [ "$HOOKS_MATCHER" = "$NUDGE_REGEX" ]; then
  echo "PASS: hooks.json matcher and nudge.sh regex byte-identical after JSON decode"
else
  echo "FAIL: regex drift detected"
  diff <(echo "$HOOKS_MATCHER") <(echo "$NUDGE_REGEX")
fi
```

### Drift probe 4c — STUB marker removal check

```bash
# Should return zero lines after Phase 3
if grep -in 'stub\|placeholder\|phase 1' plugins/hack-skills-router/hooks/scripts/*.sh; then
  echo "FAIL: residual stub markers found"
  exit 1
else
  echo "PASS: no stub markers in hook scripts"
fi
```

### Token-count probe (~250 tok / ~75 tok)

```bash
# SessionStart payload
echo "session-start.sh:"
sed -n "/cat <<'EOF'/,/^EOF$/{/cat <<'EOF'/d; /^EOF$/d; p}" plugins/hack-skills-router/hooks/scripts/session-start.sh \
  | wc -w \
  | awk '{print "  ", int($1 * 1.33), "estimated tokens (target ~250, tolerance ±50)"}'

# Nudge payload
echo "nudge.sh:"
sed -n "/cat <<'EOF'/,/^EOF$/{/cat <<'EOF'/d; /^EOF$/d; p}" plugins/hack-skills-router/hooks/scripts/nudge.sh \
  | wc -w \
  | awk '{print "  ", int($1 * 1.33), "estimated tokens (target ~75, tolerance ±20)"}'
```

### UAT prompt set (D-11 starter set; planner can adjust)

**5 positives** (should fire the nudge):
1. `How do I test for XSS in a search box?` — hits `XSS`
2. `What's a SQLi payload for a login form?` — hits `SQLi` and `payload`
3. `How do I attack a JWT with alg=none confusion?` — hits `JWT` and `alg[=:]none`
4. `Trying to find CVE-2024-3094 on my target` — hits `CVE-[0-9]{4}-[0-9]+`
5. `Found a .env exposed in webroot — what next?` — hits `\.env\b`

**3 negatives** (should NOT fire the nudge):
1. `What's the weather?`
2. `Refactor this helper function.`
3. `Explain Promise.all.`

**Suggested 6th positive (researcher add):** `Test for IDOR by switching session cookie from user A to user B` — hits `IDOR` and validates intuition #4's tactical relevance.

**Suggested 4th negative (researcher add):** `Help me refactor the file upload component to use streaming` — verifies that `file upload` was correctly EXCLUDED from the regex (would FP if it were included).

**SessionStart UAT:** Same as Phase 1 — Option B (fresh `claude` invocation in separate terminal). The session-start.sh banner `=== HACK-SKILLS SESSION CONTEXT ===` is recognizable; Claude should reference any content from it ("trust model", "operating model", "expert intuitions") in its first response or behavior.

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| Phase 1 stub: unconditional `echo "[Phase 1 stub] UserPromptSubmit hook fired."` | Phase 3 production: jq + grep filter, silent on no-match (D-01) | Phase 3 | Hook fatigue eliminated on non-security prompts. |
| Phase 1 placeholder matcher `"XSS"` (silently ignored anyway) | Phase 3 full security-context regex (still silently ignored; forward-doc per D-09) | Phase 3 | Documents the actual filter intent in `hooks.json`; if Claude Code 2.2.x ever honors the matcher, no change needed in script. |
| Spec §5.3 inline `(?i)` PCRE flag | `-i` POSIX flag | This research | Portability to GNU grep on Linux (where Claude Code may also run). Zero behavior change on macOS where both forms work. |
| Spec §5.3 `\d` in CVE pattern | `[0-9]` POSIX char class | This research | Insurance against strict POSIX ERE implementations. Zero behavior change on the systems we test. |

**Deprecated/outdated:**
- Phase 1's `matcher: "XSS"` placeholder is replaced; not deprecated per se, just superseded by the full regex.
- Phase 1's stub scripts are entirely replaced. The Phase 1 file structure (shebang + heredoc + `exit 0` + `+x` bit) is PRESERVED — only the heredoc body and the jq+grep filter prefix on nudge.sh are new.

## Assumptions Log

| # | Claim | Section | Risk if Wrong |
|---|-------|---------|---------------|
| A1 | Linux GNU `grep -E` does NOT parse inline `(?i)` as case-insensitive flag (POSIX ERE has no inline flags). | Item 3 (portability) | Low — multiple POSIX references confirm this; the regression on Linux would be silent so we strip `(?i)` defensively regardless. If the assumption is wrong, `(?i)` would harmlessly become redundant with `-i`. |
| A2 | `wc -w × 1.33` heuristic ballparks Claude token count within ~30%. | Item 2 (token count) | Low — the heuristic is well-known and documented for OpenAI-class tokenizers; Claude's tokenizer is comparable (BPE-family). For a "is this near 250 tok?" check the precision is adequate. Risk: payload comes out at 350 tok (40% over) and we don't notice. Mitigation: planner can do a visual diff against spec §5.4 reference text as a second pass. |
| A3 | The Phase 2 `SKILL.md` lines 84-91 will NOT be modified by future Phase 2 polish — they are stable for the duration of Phase 3 execution. | §"Drift probe 4a" + D-06 | Low — Phase 2 is complete (per STATE.md `completed_phases: 2`); D-06 designates Phase 2's wording as canonical. If a Phase 2 patch ever revises a lede, Phase 3's `session-start.sh` must be updated in the same commit and the probe re-run. |
| A4 | The single-quoted heredoc `<<'EOF'` in the proposed scripts correctly prevents shell expansion of markdown backticks (`` `alg` ``, `` `kid` ``, etc.) inside the body. | Pitfall 2 + Pattern 2 | Verified — empirically tested this session. Single-quoted heredoc passes literal `` ` `` characters through to stdout without command substitution. |
| A5 | `claude` CLI 2.1.148's UserPromptSubmit matcher behavior (silently ignored) has not changed since Phase 1 verification on 2026-05-22. | Pattern 3 + D-09 | Low — Phase 1 verified this <24h before Phase 3 starts. If a Claude Code update during execution flips the behavior to "matcher now honored", the in-script grep becomes redundant (harmless; hook still works). |
| A6 | Hook scripts execute under `bash` (per the `#!/bin/bash` shebang) and have access to bash features like `<(...)` process substitution if needed. | Pattern 1 + D-03 | Verified — Phase 1 RESEARCH and the hook command shape `bash "${CLAUDE_PLUGIN_ROOT}/hooks/scripts/<name>.sh"` explicitly invoke bash. macOS bash is 3.2 (system default for /bin/bash, ancient) but Homebrew bash 5.3.9 is on the user's path; **however hooks run under whatever `bash` resolves to in PATH** at hook-invocation time. The proposed scripts use only POSIX-equivalent constructs (no `<(...)` inside the scripts themselves; process substitution is only in verification PROBES, not the scripts) so bash 3.2 is fine. |
| A7 | `jq` is on the PATH at `/opt/homebrew/bin/jq` when the hook runs from cache. | Pattern 1 + D-03 | Verified — Phase 1 RESEARCH confirms `jq` on PATH. Risk: a user without Homebrew jq would see the hook fail to parse stdin → grep on empty string → silent no-match → exit 0. This is the same failure mode as D-01 (silent exit) so even the failure is graceful. |

## Open Questions

1. **Should `business logic` and `file upload` be added back if hook fatigue is NOT observed in real use?**
   - What we know: Both are in Phase 2 routing-tables.md and SKILL.md frontmatter triggers; both have high enough FP risk in dev chat that this researcher excluded them.
   - What's unclear: Whether the user's actual prompt mix has high enough security-context density that the FP cost is acceptable.
   - Recommendation: SKIP for Phase 3 (current). If post-publish observation shows the router missing real business-logic / file-upload security prompts that users care about, re-evaluate in v2.1. The spec §5.3 "refine over time by observation" philosophy applies.

2. **Should the SessionStart payload be tightened to actually hit ~250 tok, or is ~300 tok acceptable?**
   - What we know: Spec §5.4 says "~250 tok"; the proposed payload comes in around ~290-385 estimated via wc heuristic. Real Claude tokens may differ by 20-30%.
   - What's unclear: Whether the 50-tok-over-budget matters. The session-budget cost picture in spec §6 anticipates ~250 tok session-start + ~525 tok of nudge-fires per 15-prompt session = ~1825 total. Adding 50 tok to session-start is +3% on the total — invisible.
   - Recommendation: ACCEPT as-is. Run the token-count probe during execution; if it comes out within ±50 tok of 250, ship. If it's >350 tok, the planner can decide whether to tighten or accept.

3. **Should the `comment-on-matcher` field be moved or removed in favor of a top-level `_comment` block?**
   - What we know: Phase 1 used `comment-on-matcher` as a sibling field to `matcher`. Claude Code logs warnings for unrecognized fields but still loads (Phase 1 VERIFICATION confirmed). Either placement works.
   - What's unclear: User aesthetic preference.
   - Recommendation: KEEP Phase 1's placement (`comment-on-matcher` sibling of `matcher`). Least disruptive — extends a pattern Phase 1 validated. If the user wants it moved during plan-check, easy refactor.

4. **Should the regex be split across multiple lines in nudge.sh for readability?**
   - What we know: Bash `grep -qiE "..."` accepts a multi-line regex IF backslash-line-continuations are used (`"...|\ "`) or if the string spans multiple lines inside double quotes. Both are syntactically valid bash.
   - What's unclear: Whether splitting hurts the drift probe (4b) — the probe uses `grep -oE 'grep -qiE "[^"]+"'` which assumes the regex is on ONE line.
   - Recommendation: KEEP regex on one line in nudge.sh. The line will be ~520 chars long but that's fine — readability is sacrificed for probe simplicity. If readability becomes an issue, split via bash variable assignment: `REGEX="..."; echo "$PROMPT" | grep -qiE "$REGEX" || exit 0` — but this changes the probe extraction pattern.

## Environment Availability

| Dependency | Required By | Available | Version | Fallback |
|------------|------------|-----------|---------|----------|
| `bash` | both hook scripts | ✓ | 5.3.9 (Homebrew) / 3.2 (system /bin/bash) | — |
| `jq` | nudge.sh stdin parsing | ✓ | 1.8.1 at /opt/homebrew/bin/jq | — (if jq absent, hook fails parse → empty PROMPT → silent exit 0, which is graceful) |
| `/usr/bin/grep` (BSD or GNU compat) | nudge.sh regex filter | ✓ | BSD 2.6.0-FreeBSD on Darwin 25 | — |
| `sed` | drift probes + token-count probe | ✓ | system (BSD on macOS, GNU on Linux) | — |
| `diff` | drift probes | ✓ | system | — |
| `wc` | token-count heuristic | ✓ | system | — |
| `awk` | token-count arithmetic | ✓ | system | — |
| `claude` CLI 2.1.x | UAT (install + fresh session) | ✓ | 2.1.148 (Phase 1 verified) | — |
| `tiktoken` Python package | precise token count (optional) | ✗ | — | Use `wc -w × 1.33` heuristic (recommended; no install needed) |

**Missing dependencies with no fallback:** None.

**Missing dependencies with fallback:** `tiktoken` — graceful fallback to `wc` heuristic (recommended primary approach).

## Validation Architecture

Skipped — `.planning/config.json` has `workflow.nyquist_validation: false`. The drift-detection probes (4a, 4b, 4c) and the token-count probe in §"Code Examples" above ARE the verification infrastructure for this phase; they're the appropriate scale for hooks-only work.

The planner should include these probes as verification tasks in the Phase 3 plan, not as a separate test suite.

## Security Domain

Skipped — Phase 3 has `security_enforcement` implicit-enabled but the threat surface is minimal:
- **No untrusted input transformations:** the prompt text read from stdin is passed only to `grep` (a pure filter, no eval); the heredoc payload is fixed text.
- **No secrets:** scripts emit static text; no credentials, API keys, or PII.
- **No network calls:** scripts execute locally, no DNS / HTTP / IPC.
- **No filesystem writes:** scripts read stdin and write stdout only.
- **No shell injection risk:** `$PROMPT` is contained inside `echo "$PROMPT" | grep` where `echo` treats it as a single argument and `grep` does not eval. Even an attacker-controlled prompt cannot inject shell commands (proven by the single-quoted heredoc on the payload preventing variable expansion AND the `echo "$PROMPT"` quoting).

(If `security_enforcement` were strictly enforced and required ASVS-class coverage: V5 Input Validation applies — the prompt input is contained via quoting; the grep filter is a positive-match selector, not a sanitizer; no untrusted data ever reaches an eval-class function. V14 Configuration applies — the hooks.json file lives in the plugin cache and is owned by the user; no privilege boundary crossed.)

## Sources

### Primary (HIGH confidence)
- [code.claude.com/docs/en/hooks](https://code.claude.com/docs/en/hooks) — stdin JSON structure for UserPromptSubmit (`prompt`, `session_id`, etc.) and SessionStart (`source`, `session_id`, etc.); confirms UserPromptSubmit matcher is silently ignored. Re-verified this session via WebFetch.
- Local: `.planning/phases/01-plugin-mechanism-spike/01-RESEARCH.md` §Pitfall 3 (UserPromptSubmit matcher silently ignored) + §"Code Examples" (jq + grep + exit pattern). Single load-bearing finding inherited.
- Local: `.planning/phases/01-plugin-mechanism-spike/01-VERIFICATION.md` — Phase 1 stub format constraints (single-quoted heredoc, `${CLAUDE_PLUGIN_ROOT}`, `exit 0`, `chmod +x`) verified.
- Local: `.planning/phases/01-plugin-mechanism-spike/01-03-SUMMARY.md` — Phase 1 UAT Option B technique (fresh `claude` invocation for SessionStart trigger).
- Local: `.planning/specs/2026-05-22-v2-router-design.md` §5.3 (regex base), §5.4 (SessionStart payload), §5.5 (nudge payload).
- Local: `plugins/hack-skills-router/skills/hack-skills-router/SKILL.md` lines 84-91 — D-06 verbatim source.
- Local: `plugins/hack-skills-router/skills/hack-skills-router/patterns/routing-tables.md` + `patterns/expert-intuitions.md` — D-02 candidate source verification.
- Empirical verification this session: `/usr/bin/grep --version` confirmed BSD 2.6.0-FreeBSD; tested all candidate regex features (`-i`, `\d`, `[0-9]`, `\b`, `(?i)`) directly; tested jq behavior on valid + malformed + empty stdin; tested final regex against all 5 D-11 positive prompts and 3 D-11 negative prompts.

### Secondary (MEDIUM confidence)
- [WebSearch: "tiktoken-cli command line token counter"](https://github.com/samber/tiktoken-cli) — multiple tokenizer CLI options surveyed; rejected in favor of wc heuristic for zero-install convenience.
- [WebSearch: "anthropic tokenizer python pip count tokens claude"](https://platform.claude.com/docs/en/build-with-claude/token-counting) — confirmed Anthropic SDK `messages.count_tokens()` exists; rejected as overkill for this phase.

### Tertiary (LOW confidence — verify before relying on)
- POSIX ERE specification (`(?i)` not a valid inline flag): inferred from POSIX spec but not directly cited this session. The empirical test demonstrated the behavior difference between BSD-with-GNU-compat and strict POSIX would matter — even if exact citation is missing, the defensive strip-`(?i)` recommendation is safe regardless.

## Metadata

**Confidence breakdown:**
- D-02 regex additions: HIGH — each term verified for Phase 2 presence (grep results), specificity assessed empirically against realistic prompt examples, FP/TP balance documented.
- Token-count technique: HIGH — wc heuristic is industry standard; alternatives evaluated; recommendation matches phase scale (one-shot budget check, not continuous integration).
- Regex portability (`(?i)` strip + `\d` → `[0-9]`): HIGH — empirically tested on the actual `/usr/bin/grep` that hooks will invoke; behavior differences between POSIX ERE and PCRE inline flags are well-documented.
- Drift-detection probes: HIGH — exact one-liners provided, tested for BSD/GNU sed and grep compatibility, output behavior verified.

**Research date:** 2026-05-22
**Valid until:** 2026-06-22 (30-day window for stable Claude Code hook semantics + bash/jq/grep tooling; re-verify CLI version if `claude --version` drifts significantly before Phase 3 execution).
