# Phase 2: Router Skill + Content - Pattern Map

**Mapped:** 2026-05-22
**Files analyzed:** 4 (1 rewrite-in-place + 3 new)
**Analogs found:** 4 / 4 (1 in-repo for the Phase 1 SKILL.md stub + 1 in-repo upstream-cache analog for content paraphrase + 2 external rust-skills sub-file structures)

## Context

Phase 2 is a **pure content-authoring phase** with three closely-coupled analogs:

1. **Phase 1 stub `SKILL.md`** at `/Users/spencerpresley/code/hack-skills-wip/hack-skills-marketplace/plugins/hack-skills-router/skills/hack-skills-router/SKILL.md` (28 lines) — same file as Phase 2's rewrite target, current state. Provides frontmatter shape, line-style conventions, and the STUB→FINAL boundary marker that must be removed.
2. **Upstream `hack` SKILL.md** at `/Users/spencerpresley/.claude/plugins/cache/hack-skills-marketplace/hack-skills-recon/c6f732befcae-32c1cf49/hack/SKILL.md` (162 lines, MIT-licensed) — verbatim source for the 8 intuitions (lines 119–130), the operating model (lines 38–80), and the section list pattern Phase 2's body will paraphrase. Read-only content source.
3. **rust-skills `rust-router` skill** at `/Users/spencerpresley/skill-vetting/rust-skills/skills/rust-router/` — the only available structural analog for the **patterns/ + examples/ progressive-disclosure layout**. Contains `SKILL.md` + `patterns/negotiation.md` + `examples/workflow.md` + `integrations/os-checker.md` — exactly the directory shape Phase 2 builds. Used by Phase 1 PATTERNS.md as the primary external analog and reaffirmed here for Phase 2's sub-files.

The in-repo `.claude/get-shit-done/` skill set was inspected but is **NOT a good analog** for Phase 2: it uses `bin/`, `contexts/`, `references/`, `templates/`, `workflows/` — none of which match the `patterns/` + `examples/` progressive-disclosure pattern that Claude Code Skill best-practices specifies (and that the design spec §5 commits to). It's a different style of skill (workflow / GSD orchestrator).

Critical reuse from Phase 1: the **STUB → FINAL boundary discipline** documented in `01-PATTERNS.md` §"STUB vs Final Body Map" and the per-file commit pattern (`feat(02): ...`) carry forward into Phase 2's execution. Phase 2 is also the first phase that creates sub-directories under `skills/<name>/` — `patterns/` and `examples/` are both new — establishing the progressive-disclosure layout for any future skill in this repo.

## File Classification

| New/Modified File | Role | Data Flow | Closest Analog | Match Quality |
|-------------------|------|-----------|----------------|---------------|
| `plugins/hack-skills-router/skills/hack-skills-router/SKILL.md` (REWRITE in place) | skill body + frontmatter | always-on description + on-demand body | (1) `plugins/hack-skills-router/skills/hack-skills-router/SKILL.md` (current Phase 1 stub — frontmatter shape only) + (2) `/Users/spencerpresley/.claude/plugins/cache/hack-skills-marketplace/hack-skills-recon/c6f732befcae-32c1cf49/hack/SKILL.md` (upstream — section list + content source for paraphrase) + (3) `/Users/spencerpresley/skill-vetting/rust-skills/skills/rust-router/SKILL.md` (external — body section style + cross-ref-to-sub-files pattern) | exact for frontmatter (1); role-match for body structure (2 + 3) |
| `plugins/hack-skills-router/skills/hack-skills-router/patterns/routing-tables.md` (NEW) | progressive-disclosure sub-file: signal-routing tables + dual-load rules + plugin-rec template | on-demand load (sub-file referenced from SKILL.md body) | (1) Upstream `hack` SKILL.md lines 52–73 (Signal/Priority table — content source) + (2) `/Users/spencerpresley/skill-vetting/rust-skills/skills/rust-router/SKILL.md` lines 130–199 (multiple per-layer routing tables — table-of-tables organization style) | content-source (1); structure-style (2) |
| `plugins/hack-skills-router/skills/hack-skills-router/patterns/expert-intuitions.md` (NEW) | progressive-disclosure sub-file: 8 boundary-condition paragraphs + file-header attribution | on-demand load | (1) Upstream `hack` SKILL.md lines 119–130 (8 intuitions verbatim — content source) + (2) `/Users/spencerpresley/skill-vetting/rust-skills/skills/rust-router/patterns/negotiation.md` (structure: lede + table + flow + examples — paragraph-style pattern file) | content-source (1); structure-style (2) |
| `plugins/hack-skills-router/skills/hack-skills-router/examples/workflow-walkthroughs.md` (NEW) | progressive-disclosure sub-file: 4 worked-example traces | on-demand load | `/Users/spencerpresley/skill-vetting/rust-skills/skills/rust-router/examples/workflow.md` | exact (same role, same file path shape, same role in the parent SKILL.md's cross-reference structure) |

## Data Flow Map (cross-file in Phase 2's surface)

```
[user prompt matches description keywords in SKILL.md frontmatter]
   |
   v
Claude auto-invokes Skill(hack-skills-router)
   |
   v
SKILL.md body loaded (~95-105 lines after Phase 2)
   ├── "When to use" bullets        ─── stays in body
   ├── "Trust model"                 ─── stays in body
   ├── "Routing strategy"            ─── cross-refs patterns/routing-tables.md
   ├── "3-step operating model"      ─── stays in body
   ├── "Plugin availability"         ─── cross-refs patterns/routing-tables.md (template section)
   ├── "Boundary conditions"         ─── 8 one-line summaries in body; cross-refs patterns/expert-intuitions.md
   └── "Workflow examples"           ─── cross-refs examples/workflow-walkthroughs.md
   |
   v (on demand)
patterns/routing-tables.md   patterns/expert-intuitions.md   examples/workflow-walkthroughs.md
       │                              │                              │
       │  13 plugin-keyed sections    │  8 paragraph entries          │  4 scenario traces
       │  (install cmd + signal rows) │  (lede + mechanism + example) │  (prompt → phase → route
       │  + dual-load rules section   │                               │   → dual-load → boundary
       │  + plugin-rec template       │                               │   → next-test)
       │  (bottom of file)            │                               │
   |
   v
Claude produces routing decision: signal → deep skill → plugin name → install command (if not installed)
```

Critical: **all three sub-files link only back from the body**, never to each other (per RESEARCH §Pitfall 5 — multi-hop links cause Claude to partial-read). When `expert-intuitions.md` needs to reference a walkthrough, it does so as **prose mention by name**, NOT as a clickable markdown link.

---

## Pattern Assignments

### 1. `plugins/hack-skills-router/skills/hack-skills-router/SKILL.md` (REWRITE in place)

**Role:** skill frontmatter + body. **Data flow:** frontmatter `description` is always-on once plugin is installed; body loads only on `Skill(hack-skills-router)` invocation (auto-invoked when prompt matches description triggers, or explicitly via slash-command).

**Closest analogs:**
- **In-repo (frontmatter shape only):** Current Phase 1 stub at the same path — lines 1–3 (YAML frontmatter delimiters + `description:` field). Stub frontmatter is the structural starting point; Phase 2 replaces only the `description` value and the body, keeps the YAML scaffold.
- **In-repo upstream cache (content source for paraphrase):** `/Users/spencerpresley/.claude/plugins/cache/hack-skills-marketplace/hack-skills-recon/c6f732befcae-32c1cf49/hack/SKILL.md` — MIT-licensed primary source for sections 4 (Trust Model), 5 (When to Use), 6 (Operating Model), 7 (8 Intuitions), and the Signal/Priority routing table.
- **External (structural style):** `/Users/spencerpresley/skill-vetting/rust-skills/skills/rust-router/SKILL.md` — exact same role (top-level router skill), same body shape (table-rich routing tables + sub-file cross-references), same progressive-disclosure pattern.

**Frontmatter pattern (Phase 1 stub current state — lines 1–3 — the YAML shape to keep):**

```yaml
---
description: STUB — routing + scaffolding for security/hacking tasks. Phase 2 will replace this body with the full router that picks the right deep skill from the hack-skills marketplace and surfaces boundary conditions a baseline AI often misses. Triggers on security, hacking, pentest, vulnerability, XSS, SQLi, CVE.
---
```

**Frontmatter target shape (production — per RESEARCH §"Frontmatter Cap Analysis" Example 1 — tightened to respect 250-char `/skills` listing display cap):**

```yaml
---
description: |
  CRITICAL: Use FIRST for security/hacking tasks before any deep topic skill. Routes vulnerability questions to the right deep skill in the hack-skills marketplace and surfaces boundary conditions a baseline AI often misses.

  Triggers: XSS, SQLi, SSRF, XXE, IDOR, BOLA, BFLA, CSRF, CORS, RCE, SSTI, LFI, RFI, JWT,
  OAuth, SAML, OIDC, NTLM, Kerberos, vulnerability, exploit, pentest, bug bounty, payload,
  recon, enumeration, privilege escalation, lateral movement, reverse shell, burp, nmap,
  sqlmap, metasploit, CVE-XXXX-NNNN, .env exposure, .git exposure, prototype pollution,
  deserialization, race condition, request smuggling, web cache deception, host header,
  parameter pollution, type juggling, NoSQL injection, WAF bypass, file upload,
  business logic, SAML assertion, OAuth misconfiguration. Adapted from yaklang/hack-skills.
---
```

Key constraints (verified in Phase 1 + RESEARCH):
- **No `name` field** — directory name supplies it (Phase 1 SC #3 verified).
- **No `user-invocable: false`** — would hide from `claude plugin details` (Phase 1 SC #4 required it visible).
- **No `disable-model-invocation: true`** — we WANT auto-invoke on signals.
- **First paragraph ≤ 250 chars** — `/skills` listing display cap (Claude Code v2.1.86+). Tightened version is 241 chars.
- **Total description ≤ 1024 chars** — frontmatter hard cap. Tightened version is ~810 chars.
- **No XML tags in description** — explicit constraint per Claude Code docs.
- **STUB marker removed** — first 6 chars of current frontmatter (`STUB —`) must NOT appear in production version.

**Body pattern from upstream `hack` SKILL.md** (lines 10–37 show the head-of-body pattern — title + overview + trust model + when-to-use):

```markdown
# HACKING SKILLS / HackSkills

## Overview

This is a top-level routing skill for **bug bounty, web security, API security, and authorized penetration testing**.

Its core role is not to replace all specialized techniques, but to help the agent:

1. First determine the testing phase (Recon / Validation / Privilege Escalation / Chain building)
2. Then select the correct vulnerability category
3. Avoid relying only on baseline model memory; prefer structured methodology
4. Prioritize boundary conditions AI often misses but that matter in real engagements

## Trust Model

- This knowledge base emphasizes content safety and auditability.
- Use this only within **authorized targets**, **legitimate research**, **defensive validation**, and **bug-bounty-approved rules**.
- Do not use these techniques for unauthorized attacks.

## When to Use This Skill

Use this skill first in the following scenarios:

- You just received a new bug bounty target and do not know where to start
- You need to decide whether to load XSS / SQLi / SSRF / IDOR / JWT / API tracks first
- You want the agent to perform Web/API security testing with a more stable methodology
- You need to route scattered findings to the right attack surface
- You want AI to miss fewer critical test points in security work
```

**Body pattern from upstream `hack` SKILL.md** (lines 39–80 show the operating-model + signal-routing-table pattern):

```markdown
## Operating Model

### Step 1: Start with Recon and context validation

Collect first:

- Target type: classic web, REST API, mobile backend, admin panel, payment flow, file upload, GraphQL
- Identity and permission model: anonymous, regular user, admin, multi-tenant
- Input locations: URL, query parameters, JSON, headers, cookies, filenames, imported files, templates, reflection points
- Output locations: HTML, attributes, JS, PDF, email, logs, background tasks, mobile endpoints

### Step 2: Route by observed behavior

| Signal | Priority direction |
|---|---|
| Input reflects into HTML / JS | XSS / SSTI |
| Server actively fetches URL / hostname | SSRF |
| Accepts XML / Office / SVG | XXE |
[... ~17 more rows ...]
```

This is the **upstream signal/priority table** Phase 2's `patterns/routing-tables.md` paraphrases and reshapes into 13 plugin-keyed sections (per D-03). The body itself does NOT inline the full table — it cross-references the sub-file.

**Body pattern from upstream `hack` SKILL.md** (lines 119–130 — the 8 intuitions, verbatim source for `patterns/expert-intuitions.md`):

```markdown
## High-Value Expert Intuitions

These are points many baseline models miss, but they are frequently effective in real bug bounty work:

1. **The same filtering logic is often reused across multiple pages**: if one point is bypassable, similar pages usually are too.
2. **Parameter names are an attack surface too**: WAFs often inspect values but not names.
3. **Second-order vulnerabilities are common**: safe at storage time does not mean safe when later read into a dangerous context.
4. **BOLA is fundamentally 'authenticated but unauthorized'**: replaying with account A/B switching is critical.
5. **Older API versions are most likely to miss patches**: fixing v2 does not mean v1 was retired.
6. **Business-logic vulnerabilities often bring highest impact**: scanners miss them and they persist longer.
7. **Race conditions should prioritize one-time actions**: coupon redemption, claims, resets, invites, trials, inventory deduction.
8. **For JWT attacks, check key and algorithm context first**: do not blindly spray payloads; verify `alg`, `kid`, JWKS, and key source first.
```

Per D-13, the **body version** of these 8 is the one-line summaries (same bold ledes, no expanded paragraph). The **`patterns/expert-intuitions.md` version** is the lede + paragraph + example. The body version cross-references the sub-file via inline link (one-level-deep from SKILL.md per RESEARCH §Pitfall 5).

**Body pattern from rust-skills `rust-router` SKILL.md** (lines 232–240 — the sub-file reference pattern):

```markdown
## Sub-Files Reference

| File | Content |
|------|---------|
| `patterns/negotiation.md` | Negotiation protocol details |
| `examples/workflow.md` | Workflow examples |
| `integrations/os-checker.md` | OS-Checker integration |
```

Phase 2's SKILL.md adapts this: it's not a single "Sub-Files Reference" table at the bottom; instead, individual sections (Routing Strategy, Plugin Availability, Boundary Conditions, Workflow Examples) each cross-reference their relevant sub-file inline. Per RESEARCH §Pattern 1, this matches Claude Code's "high-level guide with references" best-practice.

**Body pattern from rust-skills `rust-router` SKILL.md** (lines 75–107 — voice + soft heuristic style):

```markdown
## INSTRUCTIONS FOR CLAUDE

### CRITICAL: Negotiation Protocol Trigger

**BEFORE answering, check if negotiation is required:**

| Query Contains | Action |
|----------------|--------|
| "compare", "vs", "versus" | **MUST use negotiation** |
| "best practice" | **MUST use negotiation** |
| Domain + error (e.g., "fintech system E0382") | **MUST use negotiation** |
| Ambiguous scope (e.g., "tokio performance") | **SHOULD use negotiation** |
```

Note: rust-skills uses "MUST" — Phase 2's router body **does NOT** follow this style per D-14 (soft heuristic, NOT strict algorithm). Phase 2 prefers "prefer / consider / typically" phrasing. This is the **anti-pattern from rust-skills to avoid** — flagged because the rust-router is otherwise the closest external analog and the temptation to mirror its voice is real.

**Critical constraints applied to Phase 2 SKILL.md:**

- **Body section order locked by D-12:** (1) Title + 1-line attribution, (2) When to use, (3) Trust model, (4) Routing strategy, (5) 3-step operating model, (6) Plugin availability handling, (7) Boundary conditions (8 one-liners), (8) Workflow examples cross-ref.
- **Body length: 95–105 lines** (per D-12, D-13 — boundary-conditions add ~15 lines over names-only).
- **Cross-references one level deep only** — body → sub-file; never sub-file → sub-file (RESEARCH §Pitfall 5).
- **No STUB / Phase 1 / TBD / FIXME markers** — verification probe via `grep -nE '(STUB|stub|Phase 1 (stub|spike)|TBD|FIXME|XXX)'`.
- **No "MUST" / "ALWAYS" in routing/operating sections** — soft heuristic voice per D-14 (one-or-zero permissible in Trust Model section).
- **Attribution one-liner under H1:** "Adapted from upstream `yaklang/hack-skills` `hack` SKILL.md (MIT-licensed)." (per D-15).

**STUB vs FINAL divergence (in-repo current state → Phase 2 target):**
- **Phase 1 STUB (current, 28 lines):** Single-paragraph keyword-stub description; body announces "Phase 2 will replace this".
- **Phase 2 production target:** Multi-paragraph keyword-dense description (~241 chars first para + ~570 chars keyword block + attribution); body is 95–105 lines with 8 ordered sections; cross-refs to 3 new sub-files.

---

### 2. `plugins/hack-skills-router/skills/hack-skills-router/patterns/routing-tables.md` (NEW)

**Role:** progressive-disclosure sub-file holding the full 35-row signal-routing table organized as 13 plugin-keyed sections + 6 dual-load rules + plugin-recommendation template. **Data flow:** on-demand load when SKILL.md body's "Routing strategy" or "Plugin availability" sections cross-reference it.

**No in-repo structural analog** (this is the first `patterns/*.md` sub-file in this repo).

**Content-source analog (in upstream cache):** `/Users/spencerpresley/.claude/plugins/cache/hack-skills-marketplace/hack-skills-recon/c6f732befcae-32c1cf49/hack/SKILL.md` lines 52–73 — the upstream Signal/Priority table is the seed that Phase 2's table reshapes from flat-signal-to-category into 13 plugin-keyed sections. Excerpt of source table (lines 52–73):

```markdown
| Signal | Priority direction |
|---|---|
| Input reflects into HTML / JS | XSS / SSTI |
| Server actively fetches URL / hostname | SSRF |
| Accepts XML / Office / SVG | XXE |
| Path, filename, or download endpoint is controllable | Path Traversal / LFI |
| Many object IDs appear in APIs | IDOR / BOLA / BFLA |
| Login, reset password, 2FA, sessions | Auth Bypass / JWT / OAuth |
| Multi-step transactions, coupons, pricing, inventory | Business Logic |
| MongoDB / JSON query syntax exposure | NoSQL Injection |
| CLI tools, image processing, importers | Command Injection |
| HTTP parsing anomalies / front-back framing mismatch | Request Smuggling |
| Node.js JSON handling / controllable `__proto__` | Prototype Pollution |
| PHP weak comparison / 0e hash / loose conditions | Type Juggling |
| Repeated parameter names / WAF-app parsing mismatch | HTTP Parameter Pollution |
| One-time operations (coupon/inventory/reset) | Race Condition |
| XML/XSLT template processing | XSLT Injection |
| Accessible .git/.svn/.env paths | Insecure SCM |
| CSV/Excel export features | CSV Formula Injection |
| WebSocket protocol upgrades | WebSocket Security |
| Internal package names / supply-chain inventory | Dependency Confusion |
```

**Structure-source analog (external):** `/Users/spencerpresley/skill-vetting/rust-skills/skills/rust-router/SKILL.md` lines 130–199 — multiple sequential tables with a common shape (signal column + destination column) separated by section headings. Phase 2's `routing-tables.md` adopts the same "table-of-tables" organization but adds the plugin name + install command pre-amble per section.

**Excerpt from rust-router SKILL.md (lines 130–166 — table-of-tables shape):**

```markdown
## Layer 1 Skills (Language Mechanics)

| Pattern | Route To |
|---------|----------|
| move, borrow, lifetime, E0382, E0597 | m01-ownership |
| Box, Rc, Arc, RefCell, Cell | m02-resource |
[... more rows ...]

## Layer 2 Skills (Design Choices)

| Pattern | Route To |
|---------|----------|
| domain model, business logic | m09-domain |
| performance, optimization, benchmark | m10-performance |
[... more rows ...]

## Layer 3 Skills (Domain Constraints)

| Domain Keywords | Route To |
|-----------------|----------|
| fintech, trading, decimal, currency | domain-fintech |
[... more rows ...]
```

**Per-section pattern Phase 2 should produce (per D-04, D-05 + RESEARCH §"Example 3"):**

```markdown
### hack-skills-auth-bypass

**Install:** `/plugin install hack-skills-auth-bypass@hack-skills-marketplace`

| Signal terms | Deep skill (in this plugin) |
|---|---|
| JWT, JSON Web Token, alg=none, kid injection, JWKS, RS256 vs HS256 | jwt-oauth-token-attacks |
| 401, 403, admin panel access denied, path manipulation, method override | 401-403-bypass-techniques |
| OAuth, OIDC, redirect URI, PKCE, state parameter, account binding | oauth-oidc-misconfiguration |
```

Notes on this pattern (locked by D-03, D-04, D-05):
- **Section heading is the plugin name** — `### hack-skills-<topic>` — and must match marketplace.json byte-exact (RESEARCH Pitfall 2).
- **Install command immediately under heading** — doubles as plugin-rec surface; no per-row install repetition needed.
- **Two-column table:** `| Signal terms | Deep skill (in this plugin) |`.
- **Signals are 3–6 comma-separated synonyms.**
- **Deep skill is the upstream directory name** — no `./` prefix, no backticks (RESEARCH Pitfall 1 — single-character drift risk).
- **2–3 rows per section** (per D-03 — 35 rows total across 13 sections per RESEARCH §"Row count totals").

**Dual-load rules section pattern (per D-06 + RESEARCH §"Final Dual-Load Rule Set"):** After the 13 plugin-keyed sections, a single H2 section titled "Dual-load rules" lists 6 rules in the shape:

```markdown
### Rule N: <short name>
**Trigger:** <pattern>
**Load both:** `<skill-1>` (in `hack-skills-<plugin-1>`) + `<skill-2>` (in `hack-skills-<plugin-2>`)
**Rationale:** <one-sentence justification>
```

The 6 rules with their canonical content are in RESEARCH §"Final Dual-Load Rule Set" (lines 852–895 of RESEARCH.md). The planner locks the wording; researcher's proposal is the default.

**Plugin-recommendation template section (per D-07):** Final H2 section in the file, titled "Plugin-recommendation template" — verbatim two-line block format with explicit instruction to stack (NOT merge) for dual-load cases. Source in RESEARCH §"Example 5":

```markdown
## Plugin-recommendation template

When the router selects a deep skill whose plugin isn't currently installed, surface it in
this two-line shape (don't compress into one comma-line):

> **Recommended deep skill:** jwt-oauth-token-attacks (in `hack-skills-auth-bypass`, not currently installed)
> **Install:** `/plugin install hack-skills-auth-bypass@hack-skills-marketplace`

For dual-load cases where two plugins are missing, stack two blocks — don't merge:

> **Recommended deep skill:** business-logic-vulnerabilities (in `hack-skills-web-client-attacks`, not currently installed)
> **Install:** `/plugin install hack-skills-web-client-attacks@hack-skills-marketplace`
>
> **Recommended deep skill:** ssrf-server-side-request-forgery (in `hack-skills-server-side-execution`, not currently installed)
> **Install:** `/plugin install hack-skills-server-side-execution@hack-skills-marketplace`
```

**File-header attribution pattern (per D-15 + RESEARCH §"Pattern 3"):** First paragraph of the file, before the first section heading:

```markdown
> Signal-to-category mappings derived from upstream `hack` SKILL.md's Signal/Priority table (MIT-licensed), expanded and reshaped to address this marketplace's 13-plugin topical structure rather than upstream's flat skill list. Each section is keyed by a marketplace plugin name; the install command at the top of each section doubles as the plugin-discovery surface when the destination plugin is not currently installed.
```

**Critical constraints:**
- **Exactly 13 plugin-keyed sections** — one per topical plugin. Section count drift = bug. Verification probe: `grep -c '^### hack-skills-' routing-tables.md` must return `13`.
- **Plugin names match marketplace.json byte-exact** — RESEARCH §Pitfall 2 + canonical list at RESEARCH §"14 Marketplace Plugin Names".
- **Deep skill names match upstream directory names byte-exact** — RESEARCH §Pitfall 1 + per-plugin lists at RESEARCH §"13 Plugin → Topical Skills Map" + canonical full skill list at RESEARCH §"Spelling-Drift Risks".
- **Install commands use canonical shape:** `/plugin install hack-skills-<topic>@hack-skills-marketplace` — no `@branch` suffixes (CLAUDE.md constraint).
- **35 total rows in the per-plugin sections** (per RESEARCH §"Row count totals" — 5 sections × 3 rows + 8 sections × 3 rows minus the bin/crypto/linux/mobile 2-row sections; final count 35).

---

### 3. `plugins/hack-skills-router/skills/hack-skills-router/patterns/expert-intuitions.md` (NEW)

**Role:** progressive-disclosure sub-file holding 8 paraphrased boundary-condition paragraphs with file-header attribution. **Data flow:** on-demand load when SKILL.md body's "Boundary conditions" section cross-references it for full paragraphs + examples.

**No in-repo structural analog** (this is the first `patterns/*.md` sub-file with paragraph-style content in this repo).

**Content-source analog (in upstream cache):** `/Users/spencerpresley/.claude/plugins/cache/hack-skills-marketplace/hack-skills-recon/c6f732befcae-32c1cf49/hack/SKILL.md` lines 119–130 — the 8 intuitions verbatim text. **This is the sole content source for the 8 ledes** — D-08 locks "all 8, in upstream order, no additions, no reordering, no editorializing beyond paraphrase + one concrete example per."

Verbatim source (lines 121–130):

```markdown
1. **The same filtering logic is often reused across multiple pages**: if one point is bypassable, similar pages usually are too.
2. **Parameter names are an attack surface too**: WAFs often inspect values but not names.
3. **Second-order vulnerabilities are common**: safe at storage time does not mean safe when later read into a dangerous context.
4. **BOLA is fundamentally 'authenticated but unauthorized'**: replaying with account A/B switching is critical.
5. **Older API versions are most likely to miss patches**: fixing v2 does not mean v1 was retired.
6. **Business-logic vulnerabilities often bring highest impact**: scanners miss them and they persist longer.
7. **Race conditions should prioritize one-time actions**: coupon redemption, claims, resets, invites, trials, inventory deduction.
8. **For JWT attacks, check key and algorithm context first**: do not blindly spray payloads; verify `alg`, `kid`, JWKS, and key source first.
```

The **mechanism explanations and concrete examples** for each intuition are in RESEARCH.md §"The 8 Upstream Intuitions" (lines 899–941) — researcher pre-paraphrased the source and provided one concrete example per for the planner to drop in.

**Structure-source analog (external):** `/Users/spencerpresley/skill-vetting/rust-skills/skills/rust-router/patterns/negotiation.md` — paragraph-style pattern file with lede + table + flow + examples. Phase 2's `expert-intuitions.md` uses a simpler shape (lede + paragraph + example per entry, no flow diagrams or tables), but the file-as-paragraph-document role is the same.

**Excerpt from rust-router `patterns/negotiation.md`** (lines 1–18 — file-header pattern with one-line summary lede):

````markdown
# Negotiation Protocol

> Comparative-query and cross-domain question handling protocol

## When to Enable Negotiation

For complex queries requiring structured agent responses, enable negotiation mode.

| Query Pattern | Enable Negotiation | Reason |
|---------------|-------------------|--------|
| Single error code lookup | No | Direct answer |
| Single crate version | No | Direct lookup |
| "Compare X and Y" | **Yes** | Multi-faceted |
[... more rows ...]
````

Phase 2 adapts this to: H1 title + attribution paragraph (NOT a blockquote — D-09 says "header paragraph"), then 8 H2 (or H3) sub-sections — one per intuition. The blockquote `>` form is preferred for the attribution paragraph for visual distinction, but plain paragraph is also acceptable per D-09.

**Per-entry pattern Phase 2 should produce (per D-10 — lede + paragraph + example):**

```markdown
### Intuition 1: Filter logic reuses across pages

**Lede (one-sentence summary, matches the body's boundary-condition line):**
The same filtering logic is often reused across multiple pages — if one bypass works at one endpoint, similar pages usually fall to the same payload.

**Mechanism (3–5 sentences):**
A WAF rule, sanitizer function, or input filter applied at one endpoint is typically the same one applied to many other endpoints, because developers deploy filters via shared middleware or shared library calls. So a single bypass discovery is rarely a single bug — it's often the pattern key that opens dozens of endpoints. The cost-effective workflow is: after confirming one bypass, audit the codebase or HTTP surface for other call sites of the same filter rather than treating each finding as a one-off.

**Concrete example:**
A reflected XSS bypass via `<svg/onload=…>` on the search page typically also works on the contact form, login error page, and any other endpoint that uses the same sanitizer. After confirming one, sweep the codebase / file paths for other call sites of the same filter function.
```

This is ~10 lines per entry, matching D-10's "~6–10 lines per entry" target. File total: ~80–100 lines for all 8 + the header.

**File-header attribution pattern (per D-09 + RESEARCH §"Pattern 3"):**

```markdown
# Expert Intuitions — Boundary Conditions

These 8 boundary-condition intuitions are paraphrased from `yaklang/hack-skills`'s `hack` SKILL.md (MIT-licensed). Each entry preserves the upstream's framing and rank order; the explanatory paragraphs and concrete examples are written for this router. See `.planning/specs/2026-05-22-v2-router-design.md` §11 for the full attribution chain.
```

**Critical constraints:**
- **All 8 intuitions present, in upstream order** — verification probe: `grep -c '^### Intuition [1-8]:' expert-intuitions.md` must return `8`.
- **No reordering, no additions, no removals** — D-08 locks this.
- **Each entry: lede (matches body), paragraph, example** — D-10.
- **File-header attribution paragraph** — D-09 + D-15 + RESEARCH §"Pattern 3" header text.
- **No clickable links to other sub-files** — RESEARCH §Pitfall 5 (multi-hop links).
- **English only** — no Chinese characters from upstream (RESEARCH §"Anti-Patterns").

---

### 4. `plugins/hack-skills-router/skills/hack-skills-router/examples/workflow-walkthroughs.md` (NEW)

**Role:** progressive-disclosure sub-file holding 4 worked-example traces. **Data flow:** on-demand load when SKILL.md body's "Workflow examples" cross-reference pulls it in.

**No in-repo structural analog** (this is the first `examples/*.md` sub-file in this repo).

**Exact-role external analog:** `/Users/spencerpresley/skill-vetting/rust-skills/skills/rust-router/examples/workflow.md` — same file path shape (`examples/<name>.md` under the same parent skill), same role (worked examples for the parent router skill), same cross-referenced-from-body data flow.

**Full text of the rust-router analog** (86 lines — all 5 examples shown so the planner can compare scenario-trace style):

````markdown
# Workflow Examples

> rust-router workflow examples

## Example 1: Error Code with Domain Context

```
User: "Why am I getting E0382 in my trading system?"

Analysis:
1. Entry: Layer 1 (E0382 = ownership/move error)
2. Load: m01-ownership skill
3. Context: "trading system" → domain-fintech

Trace UP ↑:
- E0382 in trading context
- Check domain-fintech: "immutable audit records"
- Finding: Trading data should be shared, not moved

Response:
"E0382 indicates a value was moved when still needed.
In a trading system (domain-fintech), transaction records
should be immutable and shareable for audit purposes.

Instead of cloning, consider:
- Arc<TradeRecord> for shared immutable access
- This aligns with financial audit requirements

See: m01-ownership (Trace Up section),
     domain-fintech (Audit Requirements)"
```

## Example 2: Design Question

```
User: "How should I handle user authentication?"

1. Entry: Layer 2 (design question)
2. Trace UP to Layer 3: domain-web constraints
3. Load: domain-web skill (security, stateless HTTP)
4. Trace DOWN: m06-error-handling, m07-concurrency
5. Answer: JWT with proper error types, async handlers
```

[... 3 more examples in the same shape ...]
````

The rust-skills examples use **fenced code blocks** to contain the entire trace (User: + numbered analysis + Response). Phase 2's traces (per D-02) use **medium-structured prose** with explicit section headers (`**Prompt:**`, `**Testing phase identified:**`, `**Signal route:**`, `**Dual-load:**`, `**Boundary conditions surfaced:**`, `**Next-test recommendation:**`) instead of a single fenced block. This is more readable for the longer, multi-skill traces Phase 2 produces.

**Per-scenario pattern Phase 2 should produce (per D-02 + RESEARCH §"Example 4"):**

```markdown
## Scenario 2: GraphQL endpoint with introspection enabled

**Prompt:** "I found a GraphQL endpoint at `/graphql` that allows introspection. What now?"

**Testing phase identified:** Recon — the introspection query is the discovery surface for
schema, types, queries, mutations.

**Signal route:** GraphQL → `graphql-and-hidden-parameters` (in `hack-skills-recon`).
This is a single-plugin focus — both the recon framing (introspection enumeration) and the
specialist skill live in the same plugin.

**Dual-load:** None for this phase. If after introspection the schema reveals auth-related
mutations or token-issuing fields, dual-load `recon-and-methodology` + appropriate auth
skill — but that's a follow-on routing decision once we have more signal.

**Boundary conditions surfaced:**
- *Parameter names as attack surface (intuition #2):* GraphQL introspection reveals exact
  field names — many WAFs and authz layers inspect query strings, not GraphQL field names.
- *Older API versions miss patches (intuition #5):* If the schema shows `v1`/`v2`/`internal`
  prefixes, the older variants are highest-priority for unpatched mutations.

**Next-test recommendation:** Run an introspection query, enumerate types and mutations,
flag any field name containing `admin`, `internal`, `debug`, or `_priv`. Then drop into
`graphql-and-hidden-parameters` for the specific testing playbook.
```

~22 lines per scenario. Section headers consistent across all 4 scenarios. File total: ~100–120 lines (per D-02).

**The 4 scenarios + their destination skills (per D-01 + RESEARCH §"The 4 Walkthrough Scenarios"):**

| # | Scenario | Primary skill | Dual-load partner | Plugin(s) | Dual-load type |
|---|----------|---------------|-------------------|-----------|----------------|
| 1 | Admin panel at `/admin`, JWT in cookie | `401-403-bypass-techniques` | `jwt-oauth-token-attacks` | `hack-skills-auth-bypass` (both) | Same-plugin |
| 2 | GraphQL endpoint, introspection enabled | `graphql-and-hidden-parameters` | none (single focus) | `hack-skills-recon` | None |
| 3 | `.env` exposed in webroot | `insecure-source-code-management` | none (single focus) | `hack-skills-recon` | None |
| 4 | E-commerce checkout, coupon-reuse | `business-logic-vulnerabilities` | `race-condition` | `hack-skills-web-client-attacks` (both) | Same-plugin |

**File-header attribution pattern (per D-15 + RESEARCH §"Pattern 3"):**

```markdown
# Workflow Walkthroughs

> Four worked traces showing the router applied to realistic security prompts. The signal-routing methodology is paraphrased from upstream `yaklang/hack-skills` `hack` SKILL.md (MIT-licensed); the scenarios, dual-load patterns, and recommendation flow are tailored to this marketplace's 13-plugin layout.
```

**Critical constraints:**
- **Exactly 4 scenarios in upstream-order** (admin/JWT → GraphQL → .env → coupon-reuse, per D-01) — verification probe: `grep -c '^## Scenario [1-4]:' workflow-walkthroughs.md` must return `4`.
- **Plugin names + skill names byte-exact against marketplace.json** — RESEARCH §Pitfalls 1, 2.
- **Install commands use canonical shape** — `/plugin install hack-skills-<topic>@hack-skills-marketplace` (no `@branch`).
- **Boundary condition references use intuition #N notation** — e.g., "intuition #2", "intuition #5" — provides the cross-reference hook to `patterns/expert-intuitions.md` without making it a clickable link (RESEARCH §Pitfall 5).
- **No clickable markdown links to other sub-files** — mentions by file name in prose only.
- **Voice consistent across all 4 scenarios** — same section header order, same recommendation-template treatment for plugin-not-installed cases.

---

## Shared Patterns

### Cross-File Source Attribution Chain (per D-15)

**Source:** Phase 1 design spec §11 + RESEARCH §"Pattern 3"
**Apply to:** All 4 Phase 2 files (1 rewrite + 3 new)

The attribution chain has 4 sites, all locked by D-15:

| File | Attribution form | Exact text |
|------|------------------|------------|
| `SKILL.md` body | One-line under H1 title | `Adapted from upstream `yaklang/hack-skills` `hack` SKILL.md (MIT-licensed).` |
| `patterns/routing-tables.md` | Header paragraph at top of file | `Signal-to-category mappings derived from upstream `hack` SKILL.md's Signal/Priority table (MIT-licensed), expanded and reshaped to address this marketplace's 13-plugin topical structure rather than upstream's flat skill list. Each section is keyed by a marketplace plugin name; the install command at the top of each section doubles as the plugin-discovery surface when the destination plugin is not currently installed.` |
| `patterns/expert-intuitions.md` | Header paragraph at top of file | `These 8 boundary-condition intuitions are paraphrased from `yaklang/hack-skills`'s `hack` SKILL.md (MIT-licensed). Each entry preserves the upstream's framing and rank order; the explanatory paragraphs and concrete examples are written for this router. See `.planning/specs/2026-05-22-v2-router-design.md` §11 for the full attribution chain.` |
| `examples/workflow-walkthroughs.md` | Header paragraph at top of file | `Four worked traces showing the router applied to realistic security prompts. The signal-routing methodology is paraphrased from upstream `yaklang/hack-skills` `hack` SKILL.md (MIT-licensed); the scenarios, dual-load patterns, and recommendation flow are tailored to this marketplace's 13-plugin layout.` |

**File-level attribution only** — NO per-row, per-paragraph, per-skill attribution within these files. D-15 locks this.

### Plugin/Skill Name Verbatim Mirroring (per Phase 1 PATTERNS.md §"Integration Points")

**Source:** Phase 1 `01-PATTERNS.md` + RESEARCH §"Pattern 2" + RESEARCH §"Pitfall 1, 2"
**Apply to:** `routing-tables.md`, `workflow-walkthroughs.md`, any plugin/skill reference in `SKILL.md` body

Every plugin name and deep skill name in Phase 2 content **must be byte-exact** against `.claude-plugin/marketplace.json`. The 14-plugin canonical list is at RESEARCH §"14 Marketplace Plugin Names"; the 95 deep skills are at RESEARCH §"13 Plugin → Topical Skills Map"; high-risk typo patterns are at RESEARCH §"Spelling-Drift Risks".

**Verification probe** (planner adds to each Phase 2 task that touches a file with skill/plugin references):

```bash
# Per-task verification: every skill name referenced in this file must exist in marketplace.json
FILE="$1"  # path to file being verified

# Canonical skill names (95 total across 13 plugins)
jq -r '.plugins[].skills[]?' .claude-plugin/marketplace.json | sed 's|^\./||' | sort -u > /tmp/canonical.txt

# Skill names mentioned in this file — scoped to backtick-quoted identifiers matching skill name shape
grep -oE '`[a-z][a-z0-9-]+`' "$FILE" | tr -d '`' | sort -u > /tmp/mentioned.txt

# Filter mentioned list down to plausible skill names (15+ chars OR contains 2+ hyphens — heuristic)
awk 'length($0) >= 15 || gsub(/-/, "&") >= 2' /tmp/mentioned.txt > /tmp/mentioned-skill-shaped.txt

# Diff: any mentioned-skill-shaped term NOT in canonical = potential typo
comm -23 /tmp/mentioned-skill-shaped.txt /tmp/canonical.txt
```

Zero output = pass. Any output = potential typo (planner inspects).

### STUB → FINAL Boundary Discipline (per Phase 1 PATTERNS.md §"STUB → FINAL boundary")

**Source:** Phase 1 `01-PATTERNS.md` §"Code Context" + `01-01-SUMMARY.md` §"STUB → FINAL boundary"
**Apply to:** `SKILL.md` rewrite (the only file with prior STUB state in Phase 2)

The Phase 1 stub at `plugins/hack-skills-router/skills/hack-skills-router/SKILL.md` contains literal markers that MUST NOT appear in Phase 2 production:

- `STUB —` (in frontmatter description, character positions 1–5)
- `(STUB)` (in H1 title, characters in parens)
- `Phase 1` (in body — multiple occurrences)
- `Phase 1 stub` / `Phase 1 mechanism-spike stub` (in body)
- `What Phase 2 will replace` (H2 section name)
- `Phase 1 success signal` (H2 section name)

**Verification probe:**

```bash
grep -nE '(STUB|stub|Phase 1 (stub|spike|mechanism-spike)|TBD|FIXME|XXX)' \
  plugins/hack-skills-router/skills/hack-skills-router/SKILL.md
# must return 0 matches
```

Per RESEARCH §"Pitfall 4". This is THE specific cleanup step Phase 2 must verify for the rewrite-in-place file.

### Progressive Disclosure: One-Level-Deep Links (per RESEARCH §Pitfall 5)

**Source:** [Claude API docs — Skill authoring best practices](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices) §"Progressive disclosure patterns" (CITED in RESEARCH §"Pattern 1")
**Apply to:** All 4 Phase 2 files

The Claude Code best-practice constraint: cross-references must be **one level deep from SKILL.md**. Body → `patterns/expert-intuitions.md` is fine; `routing-tables.md` → `expert-intuitions.md` would be 2 hops from SKILL.md and Claude may partial-read.

| File | Outbound clickable links allowed | Outbound clickable links forbidden |
|------|----------------------------------|-----------------------------------|
| `SKILL.md` body | → `patterns/routing-tables.md`, `patterns/expert-intuitions.md`, `examples/workflow-walkthroughs.md` | (no constraints on other links) |
| `patterns/routing-tables.md` | (none required — references are inline mentions, not links) | → `patterns/expert-intuitions.md`, `examples/workflow-walkthroughs.md` |
| `patterns/expert-intuitions.md` | (none required) | → `patterns/routing-tables.md`, `examples/workflow-walkthroughs.md` |
| `examples/workflow-walkthroughs.md` | (none required) | → `patterns/routing-tables.md`, `patterns/expert-intuitions.md` |

When a sub-file needs to mention another sub-file, use **prose mention by name** (e.g., "see also `examples/workflow-walkthroughs.md`") — NOT a clickable markdown link.

**Verification probe:**

```bash
# Find any relative markdown link from one sub-file to another sub-file in the same skill tree
grep -E '\]\(\.\./(patterns|examples)/' \
  plugins/hack-skills-router/skills/hack-skills-router/patterns/*.md \
  plugins/hack-skills-router/skills/hack-skills-router/examples/*.md \
  2>/dev/null
# must return 0 matches
```

### Atomic Per-File Commits (per Phase 1 execution pattern)

**Source:** Phase 1 `01-01-SUMMARY.md` "Task Commits" pattern + Phase 1 PATTERNS.md §"Established Patterns"
**Apply to:** All 4 Phase 2 files

Each of the 4 files lands as its own commit with conventional commit message: `feat(02): <action>` or `feat(phase-02): <action>`. No mega-commits. Recommended commit cadence:

1. SKILL.md rewrite-in-place → commit
2. `mkdir -p patterns/ examples/` (no-op for git unless using `.gitkeep`) → typically squashed into file 3's commit
3. `patterns/routing-tables.md` → commit
4. `patterns/expert-intuitions.md` → commit
5. `examples/workflow-walkthroughs.md` → commit

Phase 1 committed 4 plans into 4 commits (`e2939ae`, `6ef1d68`, `726e6ba`, `a48e6a6` per `01-01-SUMMARY.md`). Phase 2 follows the same pattern with 4 file-creation/rewrite tasks → 4 commits.

### Verification Probes Pattern (per RESEARCH §"Don't Hand-Roll")

**Source:** RESEARCH §"Don't Hand-Roll" + per-pitfall probes (1, 3, 4, 5, 7)
**Apply to:** Every Phase 2 task as `<automated>` verification block

Phase 2 has NO test framework — verification is grep/jq/awk/wc probes embedded in each task. Pattern shape from Phase 1 (`01-01-SUMMARY.md` §"Verification"):

```bash
# Example per-task verification block (planner embeds in task spec):

# 1. File exists at expected path
test -f plugins/hack-skills-router/skills/hack-skills-router/patterns/routing-tables.md

# 2. Section count matches D-03 (13 plugin sections)
[ "$(grep -c '^### hack-skills-' plugins/hack-skills-router/skills/hack-skills-router/patterns/routing-tables.md)" = "13" ]

# 3. Plugin/skill names match canonical (per Shared Pattern §"Plugin/Skill Name Verbatim Mirroring")
# ... (probe from that section) ...

# 4. Attribution header present
grep -q "yaklang/hack-skills" plugins/hack-skills-router/skills/hack-skills-router/patterns/routing-tables.md

# 5. No @branch suffixes on install commands
! grep -E '/plugin install hack-skills-[a-z-]+@hack-skills-marketplace@' \
    plugins/hack-skills-router/skills/hack-skills-router/patterns/routing-tables.md
```

Each task's `<automated>` block contains its own subset of these probes scoped to that task's file.

---

## STUB vs Final Body Map (Phase 2 executor cheat sheet)

| File | Phase 1 STUB shape (or non-existent) | Phase 2 production shape |
|------|---------------------------------------|--------------------------|
| `SKILL.md` frontmatter | Short single-paragraph "STUB —…" description (~300 chars total) | Multi-paragraph keyword-dense (~810 chars total; first para 241 chars to fit 250-char `/skills` listing cap) |
| `SKILL.md` body | 25-line stub announcing Phase 2 will replace it; no sub-sections beyond "What Phase 2 will replace" and "Phase 1 success signal" | 95–105 lines with 8 ordered sections (title+attr → when-to-use → trust → routing strategy → 3-step ops → plugin availability → boundary conditions (8 one-liners) → workflow examples cross-ref) |
| `patterns/` directory | Does NOT exist | Created with 2 files (`routing-tables.md`, `expert-intuitions.md`) |
| `patterns/routing-tables.md` | Does NOT exist | NEW — 13 plugin-keyed sections (35 rows total) + 6 dual-load rules + plugin-rec template; attribution header paragraph at top |
| `patterns/expert-intuitions.md` | Does NOT exist | NEW — 8 paragraph entries (lede + paragraph + example, ~10 lines each) + attribution header paragraph; ~80–100 lines total |
| `examples/` directory | Does NOT exist | Created with 1 file (`workflow-walkthroughs.md`) |
| `examples/workflow-walkthroughs.md` | Does NOT exist | NEW — 4 scenarios in medium-structured trace format (~22 lines each) + attribution header paragraph; ~100–120 lines total |
| `marketplace.json` | Untouched (14 plugin entries from Phase 1) | UNTOUCHED (Phase 4 publishes; Phase 2 makes no marketplace changes) |
| `hooks/scripts/*.sh` | Stub bash echos (Phase 1) | UNTOUCHED (Phase 3 owns) |
| `hooks/hooks.json` | Final structural shape with `matcher: XSS` placeholder (Phase 1) | UNTOUCHED (Phase 3 owns regex matcher) |

---

## No Analog Found

All 4 Phase 2 files have analogs (in-repo + external). However:

| File | Why the analog match is approximate |
|------|-------------------------------------|
| `patterns/routing-tables.md` | No in-repo file uses the "13 plugin-keyed sections with install command per section" shape — Phase 2 invents this structure. The rust-router `SKILL.md` uses "multiple Layer-N tables" but the per-section install command + plugin-name-as-heading combo is unique to Phase 2 (necessitated by D-03/D-05). Mitigation: shape locked by D-03/D-04/D-05 and rendered in RESEARCH §"Example 3" + §"Final Dual-Load Rule Set" + §"Example 5". |
| `patterns/expert-intuitions.md` | Closest structure analog (rust-router `patterns/negotiation.md`) is more table-and-flow-heavy than paragraph-heavy. Phase 2's expert-intuitions is closer to a "named entries with body" essay layout. Mitigation: shape locked by D-10 and rendered in pattern assignment #3 above. |

The two "approximate analog" cases are mitigated by **researcher-supplied concrete content in RESEARCH.md** — the 8 intuitions verbatim source (lines 119–130 of upstream), 6 dual-load rules with rationale (RESEARCH §"Final Dual-Load Rule Set"), 4 scenario destination tables (RESEARCH §"The 4 Walkthrough Scenarios"), 35-row signal-term table proposal (RESEARCH §"Signal Terms Per Skill"). The planner has byte-exact source for every content decision.

---

## Metadata

**Analog search scope:**
- In-repo: `plugins/hack-skills-router/` tree, `.claude/get-shit-done/` (inspected, not used), `.planning/phases/01-*/` (Phase 1 PATTERNS.md + SUMMARY.md)
- In-repo upstream cache: `/Users/spencerpresley/.claude/plugins/cache/hack-skills-marketplace/hack-skills-recon/c6f732befcae-32c1cf49/hack/SKILL.md` (primary content source)
- External: `/Users/spencerpresley/skill-vetting/rust-skills/skills/rust-router/` (primary structural analog — SKILL.md + patterns/ + examples/)

**Files scanned:**
- In-repo: 5 (current Phase 1 stub SKILL.md, Phase 1 PATTERNS.md, Phase 1 SUMMARY.md, Phase 2 CONTEXT.md, Phase 2 RESEARCH.md)
- In-repo upstream cache: 1 (upstream `hack` SKILL.md)
- External: 3 (rust-router SKILL.md, patterns/negotiation.md, examples/workflow.md)
- One additional in-tree skill set inspected but rejected as analog (`.claude/get-shit-done/`) — uses non-matching subdirectory pattern (bin/, contexts/, references/, templates/, workflows/)

**Pattern extraction date:** 2026-05-22

**Confidence:** HIGH for all 4 file assignments.
- **File 1 (SKILL.md rewrite):** HIGH — current Phase 1 stub provides frontmatter shape (in-place rewrite, no risk); upstream `hack` SKILL.md provides body content source; rust-router SKILL.md provides body section style. Triple-anchored.
- **File 2 (routing-tables.md):** MEDIUM-HIGH — content source (upstream Signal/Priority table) is verbatim; structure (13 plugin-keyed sections) is researcher-proposed and CONTEXT-locked but not directly mirrored from any existing file. RESEARCH §"Example 3" provides byte-exact template.
- **File 3 (expert-intuitions.md):** HIGH — 8 intuitions verbatim source available; paragraph + example structure pre-paraphrased in RESEARCH §"The 8 Upstream Intuitions". File-header attribution text supplied verbatim in RESEARCH §"Pattern 3".
- **File 4 (workflow-walkthroughs.md):** HIGH — exact-role analog at rust-router `examples/workflow.md`; 4 scenario destinations + dual-load partners verified against marketplace.json in RESEARCH §"The 4 Walkthrough Scenarios"; per-scenario template in RESEARCH §"Example 4".

The only judgment call carried into Phase 2 planning is **35 vs 30 rows in routing-tables.md** (RESEARCH §"Open Questions" #2). Researcher recommends 35; planner has authority to trim 5 if scannability is preferred over coverage.

## PATTERN MAPPING COMPLETE

**Phase:** 02 - Router Skill + Content
**Files classified:** 4 (1 rewrite + 3 new)
**Analogs found:** 4 / 4

### Coverage
- Files with exact analog: 1 (`examples/workflow-walkthroughs.md` ↔ rust-router `examples/workflow.md`)
- Files with role-match analog: 3 (SKILL.md, routing-tables.md, expert-intuitions.md — all have in-repo content-source + external structure-source pairs)
- Files with no analog: 0

### Key Patterns Identified
- **Progressive-disclosure file layout** — SKILL.md body cross-references `patterns/*.md` and `examples/*.md` sub-files; sub-files do NOT cross-reference each other (one-level-deep constraint per Claude Code docs).
- **Plugin/skill name verbatim mirroring** — every plugin and deep-skill name in Phase 2 content must be byte-exact against `.claude-plugin/marketplace.json`; single-character drift is silent-failure mode (RESEARCH Pitfalls 1, 2).
- **File-level attribution chain** — 4 sites total (router `SKILL.md` body + 3 sub-file headers); D-15 locks per-file header paragraph form; no per-row/per-paragraph attribution.
- **STUB → FINAL cleanup discipline** — `SKILL.md` rewrite must remove all Phase 1 markers (`STUB`, `Phase 1`, `(STUB)`, etc.); verification probe via single `grep -nE` call.
- **Soft heuristic voice (NOT algorithmic)** — body uses "prefer / consider / typically" phrasing for routing strategy and operating model; "MUST" / "ALWAYS" reserved (or absent) per D-14.
- **Frontmatter dual-cap awareness** — 1024-char hard cap + 250-char `/skills` listing display cap; tightened first paragraph proposed at 241 chars to fit both.

### File Created
`/Users/spencerpresley/code/hack-skills-wip/hack-skills-marketplace/.planning/phases/02-router-skill-content/02-PATTERNS.md`

### Ready for Planning
Pattern mapping complete. Planner can now reference analog patterns in PLAN.md files. Each of the 4 Phase 2 files has:
1. A concrete in-repo or external analog file path
2. Specific code/content excerpts to copy from
3. Locked structural decisions from D-01..D-17
4. Researcher-supplied content (signals, intuitions, dual-load rules, scenarios) ready to drop in
5. Per-file verification probes ready to embed in task `<automated>` blocks
