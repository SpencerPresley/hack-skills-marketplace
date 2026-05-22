---
title: v2 Router Plugin Design
date: 2026-05-22
status: draft (pending user review)
supersedes_handoff: .planning/HANDOFF-v2-router-exploration.md
target_milestone: v2.0 (new milestone, see §8)
---

# v2 Router Plugin Design

A sidecar router + hook design that layers methodology scaffolding and routing intelligence on top of v1's 13 topical plugins, without breaking v1.

---

## 1. Context

v1 (shipped, live at `github.com/SpencerPresley/hack-skills-marketplace` as of 2026-05-22) curates 95 upstream skills from `yaklang/hack-skills` into 13 topically-grouped plugins. `hack-skills-routers` was excluded per PROJECT.md grouping axis.

v1 solves "context bloat from 102 upstream skills" by **pre-curation**: user installs only the topical plugin(s) relevant to current work.

v2 adds **routing intelligence and methodology scaffolding** as a sidecar plugin, without touching v1's plugins. v2 does NOT replace v1 — it composes with it.

---

## 2. Constraint analysis

### 2.1 Source immutability + the always-on description tax

PROJECT.md hard constraint: never modify upstream files in `yaklang/hack-skills`.

Phase 1 finding: when a marketplace plugin lists skills via `strict: false + skills: [...]`, the listed skills' descriptions appear in the session's always-on context (~100 tok per skill). This is what makes v1 work for selective activation.

Implication for v2: there is **no marketplace-level mechanism to hide upstream skills from always-on context once they're in a plugin's `skills` array.** The rust-skills "router with hidden layer skills" pattern depends on `user-invocable: false` in each layer skill's frontmatter — we can't add that to upstream files.

### 2.2 Why a mega-plugin (all 95 skills + router + hook) defeats the core value

95 skill descriptions × ~100 tok = ~9,500 tok always-on. That's 10% of a 100K context window before any work begins. Worse than v1, in direct contradiction with the PROJECT.md Core Value of "selective topical activation per session."

### 2.3 Why a sidecar router plugin works

A sidecar plugin can contain just the router skill + hook configs (no upstream skills). Its always-on cost is one skill description (~150 tok for the router). Topical plugins are installed separately on a per-session basis exactly as in v1. The router routes across whatever's installed.

---

## 3. Decisions (locked in conversation)

| # | Decision | Outcome |
|---|---|---|
| 1 | Marketplace shape | **Sidecar router plugin.** `hack-skills-router` added as the 14th entry in marketplace.json. v1's 13 topical plugins unchanged. |
| 2 | Router role / hook weight | **Redefined middle.** SessionStart hook injects trust + philosophy + intuitions once per session. UserPromptSubmit hook injects a light nudge on security signals. Router skill body carries methodology tables. No forced output template. |
| 3 | UserPromptSubmit trigger model | **Regex matcher in hooks.json.** Hook script is dumb — just `cat`s the nudge text. Regex maintenance happens in JSON. |
| 4 | Routing decision strategy | **Hybrid: static table primary + model-reasoning fallback.** Static for high-signal cases (~30 rows in `patterns/routing-tables.md`); reasoning for ambiguous queries. |
| 5 | Progressive disclosure layout | **Apply to the file we control (router SKILL.md).** Terse description + body; sub-files for `patterns/` and `examples/`. Accept that upstream skill bodies aren't ours to restructure. |
| 6 | v1 compatibility | **Full additive.** v1 names stay, v1 plugins ship unchanged. |
| 7 | Milestone scope | **New v2.0 milestone.** v1 is shipped and live; minimum-ceremony transition. PROJECT.md will retract the "no hooks/agents/MCP/commands" Out of Scope line at v2.0 open. |

---

## 4. Architecture overview

```
hack-skills-marketplace/                      (this repo, already live)
  .claude-plugin/
    marketplace.json                          v1's 13 entries + 1 new entry
                                              (hack-skills-router via "./plugins/hack-skills-router")
  plugins/                                    NEW dir
    hack-skills-router/                       NEW plugin authored by us
      .claude-plugin/
        plugin.json                           minimal manifest
      skills/
        hack-skills-router/
          SKILL.md                            router brain (terse desc + body)
          patterns/
            routing-tables.md                 signal -> topic skill mappings
            expert-intuitions.md              "boundary conditions AI misses"
          examples/
            workflow-walkthroughs.md          recon -> auth -> exploit chains
      hooks/
        hooks.json                            SessionStart + UserPromptSubmit configs
        scripts/
          session-start.sh                    once-per-session inject
          nudge.sh                            per-prompt regex-matched inject
  .planning/                                  existing
  PROJECT.md, CLAUDE.md                       existing (PROJECT.md updated at v2 milestone open)
```

### 4.1 Component responsibilities and costs

| Component | Fires/Lives | Token cost | Role |
|---|---|---|---|
| Router SKILL.md description (frontmatter) | Always-on when plugin installed | ~150 tok | Marker; keyword-dense to maximize description-match auto-invocation |
| Router SKILL.md body | On demand (when invoked) | variable | Routing tables, dual-skill rules, methodology |
| `patterns/*.md`, `examples/*.md` | On demand from router body | variable | Deep methodology, intuitions, walkthroughs |
| `SessionStart` hook | Once per session start | ~250 tok one-time | Trust gate + workflow philosophy + intuitions snapshot |
| `UserPromptSubmit` hook | Each prompt matching security regex | ~75 tok per fire | Light nudge: load router + surface boundary conditions |

### 4.2 Install model

```bash
# one-time setup
/plugin marketplace add SpencerPresley/hack-skills-marketplace

# once, leave installed (infrastructure)
/plugin install hack-skills-router@hack-skills-marketplace

# per-session, install whichever topics relevant
/plugin install hack-skills-auth-bypass@hack-skills-marketplace
# ...etc
```

The router is **infrastructure** (install once, forget). v1's topical plugins are **what I'm working on today**.

---

## 5. Component specifications

### 5.1 marketplace.json entry (new addition to existing array)

```json
{
  "name": "hack-skills-router",
  "source": "./plugins/hack-skills-router",
  "description": "Routing + scaffolding for hack-skills topical plugins. Adapted from yaklang/hack-skills upstream router.",
  "version": "0.1.0",
  "keywords": ["security", "pentest", "router", "hooks", "methodology"]
}
```

Note `source` is the relative-path string form (per `simple-but-powerful`'s pattern), not the `git-subdir` object form used for the upstream-curating plugins.

### 5.2 plugin.json (`plugins/hack-skills-router/.claude-plugin/plugin.json`)

```json
{
  "name": "hack-skills-router",
  "description": "Routing + scaffolding for hack-skills topical plugins.",
  "version": "0.1.0",
  "author": { "name": "Spencer Presley" }
}
```

### 5.3 hooks.json (`plugins/hack-skills-router/hooks/hooks.json`)

```json
{
  "description": "Hack-skills router hooks. SessionStart for one-time setup; UserPromptSubmit for per-prompt security-context nudge.",
  "hooks": {
    "SessionStart": [
      {
        "matcher": "*",
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
        "matcher": "(?i)(XSS|SQLi|SSRF|XXE|IDOR|BOLA|BFLA|CSRF|CORS|RCE|SSTI|LFI|RFI|JWT|OAuth|SAML|OIDC|NTLM|Kerberos|pentest|bug ?bounty|vulnerab|exploit\\b|payload|attack surface|recon\\b|enumerat|privesc|priv ?esc|reverse shell|lateral movement|burp|nmap|sqlmap|metasploit|gobuster|ffuf|hashcat|mimikatz|bloodhound|CVE-\\d{4}-\\d+|\\.git/|\\.env\\b|robots\\.txt|/etc/passwd|prototype pollution|deserialization|race condition|web cache|request smuggling)",
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

#### Regex design notes
- Case-insensitive (`(?i)`).
- **Vulnerability acronyms** (XSS, SQLi, SSRF, ...): cleanest signal.
- **Verb stems** (`vulnerab`, `exploit\b`, `enumerat`): word-boundary on `exploit` to skip false positives like "exploitative."
- **Tool names**: only security-specific ones, no generic CLI names.
- **CVE pattern** `CVE-\d{4}-\d+`: hard signal, zero false positives.
- **File-name artifacts** (`\.env\b`, `\.git/`, `robots\.txt`, `/etc/passwd`): security-recon shapes.
- **Accepted false positives**: "hack a quick script", "exploit the feature flag", "vuln scanner CI". Refine over time by observation, not by trying to enumerate perfectly upfront.

### 5.4 `session-start.sh` payload

```bash
#!/bin/bash
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
- The same filtering logic is often reused across pages — if one is bypassable,
  similar pages usually are too.
- Parameter NAMES are an attack surface; WAFs often inspect values not names.
- Second-order vulnerabilities: safe at storage time != safe at later use.
- BOLA is fundamentally "authenticated but unauthorized" — A/B account replay matters.
- Older API versions are most likely to miss patches.
- Business-logic flaws bring highest impact and persist longest.
- Race conditions: prioritize one-time operations (coupon, claim, reset, inventory).
- JWT: verify alg, kid, JWKS source, and key origin BEFORE spraying payloads.

Full router and deep skills: load Skill(hack-skills-router) when ready.
===================================
EOF
```

~250 tok, once per session.

### 5.5 `nudge.sh` payload

```bash
#!/bin/bash
cat <<'EOF'

=== HACK-SKILLS (security task detected) ===
Before answering:
1. Confirm scope is authorized — if not, refuse.
2. If you haven't already, load Skill(hack-skills-router) for category selection.
3. Surface 2–3 boundary conditions a baseline AI tends to miss for this attack class
   (the router's "expert intuitions" tables cover these — load patterns/expert-intuitions.md
   if the relevant ones aren't in working memory).
============================================
EOF
```

~75 tok, per matching prompt.

### 5.6 Router SKILL.md frontmatter

```yaml
---
name: hack-skills-router
description: |
  CRITICAL: Use this skill FIRST for security/hacking tasks before any deep topic skill.
  Routes vulnerability questions to the right deep skill from the hack-skills marketplace
  and surfaces boundary conditions a baseline AI often misses. Adapted from yaklang/hack-skills.

  Triggers: XSS, SQLi, SSRF, XXE, IDOR, BOLA, BFLA, CSRF, CORS, RCE, SSTI, LFI, RFI, JWT,
  OAuth, SAML, OIDC, NTLM, Kerberos, vulnerability, exploit, pentest, bug bounty, payload,
  recon, enumeration, privilege escalation, lateral movement, reverse shell, burp, nmap,
  sqlmap, metasploit, CVE-XXXX-NNNN, .env exposure, .git exposure, prototype pollution,
  deserialization, race condition, request smuggling, web cache deception, host header,
  parameter pollution, type juggling, NoSQL injection, WAF bypass, file upload,
  business logic, SAML assertion, OAuth misconfiguration.
---
```

### 5.7 Router SKILL.md body outline

```markdown
# Hack-Skills Router

Routes security tasks to the right deep skill from the hack-skills marketplace.
Adapted from upstream yaklang/hack-skills `hack` SKILL.md.

## When to use this skill
- New target, unclear where to start
- Multiple signals could route to multiple categories
- Need methodology rigor, not payload guessing
- Want the "boundary conditions baseline AI misses" surfaced

## Trust model
Authorized targets only. If scope is unclear, refuse or ask.

## Routing strategy (hybrid)
Primary: static signal -> topic table (see `patterns/routing-tables.md`).
Fallback: model reasoning over deep-skill descriptions for ambiguous cases.

## Operating model (3 steps)
1. Phase identification (Recon / Validation / PrivEsc / Chain).
2. Signal routing (table or fallback).
3. Dual-load if needed (see routing-tables dual-load section).

## Plugin availability
If the routing target's plugin isn't installed, recommend the install command
explicitly. The router IS the discovery surface for v1's topical plugins.

## Boundary conditions (quick ref)
[short list; full at `patterns/expert-intuitions.md`]

## Workflow examples
[link to `examples/workflow-walkthroughs.md`]
```

~80 lines body. On-demand only.

### 5.8 `patterns/routing-tables.md` outline

```markdown
# Routing Tables

## Primary: signal -> topic skill

| Signal terms | Topic skill | Marketplace plugin |
|---|---|---|
| XSS, cross-site scripting, innerHTML, DOM sink, ... | xss-cross-site-scripting | hack-skills-web-injection |
| SQLi, SQL injection, UNION, blind SQL, ... | sqli-sql-injection | hack-skills-web-injection |
| [~30 rows total — one per high-signal cluster across the 95 skills]

## Dual-load rules

| Trigger | Load BOTH |
|---|---|
| Auth bypass + JWT/OAuth context | authbypass-* + jwt-oauth-token-attacks |
| SSRF + payment / coupon / business flow | ssrf-* + business-logic-vulnerabilities |
| API testing + auth | api-recon-and-docs + api-auth-and-jwt-abuse |
| Web target, unknown specifics | recon-and-methodology + appropriate category |
| [~6 dual-load rules total]

## Plugin recommendations

If a recommended skill is not in currently-installed plugins, output:
> "Recommended skill: <skill>. Not currently installed.
> Run: /plugin install hack-skills-<topic>@hack-skills-marketplace"
```

### 5.9 `patterns/expert-intuitions.md` outline

The 8 high-value intuitions from upstream `hack` SKILL.md, each expanded to one paragraph with a concrete example. Reusable knowledge cited by name from the router body but not inlined. ~30 lines, on-demand.

### 5.10 `examples/workflow-walkthroughs.md` outline

End-to-end traces showing the router applied to realistic prompts:

- "Admin panel at `/admin`, JWT in cookie, what now?" — recon → 401-403-bypass + jwt-oauth-token-attacks → boundary conditions for each → recommended next step
- "GraphQL endpoint, introspection enabled." — recon-and-methodology → graphql-and-hidden-parameters
- "Found `.env` in webroot." — insecure-source-code-management → secret scanning → recon expansion
- "E-commerce checkout flow, can coupon be reused?" — business-logic-vulnerabilities + race-condition

~100 lines total, on-demand.

---

## 6. Token cost picture

| | v1 baseline | v2 (with sidecar) |
|---|---|---|
| Always-on (router desc + N topical descs, N=9 for auth-bypass) | ~900 tok | ~1050 tok (+150 for router desc) |
| SessionStart inject | 0 | ~250 tok (once) |
| Per-prompt inject (matching regex, est. 50% of prompts × 15 prompts/session) | 0 | ~75 tok × ~7 = ~525 tok |
| **Approx session total** | **~900 tok** | **~1825 tok** |

~2× v1's always-on cost across a session. In exchange: methodology scaffolding, trust gating, surfaced expert intuitions on every security prompt, and a router that disambiguates across topics and recommends installs for missing plugins. Worth it for security work.

---

## 7. Sequencing (v1 → v2 transition)

v1 is live (`github.com/SpencerPresley/hack-skills-marketplace`, default branch `main`, public visibility, install verified by user out-of-band).

Minimum-ceremony transition:

1. **One-line STATE.md update**: mark Phase 4 complete, milestone v1.0 closed. No formal VERIFICATION.md (user confirmed live install works).
2. **PROJECT.md scope update**: retract the "Non-skill components (hooks, agents, MCP, commands) in groups" Out of Scope line. Add "Sidecar router plugin pattern" to Active when v2 work begins; promote to Validated when v2 ships.
3. **`/gsd:new-milestone v2.0`** with new ROADMAP for v2 phases.

### 7.1 Proposed v2 phase outline

| Phase | Goal |
|---|---|
| v2 Phase 1 | **Mechanism spike.** Verify (a) in-repo authored plugin loads from `./plugins/hack-skills-router`, (b) SessionStart hook fires once per session and injects expected text, (c) UserPromptSubmit hook fires on matching prompts and not on non-matching, (d) router skill description appears in always-on context. Same shape as v1's Phase 1 schema verification. |
| v2 Phase 2 | **Router SKILL.md + sub-file content.** Author the router body + populate `patterns/routing-tables.md` (~30 rows covering all 95 upstream skills + 6 dual-load rules) + `patterns/expert-intuitions.md` + `examples/workflow-walkthroughs.md`. The biggest content-authoring phase. |
| v2 Phase 3 | **Hook scripts + regex.** Author `session-start.sh`, `nudge.sh`, `hooks.json` with the regex from §5.3. |
| v2 Phase 4 | **End-to-end live validation.** Publish to GitHub, run a fresh-state install, capture evidence that all hooks fire, router invocations work, plugin-recommendation flow works when a missing plugin is suggested. |

This is a coarse outline; the detailed plans get written during `/gsd:plan-phase` for each.

---

## 8. PROJECT.md updates required at v2 milestone open

Specific deltas to apply when running `/gsd:new-milestone`:

1. **Out of Scope** — remove or rewrite the line: *"Non-skill components (hooks, agents, MCP, commands) in groups — Groups are skill-only curations. Other component types are not the focus."*
   Replacement (suggested): *"Groups remain skill-only curations of upstream content. Non-skill components (hooks, agents) are introduced ONLY in the sidecar `hack-skills-router` plugin, not in the topical groups."*
2. **Core Value** — extend from "selective topical activation" to "selective topical activation, with optional routing + methodology scaffolding via the sidecar router plugin."
3. **Constraints** — add: *"Sidecar pattern: the `hack-skills-router` plugin authors original content (router skill + hooks) under `plugins/hack-skills-router/`. Topical plugins remain pure curation of `yaklang/hack-skills`."*
4. **Key Decisions** — add row: *"Use sidecar router plugin instead of bundling hooks/router into topical plugins — preserves v1 selective-activation, avoids duplication, keeps maintenance burden on a single file."*

---

## 9. Open implementation questions (to verify during Phase 1 spike)

These are NOT design decisions; they're things the spike needs to nail down before content authoring begins.

1. **Does `source: "./plugins/hack-skills-router"` work from a marketplace.json that's referenced via `/plugin marketplace add <github-repo>`?** It works for `simple-but-powerful` locally; need to verify for the GitHub-published flow.
2. **Does the SessionStart hook fire on plugin install, or only on subsequent session start?** If only on session start, the user's first install session won't see the SessionStart inject — minor UX wrinkle.
3. **What does Claude Code do with the UserPromptSubmit regex if it's malformed?** Need to verify the regex parses cleanly and fires as expected. (jq-validate the JSON; regex itself we'll test in the spike.)
4. **Does `${CLAUDE_PLUGIN_ROOT}` resolve correctly inside a `simple-but-powerful`-style plugin?** Should — that's exactly what `codex-context-loader` uses — but worth a smoke test.
5. **Hook timeout (3s for nudge, 5s for SessionStart, 5s for hooks.json overall)** — `cat` should be instant; the timeout exists just in case. Leave as a safety margin.

---

## 10. Out of scope (v2)

- **Modifying upstream `yaklang/hack-skills` files** — same PROJECT.md hard constraint as v1.
- **Auto-syncing with upstream changes** — same snapshot-consumption model as v1.
- **Restructuring v1's 13 topical plugin groupings** — v2 is additive.
- **A "kill switch" for the hook** — initially. If hook fatigue manifests, add an env var (`HACK_SKILLS_SKIP_HOOK=1`) in a follow-up.
- **Multi-language router triggers** — English only. Upstream's `hack` SKILL.md is bilingual; we're not.
- **Forced output template** ("Testing Phase: X / Signal Route: Y" headers) — explicitly rejected during design (see §3 decision 2).
- **Lifecycle hooks beyond SessionStart + UserPromptSubmit** — could add PreCompact, Stop, etc. later; not in v2.0.

---

## 11. Source attribution

The SessionStart payload's Operating Model and Expert Intuitions sections are paraphrased from `yaklang/hack-skills/skills/hack/SKILL.md` (MIT-licensed). The routing tables in `patterns/routing-tables.md` are derived from the same source's Signal/Priority table, expanded to address our 13-plugin topical structure rather than upstream's flat skill list.

Source attribution appears in:
- Router SKILL.md body (header line: "Adapted from upstream yaklang/hack-skills `hack` SKILL.md")
- This design doc (this section)
- The router plugin's `plugin.json` description ("Adapted from yaklang/hack-skills upstream router.")
- `patterns/expert-intuitions.md` (full attribution paragraph at top)

---

## 12. Decision provenance

These decisions were made in a single brainstorming conversation on 2026-05-22. The conversation began from `.planning/HANDOFF-v2-router-exploration.md`, absorbed the rust-skills and oh-my-claudecode reference designs, identified the source-immutability constraint as the key design pressure, and converged on the sidecar shape + redefined-middle hook weight + regex matcher trigger + hybrid routing strategy in ~7 question-driven exchanges.

Major alternative paths explicitly rejected:
- **Mega-plugin** (one plugin with all 95 skills + router + hook): defeats core value (§2.2).
- **Per-plugin bundle** (router + hook embedded in each of v1's 13 plugins): 13× duplication, cross-topic routing breaks. See conversation log if reconstructable from git/state.
- **Heavy router enforcing output structure** (rust-skills shape verbatim): too performative for ad-hoc security work, per-prompt cost too high. Critique in §3 decision 2.
- **No hook** (router-only via description matching): no enforcement of trust gating; Claude might not auto-invoke router.
- **Always-fire hook + script regex** (OMC pattern): more flexible but more moving parts than needed for a personal marketplace.

---

## 13. Next step

After user review and approval of this design:
1. Invoke `writing-plans` skill to create an implementation plan.
2. The plan becomes the v2 milestone's roadmap (likely 4 phases per §7.1).
3. PROJECT.md updates per §8 happen at milestone-open.
