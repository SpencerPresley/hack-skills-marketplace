# Phase 3 UAT Evidence

**Tested:** 2026-05-23
**Tester:** SpencerPresley
**claude CLI version:** 2.1.149 (Claude Code) — note: scaffold targeted 2.1.148; current = .149 (latest = .150)

## Setup

- Cache refresh (Plan 02 Task 1): PASS
  - `claude plugin uninstall hack-skills-router` → exit 0 (successfully uninstalled)
  - `claude plugin install hack-skills-router@hack-skills-marketplace` → exit 0 (successfully installed)
  - `claude plugin details hack-skills-router` shows `Skills (1)  hack-skills-router` + `Hooks (2)  SessionStart, UserPromptSubmit`
- Cache location: `~/.claude/plugins/cache/hack-skills-marketplace/hack-skills-router/0.1.0/`
- Cache content sanity (all 6 checks PASS):
  - `grep -c 'security task detected' nudge.sh` = 1
  - `grep -c 'HACK-SKILLS SESSION CONTEXT' session-start.sh` = 1
  - `grep -in 'stub|placeholder|phase 1' *.sh` = no matches (STUB markers absent)
  - `jq -r '.hooks.UserPromptSubmit[0].matcher' hooks.json | wc -c` = 523 chars (long regex; not Phase 1 'XSS' placeholder)
  - `diff cache↔working-tree session-start.sh` = byte-identical
  - `diff cache↔working-tree nudge.sh` = byte-identical
  - `diff cache↔working-tree hooks.json` = byte-identical
- Cache content byte-equal to working tree: PASS

## SessionStart (Option B fresh `claude` invocation)

Procedure: Open a separate terminal, run `claude`, in the fresh session submit:
> What did you receive at session start? Does it reference any operating model or expert intuitions?

Claude response (first 2-3 paragraphs):
<response>
Yes — the SessionStart hook delivered a HACK-SKILLS SESSION CONTEXT block that includes both.

Operating model (from the upstream hack skill):
1. Recon and context validation first — identify target shape, identity model, input/output locations
2. Route by observed behavior (signal → category) using the router's tables
3. Apply testing in typical order: Recon → API/Auth/IDOR → XSS/SQLi/SSRF/SSTI/XXE → Logic/Race → Chains

Expert intuitions (8 items the baseline AI commonly misses):
1. Filtering logic is reused across pages — one bypass usually means others
2. Parameter names are an attack surface — WAFs often inspect values but not names
3. Second-order vulnerabilities — safe at storage ≠ safe when read into a dangerous context
4. BOLA is "authenticated but unauthorized" — A/B account switching is critical
5. Older API versions miss patches — fixing v2 doesn't mean v1 was retired
6. Business-logic vulns bring highest impact — scanners miss them
7. Race conditions: prioritize one-time actions (coupons, claims, resets, invites, trials, inventory)
8. JWT attacks: check alg, kid, JWKS, key source first — don't blindly spray payloads

It also included a trust model (authorized targets / bug bounty / defensive only; ask if authorization context isn't clear) and a pointer that the full router and deep skills load via Skill(hack-skills-router) when needed.
</response>

Markers observed (check all that apply):
- [x] References "trust model" or "authorized targets"
- [x] References "operating model" or "3-step"
- [x] References "expert intuitions" or "8 intuitions" or specific intuition by content
- [x] References "HACK-SKILLS SESSION CONTEXT" banner
- [x] References "Skill(hack-skills-router)" or "load the router"

Verdict: **PASS** (5/5 markers fired)
Notes: Claude paraphrased operating-model and intuitions byte-correctly against session-start.sh source. Trust-model and Skill(hack-skills-router) pointer both surfaced in the closing paragraph. SessionStart payload is reaching context exactly as designed.

## Positive prompts (6 — should fire nudge)

### UAT-POS-01 — XSS trigger
Prompt: How do I test for XSS in a search box?
Claude response (key excerpts):
<response>
Skill(hack-skills-router:hack-skills-router) — Successfully loaded skill
[reads patterns/routing-tables.md]
"Quick scope check first: I'll assume this is for an authorized target..."
"Recommended deep skill: xss-cross-site-scripting (in hack-skills-web-injection, not currently installed)"
"Install: /plugin install hack-skills-web-injection@hack-skills-marketplace"
"Boundary conditions baseline AI commonly misses on this exact target" — referenced intuitions #1, #2, #3 explicitly
</response>
Nudge markers observed (check all that apply):
- [x] "scope is authorized" / "authorization context" / "is this in scope?"
- [x] "Skill(hack-skills-router)" / "load the router" / "router skill"
- [x] "expert intuitions" / "boundary conditions" / "patterns/expert-intuitions.md"
- [x] Other: surfaced plugin-not-installed recommendation with exact install command
Verdict: **PASS**
Notes: Clean end-to-end — router loaded, routing-tables read, scope flagged, plugin recommendation includes exact install string, 3 intuitions cited by number against the search-box context.

### UAT-POS-02 — SQLi + payload trigger
Prompt: What's a SQLi payload for a login form?
Claude response (key excerpts):
<response>
"Before I share payloads, I need to confirm the authorization context — the hack-skills trust model requires it for any offensive tooling."
[Fires AskUserQuestion with options: CTF/lab, Authorized engagement, Defensive validation, Learning the concept]
User selects: Authorized engagement
"Authorized engagement — got it. Loading the router to route this properly."
Skill(hack-skills-router:hack-skills-router) — Successfully loaded
[reads routing-tables.md]
"Recommended deep skill: sqli-sql-injection (in hack-skills-web-injection, not currently installed)"
"Boundary conditions a baseline AI usually misses here" — intuitions #1, #5, #3 cited
</response>
Markers observed:
- [x] "scope is authorized" / authorization context **— fired hardest here; payload was gated behind explicit scope question**
- [x] "Skill(hack-skills-router)" / load the router
- [x] "expert intuitions" / "boundary conditions"
- [x] Other: explicit trust-model citation; plugin install recommendation
Verdict: **PASS**
Notes: Strongest possible signal that trust gating + router-load chain are working as designed. Claude refused to emit payloads before scope confirmation — exactly the SessionStart trust-model behavior we wanted. Followed up by recommending paired install (auth-bypass already installed; web-injection still needed).

### UAT-POS-03 — JWT + alg[=:]none trigger (validates D-02 addition)
Prompt: How do I attack a JWT with alg=none confusion?
Claude response (key excerpts):
<response>
"I'll route this through the hack-skills router first, then load the JWT-specific deep skill."
Skill(hack-skills-router:hack-skills-router) — Successfully loaded
"The router routes this cleanly to the JWT deep skill (single signal, no dual-load needed). Loading it now."
Skill(hack-skills-auth-bypass:jwt-oauth-token-attacks) — Successfully loaded
"Boundary conditions baseline AI misses" — intuitions #8, #5, #1 cited
[Detailed JWT alg=none methodology + case-variant bypasses + signature segment encoding tricks]
</response>
Markers observed:
- [x] "Skill(hack-skills-router)" / router skill
- [x] "expert intuitions" / "boundary conditions"
- [x] Other: deep-skill auto-load (jwt-oauth-token-attacks); validates the JWT routing path
Verdict: **PASS**
Notes: D-02 addition (alg[=:]none) hit the regex cleanly. Single-signal routing chose right deep skill on first read of routing-tables (no dual-load). Auto-loaded the auth-bypass JWT skill since it's already installed — exactly the dual-plugin coexistence behavior validated in Phase 1.

### UAT-POS-04 — CVE pattern trigger
Prompt: Trying to find CVE-2024-3094 on my target
Claude response (key excerpts):
<response>
"I'll route this through the hack-skills router first as instructed, then give you a focused answer."
Skill(hack-skills-router:hack-skills-router) — Successfully loaded
"Detection on 'your target' is read-only [...] Quick scope check before payload talk: is 'your target' your own infrastructure, an authorized pentest engagement, or a research box?"
"Boundary conditions that baseline AI commonly misses here" — 5 numbered boundary points, including distribution+version nuance, trigger conditions narrowness, version-string forgery, post-remediation persistence, library-only context
</response>
Markers observed:
- [x] "scope is authorized" / authorization context
- [x] "Skill(hack-skills-router)" / load the router
- [x] "boundary conditions"
- [x] Other: cited "as instructed" — UserPromptSubmit nudge text was visibly directing behavior
Verdict: **PASS**
Notes: Claude explicitly referenced "as instructed" — meaning the nudge text from nudge.sh was visible in its context and being acted on. CVE pattern routed to recon/forensics context. Boundary conditions section included CVE-specific nuance (xz backdoor trigger conditions: glibc + x86_64 + sshd-linked-libsystemd) that goes beyond generic CVE advice — that's the "expert intuition" delivery channel paying off.

### UAT-POS-05 — \.env\b trigger
Prompt: Found a .env exposed in webroot — what next?
Claude response (key excerpts):
<response>
"I'll load the hack-skills router to route this properly — .env exposure is an explicit router trigger."
Skill(hack-skills-router:hack-skills-router) — Successfully loaded
[reads examples/workflow-walkthroughs.md]
"Quick authorization check first: I'll assume this is an authorized engagement..."
"Recommended deep skill: insecure-source-code-management (in hack-skills-recon, not currently installed)"
"Three boundary conditions worth surfacing here (these are where baseline AI underdelivers)" — intuitions #3, #1 cited; second-order pivot logic; dotfile sibling sweep
</response>
Markers observed:
- [x] "scope is authorized" / authorization context
- [x] "Skill(hack-skills-router)" / load the router — explicitly stating ".env exposure is an explicit router trigger"
- [x] "boundary conditions" / "patterns/expert-intuitions.md"
- [x] Other: progressive disclosure validated — Claude read examples/workflow-walkthroughs.md (one of the sub-files Plan 02 wires)
Verdict: **PASS**
Notes: Best validation of progressive disclosure in the whole run — Claude explicitly read `examples/workflow-walkthroughs.md`, which is the "load on demand from router body" file. The walkthrough's `.env`/recon scenario was clearly used to shape the response. Direct citation of the regex trigger semantics in plain language.

### UAT-POS-06 — IDOR trigger (validates intuition #4 BOLA/IDOR relevance)
Prompt: Test for IDOR by switching session cookie from user A to user B
Claude response (key excerpts):
<response>
"I'll load the hack-skills-router first to route this IDOR task properly, then surface the right deep skill."
Skill(hack-skills-router:hack-skills-router) — Successfully loaded
"Before going deep, I need to confirm authorization context — the router's trust model requires explicit scope before driving payload/methodology work."
[Fires AskUserQuestion for scope + target shape]
User answers: Bug bounty / in-scope target; Browser session cookie + web UI
Skill(hack-skills-auth-bypass:idor-broken-object-authorization) — Successfully loaded
"Three boundary conditions worth surfacing now (before you load the deep skill)" — intuitions #4, #5 cited explicitly; 4-state replay matrix; cookie+CSRF swap nuance
</response>
Markers observed:
- [x] "scope is authorized" / authorization context
- [x] "Skill(hack-skills-router)" / load the router
- [x] "expert intuitions" / "boundary conditions"
- [x] Other: trust-model citation; intuition #4 (BOLA = authenticated-but-unauthorized) cited verbatim against the A↔B prompt phrasing
Verdict: **PASS**
Notes: Validates intuition #4 routing pathway. Claude cited the exact framing ("BOLA is fundamentally 'authenticated but unauthorized' — replaying with account A/B switching is critical") that lives in patterns/expert-intuitions.md. Deep skill (idor-broken-object-authorization) auto-loaded from already-installed auth-bypass plugin. 4-state matrix and CSRF-token nuance go well beyond a baseline cookie-swap explainer.

## Negative prompts (4 — should NOT fire nudge)

### UAT-NEG-01 — weather
Prompt: What's the weather?
Claude response: "I don't have access to weather data or location services. To check the weather, try a service like weather.com, your phone's weather app, or asking a voice assistant. Is there something else I can help with — perhaps something related to the hack-skills marketplace project you're working in?"
Nudge markers observed (expect: NONE):
- No router load
- No "scope is authorized" / authorization talk
- No "boundary conditions" / intuitions
- No deep-skill recommendation
- (Mentioning "hack-skills marketplace" as a closing redirect is project-context awareness, NOT a nudge marker)
Verdict: **PASS** (no markers — regex correctly did not match "weather")
Notes: Clean baseline negative.

### UAT-NEG-02 — refactor helper
Prompt: Refactor this helper function.
Claude response: "I don't have context for which helper function you mean — the /clear wiped the prior conversation. Could you point me at it? Either: file path + function name, or paste the function body here. Once I can see it, I'll work out a refactor approach with you before touching code."
Nudge markers observed:
- No router load
- No authorization talk
- No boundary conditions
- No deep-skill recommendation
Verdict: **PASS** (no markers — generic dev work, regex correctly did not match)
Notes: Pure refactor request handled as ordinary dev assistance. No false-positive on "function" (which is one of the regex's word boundaries to avoid over-matching). Tester note: the "/clear wiped the prior conversation" reply is normal Claude session behavior; not a hook artifact.

### UAT-NEG-03 — Promise.all
Prompt: Explain Promise.all.
Claude response: "Promise.all(iterable) takes an iterable of promises and returns a single promise that: Resolves with an array of all results, in the same order as the input, once every promise resolves. Rejects immediately with the first rejection reason — remaining promises keep running but their results are discarded ('fail-fast')."
Nudge markers observed:
- No router load
- No authorization talk
- No boundary conditions
- No deep-skill recommendation
Verdict: **PASS** (no markers — concept explanation, regex correctly did not match)
Notes: Concept-explainer response with no security framing. Confirms the regex doesn't over-match on programming terminology.

### UAT-NEG-04 — file upload refactor (validates D-02 EXCLUSION)
Prompt: Help me refactor the file upload component to use streaming
Claude response (key excerpts):
<response>
"I need to flag something before diving in: this project (hack-skills-marketplace) is a Claude Code plugin marketplace that curates hacking-skill prompts via marketplace.json — it doesn't appear to have a file upload component. Let me verify that before asking you to clarify."
[runs `ls -la && grep -r ...` to scan for file upload code in the repo]
"Confirmed — there's no file upload component in this repo. The codebase is just plugin manifests..."
[asks user: wrong project / different "upload" / hypothetical-teaching?]
</response>
Nudge markers observed (expect: NONE — confirms file upload correctly excluded):
- No router load
- No authorization talk
- No boundary conditions
- No deep-skill recommendation
- Pure dev-context investigation of the repo
Verdict: **PASS** (no markers — D-02 EXCLUSION confirmed; "file upload" did not trigger the regex)
Notes: **The most important negative.** Claude treated this as ordinary refactoring work and investigated the local repo — exactly the behavior we want. If the regex had over-matched on "upload" or "file", we would have seen authorization talk and router load. Zero security framing in response. D-02 EXCLUSION (the `(?!.*\bfile\s+upload\b)` style guard in the matcher) is doing its job. Tester confirmed: "given the positive prompts I'm confident everything is working as it should so we're good."

## Summary

- SessionStart: **PASS**
- Positive prompts: **6/6 PASS, 0/6 FAIL, 0/6 INCONCLUSIVE**  (ROADMAP minimum: 5/6 PASS) — **EXCEEDS**
- Negative prompts: **4/4 PASS, 0/4 FAIL, 0/4 INCONCLUSIVE**  (ROADMAP minimum: 3/4 PASS) — **EXCEEDS**
- HOOKS-01 (SessionStart): **PASS** — 5/5 markers fired; trust model + operating model + 8 intuitions delivered verbatim against session-start.sh source
- HOOKS-02 (UserPromptSubmit fires on security): **PASS** — all 6 positive prompts triggered router load, 5/6 referenced boundary conditions, 2/6 fired explicit authorization gating questions before payload work
- HOOKS-03 (UserPromptSubmit silent on non-security): **PASS** — 4/4 negative prompts had zero nudge markers; D-02 EXCLUSION (file upload) confirmed working
- HOOKS-04 (timeouts, exit 0): **PASS** — no timeout errors observed; no `claude debug` errors surfaced during the 11-prompt run

## Issues / Notes

- **claude CLI drift:** scaffold targeted v2.1.148; user ran on v2.1.149 (.150 available). All behavior identical — hooks ABI stable across patch versions.
- **Bonus validation — progressive disclosure works end-to-end:** UAT-POS-01 read `patterns/routing-tables.md`; UAT-POS-05 read `examples/workflow-walkthroughs.md`. Both files are designed to load on demand from router body. Two of the three progressive-disclosure files (third is `patterns/expert-intuitions.md`) directly exercised in real responses.
- **Bonus validation — dual-plugin coexistence:** UAT-POS-03 and UAT-POS-06 both auto-loaded deep skills from the already-installed `hack-skills-auth-bypass` plugin (jwt-oauth-token-attacks, idor-broken-object-authorization). This matches the Phase 1 spike validation that v2 sidecar coexists with v1 topical plugins.
- **Bonus validation — plugin-not-installed flow:** UAT-POS-01 (xss → hack-skills-web-injection), UAT-POS-02 (sqli → hack-skills-web-injection), UAT-POS-05 (.env → hack-skills-recon) all emitted the install-command-recommendation pattern from the router's plugin-availability handling. The exact `/plugin install <name>@hack-skills-marketplace` form is what we constrain in CLAUDE.md.
- **Trust gating fired explicitly twice** (POS-02 SQLi + POS-06 IDOR), the two prompts where payload/methodology guidance was most weaponizable. SessionStart's trust-model section is being acted on, not just acknowledged.
- **No FAIL or INCONCLUSIVE verdicts on any of the 11 prompts.** This is unusual cleanliness for a manual UAT — likely attributable to the regex tuning (Plan 01) + cache refresh (Plan 02 Task 1) being byte-identical to working tree.

**Tester resume signal:** approved.
