---
phase: 02-router-skill-content
reviewed: 2026-05-22T18:01:32Z
depth: standard
files_reviewed: 4
files_reviewed_list:
  - plugins/hack-skills-router/skills/hack-skills-router/SKILL.md
  - plugins/hack-skills-router/skills/hack-skills-router/examples/workflow-walkthroughs.md
  - plugins/hack-skills-router/skills/hack-skills-router/patterns/expert-intuitions.md
  - plugins/hack-skills-router/skills/hack-skills-router/patterns/routing-tables.md
findings:
  critical: 1
  warning: 5
  info: 5
  total: 11
status: issues_found
---

# Phase 02: Code Review Report

**Reviewed:** 2026-05-22T18:01:32Z
**Depth:** standard
**Files Reviewed:** 4
**Status:** issues_found

## Summary

The four router-skill content files are largely consistent: the 13 plugin section headers in `patterns/routing-tables.md` match the 13 topical plugins in `.claude-plugin/marketplace.json` byte-exact; the 8 boundary-condition ledes in `SKILL.md` match `patterns/expert-intuitions.md` verbatim; the 4 walkthrough scenarios in `examples/workflow-walkthroughs.md` route to canonical deep-skill names; and every `/plugin install …@hack-skills-marketplace` command resolves to a real marketplace entry. Attribution to upstream `yaklang/hack-skills` (MIT-licensed) is present in all four files per D-15.

That said, an adversarial sweep surfaced one critical correctness gap and several quality defects that should land before publish:

- **BLOCKER:** the frontmatter trigger list advertises ~15 vulnerability classes (LFI, RFI, CORS, RCE, prototype pollution, deserialization, type juggling, NoSQL, WAF bypass, file upload, parameter pollution, SAML assertion, OAuth misconfiguration, BFLA, request smuggling) that the model will be auto-invoked on — but `patterns/routing-tables.md` has **zero rows** routing those triggers anywhere. When the model invokes the router on `LFI` or `prototype pollution`, the static table cannot route and the fallback "model reasoning over deep-skill descriptions" has no actual deep-skill description to reason over. Either the triggers must be pruned to match the table coverage, or routing rows for the canonical skills (`path-traversal-lfi`, `prototype-pollution`, `prototype-pollution-advanced`, `cors-cross-origin-misconfiguration`, `nosql-injection`, `deserialization-insecure`, `type-juggling`, `upload-insecure-files`, `waf-bypass-techniques`, `oauth-oidc-misconfiguration`, `saml-sso-assertion-attacks`, `http-parameter-pollution`, `request-smuggling` row exists, `web-cache-deception` row exists, …) must be added.
- **WARNING:** the body claims the operating model "compresses upstream's 4-step operating model into 3 considerations", but upstream `hack` SKILL.md has 3 steps, not 4. The compression claim is factually wrong.
- **WARNING:** the dual-load rules in `patterns/routing-tables.md` reference four real skills (`api-auth-and-jwt-abuse`, `api-recon-and-docs`, `api-authorization-and-bola`, `authbypass-authentication-flaws`) that have **no row anywhere** in the per-plugin routing tables — so the table never introduces these skills, but the dual-load section presupposes they are familiar.
- Several smaller items below (heading-level inconsistency in `routing-tables.md`, JWKS endpoint over-claim, "bilateral JWT context" jargon, prose-only triple "over").

No security or prompt-injection risks were identified — the trust-model paragraph is in place, walkthroughs operate within "authorized targets" framing, and no executable content (shell/JS) was included that could mislead users into unsafe ops on unauthorized targets.

## Critical Issues

### CR-01: Frontmatter triggers advertise routes that the routing table cannot fulfill

**File:** `plugins/hack-skills-router/skills/hack-skills-router/SKILL.md:5-11` (frontmatter `description:` trigger list) and `plugins/hack-skills-router/skills/hack-skills-router/patterns/routing-tables.md` (entire per-plugin table set)

**Issue:** The SKILL.md frontmatter description (lines 5-11) auto-invokes the router on a long trigger list, including: `BFLA`, `CORS`, `RCE`, `LFI`, `RFI`, `prototype pollution`, `deserialization`, `request smuggling` (present in table), `web cache deception` (present in table), `host header` (present in table), `parameter pollution`, `type juggling`, `NoSQL injection`, `WAF bypass`, `file upload`, `business logic` (present in table), `SAML assertion`, `OAuth misconfiguration`. 

Cross-referencing against the 13-section table in `patterns/routing-tables.md`, the following canonical skills exist in `.claude-plugin/marketplace.json` but have **no row** in routing-tables.md, despite their trigger terms being advertised in the frontmatter:

| Frontmatter trigger | Canonical skill (exists in marketplace.json) | In routing table? |
|---|---|---|
| `LFI` / `RFI` | `path-traversal-lfi` (in `hack-skills-server-side-execution`) | No |
| `prototype pollution` | `prototype-pollution`, `prototype-pollution-advanced` (in `hack-skills-web-client-attacks`) | No |
| `CORS` | `cors-cross-origin-misconfiguration` (in `hack-skills-web-client-attacks`) | No |
| `deserialization` | `deserialization-insecure` (in `hack-skills-server-side-execution`) | No |
| `type juggling` | `type-juggling` (in `hack-skills-auth-bypass`) | No |
| `NoSQL injection` | `nosql-injection` (in `hack-skills-web-injection`) | No |
| `WAF bypass` | `waf-bypass-techniques` (in `hack-skills-web-injection`) | No |
| `file upload` | `upload-insecure-files` (in `hack-skills-server-side-execution`) | No |
| `parameter pollution` | `http-parameter-pollution` (in `hack-skills-web-protocol-attacks`) | No |
| `SAML assertion` | `saml-sso-assertion-attacks` (in `hack-skills-auth-bypass`) | No |
| `OAuth misconfiguration` | `oauth-oidc-misconfiguration` (in `hack-skills-auth-bypass`) | No |
| `BFLA` | (no dedicated skill; closest is `api-authorization-and-bola`) | No |
| `RCE` (as primary class) | (covered by `cmdi-command-injection`, etc., but RCE-the-keyword isn't a table signal) | Partial |

Operational consequence: when the model is auto-invoked on a prompt containing, say, "I think this is a prototype pollution bug", the router body says "Prefer the table in `patterns/routing-tables.md`; fall back to reasoning when signals are ambiguous." But the table has no prototype-pollution row, so the model falls back to reasoning — except the router doesn't include deep-skill descriptions to reason over. The model is left to guess which plugin holds the skill, which contradicts the router's stated value ("doubles as the discovery surface for v1's 13 topical plugins" — SKILL.md:26). For a user who types `/plugin install` to discover skills, this means at least 12 advertised trigger classes have no install path the router surfaces.

This is a contract gap between the auto-invoke surface (frontmatter triggers) and the routing surface (table rows). It is also why dual-load Rule 2 in `routing-tables.md:140-141` references `api-recon-and-docs`, `api-auth-and-jwt-abuse`, and `api-authorization-and-bola` even though none of those have rows — the dual-load section quietly relies on the table being more comprehensive than it is.

**Fix:** Pick one of two paths.

*Option A — expand the table (preferred per D-03 "~30 rows organized as 13 plugin-keyed sections, 2–3 rows per section" — currently 33 rows, so room exists to add):* add rows for the canonical missing skills enumerated above. At minimum add the four skills the dual-load section already names (`api-recon-and-docs`, `api-auth-and-jwt-abuse`, `api-authorization-and-bola`, `authbypass-authentication-flaws`) plus rows for `path-traversal-lfi`, `deserialization-insecure`, `upload-insecure-files`, `cors-cross-origin-misconfiguration`, `prototype-pollution`, `type-juggling`, `nosql-injection`, `waf-bypass-techniques`, `http-parameter-pollution`, `oauth-oidc-misconfiguration`, `saml-sso-assertion-attacks`. This raises the table to ~45 rows — still inside D-03's "2–3 per section" guidance for most sections.

*Option B — prune the frontmatter triggers* to match what the table actually routes. Remove `LFI`, `RFI`, `CORS`, `prototype pollution`, `deserialization`, `parameter pollution`, `type juggling`, `NoSQL injection`, `WAF bypass`, `file upload`, `SAML assertion`, `OAuth misconfiguration`, `BFLA` from the trigger list. The router still auto-invokes on the remaining triggers (XSS, SQLi, SSRF, XXE, IDOR, BOLA, CSRF, RCE — though RCE has weak coverage — SSTI, JWT, OAuth, SAML, OIDC, NTLM, Kerberos, etc.) and is honest about its coverage gap. This is the lower-effort fix.

Option A is preferred because the frontmatter triggers map to a deliberate decision (design spec §5.6 verbatim per D-11), so the gap is "table under-coverage" not "frontmatter over-claim."

## Warnings

### WR-01: "Compresses upstream's 4-step operating model" is factually wrong — upstream has 3 steps

**File:** `plugins/hack-skills-router/skills/hack-skills-router/SKILL.md:52`

**Issue:** The body opens "Operating model (3 steps)" with the sentence: "The router compresses upstream's 4-step operating model into 3 considerations." Cross-checking upstream `hack` SKILL.md (cached at `/Users/spencerpresley/.claude/plugins/cache/hack-skills-marketplace/hack-skills-recon/c6f732befcae-32c1cf49/hack/SKILL.md`), upstream's Operating Model has exactly **3 steps**, not 4:

- Step 1: Start with Recon and context validation
- Step 2: Route by observed behavior
- Step 3: Use the most likely-hit testing order

So the router isn't compressing 4→3; it's restructuring 3→3 (renaming Step 1 to "Phase ID", Step 2 to "Signal route", and replacing Step 3 with "Dual-load if needed"). The "4-step" claim appears to be inherited from `02-CONTEXT.md` <specifics> line 192 ("paraphrase + compression of upstream's 4-step") which is itself wrong about the upstream.

**Fix:** Rewrite line 52 to something like: "The router restructures upstream's 3-step operating model into 3 considerations — replacing upstream's 'most likely-hit testing order' with a dual-load decision, because the marketplace's plugin-availability surface needs an explicit "should I recommend a second install?" branch that upstream's flat skill list does not." This preserves the meaning while being accurate.

### WR-02: Dual-load rules reference 4 canonical skills with no corresponding routing-table row

**File:** `plugins/hack-skills-router/skills/hack-skills-router/patterns/routing-tables.md:135, 140-141, 150` (also referenced by `SKILL.md:58`)

**Issue:** The dual-load rules section references these canonical deep skills:

- Rule 1 (line 135): `api-auth-and-jwt-abuse` (in `hack-skills-auth-bypass`)
- Rule 2 (lines 140-141): `api-recon-and-docs`, `api-auth-and-jwt-abuse`, `api-authorization-and-bola`
- Rule 4 (line 150): `authbypass-authentication-flaws`

All four skills exist in `.claude-plugin/marketplace.json`, but **none** appear in any per-plugin section's table (verified via grep across lines 5-129). The reader who reaches the dual-load section is asked to load skills they have never seen mentioned, while the table they were told is "primary" never introduces them.

This is closely coupled to CR-01 but is a quality issue even if CR-01's frontmatter is pruned: the dual-load section presupposes a richer table than what is delivered.

**Fix:** Add rows in `routing-tables.md`'s `hack-skills-auth-bypass` and `hack-skills-recon` sections for these four skills before the Dual-load rules section. Suggested rows:

```markdown
### hack-skills-auth-bypass
| ... existing rows ... |
| REST API auth, API session, API token flow, mobile API auth, bearer token in API | api-auth-and-jwt-abuse |
| login flow, password reset, MFA bypass, session boundary, account takeover | authbypass-authentication-flaws |
| REST API authorization, BFLA, function-level auth, role-based API access | api-authorization-and-bola |

### hack-skills-recon
| ... existing rows ... |
| REST API, OpenAPI, Swagger, Postman collection, API docs leak, undocumented endpoint | api-recon-and-docs |
```

### WR-03: Heading-level inconsistency in `routing-tables.md` — per-plugin sections use `###` without `##` parent

**File:** `plugins/hack-skills-router/skills/hack-skills-router/patterns/routing-tables.md:5, 15, 25, 35, 44, 53, 63, 72, 81, 91, 101, 111, 121`

**Issue:** The file's outline is:

```
# Routing Tables                               (h1)
### hack-skills-active-directory-and-windows   (h3 — but no h2 parent yet)
### hack-skills-ai-and-supply-chain            (h3)
...                                            (11 more h3 plugin sections)
## Dual-load rules                             (h2 — appears after 13 h3s)
### Rule 1: Recon + auth context               (h3)
...
## Plugin-recommendation template              (h2)
```

The 13 per-plugin sections are h3 with no h2 parent. Then "Dual-load rules" jumps back to h2. The TOC outline becomes nonsensical (the h3s appear to be children of the h1 title, then h2 siblings appear after).

**Fix:** Either:
- Promote all 13 plugin sections from `###` to `##` (matches their structural role as top-level table groups, parallels the "## Dual-load rules" and "## Plugin-recommendation template" sections).
- Or add a `## Per-plugin signal tables` h2 immediately after the file's intro paragraph so the h3 plugin sections have a proper parent.

The first option is cleaner — promote to `##` for all 13 plugin headers.

### WR-04: JWKS endpoint over-claim — `/.well-known/jwks.json` is not the canonical universal path

**File:** `plugins/hack-skills-router/skills/hack-skills-router/examples/workflow-walkthroughs.md:21` and `plugins/hack-skills-router/skills/hack-skills-router/patterns/expert-intuitions.md:65`

**Issue:** Both files instruct enumerating "`/.well-known/jwks.json`" as the JWKS endpoint. In practice the JWKS URI is *discovered* from `jwks_uri` in the OAuth/OIDC discovery doc (`/.well-known/openid-configuration`), or advertised in the JWT header's `jku` claim. `/.well-known/jwks.json` is one common convention among many — Auth0, Microsoft Entra, Google, Okta, and Cognito all use **different** paths (e.g., Auth0: `/.well-known/jwks.json`, Microsoft: `/discovery/v2.0/keys`, Google: `/oauth2/v3/certs`).

Telling Claude that this single path IS the JWKS endpoint risks the model giving the user a confidently-wrong path during a real audit. The intuition #8 is otherwise excellent; the over-claim is in the operational example only.

**Fix:** Replace "`/.well-known/jwks.json`" with "the JWKS endpoint (typically discovered from `/.well-known/openid-configuration`'s `jwks_uri` field, or advertised in the JWT header's `jku` claim — `/.well-known/jwks.json` is one common path but providers vary)." A shorter form: "the JWKS endpoint (discovered via `/.well-known/openid-configuration` → `jwks_uri`, or via the `jku` header)."

### WR-05: SKILL.md description length is ~845 bytes (~210 tokens) — exceeds the spec's "~150 tok" target

**File:** `plugins/hack-skills-router/skills/hack-skills-router/SKILL.md:2-11`

**Issue:** Plan decision D-11 said: "use design spec §5.6 verbatim as the starting point ... Plan should verify the description length against any Claude Code frontmatter cap (research item: spec said ~150 tok, but check live constraint)." The implemented description body is **845 bytes** (counted via `awk 'BEGIN{p=0}/^description:/{p=1;next}/^---$/{if(p)exit}{if(p)print}'`), which is roughly 210 tokens at ~4 bytes/token — meaningfully over the ~150 tok target.

There is no documented evidence (in the planning artifacts read) that anyone confirmed Claude Code's actual frontmatter cap. If Claude Code silently truncates descriptions past N tokens, the back-half triggers (`prototype pollution`, `deserialization`, `race condition`, `request smuggling`, `web cache deception`, `host header`, `parameter pollution`, `type juggling`, `NoSQL injection`, `WAF bypass`, `file upload`, `business logic`, `SAML assertion`, `OAuth misconfiguration`) may be dropped before the model sees them — defeating the auto-invoke design.

**Fix:** One of:
- Verify Claude Code's frontmatter description cap empirically before publish (probe via SDK or via the marketplace upload tooling).
- Trim the description to ≤150 tok by dropping the less-distinctive triggers (`vulnerability`, `exploit`, `pentest`, `bug bounty`, `payload` are generic enough that the model would auto-invoke on them via the more specific terms anyway).
- If the empirical cap is >256 tok, document that in the phase summary so future maintainers know the live constraint.

This pairs with CR-01: if the frontmatter is pruned (CR-01 Option B), this warning resolves automatically.

## Info

### IN-01: Awkward triple "over" in routing strategy paragraph

**File:** `plugins/hack-skills-router/skills/hack-skills-router/SKILL.md:44`

**Issue:** Line 44 reads: "prefer reasoning over deep-skill descriptions over force-fitting a near-miss table row." Two "over"s in succession with different meanings (first = "based on", second = "rather than") makes the sentence parse twice before landing on intent.

**Fix:** "prefer reasoning against deep-skill descriptions rather than force-fitting a near-miss table row."

### IN-02: "Bilateral JWT context" is non-standard jargon

**File:** `plugins/hack-skills-router/skills/hack-skills-router/SKILL.md:56`

**Issue:** "bilateral JWT context biases toward verifying configuration before payload spray per intuition #8." "Bilateral" is not a standard JWT term (the standard term is the algorithm class — symmetric vs asymmetric — or simply "JWT auth flow"). A reader unfamiliar with the author's intended meaning has to guess.

**Fix:** Replace with concrete language: "the presence of any JWT in the prompt biases toward verifying `alg`/`kid`/JWKS before payload selection per intuition #8."

### IN-03: Scenario 3 conflates AWS IMDS and `aws sts get-caller-identity`

**File:** `plugins/hack-skills-router/skills/hack-skills-router/examples/workflow-walkthroughs.md:58`

**Issue:** The next-test recommendation says "try AWS IMDS / `aws sts get-caller-identity` for cloud keys." These are two distinct techniques: AWS IMDS (`169.254.169.254/latest/meta-data/iam/...`) is for retrieving creds from inside an EC2 instance; `aws sts get-caller-identity` is for confirming whose creds an `aws` CLI session is using (the leaked `.env` provides the creds, then `sts get-caller-identity` is the canary). They are NOT alternatives — one is a credential source, the other is a credential validator.

**Fix:** "Configure the leaked AWS key/secret into your authorized testing host (`AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`), then run `aws sts get-caller-identity` to confirm the account/principal the keys belong to. (AWS IMDS is a separate vector — `169.254.169.254/latest/meta-data/iam/security-credentials/`, only reachable from inside an EC2 instance; relevant only if the `.env` instead leaks an SSRF vector.)"

### IN-04: "Three considerations interleave" / "guidance, not an algorithm" closing line is mildly redundant

**File:** `plugins/hack-skills-router/skills/hack-skills-router/SKILL.md:60`

**Issue:** Line 60 says: "This is guidance, not an algorithm. The three considerations interleave — phase ID often informs signal routing, and signal routing often informs the dual-load decision." The opening of the same section already says (line 52): "the three steps name the considerations, not a forced sequence." The two sentences make the same point. Per D-14 ("soft heuristic, not strict algorithm") one mention is sufficient.

**Fix:** Either remove line 60 entirely (the line-52 framing suffices), or remove "the three steps name the considerations, not a forced sequence" from line 52 and keep line 60 as the closing softener.

### IN-05: Body uses inconsistent backtick conventions for skill names

**File:** Multiple files

**Issue:** Skill names are sometimes backticked, sometimes not:

- `SKILL.md:73, 76` backticks `business-logic-vulnerabilities`, `race-condition`, etc. in prose.
- `SKILL.md:70` does **not** backtick `ssrf-server-side-request-forgery` in the recommendation block (it's plain text inside a blockquote).
- `routing-tables.md:167, 172, 175` recommendation template — skill names **not** backticked.
- `workflow-walkthroughs.md:23, 42, 60, 79` recommendation blocks — skill names **are** backticked.

This is cosmetic but inconsistent. The recommendation-block convention should be one or the other across all files.

**Fix:** Pick one convention (recommendation: backtick all skill names in recommendation blocks, matching the workflow-walkthroughs.md style which is more recent and more legible) and apply uniformly to `SKILL.md:70, 73` and `routing-tables.md:167, 172, 175`.

---

_Reviewed: 2026-05-22T18:01:32Z_
_Reviewer: Claude (gsd-code-reviewer)_
_Depth: standard_
