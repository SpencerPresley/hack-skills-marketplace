# Phase 1: Schema Verification - Pattern Map

**Mapped:** 2026-05-22
**Files analyzed:** 2
**Analogs found:** 2 / 2 (both partial — see notes)

<summary>
## Summary for Planner

This phase only touches two files. Both have analogs *external to this repo* — there is no prior precedent inside `hack-skills-marketplace/` because Phase 1 is the first executable phase.

1. **`.claude-plugin/marketplace.json`** — currently a zero-byte placeholder. **Exact-pattern analog exists** at `~/.claude/plugins/marketplaces/wondelai-skills/.claude-plugin/marketplace.json`: same `strict: false` + curated `skills` array of individual subdirectory paths, multiple plugins. Copy the *outer shape* from wondelai; replace plugin entries with the two from CONTEXT.md D-01. CRITICAL DIFFERENCE: wondelai uses `"source": "./"` (the marketplace IS the source repo); our plugins use `"source": { "source": "github", "repo": "yaklang/hack-skills" }` per CONTEXT.md D-03. Copy structure, not the source descriptor.

2. **`.planning/phases/01-schema-verification/01-VERIFICATION.md`** — no prior verification artifact exists in this repo (Phase 1 is the first). The GSD template at `.claude/get-shit-done/templates/verification-report.md` is a *structural* analog (frontmatter + table-driven evidence + status enum), but its axes (`Observable Truths`, `Required Artifacts`, `Key Link Verification`, `Anti-Patterns Found`) are tuned for application code verification, not for *observing CLI/runtime behavior of a developer tool against authored configuration*. CONTEXT.md D-06 prescribes a different per-VERIFY-question structure that should override the template's axes. The planner should borrow the template's *tone* and *frontmatter convention*, but invent the section bodies per D-06.

3. **Install/observe/uninstall command sequences** — not files, but reproducible procedures. The verbatim copy-source is RESEARCH.md Pattern 2 (lines 254–285) and Examples 3–5 (lines 444–548). The planner should copy these verbatim into the plan's action steps and into 01-VERIFICATION.md evidence blocks.

No "code patterns" in the traditional sense exist to copy from — this phase authors a JSON configuration file and produces a markdown report. The closest analogs are documented below with exact line refs.
</summary>

## File Classification

| New/Modified File | Role | Data Flow | Closest Analog | Match Quality |
|-------------------|------|-----------|----------------|---------------|
| `.claude-plugin/marketplace.json` | config (marketplace declaration) | declarative / read-once-at-install | `~/.claude/plugins/marketplaces/wondelai-skills/.claude-plugin/marketplace.json` | **Exact-pattern** for `strict: false` + curated `skills` array shape; **partial** for `source` descriptor (wondelai uses `"./"`, we use `github`) |
| `.planning/phases/01-schema-verification/01-VERIFICATION.md` | report / phase verification artifact | none (static markdown) | `.claude/get-shit-done/templates/verification-report.md` | **Partial** — structural template (frontmatter, tables, status enum) is borrowable; axes (`Observable Truths`, `Wiring`) don't fit observational verification of a CLI-driven configuration test. CONTEXT.md D-06 overrides axes. |

## Pattern Assignments

### `.claude-plugin/marketplace.json` (config, declarative)

**Analog:** `~/.claude/plugins/marketplaces/wondelai-skills/.claude-plugin/marketplace.json`
**Why this analog:** Same exact use-case the Phase 1 verification questions are testing — `strict: false` plus a `skills` array listing individual subdirectory paths, with multiple plugins in the same marketplace. Existence-proves the pattern at the runtime level (it's installed and working on this machine right now).
**Secondary reference:** `/Users/spencerpresley/.claude/plugins/cache/claude-plugins-official/plugin-dev/unknown/skills/plugin-structure/SKILL.md` — Anthropic's own documentation of marketplace/plugin schema. The `skills` array semantics are documented there (lines 165–199 describe skill directory structure, lines 100–107 describe path rules `must start with ./`).

**Top-level structure pattern** (wondelai lines 1–13):
```jsonc
{
  "$schema": "https://anthropic.com/claude-code/marketplace.schema.json",
  "name": "wondelai-skills",
  "description": "42 agent skills for product strategy, UX design, marketing, sales...",
  "owner": {
    "name": "Wondel.ai",
    "email": "hello@wondel.ai"
  },
  "metadata": {
    "description": "...",
    "version": "1.3.0"
  },
  "plugins": [
    ...
  ]
}
```

**Per-plugin entry pattern — the load-bearing part** (wondelai lines 14–34, plugin `product-strategy`):
```jsonc
{
  "name": "product-strategy",
  "description": "Product strategy and innovation frameworks including Jobs to Be Done ...",
  "version": "1.0.0",
  "author": { "name": "Wondel.ai", "url": "https://wondel.ai" },
  "homepage": "https://github.com/wondelai/skills",
  "repository": "https://github.com/wondelai/skills",
  "license": "MIT",
  "category": "productivity",
  "keywords": ["product-strategy", "jobs-to-be-done", "negotiation", "..."],
  "source": "./",
  "strict": false,
  "skills": [
    "./jobs-to-be-done",
    "./negotiation",
    "./mom-test"
  ]
}
```

**What to copy verbatim from this analog:**
- The `strict: false` + `skills: [...]` pairing. This is THE pattern under test.
- The `./skill-name`-with-leading-`./` path convention. Wondelai uses it for every entry across all 9 plugins (lines 30–33, 50–61, 78–84, 101–106, 122–130, 146–152, 169–171, 188–194, 211–217). RESEARCH.md Anti-Pattern (line 299) explicitly flags missing-`./` as invalid syntax.
- The shape of `plugins: [ {...}, {...}, ... ]` with each plugin as a self-contained object.
- The `$schema` line (helpful for editor validation; not required by runtime but harmless).

**What to NOT copy from this analog (intentional divergence per CONTEXT.md D-03):**
- `"source": "./"` — wondelai's marketplace repo IS the source for its plugins (skills live alongside marketplace.json in the same repo). Our marketplace points to an *external* repo (`yaklang/hack-skills`), so our `source` is `{ "source": "github", "repo": "yaklang/hack-skills" }` per CONTEXT.md D-03 and per the canonical research example.
- Skill paths in wondelai are relative to the marketplace root (`./jobs-to-be-done`). In our marketplace, skill paths are relative to **the plugin's source root** — i.e., the cloned `yaklang/hack-skills` repo. Since that repo organizes skills under `skills/`, our paths are `./skills/<skill-name>`. RESEARCH.md line 250 explicitly cites this.

**Definitive copy-source for the file body to author** — RESEARCH.md Example 1 (lines 401–431) is the literal target shape. It already merges the wondelai outer structure with the CONTEXT.md D-01 plugin entries and the D-03 `source` descriptor. The planner should treat that block as the authoritative target.

**Secondary references showing schema variation** (helpful for understanding the spec, not for copying):
- `~/.claude/plugins/marketplaces/rust-skills/.claude-plugin/marketplace.json` (lines 1–18) — minimal example, single-plugin marketplace, no `strict` field, no `skills` array. Demonstrates the "default" (strict-implicit) shape that we're *not* using.
- `~/.claude/plugins/marketplaces/omc/.claude-plugin/marketplace.json`, `~/.claude/plugins/marketplaces/claude-plugins-official/.claude-plugin/marketplace.json`, `~/.claude/plugins/marketplaces/openai-codex/.claude-plugin/marketplace.json` exist on this machine; the planner only needs to read them if a question arises about a specific field. Wondelai is the closest match and is sufficient.

---

### `.planning/phases/01-schema-verification/01-VERIFICATION.md` (report, static markdown)

**Analog:** `.claude/get-shit-done/templates/verification-report.md`
**Why this analog:** It's the GSD-convention template for phase-verification artifacts, lives in this repo's tooling, and provides a known-good frontmatter + table-driven evidence shape that the planner can lift directly. It is the ONLY pre-existing structural reference for "what does a phase VERIFICATION.md look like in this project."
**Caveat:** Its body axes are tuned for verifying application code (components, API routes, schema, wiring). Phase 1 verifies *runtime behavior of an external developer tool against an authored config file*. Different semantic surface. Borrow structure, replace axes.

**Borrowable from this analog (use as-is):**

Frontmatter shape (template lines 9–15):
```markdown
---
phase: 01-schema-verification
verified: 2026-05-22T..:..:..Z
status: passed | gaps_found | human_needed
score: N/M VERIFY questions resolved
---

# Phase 1: Schema Verification Report

**Phase Goal:** {from .planning/ROADMAP.md §Phase 1}
**Verified:** {timestamp}
**Status:** {passed | gaps_found | human_needed}
```

Table-driven evidence convention (template lines 27–32, 38–44) — evidence rendered as tables with `Status` + `Evidence` columns. This is the borrowable pattern for compact, scannable verification rows. Status values per template line 165: `passed | gaps_found | human_needed`.

Verification metadata footer (template lines 147–155):
```markdown
## Verification Metadata

**Verification approach:** {empirical / observational}
**Automated checks:** {N} passed, {M} failed
**Human checks required:** {N}
**Total verification time:** {duration}

---
*Verified: {timestamp}*
*Verifier: Spencer (manual)*  // NOT a subagent for Phase 1 — manual execution
```

**NOT borrowable — discard these axes from the template:**
- `Observable Truths` table (template lines 26–32) — designed for app-feature outcomes ("user can send message"); Phase 1's analog is the three VERIFY questions, which CONTEXT.md D-06 already prescribes as the section structure.
- `Required Artifacts` table (template lines 38–44) — designed for "did the file get created and is it real"; not relevant. Phase 1 produces only one config file plus the report itself.
- `Key Link Verification` (template lines 48–54) — wiring between code modules; no wiring in this phase.
- `Anti-Patterns Found` (template lines 67–73) — stub detection in app code; not relevant.
- `Requirements Coverage` table can be lightly adapted (template lines 57–61) — it could map VERIFY-01/02/03 to pass/fail, but it duplicates the per-question sections so probably redundant. Planner's call.
- `Recommended Fix Plans` (template lines 119–144) — only triggers on `gaps_found`. For Phase 1, the equivalent is the "Pivot Policy" section (CONTEXT.md D-08/D-09).

**Overriding spec from CONTEXT.md D-06 (USE THIS, not the template axes):**

The artifact MUST contain ONE SECTION PER VERIFY QUESTION (VERIFY-01, VERIFY-02, VERIFY-03), each with:
1. A yes/no answer
2. The install command used
3. The exact observation evidence (verbatim quote blocks):
   - For VERIFY-01: `claude plugin details` output's `Skills (N)` line
   - For VERIFY-02: system-reminder excerpt (PRIMARY, per D-07) + `claude plugin details` Skills line (SECONDARY, per D-07)
   - For VERIFY-03: `find ~/.claude/plugins/cache/hack-skills-marketplace -maxdepth 3 -type d` output + `du -sh` sizes
4. A one-line conclusion

PLUS a "Pivot Policy" section containing the pre-decided pivot stance for each VERIFY's "no" outcome per CONTEXT.md D-09. If all three VERIFY answers are "yes", each pivot entry reads `N/A — answer was yes` per D-08.

**SPECIFICS verbatim-quote requirement** (from CONTEXT.md line 104): System-reminder evidence MUST be a verbatim fenced code block, NOT paraphrased. Same applies to all CLI output evidence — exact tokens (SHA, paths, byte counts) preserved.

**Resulting per-VERIFY section shape (planner should propose; this is a sketch):**

```markdown
## VERIFY-01: Individual Skill Path Addressing

**Answer:** YES | NO
**Plugin under test:** `hack-skills-auth-bypass@hack-skills-marketplace`
**Install command:**
\`\`\`bash
claude plugin install hack-skills-auth-bypass@hack-skills-marketplace --scope user
\`\`\`

**Primary evidence** (`claude plugin details` output, verbatim):
\`\`\`
{verbatim paste — must show "Skills (2) 401-403-bypass-techniques, api-auth-and-jwt-abuse"}
\`\`\`

**Conclusion:** {one sentence linking evidence to the yes/no}

---
```

(Same template structure for VERIFY-02 with dual evidence per D-07; for VERIFY-03 with cache-tree paste per D-10's "both installed concurrently" exception.)

---

## Shared Patterns

### Source-repo immutability (cross-cutting constraint, not a code pattern)

**Source:** `CLAUDE.md` line 12 — `Source immutability: Never modify files in yaklang/hack-skills.`
**Apply to:** `.claude-plugin/marketplace.json` authorship and all phase-1 hygiene commands.
**Impact:** The `source` descriptor in marketplace.json MUST point at upstream `yaklang/hack-skills` via `github`; no `plugin.json` is added to the upstream repo (CONTEXT.md D-03 makes this explicit). The whole reason `strict: false` is used is to enable curation WITHOUT touching the source repo.

### Install command shape (cross-cutting constraint)

**Source:** `CLAUDE.md` line 13 — `Install command shape: No @branch suffixes — use the default ref.`
**Apply to:** Every `claude plugin install ...` command in 01-VERIFICATION.md evidence blocks.
**Impact:** Commands are plain `claude plugin install <name>@hack-skills-marketplace --scope user`. No `@main`, no `@HEAD`, no `@<sha>`. RESEARCH.md Pattern 2 (lines 254–285) already obeys this.

### Verbatim evidence (cross-cutting documentation convention for this phase)

**Source:** CONTEXT.md §Specifics line 104 — `Capture system-reminder evidence as a verbatim quote block in the verification artifact, not paraphrased. The exact text is the evidence.`
**Apply to:** Every observation paste in 01-VERIFICATION.md.
**Impact:** Use fenced code blocks for all CLI output, system-reminder excerpts, and filesystem listings. Do not summarize "the output showed two skills" — paste the literal `Skills (2) 401-403-bypass-techniques, api-auth-and-jwt-abuse` line.

### Per-phase artifact location (GSD convention)

**Source:** CONTEXT.md D-05 — Phase artifacts under `.planning/phases/${padded_phase}-${slug}/`. The GSD template at `.claude/get-shit-done/templates/verification-report.md` line 3 confirms the convention.
**Apply to:** 01-VERIFICATION.md location.
**Impact:** File goes at `.planning/phases/01-schema-verification/01-VERIFICATION.md` (not under `docs/` and not at repo root).

### Install/observe/uninstall procedure (cross-cutting reproducibility pattern)

**Source:** RESEARCH.md Pattern 2 (lines 254–285), Examples 3–5 (lines 444–548).
**Apply to:** The plan's action sequence AND the install-command rows inside each VERIFY section of 01-VERIFICATION.md.
**Impact:** Planner should literally copy the command sequences from RESEARCH.md — they're already keyed to the three VERIFY questions and respect CONTEXT.md D-10's "uninstall between sub-tests, install both concurrently for VERIFY-03" hygiene.

Key procedural anchors:
- Pre-flight: `claude plugin validate /Users/spencerpresley/code/hack-skills-wip/hack-skills-marketplace` (RESEARCH.md line 257)
- VERIFY-01 + VERIFY-02 sequence: `marketplace add` → `install hack-skills-recon` → `enable` → `details` → start interactive session for system-reminder capture → `uninstall` → repeat for `hack-skills-auth-bypass` → `marketplace remove` (RESEARCH.md lines 260–269)
- VERIFY-03 sequence (no teardown between installs): `marketplace add` → `install hack-skills-recon` → `install hack-skills-auth-bypass` → `enable` both → `find` cache tree → `du -sh` → final teardown (RESEARCH.md lines 272–284)
- Strict-pass assertion for VERIFY-03 (RESEARCH.md lines 538–540): `[ "$(find ~/.claude/plugins/cache/hack-skills-marketplace -mindepth 2 -maxdepth 2 -type d | wc -l)" -eq 2 ]`

## No Analog Found

| File | Role | Reason |
|------|------|--------|
| (none) | — | Both files have at least partial analogs. Notable: there is no prior `01-VERIFICATION.md` in this project, but the GSD template provides enough structural scaffolding to qualify as a partial analog. |

## Metadata

**Analog search scope:**
- `~/.claude/plugins/marketplaces/` (5 real marketplaces inspected; wondelai-skills selected as primary; others noted as alternatives)
- `~/.claude/plugins/cache/claude-plugins-official/plugin-dev/unknown/skills/plugin-structure/SKILL.md` (Anthropic's own plugin-structure reference)
- `/Users/spencerpresley/code/hack-skills-wip/hack-skills-marketplace/.claude/get-shit-done/templates/` (GSD report templates)
- `/Users/spencerpresley/code/hack-skills-wip/hack-skills-marketplace/.claude/get-shit-done/references/verification-patterns.md` (GSD verification-patterns reference — reviewed but inapplicable; designed for stub-detection in app code, not behavior observation against a config)

**Files scanned:** 7 (5 marketplace.json files, 1 GSD template, 1 GSD reference; plus 1 SKILL.md for schema cross-reference)
**Files NOT scanned (out of scope):** Source code under `yaklang/hack-skills` — read-only upstream; only its skill paths are referenced, not its file contents.

**Pattern extraction date:** 2026-05-22

## PATTERN MAPPING COMPLETE
