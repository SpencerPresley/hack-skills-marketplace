# Expert Intuitions — Boundary Conditions

> These 8 boundary-condition intuitions are paraphrased from `yaklang/hack-skills`'s `hack` SKILL.md (MIT-licensed). Each entry preserves the upstream's framing and rank order; the explanatory paragraphs and concrete examples are written for this router. See `.planning/specs/2026-05-22-v2-router-design.md` §11 for the full attribution chain.

### Intuition 1: Filter logic reuses across pages

**Lede:** The same filtering logic is often reused across multiple pages — if one point is bypassable, similar pages usually are too.

**Mechanism:** A WAF rule, sanitizer function, or input filter applied at one endpoint is typically the same one applied to many other endpoints — devs deploy filters via shared middleware or shared library calls. So a single bypass discovery is rarely a single bug; it's often the pattern key that opens dozens.

**Example:** A reflected XSS bypass via `<svg/onload=…>` on the search page typically also works on the contact form, login error page, and any other endpoint that uses the same sanitizer. After confirming one, audit the codebase / file paths for other call sites of the same filter.

### Intuition 2: Parameter names as attack surface

**Lede:** Parameter names are an attack surface too — WAFs often inspect values but not names.

**Mechanism:** Most WAFs and security middleware focus on parameter values (the part the user typically controls). The parameter names themselves — query string keys, JSON object keys, form field names — are often unchecked. Renaming or duplicating a parameter, or using a name that the framework parses but the WAF ignores, can bypass filtering.

**Example:** Sending `?admin=true` is blocked, but `?Admin=true`, `?adm[in]=true`, or `?admin[]=true` may slip through because the WAF normalizes values but not key syntax. Same pattern with HTTP Parameter Pollution (`?role=user&role=admin`).

### Intuition 3: Second-order vulnerabilities

**Lede:** Second-order vulnerabilities are common — safe at storage time does not mean safe when later read into a dangerous context.

**Mechanism:** Input is sanitized for one context (e.g., HTML output) at the time it's stored, but later consumed in a different context (e.g., a JavaScript template, an OS command, a SQL query) where the original sanitization is meaningless. The vuln class is fundamentally "right escape, wrong context."

**Example:** A username sanitized for HTML safety at registration ends up rendered into a JS string in an email template; `");alert(1);//` survives HTML escape but breaks out of the JS context. Same pattern with stored payloads that later get consumed by report exports, log viewers, or admin dashboards.

### Intuition 4: BOLA — authenticated but unauthorized

**Lede:** BOLA is fundamentally "authenticated but unauthorized" — replaying with account A/B switching is critical.

**Mechanism:** Broken Object Level Authorization vulns aren't about defeating the auth layer — the user IS authenticated, just not authorized to access a specific object. The test methodology is: log in as user A, fetch an object, then replay the same request with user B's session — if B can read A's data, that's BOLA. The cookie/token switching IS the technique.

**Example:** `GET /api/v1/user/123/profile` returns user 123's profile. As user A (id=456), swap your session for user B's (id=789) and re-issue the same URL. If you see 123's profile, that's BOLA: the endpoint validates auth (you have a session) but not authorization (does session-owner 789 actually own object 123?).

### Intuition 5: Older API versions miss patches

**Lede:** Older API versions are most likely to miss patches — fixing v2 does not mean v1 was retired.

**Mechanism:** When a security fix lands in the current API version, older versions often remain available for backwards compatibility. The fix tracking, the test suite, and the audit trail focus on the current version — `/api/v1/` quietly retains the bug that `/api/v2/` patched.

**Example:** `/api/v2/users/{id}` requires the requesting user own the resource; `/api/v1/users/{id}` doesn't (and is still up because mobile clients haven't updated). Test by enumerating version prefixes (`/v1/`, `/v2/`, `/internal/`, `/legacy/`) and replaying every interesting endpoint against each.

### Intuition 6: Business-logic flaws bring highest impact

**Lede:** Business-logic vulnerabilities often bring highest impact — scanners miss them and they persist longer.

**Mechanism:** Business-logic flaws (race conditions on coupon redemption, integer underflow on refunds, state-machine skips on multi-step checkout) require understanding the application's intended workflow — scanners can't infer "what was supposed to happen." So these flaws survive automated scanning AND code review (because the flaw isn't in any single line of code — it's in the workflow design).

**Example:** A coupon system that decrements the global usage counter after applying the discount — a race where two parallel requests both pass the "remaining uses > 0" check and both decrement, yielding 2 redemptions for 1 coupon. Scanners see a perfectly safe endpoint; manual logic review catches the workflow gap.

### Intuition 7: Race conditions on one-time operations

**Lede:** Race conditions should prioritize one-time actions — coupon redemption, claims, resets, invites, trials, inventory deduction.

**Mechanism:** Race-condition impact correlates with how "one-time" the targeted operation is. A race on a generic GET request has minimal impact; a race on "use this coupon once" can yield infinite discounts. Test targets: operations that the business EXPLICITLY intended to be atomic single-use.

**Example:** Promo code `FREEMONEY` (one-use-per-account). Fire 100 concurrent POST `/coupon/apply` requests via Turbo Intruder's single-packet attack on HTTP/2. If the validation checks usage state before incrementing, all 100 may succeed — 100x the intended grant.

### Intuition 8: JWT — verify key and algorithm context first

**Lede:** For JWT attacks, check key and algorithm context first — do not blindly spray payloads; verify `alg`, `kid`, JWKS, and key source first.

**Mechanism:** JWT attack payloads (alg=none, RS256→HS256 confusion, kid path traversal, JWKS spoofing) only work in specific configurations. Spraying every payload at every JWT wastes time and tips off WAFs. The correct workflow: decode the header (`alg`, `kid`, `jku`), find the JWKS endpoint (`/.well-known/jwks.json`), identify the verification library and version, then pick the payload that targets that exact configuration.

**Example:** A JWT with `alg: HS256` (symmetric) but the discovery surface advertises a JWKS endpoint (asymmetric) suggests RS256→HS256 confusion — sign the token with the public key as HMAC secret. Different from `alg: none` (server skips signature check) — those are different bugs requiring different payloads.
