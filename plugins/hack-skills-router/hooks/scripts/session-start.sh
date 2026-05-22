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
(1) Recon and context validation FIRST. Identify target shape, identity model,
    input/output locations.
(2) Route by observed behavior (signal -> category) using the router's tables.
(3) Apply testing in this typical order:
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
