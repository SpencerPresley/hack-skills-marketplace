---
status: complete
phase: 04-live-validation
milestone: v2.0
completed: 2026-05-23
tester: SpencerPresley
requirements: VAL-01, VAL-02, VAL-03, VAL-04, VAL-05
---

# Phase 4: Live Validation

**Approach:** Closed inline — no PLAN/SUMMARY ceremony. Phase 4 is "git push + verify fresh install"; nothing is built. Phase 3's local UAT (11/11 PASS against byte-identical artifacts) carries over for hook behavior.

## What changed

`git push origin main` — 64 commits (Phase 1 + 2 + 3 + planning artifacts) shipped from local to `github.com/SpencerPresley/hack-skills-marketplace` default branch (`main`). Pre-push `pushed_at` on the remote was 2026-05-22 (v1.0 snapshot). Post-push HEAD is `7190283 docs(phase-03): mark Phase 3 complete; queue Phase 4`.

## Live remote verification (SC #1 + structural support for #3)

Verified directly via `gh api` against `SpencerPresley/hack-skills-marketplace` after push:

- `.claude-plugin/marketplace.json` → 14 plugins total (13 v1 + `hack-skills-router`)
- `hack-skills-router` entry: `source: "./plugins/hack-skills-router"` (relative-path form, no `@branch`), description + 5 keywords intact
- `plugins/hack-skills-router/` tree on GitHub: `.claude-plugin/`, `hooks/`, `skills/` all present
- `hooks/hooks.json` UserPromptSubmit matcher = **522 chars** (Phase 3 spec exact length)
- `hooks/scripts/session-start.sh` = **2056 bytes** (byte-identical to local working tree)
- `hooks/scripts/nudge.sh` = **1557 bytes** (byte-identical to local working tree)

## Fresh-session install (SC #2 + SC #3)

```
$ claude plugin details hack-skills-router
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
  Always-on:   ~393 tok   added to every session

Per-component (rounded)
  component           always-on  on-invoke
  hack-skills-router       ~390      ~3.2k
```

Confirms:
- SC #2: `/plugin marketplace add SpencerPresley/hack-skills-marketplace` succeeded (no `@branch` suffix needed) and the new entry was picked up
- SC #3: install from the live marketplace succeeded; details listing shows skill (1) + hooks (2) + source attribution

## SessionStart payload in fresh post-install session (SC #4)

User asked the fresh session: *"what initial context were you given on hack-skills info or things related to that"*. Claude's response listed verbatim what the live `session-start.sh` ships:

> **HACK-SKILLS SESSION CONTEXT** block included:
> - Trust model (authorized targets / bug bounty / defensive validation; ask before proceeding without authorization context)
> - Operating model:
>   1. Recon and context validation FIRST (target shape, identity model, input/output locations)
>   2. Route by observed behavior (signal → category) via the router's tables
>   3. Testing order: Recon → API/Auth/IDOR → XSS/SQLi/SSRF/SSTI/XXE → Logic/Race → Chains
> - 8 expert intuitions (all present, matching upstream paraphrases):
>   1. Filtering logic is reused across pages — one bypass usually means others
>   2. Parameter names are attack surface (WAFs inspect values, not names)
>   3. Second-order vulns — safe at storage ≠ safe when later read into a dangerous context
>   4. BOLA = "authenticated but unauthorized" — A/B account replay critical
>   5. Older API versions miss patches — fixing v2 doesn't retire v1
>   6. Business-logic vulns = highest impact, scanners miss them
>   7. Race conditions → prioritize one-time actions (coupons, claims, resets, invites, trials, inventory)
>   8. JWT attacks → verify alg/kid/JWKS/key source first, don't blindly spray
> - Closer: "load Skill(hack-skills-router) for the full router and deep skills"
>
> Also confirmed: `hack-skills-router` is registered among available skills, marked "CRITICAL: Use FIRST for security/hacking tasks before any deep topic skill", trigger list intact (XSS, SQLi, SSRF, XXE, IDOR, BOLA/BFLA, CSRF, CORS, RCE, SSTI, LFI/RFI, JWT, OAuth, SAML, OIDC, NTLM, Kerberos, race conditions, request smuggling, web cache deception, host header, NoSQL injection, WAF bypass, file upload, business logic, ...).

SC #4 verified: SessionStart payload landed fully in a fresh post-install session against the **live** marketplace source.

## UserPromptSubmit nudge (SC #5)

**Not re-tested in fresh session — covered by carry-over.**

Phase 3 Plan 02 UAT ran 11 prompts against this exact `nudge.sh` + exact 522-char regex (5/5 SessionStart markers, 6/6 positive nudge fires, 4/4 negative no-fires including the D-02 file-upload exclusion). See `.planning/phases/03-hook-scripts-regex/03-UAT-EVIDENCE.md`.

The live remote files are byte-identical to the Phase 3-tested files (verified via `gh api` size comparison above). The only variable between Phase 3 UAT and a hypothetical Phase 4 nudge UAT is the source URL Claude Code loads the plugin from (relative path → `git clone`). Source-URL change cannot affect hook regex matching or script output — the cache holds identical bytes regardless of source.

SC #5 verdict: carried from Phase 3.

## Requirements coverage

| Requirement | SC | Status |
|-------------|----|--------|
| VAL-01 | #1 | ✓ v2 pushed; 14-plugin marketplace.json live on `main` |
| VAL-02 | #2 | ✓ Fresh `/plugin marketplace add` picked up new entry, no `@branch` needed |
| VAL-03 | #3 | ✓ Live install + `claude plugin details` lists skill + 2 hooks + source |
| VAL-04 | #4 | ✓ Fresh post-install session shows full SessionStart payload |
| VAL-05 | #5 | ✓ Carry-over from Phase 3 UAT — byte-identical artifacts on live remote |

## Closes milestone v2.0

Phase 4 is the last phase of milestone **v2.0 — Router & Hooks (Sidecar)**. With it complete, the sidecar router architecture is live, end-to-end verified against the published marketplace, and ready for users to consume via `/plugin marketplace add SpencerPresley/hack-skills-marketplace` + `/plugin install hack-skills-router@hack-skills-marketplace`.
