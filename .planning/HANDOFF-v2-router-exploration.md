# Handoff: v2 Router + Hook + Progressive Disclosure Design Exploration

**Audience:** Future me in a fresh session.
**Status:** Exploration / pre-brainstorm. Nothing committed except this file.
**Created:** 2026-05-22

---

## 1. What you're being asked to do

The user wants to explore a v2 design for this marketplace that uses a **`UserPromptSubmit` hook + a top-level router skill + progressive disclosure**, instead of the current v1 design (13 pre-curated topical plugins).

**Do not start implementing.** This is a design exploration. Brainstorm, draft an approach, and align with the user before touching any code or marketplace.json. Consider invoking `/gsd:explore` or the `brainstorming` superpower skill for the design conversation.

The user explicitly said: **"we would need to do that part ourself"** — meaning the router is something **we** write, not the upstream's `hack` / `*-sec` skills. So plan for a custom router, not for extending the upstream's existing router model. (The upstream's router skills are currently excluded from the v1 marketplace — see §4 below.)

---

## 2. Project context (read these FIRST in this order)

Read top-to-bottom; these are short and load-bearing:

1. **`PROJECT.md`** — the project charter. Pay attention to:
   - "Core Value: Selective topical activation"
   - The Constraints section (source immutability, install command shape, group sizing, grouping axis)
   - These constraints still apply to v2; the exploration may *reshape* how they're satisfied but cannot violate them.

2. **`CLAUDE.md`** — project-specific Claude guidelines.

3. **`.planning/ROADMAP.md`** — what's planned vs done. As of this handoff:
   - Phase 1 (Schema Verification) — ✓ complete
   - Phase 2 (Skill Classification & Taxonomy) — ✓ complete
   - Phase 3 (Marketplace Build-Out) — ✓ complete (13 plugins shipped)
   - Phase 4 (Publish & Live Validation) — pending; **this exploration may inform whether we ship v1 as-is then iterate to v2, or pivot before publish**

4. **`.planning/STATE.md`** — current position snapshot.

5. **`.planning/phases/03-marketplace-build-out/03-01-SUMMARY.md`** — what shipped in Phase 3 (the 13-plugin manifest). Includes the `hack-skills-routers` exclusion decision.

6. **`.planning/phases/03-marketplace-build-out/03-VERIFICATION.md`** — Phase 3 SC mapping with evidence (proves the v1 design works end-to-end locally).

7. **`.claude-plugin/marketplace.json`** — the shipped v1 manifest. 13 plugins, derived from `02-CLASSIFICATION.json`.

---

## 3. The design question, restated

**v1 (shipped):**
- 13 plugins, one per non-router topical bucket from Phase 2.
- Each plugin loads 3–12 skills' SKILL.md descriptions into the session's always-on context.
- User picks which plugins to install based on what they're working on today.
- Solves "context bloat from 102 skills" by **pre-curation**.

**v2 (exploration target):**
- A few plugins (likely 1–3, not 13), each containing **all** topical skills + a router + a hook.
- Hook fires on `UserPromptSubmit`, matches security-task keywords, runs a script that injects routing instructions into Claude's context.
- Router skill decides which deep topical skill(s) actually load for the current task.
- Deep skills are marked `user-invocable: false` so they don't auto-load — only the router pulls them in.
- Progressive disclosure: keep `SKILL.md` descriptions terse; move payloads/examples/playbooks into sub-files (`examples/`, `patterns/`, etc.) loaded on demand.
- Solves "context bloat" by **routing**, not pre-curation.

**Why v2 is worth exploring:**
- Today, installing `hack-skills-auth-bypass` loads all 9 auth-bypass skill descriptions into always-on context regardless of whether you're testing JWT, IDOR, or SAML.
- With a router, you'd load the router (cheap) and let it pick the one specific deep skill that matches your task. Much smaller always-on footprint per session.
- The marketplace activation model becomes "install routing for security work" rather than "install these 9 specific skills."

**Tradeoffs to think about (the user already raised these — don't relitigate, just be aware):**
- Hook complexity. A `UserPromptSubmit` hook runs a shell script every prompt. Maintenance burden of the regex is real.
- For security tasks, file-glob activation is weak (no `Cargo.toml` equivalent), so the hook does most of the activation work — its regex carries design weight.
- Custom router vs extending upstream's `hack` router — user said custom.

---

## 4. The reference design: rust-skills

The user pointed at `/Users/spencerpresley/skill-vetting/rust-skills` as the inspiration. **Re-read these before drafting v2:**

| File | Why it matters |
|------|---------------|
| `/Users/spencerpresley/skill-vetting/rust-skills/README.md` | Top-level explanation of the meta-cognition model |
| `/Users/spencerpresley/skill-vetting/rust-skills/skills/rust-router/SKILL.md` | The actual router skill — has the routing tables, layer model, dual-skill loading rules, output format. **This is the closest analog to what you'll be designing.** |
| `/Users/spencerpresley/skill-vetting/rust-skills/hooks/hooks.json` | The hook config (`UserPromptSubmit` matcher regex + command). |
| `/Users/spencerpresley/skill-vetting/rust-skills/.claude/hooks/rust-skill-eval-hook.sh` | The hook script that injects routing instructions. |
| `/Users/spencerpresley/skill-vetting/rust-skills/skills/m01-ownership/` | A "layer" skill showing progressive disclosure: terse `SKILL.md` + `patterns/`, `examples/` subdirs. |
| `/Users/spencerpresley/skill-vetting/rust-skills/skills/m01-ownership/SKILL.md` frontmatter | Note `user-invocable: false` — the layer skill is not surfaced directly; only the router pulls it. |
| `/Users/spencerpresley/skill-vetting/rust-skills/AGENTS.md`, `CLAUDE.md` | If they have project-level guidance about how the router and skills interact. |

Key takeaways from the rust-skills design (already absorbed; just for your re-orientation):

- **3-layer cognitive model**: Domain (WHY) → Design (WHAT) → Mechanics (HOW). For security work, the analog might be **Testing Phase → Vulnerability Category → Specific Technique**, which is exactly what the upstream's `hack` SKILL.md already articulates (see §5).
- **Dual-skill loading**: when a query has both a mechanics signal AND a domain signal, the router loads BOTH skills. The hack-skills analog: a query like "test JWT auth on this API" should load both an auth-flow skill and an API-recon skill.
- **`user-invocable: false`**: hides skills from direct invocation; the router gates access.
- **Globs in router frontmatter**: rust-router uses `globs: ["**/Cargo.toml", "**/*.rs"]` to activate passively. For security work, glob-based activation is harder — see §6.

---

## 5. The upstream context you need

The upstream `yaklang/hack-skills` already has a router model. Even though we excluded their router skills from v1, **read the upstream's `hack` SKILL.md** before designing — it documents their intended 3-stage flow, which is a strong reference even if we replace it:

- **Cached copy on disk:** `/Users/spencerpresley/.claude/plugins/cache/hack-skills-marketplace/hack-skills-recon/c6f732befcae-32c1cf49/hack/SKILL.md`
  - (The cache path's `hack-skills-recon` prefix is a v1 plugin name artifact, not relevant to v2.)
- The upstream's `hack` describes itself as "Entry P0 primary router" with a 4-step Operating Model: determine testing phase → select vulnerability category → trace to deep skill → prioritize boundary conditions AI often misses.
- The 7 router skills the user wants us to *replace*, not extend: `hack`, `api-sec`, `auth-sec`, `business-logic-vuln`, `file-access-vuln`, `injection-checking`, `recon-for-sec`. They live in the upstream repo and stay there — our router supersedes them in our marketplace.

Also re-read:
- **`.planning/phases/02-skill-classification-taxonomy/02-CLASSIFICATION.md`** — the topical taxonomy. The router needs to know about these buckets (active-directory-and-windows, auth-bypass, binary-exploitation, etc.) and route to skills within them.
- **`.planning/phases/02-skill-classification-taxonomy/02-CLASSIFICATION.json`** — same data, machine-readable. Useful as the router's source of truth for which skills belong to which topical area.
- **`.planning/phases/02-skill-classification-taxonomy/02-CLASSIFICATION.json` `skill_metadata` key** — per-skill verbatim descriptions from upstream. The router will need these to make routing decisions.

---

## 6. Specific design questions to think through (before talking to the user)

These are the things you should have a draft opinion on when you re-engage:

1. **What does the hook regex match on?**
   - rust-skills matched on language tokens (`Cargo.toml`, `tokio`, error codes `E0382`, etc.). For security, what's the analog? CVE patterns (`CVE-\d{4}-\d+`)? Tool names (`burp`, `nmap`, `sqlmap`)? Vulnerability terms (`XSS`, `SQLi`, `IDOR`)? URL/IP shapes? "Test this endpoint" / "find vulns in" phrasings? Authorization context (`pentest`, `bug bounty`)?
   - The regex carries design weight — too narrow and the router never fires; too broad and it fires on unrelated work.

2. **What's the hook script actually inject?**
   - rust-skills' hook injects a multi-section instruction block: identify entry layer, load BOTH layer skills, output a "Reasoning Chain" + "Negotiation Analysis" section. Do we want that level of forced output structure for security work, or something lighter?
   - The hook can also gate access (e.g., "this is authorized pentest context only — if not, refuse"). Worth considering for hack-skills given the dual-use security context.

3. **How does the router make routing decisions?**
   - Keyword-table approach (like rust-router's tables)? Or dynamic — load the taxonomy JSON and let Claude reason over it? Or a hybrid?
   - rust-router has explicit tables: `| Web API, HTTP, axum → m07-concurrency + domain-web |`. For hack-skills, the table would be: `| login flow, JWT, OAuth → auth-bypass.jwt-oauth-token-attacks |`. Building this table is most of the design work.

4. **Marketplace shape:**
   - One plugin with everything (`hack-skills-core`)? Two plugins (`hack-skills-core` + `hack-skills-extras` for low-frequency stuff)? Three (split by something other than topic)?
   - This depends on whether install-time choice still matters or routing handles all selection.

5. **Progressive disclosure file layout:**
   - Each topical skill's `SKILL.md` should stay tight (description + when-to-use). Detailed payloads/examples go into sub-files. Look at the rust-skills `m01-ownership/patterns/` and `m01-ownership/examples/` directories for the layout — what's the analog for, say, an injection skill? `payloads/`? `recon-steps/`?
   - We can't modify upstream files (Constraint: Source immutability), so progressive disclosure has to live in our marketplace repo, not in the skills themselves. **This is a meaningful constraint** — re-check how it affects the design.

6. **Compatibility with current v1:**
   - v1 ships 13 plugin names like `hack-skills-auth-bypass`. If anyone installs v1 between now and v2, do we keep those names as installable aliases? Deprecate them? Hard-cut?
   - This affects Phase 4 timing: ship v1 first then iterate, or hold Phase 4 and pivot directly to v2?

7. **Is this still v1.0 scope or a v2.0 milestone?**
   - PROJECT.md describes v1 as "selective topical activation." A router + hook is a *different* model of selective activation. It might be v1.0-still (just a more sophisticated implementation of the same core value) OR it might warrant a v2.0 milestone with its own ROADMAP.
   - The user's call. Be ready to recommend.

---

## 7. Things to NOT do

- **Don't start writing the hook script or router SKILL.md until the user has reviewed your design draft.**
- **Don't modify `.claude-plugin/marketplace.json` or anything in `.planning/phases/01..03/` — those are shipped artifacts.**
- **Don't fork the upstream `yaklang/hack-skills` repo or modify any cached upstream files** (PROJECT.md constraint: source immutability).
- **Don't auto-promote this to a new phase or milestone in ROADMAP.md** without explicit user direction. This is exploration; phase/milestone shape comes after the design has been aligned.

---

## 8. Suggested re-entry sequence

When you pick this up in a fresh session:

1. Read this handoff completely.
2. Read the §2 project context files in order.
3. Read the §4 rust-skills reference files. Take notes on what maps cleanly and what doesn't.
4. Read the upstream `hack` SKILL.md (§5) for the existing router model — it's a strong reference even though we're not extending it.
5. Skim §6 design questions and form a draft opinion on each.
6. Re-engage the user with: "Here's what I've absorbed. Here are the design questions and my draft answers. Where do you want to dig in first?"
7. If the conversation goes deep, consider invoking `/gsd:explore`, `/gsd:spike` (for a throwaway prototype), or the `brainstorming` superpower skill — but only once the user wants to commit to the next step.

---

## 9. State of the world at handoff time

- Branch: `main`
- Last commits (relevant):
  - `98df09a` docs(phase-03): add phase artifacts and close out in STATE/ROADMAP
  - `372af2a` feat(.claude-plugin): build full marketplace from Phase 2 taxonomy
- Working tree: clean except `.claude/` (untracked, local GSD tooling; ignored intentionally) and this handoff file.
- Local marketplace is registered (`claude plugin marketplace list` shows `hack-skills-marketplace` rooted at this repo). No v1 plugins are currently installed (the `hack-skills-mobile` smoke-test install was uninstalled in Phase 3).
- The marketplace is NOT yet pushed to GitHub (Phase 4 territory).

---

## 10. One-sentence summary

**Design (don't build) a router + hook + progressive-disclosure replacement for the current 13-plugin v1 marketplace, using `/Users/spencerpresley/skill-vetting/rust-skills` as the structural reference and a custom router (not the upstream's `hack`) as the directive — then align with the user before any code lands.**
