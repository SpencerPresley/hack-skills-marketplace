---
description: |
  CRITICAL: Use FIRST for security/hacking tasks before any deep topic skill. Routes vulnerability questions to the right deep skill in the hack-skills marketplace and surfaces boundary conditions a baseline AI often misses.

  Triggers: XSS, SQLi, SSRF, XXE, IDOR, BOLA, BFLA, CSRF, CORS, RCE, SSTI, LFI, RFI, JWT,
  OAuth, SAML, OIDC, NTLM, Kerberos, vulnerability, exploit, pentest, bug bounty, payload,
  recon, enumeration, privilege escalation, lateral movement, reverse shell, burp, nmap,
  sqlmap, metasploit, CVE identifier, .env exposure, .git exposure, prototype pollution,
  deserialization, race condition, request smuggling, web cache deception, host header,
  parameter pollution, type juggling, NoSQL injection, WAF bypass, file upload,
  business logic, SAML assertion, OAuth misconfiguration. Adapted from yaklang/hack-skills.
---

# Hack-Skills Router

Adapted from upstream `yaklang/hack-skills` `hack` SKILL.md (MIT-licensed).

## When to use this skill

Use the router first on security and hacking tasks — before any deep topic skill. The 5 canonical triggers:

- New target, unclear where to start — pick a category before guessing payloads.
- Multiple signals could route to multiple categories (cross-topic prompts where dual-loading two deep skills is stronger than picking one).
- Need methodology rigor, not payload guessing — surface the testing-phase and the right deep skill before any payload work.
- Want the boundary conditions baseline AI misses (the 8 high-value intuitions section below).
- Want install commands for plugins you don't yet have — the router doubles as the discovery surface for v1's 13 topical plugins.

If none of the above apply (the prompt is clearly already on a specific deep skill's surface), the router can step aside and the deep skill takes over.

## Trust model

This router is for use only within authorized targets, legitimate research, defensive validation, and bug-bounty-approved scope.

If the task lacks clear authorization context, you should ask before proceeding or refuse — never assume scope. The hack-skills marketplace is research and methodology scaffolding, not an unauthorized-attack toolkit.

Surface the trust question early in the conversation when the prompt is ambiguous about whether the target is in scope; this is the one place soft "should" guidance is preferred over silent assumption.

## Routing strategy (hybrid)

Two-tier. The static signal table in [patterns/routing-tables.md](patterns/routing-tables.md) is primary.

Common signals — "XSS in a search box", "SQLi in a login form", "SSRF on a URL-fetcher endpoint", "JWT in a cookie" — typically match a row and route directly to the relevant deep skill. The sub-file's 13 plugin-keyed sections cover the v1 topical plugins; each section starts with its own install command so the table doubles as a plugin-discovery surface when the destination plugin is not yet installed.

Model reasoning is the fallback for ambiguous queries. When the prompt mentions signals that span topics — "checkout flow with weird timing" could be race condition, could be business logic, could be both — prefer reasoning over deep-skill descriptions over force-fitting a near-miss table row.

Consider dual-loading when two routes are both plausible; the `## Dual-load rules` section of [patterns/routing-tables.md](patterns/routing-tables.md) lists the canonical pairs and the trigger conditions for each.

Prefer the table when a signal cleanly matches; consider reasoning when it doesn't. Typically a single-route prompt picks one deep skill, while a cross-topic prompt picks two. Don't force-fit signals into the nearest table row if the route feels wrong — that's the reasoning case, and ambiguity itself is a useful signal that dual-load may apply.

## Operating model (3 steps)

The router compresses upstream's 4-step operating model into 3 considerations. Phase ID, signal route, and dual-load decision typically happen together once the prompt is read — the three steps name the considerations, not a forced sequence.

1. **Identify the testing phase.** Recon (mapping the surface, asset discovery, technology fingerprint), Validation (confirming a finding, characterizing the bug class), Privilege escalation (escalating access on a known foothold), or Chain (composing primitives across surfaces). Phase ID typically comes from the prompt's verbs — "I found", "I want to bypass", "how do I escalate", "can I combine". Recon-first is preferred when context is unclear; specialist work is preferred when the surface is already mapped.

2. **Look for signals that route to a specific category.** Prefer the table in [patterns/routing-tables.md](patterns/routing-tables.md); fall back to reasoning when signals are ambiguous. Boundary-condition intuitions can also bias the route — one-time operations bias toward race-condition routing per intuition #7, account-switching prompts bias toward BOLA per intuition #4, and bilateral JWT context biases toward verifying configuration before payload spray per intuition #8.

3. **Consider dual-loading if signals span topics.** The dual-load rules section of [patterns/routing-tables.md](patterns/routing-tables.md) lists the canonical pairs — recon + auth context, API + auth + IDOR, SSRF + business-flow, auth-bypass + JWT/OAuth, business-logic + race-condition, and a recon-first fallback for vague web targets. Same-plugin dual-load is one install (the cleanest case); cross-plugin dual-load is two installs and warrants two stacked recommendation blocks per the plugin-availability section below.

This is guidance, not an algorithm. The three considerations interleave — phase ID often informs signal routing, and signal routing often informs the dual-load decision.

## Plugin availability

When the deep skill the router recommends lives in a plugin that isn't currently installed, surface an install command for it.

Use the canonical two-line shape from the plugin-recommendation template at the bottom of [patterns/routing-tables.md](patterns/routing-tables.md): one line names the recommended deep skill and its parent plugin (with "not currently installed" annotation), the next line provides the `/plugin install <name>@hack-skills-marketplace` command. The install command shape uses the default ref — no `@branch` suffix anywhere.

For dual-load cases where two plugins are missing, stack two blocks rather than compressing into one comma-line — the user-action is two installs, and the stacking makes that explicit. The synthetic SSRF + business-flow case (Rule 3 in the dual-load section of [patterns/routing-tables.md](patterns/routing-tables.md)) is the canonical cross-plugin example:

> **Recommended deep skill:** ssrf-server-side-request-forgery (in `hack-skills-server-side-execution`, not currently installed)
> **Install:** `/plugin install hack-skills-server-side-execution@hack-skills-marketplace`
>
> **Recommended deep skill:** business-logic-vulnerabilities (in `hack-skills-web-client-attacks`, not currently installed)
> **Install:** `/plugin install hack-skills-web-client-attacks@hack-skills-marketplace`

Same-plugin dual-load cases — e.g., `401-403-bypass-techniques` + `jwt-oauth-token-attacks` both inside `hack-skills-auth-bypass`, or `business-logic-vulnerabilities` + `race-condition` both inside `hack-skills-web-client-attacks` — collapse to one install command. See scenarios 1 and 4 of the workflow examples for worked instances of the same-plugin shape.

## Boundary conditions (quick reference)

These are the 8 high-value intuitions a baseline AI commonly misses on real targets. The one-line summaries here mirror the ledes in the full sub-file; load the sub-file for the mechanism paragraphs and concrete examples.

The router's core value is these 8 boundary conditions — they're the reason this plugin exists alongside the topical curations. Surface relevant intuitions during the routing decision, not as an afterthought.

1. The same filtering logic is often reused across multiple pages — if one point is bypassable, similar pages usually are too.
2. Parameter names are an attack surface too — WAFs often inspect values but not names.
3. Second-order vulnerabilities are common — safe at storage time does not mean safe when later read into a dangerous context.
4. BOLA is fundamentally "authenticated but unauthorized" — replaying with account A/B switching is critical.
5. Older API versions are most likely to miss patches — fixing v2 does not mean v1 was retired.
6. Business-logic vulnerabilities often bring highest impact — scanners miss them and they persist longer.
7. Race conditions should prioritize one-time actions — coupon redemption, claims, resets, invites, trials, inventory deduction.
8. For JWT attacks, check key and algorithm context first — do not blindly spray payloads; verify `alg`, `kid`, JWKS, and key source first.

For full paragraphs and concrete examples, load [patterns/expert-intuitions.md](patterns/expert-intuitions.md).

## Workflow examples

For four worked traces — admin panel + JWT, GraphQL with introspection, `.env` in webroot, coupon-reuse checkout — see [examples/workflow-walkthroughs.md](examples/workflow-walkthroughs.md). Each trace shows the prompt, the testing phase identified, the signal route, any dual-load decision, the boundary conditions surfaced, and a concrete next-test recommendation.

The four scenarios together cover the full routing-strategy surface. Scenarios 1 and 4 demonstrate same-plugin dual-load (one install covers two deep skills, the cleanest case). Scenarios 2 and 3 demonstrate single-plugin focus where the recon and specialist work both live in `hack-skills-recon` — the routing decision collapses to one install plus a single deep skill load.

The walkthroughs are concrete worked applications of the routing strategy and operating model described above; they're the on-demand reference when the router's general guidance needs to be grounded against a realistic prompt.
