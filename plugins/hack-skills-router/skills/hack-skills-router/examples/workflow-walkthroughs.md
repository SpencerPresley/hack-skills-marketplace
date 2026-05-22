# Workflow Walkthroughs

> Four worked traces showing the router applied to realistic security prompts. The signal-routing methodology is paraphrased from upstream `yaklang/hack-skills` `hack` SKILL.md (MIT-licensed); the scenarios, dual-load patterns, and recommendation flow are tailored to this marketplace's 13-plugin layout.

Each scenario walks from the user's prompt through testing-phase identification, signal-based routing, dual-load decisions, the boundary conditions a baseline AI typically misses, and a concrete next-test recommendation. Scenarios 1 and 4 demonstrate same-plugin dual-load (two skills, one install); scenarios 2 and 3 demonstrate single-plugin focus.

## Scenario 1: Admin panel at `/admin`, JWT in cookie

**Prompt:** "I found a `/admin` route returning 403 and noticed the session uses a JWT in a cookie. Where do I start?"

**Testing phase identified:** Validation — the surface is mapped (admin path + JWT auth context), and the next step is probing the access control and token verification chain.

**Signal route:** Admin path access denied → `401-403-bypass-techniques` (in `hack-skills-auth-bypass`). JWT in cookie → `jwt-oauth-token-attacks` (in `hack-skills-auth-bypass`). The router treats "admin + access denied + token context" as a paired signal, not two separate routes.

**Dual-load:** Same-plugin dual-load — both `401-403-bypass-techniques` and `jwt-oauth-token-attacks` live in `hack-skills-auth-bypass`, so one install command covers both. Load them together because the 403 may be bypassable at the request-shape layer (path, method, header) OR at the token-verification layer (algorithm, kid, JWKS); without both skills, half the surface goes unprobed.

**Boundary conditions surfaced:**
- *For JWT attacks, check key and algorithm context first (intuition #8):* Decode the cookie's JWT header, identify `alg`, look for a `kid` field, and find any JWKS endpoint BEFORE spraying alg=none / RS256→HS256 / kid-injection payloads. Choosing the right payload depends on the configuration.
- *Filter logic often reuses across pages (intuition #1):* If a path-manipulation trick (`/admin/`, `/admin/.`, `/admin/%2e`, method override) bypasses 403 here, the same trick likely works on other authenticated endpoints — sweep the surface after confirming one bypass.

**Next-test recommendation:** Decode the JWT header, enumerate the JWKS endpoint (`/.well-known/jwks.json`), then run path-manipulation + method-override probes against `/admin` in parallel. Capture both verification config and access-control behavior before picking payloads.

> **Recommended deep skill:** `401-403-bypass-techniques` + `jwt-oauth-token-attacks` (in `hack-skills-auth-bypass`, not currently installed)
> **Install:** `/plugin install hack-skills-auth-bypass@hack-skills-marketplace`

## Scenario 2: GraphQL endpoint with introspection enabled

**Prompt:** "I found a GraphQL endpoint at `/graphql` that allows introspection. What now?"

**Testing phase identified:** Recon — the introspection query is the discovery surface for schema, types, queries, and mutations. The next decisions depend on what the schema reveals.

**Signal route:** GraphQL + introspection → `graphql-and-hidden-parameters` (in `hack-skills-recon`). Single-plugin focus — both the recon framing (introspection enumeration) and the specialist playbook live in the same plugin.

**Dual-load:** None for this phase. If introspection reveals auth-related mutations or token-issuing fields, a follow-on dual-load pairing `recon-and-methodology` (also in `hack-skills-recon`) with an auth skill becomes appropriate — but that's a downstream routing decision once the schema is mapped.

**Boundary conditions surfaced:**
- *Parameter names as attack surface (intuition #2):* GraphQL introspection reveals exact field names. Many WAFs and authz layers inspect HTTP query string values, not GraphQL field names — fields like `adminUser`, `internal_*`, or `_debug*` slip past surface-level filters.
- *Older API versions miss patches (intuition #5):* If the schema exposes `v1`/`v2`/`internal`/`legacy` prefixes on types or queries, the older variants are highest-priority targets for unpatched mutations the current schema has since fixed.

**Next-test recommendation:** Run an introspection query, dump the full schema, then enumerate types and mutations flagging any name containing `admin`, `internal`, `debug`, or `_priv`. Then drop into `graphql-and-hidden-parameters` for the specific batching, hidden-parameter, and alias-abuse playbooks.

> **Recommended deep skill:** `graphql-and-hidden-parameters` (in `hack-skills-recon`, not currently installed)
> **Install:** `/plugin install hack-skills-recon@hack-skills-marketplace`

## Scenario 3: `.env` exposed in webroot

**Prompt:** "Burp Suite flagged an accessible `/.env` file on the target's webroot. What's in scope?"

**Testing phase identified:** Recon — an SCM/config-leak finding is itself a discovery surface; the real work is parsing what the file exposes and expanding into the systems those secrets reach.

**Signal route:** Accessible `.env` / `.git` / config-file leak → `insecure-source-code-management` (in `hack-skills-recon`). Single-plugin focus — the SCM-leak skill covers both detection patterns (`.env`, `.git/HEAD`, `.svn/entries`, backup files) and the post-leak enumeration playbook.

**Dual-load:** None for this phase. The follow-on routing depends entirely on what the `.env` contains — DB credentials route to data-tier testing, cloud keys route to recon into the cloud surface, internal service URLs route to recon expansion. The router waits for that signal rather than guessing.

**Boundary conditions surfaced:**
- *Second-order vulnerabilities are common (intuition #3):* A leaked `.env` is rarely the bug itself — it's a vector into other systems. AWS keys become a cloud-recon chain; database creds become a data-tier chain; OAuth client secrets become a token-forgery chain. Each surfaced credential needs its own threat-modeling pass.

**Next-test recommendation:** Mirror the `.env` contents, classify each secret by destination system, then expand recon surface accordingly — try AWS IMDS / `aws sts get-caller-identity` for cloud keys, attempt DB connection from an authorized testing host for credentials, and check whether any internal service URLs are reachable from your scope.

> **Recommended deep skill:** `insecure-source-code-management` (in `hack-skills-recon`, not currently installed)
> **Install:** `/plugin install hack-skills-recon@hack-skills-marketplace`

## Scenario 4: E-commerce checkout, coupon-reuse

**Prompt:** "Checkout flow has a one-time `FREESHIP` coupon. I want to know if I can reuse it."

**Testing phase identified:** Validation moving into Chain — the surface (coupon, multi-step checkout) is mapped, and the next step is probing whether the application's one-time guarantee actually holds under concurrent or replay conditions.

**Signal route:** Coupon + one-time op + multi-step workflow → `business-logic-vulnerabilities` (in `hack-skills-web-client-attacks`). Concurrent-request abuse + TOCTOU on validation → `race-condition` (in `hack-skills-web-client-attacks`). Both routes hit the same plugin because the canonical coupon-reuse exploit is a business-logic flaw whose primitive IS a race condition.

**Dual-load:** Same-plugin dual-load — both `business-logic-vulnerabilities` and `race-condition` live in `hack-skills-web-client-attacks`, so one install covers both. Neither skill alone captures the combo: business-logic frames the workflow-level expectation; race-condition supplies the exploit primitive that breaks that expectation.

**Boundary conditions surfaced:**
- *Business-logic vulnerabilities often bring highest impact (intuition #6):* Scanners can't infer "the application intends this coupon to apply once." Coupon-reuse, refund underflow, inventory deduction, and state-machine skips survive automated scanning and code review because the flaw isn't in any single line — it's in the workflow design.
- *Race conditions should prioritize one-time actions (intuition #7):* Coupon redemption is the canonical one-time op. Fire N concurrent requests via Turbo Intruder's single-packet attack — if validation checks usage state before incrementing, all N may succeed.

**Next-test recommendation:** Reproduce a normal coupon redemption first to map the request shape, then fire 20–100 concurrent `POST /coupon/apply` requests via Turbo Intruder on HTTP/2 (single-packet attack). If multiple succeed, escalate to inventory/refund flows that share the same validation pattern.

> **Recommended deep skill:** `business-logic-vulnerabilities` + `race-condition` (in `hack-skills-web-client-attacks`, not currently installed)
> **Install:** `/plugin install hack-skills-web-client-attacks@hack-skills-marketplace`
