# Phase 2: Skill Classification & Taxonomy - Pattern Map

**Mapped:** 2026-05-22
**Files analyzed:** 2
**Analogs found:** 2 / 2 (both partial — both files are genuinely novel formats; closest structural analogs identified and reusable elements extracted)

<summary>
## Summary for Planner

This phase produces ONLY two `.planning/`-tree files. No application code is authored, no schema is changed, no UI is touched. The upstream source at `/Users/spencerpresley/code/hack-skills-wip/hack-skills/skills/` is read-only (PROJECT.md source-immutability constraint).

Both artifacts are **novel formats** for this codebase:

1. **`02-CLASSIFICATION.md`** — A "phase produces a structured report consumed by the next phase" artifact. The closest analog is `01-VERIFICATION.md` (same role, same data flow: structured-report-for-next-phase). Borrow its YAML frontmatter shape, table-driven evidence convention, summary-at-top + section-bodies-below structure, and verbatim-fenced-evidence convention. Override the body axes: VERIFICATION used `VERIFY-NN` sections; CLASSIFICATION uses `Bucket sections + Catch-all + Master table + Decision log` per CONTEXT.md D-12.

2. **`02-CLASSIFICATION.json`** — A bucket-keyed machine-readable map consumed by Phase 3's executor. The closest analog is `.claude-plugin/marketplace.json` (same JSON shape vocabulary: plugin entries with `name`, `description`, `skills: ["./<path>"]` arrays using Phase 1 D-03-REVISED's root-level path form). Borrow the `description` tone and the `skills` path convention verbatim. Override the outer container: marketplace.json is a flat `plugins: [...]` array; CLASSIFICATION.json is a bucket-keyed top-level object per CONTEXT.md D-13 (so Phase 3 can iterate by bucket-name).

**Critical procedural pattern to surface in the plan:** D-16 requires a **mid-phase user-review checkpoint** between first-pass bucket assignment and the final artifact write. This is the only Phase 2-specific procedural pattern — no analog exists in Phase 1 (Phase 1's mid-phase pivot was reactive, not planned). The planner MUST build the checkpoint into the action sequence as an explicit pause point, not bury it inside an autonomous execution flow.

**Extraction-tooling pattern (not file-pattern):** D-14 mandates verbatim YAML-frontmatter `description` lifted from each of the 102 upstream SKILL.md files. This is mechanical (Bash `awk`/`sed` over frontmatter blocks, a small Node script, or subagent dispatch). The frontmatter shape is uniform — verified on 401-403-bypass-techniques/SKILL.md: a `---`-fenced block with `name:` and `description: >-` (folded YAML scalar). The planner picks the tool; PATTERNS recommends a single shell pipeline (cheapest context cost).

No "code patterns" in the traditional sense exist to copy from — this phase reads 102 markdown frontmatters, makes assignment decisions, and writes one structured markdown report plus one structured JSON file.
</summary>

## File Classification

| New File | Role | Data Flow | Closest Analog | Match Quality |
|----------|------|-----------|----------------|---------------|
| `.planning/phases/02-skill-classification-taxonomy/02-CLASSIFICATION.md` | report / phase classification artifact (taxonomy + per-skill assignments) | static markdown — read-once by Phase 3 planner/executor | `.planning/phases/01-schema-verification/01-VERIFICATION.md` | **Partial** — same role (phase-produces-structured-report-for-next-phase), same data flow, same GSD location convention. **Body axes differ** (VERIFY-NN sections vs. Bucket / Catch-all / Master-table / Decision-log per CONTEXT.md D-12). Borrow frontmatter + summary-at-top + verbatim-evidence convention. |
| `.planning/phases/02-skill-classification-taxonomy/02-CLASSIFICATION.json` | config / data export consumed by Phase 3 executor | static JSON — read-once by Phase 3 executor to author marketplace.json | `.claude-plugin/marketplace.json` | **Partial** — same JSON vocabulary (`name`, `description`, `skills: ["./<path>"]` arrays following Phase 1 D-03-REVISED root-level form). **Outer container differs** (flat `plugins: [...]` array vs. bucket-keyed top-level object per CONTEXT.md D-13). Borrow the `description` tone and the skill-path convention verbatim. |

## Pattern Assignments

### `02-CLASSIFICATION.md` (report, static markdown)

**Analog:** `.planning/phases/01-schema-verification/01-VERIFICATION.md` (the only prior phase artifact in this repo).

**Why this analog:** It's the GSD precedent for "phase produces a structured report consumed by the next phase." Same data flow (static markdown, read-once by the next phase's planner/executor). Same location convention (`.planning/phases/${padded_phase}-${slug}/${padded_phase}-{ARTIFACT}.md`). It establishes the in-repo conventions for frontmatter, evidence-as-verbatim-fenced-blocks, summary-at-top, and one-line-conclusion-per-section that Phase 2 should mirror.

**Caveat:** 01-VERIFICATION.md's body axes are the three VERIFY-NN questions plus a Pivot Policy section. Those are wrong for Phase 2 — CONTEXT.md D-12 prescribes a fundamentally different per-bucket / catch-all / master-table / decision-log structure. **Borrow the meta-shape, replace the axes.**

#### Borrowable from 01-VERIFICATION.md (use as-is or near-verbatim)

**Frontmatter pattern** (01-VERIFICATION.md lines 1-12):
```markdown
---
status: passed
phase: 01-schema-verification
verified: 2026-05-22
verify_questions: VERIFY-01, VERIFY-02, VERIFY-03
all_answers: yes
pivot_required: false
mechanism_correction_during_phase: yes
evidence_files:
  - .planning/phases/01-schema-verification/.task01-evidence-after-fix.txt
  - .planning/phases/01-schema-verification/.task02-system-reminder.txt
---
```

For Phase 2 CLASSIFICATION.md, adapt the frontmatter axes to the classification axes:
```markdown
---
status: passed | gaps_found | human_needed
phase: 02-skill-classification-taxonomy
classified: <date>
requirements: GROUP-01, GROUP-02, GROUP-03, GROUP-04
total_skills: 102
bucket_count: <N derived from D-01/D-02/D-03>
catch_all_shape: multiple_themed | single_misc   # per D-06
sized_within_8_15: <true|false with note on any documented exceptions>
mid_phase_checkpoint: completed   # per D-16
checkpoint_approval_signal: <how user-approval was recorded — e.g. "discussion-log Q-NN" or "explicit approval message">
---
```

**Top-of-file summary pattern** (01-VERIFICATION.md lines 14-26):
```markdown
# Phase 1 Verification: Schema Verification

## Summary

All three open schema questions (VERIFY-01..., VERIFY-02..., VERIFY-03...) answered **YES** with evidence, **after a mid-phase mechanism correction**. Phase 2 can proceed.

| Question | Answer | Evidence Source |
|---|---|---|
| **VERIFY-01** ... | YES | `claude plugin details` reports... |
| **VERIFY-02** ... | YES | Fresh `claude -p` session... |
| **VERIFY-03** ... | YES | Two parallel cache subdirs... |
```

For Phase 2 CLASSIFICATION.md, the summary block becomes:
- A 1-2 sentence rollup ("All 102 skills classified into N buckets; X catch-all bucket(s); Y `also_relevant_to` close-call entries logged in Decision Log.")
- A compact bucket-overview table: `bucket_name | member_count | sized_within_8_15 | notes`
- An explicit statement that **D-07 invariant** holds (every one of the 102 skills appears exactly once), with the count as evidence.

**Verbatim-evidence convention** (01-VERIFICATION.md lines 60-79, 122-131, 144-158):

01-VERIFICATION.md uses fenced code blocks for ALL externally-sourced text — `claude plugin details` output, system-reminder excerpts, `find` output. The same convention applies in spirit to Phase 2's verbatim SKILL.md descriptions (D-14):
- Each per-bucket member list MUST quote the upstream `description` field verbatim — no paraphrasing, no truncation.
- The recommended rendering is a markdown list with `- \`<skill-name>\`: <verbatim description text>` per item (descriptions are short enough — ~100 chars/skill — that a fenced block per item would be overkill).
- The master 102-row table MUST also use the verbatim `description` in the `summary` column. Same content, different layout (table vs. per-bucket list).

**Roadmap-success-criteria-check pattern** (01-VERIFICATION.md lines 181-191):

01-VERIFICATION.md closes with an explicit checklist against the Roadmap's per-phase success criteria. Phase 2 should do the same against ROADMAP.md §Phase 2's five success criteria (criterion #5 is preserved via D-07; criterion #4 is reframed via D-06 into "assigned to a catch-all bucket" rather than "absent from marketplace.json").

```markdown
## Roadmap Success Criteria (Phase 2)

Checking against the 5 success criteria listed in ROADMAP.md §Phase 2:

1. ✓ A classification artifact exists in the repo listing all 102 skills ... — see Master 102-row table below.
2. ✓ A final topical group taxonomy is documented ... — see Per-bucket sections below.
3. ✓ Each proposed group's skill membership falls within 8–15 ... — see Bucket-overview table; exceptions noted under Catch-all section.
4. ✓ Skills that don't map ... explicitly listed ... with reason — see Catch-all section (D-06 reframe: assigned to catch-all bucket rather than dropped).
5. ✓ Every one of the 102 skills appears in the classification artifact exactly once — D-07 invariant; total count verified against `ls /Users/spencerpresley/code/hack-skills-wip/hack-skills/skills/ | wc -l = 102`.

**All 5 success criteria met. Phase 2 unlocks Phase 3.**
```

#### Override from CONTEXT.md D-12 (USE THESE BODY SECTIONS, not the VERIFY-NN axes)

Per CONTEXT.md D-12, the body of 02-CLASSIFICATION.md is:

1. **Per-bucket sections** — one `##` section per group. Required fields per section:
   - Bucket name (matches the JSON key in CLASSIFICATION.json — terse `kebab-case` recommended per CONTEXT.md Claude's Discretion bullet)
   - Scope paragraph (one paragraph — what unifies the members; the same text lifted into CLASSIFICATION.json's `description` field and downstream into marketplace.json's plugin `description` per CONTEXT.md D-13 + D-04 deferred-ideas)
   - Member list with `- \`<skill-name>\`: <verbatim description from upstream SKILL.md>` per item, alphabetical by skill-name (CONTEXT.md Claude's Discretion bullet recommends alphabetical for ctrl-F predictability)
   - Member count
   - Sizing note for any special case: catch-all flag (D-06), sized outside 8–15 (D-02), merge/split origin (D-02 — "originally `crypto` (4 skills), merged into this bucket because...")

2. **Catch-all section** — `##` section. Per CONTEXT.md D-06:
   - Header notes which shape applied (`multiple themed catch-alls` vs. `single hack-skills-misc`)
   - For each catch-all bucket, the same fields as a per-bucket section (D-06 says catch-alls also aim for ~8–15 if they cluster naturally)
   - Per-member reason flag: `standalone` (no cluster) or `redundant` (overlaps heavily) per D-05

3. **Master 102-row table** — single table at bottom. Columns per D-12:
   - `name` (skill name, matches upstream directory name)
   - `summary` (verbatim `description` from upstream SKILL.md frontmatter, per D-14)
   - `assigned_bucket` (matches a bucket name in the Per-bucket or Catch-all sections above)
   - `also_relevant_to` (other bucket name, or empty — per D-10, populated only for genuine close calls)

   ```markdown
   | name | summary | assigned_bucket | also_relevant_to |
   |---|---|---|---|
   | 401-403-bypass-techniques | 401/403 bypass playbook. Use when encountering access-denied responses on admin panels, API endpoints, or restricted paths. Covers path manipulation, HTTP method tampering, header injection, protocol downgrade, and automated bypass tools. | auth-bypass | |
   | ... (101 more rows) | ... | ... | ... |
   ```

   Row count MUST equal 102 — this is the load-bearing audit invariant for ROADMAP Phase 2 Success Criterion #5 (D-07).

4. **Decision log** — `##` section. Per CONTEXT.md D-12 and SPECIFICS bullet on `also_relevant_to`:
   - One entry per **non-obvious close call only** (skip routine assignments — log is for the calls a human auditor would want explained, not for every skill)
   - Format: `<skill-name>: assigned to <bucket> over <other>; reason: <skill's own framing emphasized X>`. Reference D-09 tiebreaker logic ("primary attack surface in the skill's own SKILL.md") or the SKILL.md body's `RELATED ROUTING` cross-references (CONTEXT.md code_context bullet, SPECIFICS bullet) as the cited evidence.
   - Should be scannable, not verbose — CONTEXT.md D-12 explicitly says "limited to non-obvious close calls only"

#### What to NOT borrow from 01-VERIFICATION.md

- **`## VERIFY-NN` per-section structure** — wrong axes. 01-VERIFICATION.md has 3 well-known yes/no questions to verify; 02-CLASSIFICATION.md has N derived buckets to document. D-12 provides the correct alternative structure.
- **`## Pivot Policy` section** — VERIFY-specific. Phase 2 has no analog (the mid-phase checkpoint per D-16 happens BEFORE the artifact is written and is captured in the discussion log + a frontmatter flag, not as an in-artifact section).
- **`### VERIFY-NN corrective note`** subsections (01-VERIFICATION.md lines 100-109) — those captured Phase 1's mid-phase mechanism pivot. Phase 2's mid-phase checkpoint (D-16) is planned, not reactive; any pre-checkpoint vs. post-checkpoint bucket changes are documented in the Decision log or in a brief frontmatter note (`mid_phase_checkpoint: completed`), not as standalone corrective subsections.

---

### `02-CLASSIFICATION.json` (config / data export, static JSON)

**Analog:** `.claude-plugin/marketplace.json` (current Phase 1 output — `hack-skills-recon` + `hack-skills-auth-bypass` two-plugin test marketplace).

**Why this analog:** Same vocabulary (`name` / `description` / `skills` array). Same skill-path convention — root-level `./<skill-name>` per Phase 1 D-03-REVISED, verified in marketplace.json lines 15 and 26-28. Same usage shape: downstream-consumed data file, written-once-per-phase, hand-readable but primarily machine-parsed. The CLASSIFICATION.json `skills` arrays should be **drop-in-ready** for Phase 3 to paste into the plugins-list entries it authors.

**Caveat:** marketplace.json is a flat `plugins: [...]` array at top level. CLASSIFICATION.json per CONTEXT.md D-13 is a **bucket-keyed top-level object** (so Phase 3's executor can iterate by bucket-name without scanning an array). This is a deliberate divergence — Phase 3 will TRANSLATE bucket-keyed → array-shaped when authoring marketplace.json.

#### Borrowable from marketplace.json (use verbatim where called out)

**Skill-path convention** (marketplace.json lines 15, 27-28):
```json
"skills": ["./api-recon-and-docs"]
```
and
```json
"skills": [
  "./401-403-bypass-techniques",
  "./api-auth-and-jwt-abuse"
]
```

Every path: leading `./`, no `./skills/` prefix, matches the upstream directory name verbatim. This is locked by Phase 1 D-03-REVISED and is non-negotiable — Phase 3 needs these arrays as-is. CONTEXT.md canonical_refs section explicitly calls this out: "the JSON artifact's `skills` arrays must use that root-level form."

**Description-field tone** (marketplace.json lines 14, 25):
```json
"description": "Reconnaissance and information gathering"
```
```json
"description": "Authentication and authorization bypass"
```

Each is a one-line capability summary, not a full sentence — gerund or noun-phrase form, ~3-6 words, no period. This is the tone Phase 3 will emit downstream into the marketplace.json plugin `description` per CONTEXT.md D-13 and per the v2 deferred-ideas bullet on bucket descriptions. The CLASSIFICATION.json `description` field per bucket should follow this tone so Phase 3 can lift it verbatim.

#### Override from CONTEXT.md D-13 (USE THIS, not the marketplace.json outer container)

Per CONTEXT.md D-13, CLASSIFICATION.json structure:

```json
{
  "<bucket-name-1>": {
    "description": "<one-line bucket scope, gerund/noun-phrase tone matching marketplace.json>",
    "skills": [
      "./<skill-name-1>",
      "./<skill-name-2>"
    ],
    "notes": "<sizing exception, catch-all flag, merge/split origin — or empty>"
  },
  "<bucket-name-2>": {
    "description": "...",
    "skills": ["..."],
    "notes": "..."
  },
  "excluded": [],
  "skill_metadata": {
    "<skill-name>": { "also_relevant_to": "<other-bucket-name>" }
  }
}
```

Notes on the structure (per CONTEXT.md D-13 + Claude's Discretion bullet on JSON nesting):

- **Top-level keys** are bucket names (kebab-case, matching the per-bucket section headings in CLASSIFICATION.md so the two files cross-reference cleanly).
- **`excluded` array** is reserved at top level per D-13. Under D-06's "misfits go into catch-alls" rule, this array is **likely empty** — but it exists for schema completeness so Phase 3's executor doesn't need a conditional `if "excluded" in data`.
- **`skill_metadata` map** holds `also_relevant_to` cross-references per skill (D-10). Inline-per-bucket vs. separate top-level map is Claude's Discretion per CONTEXT.md — the recommendation here is a **separate top-level map** so the per-bucket `skills: []` arrays stay clean and Phase 3 can paste them directly into marketplace.json without needing to strip metadata fields.
- **`notes` field per bucket** holds sizing-exception text, catch-all flag, merge/split origin — anything Phase 3 might want to surface in commit messages or post-build documentation. Empty string if no special case.

**Optional but recommended** (Claude's Discretion):
- **Bucket-name keys** preserve insertion order (JSON object iteration order is preserved in modern JS / Python — Phase 3 should iterate by `Object.keys(...)`). Alphabetical key ordering recommended for diff stability across re-generations.
- A top-level `_meta` key holding generation metadata (date, total skill count, bucket count, mid-phase checkpoint approval marker) is optional but mirrors the CLASSIFICATION.md frontmatter and helps Phase 3 sanity-check the file (e.g. assert `_meta.total_skills == 102` before iterating).

#### What to NOT borrow from marketplace.json

- **`plugins: [...]` outer container** — wrong shape per D-13. Bucket-keyed object is correct for CLASSIFICATION.json's downstream iteration pattern.
- **`source` descriptor** — marketplace.json carries `{ "source": "git-subdir", "url": ..., "path": "skills" }` per Phase 1 D-03-REVISED. CLASSIFICATION.json does NOT — that's Phase 3's job to add when it translates buckets into plugin entries. Including it here would invite drift if Phase 1's decision is later refined.
- **`strict: false` field** — also Phase 3's responsibility per the same logic. CLASSIFICATION.json describes the *classification*, not the marketplace shape.
- **`owner` / top-level `name` / top-level `description`** — those are marketplace-level fields, not bucket-level. The CLASSIFICATION.json file is its own thing, not a marketplace.json variant.

---

## Shared Patterns

### Source-repo immutability (cross-cutting constraint)

**Source:** `CLAUDE.md` "Source immutability: Never modify files in `yaklang/hack-skills`."
**Apply to:** Every read of `/Users/spencerpresley/code/hack-skills-wip/hack-skills/skills/`.
**Impact:** All 102 SKILL.md reads MUST be read-only. No `sed -i`, no `awk` with output redirect into the source tree, no scripts that materialize derived files inside the source tree. Extraction tooling reads from source, writes to either stdout (piped into the artifacts) or to `.planning/phases/02-skill-classification-taxonomy/` only. The orchestrator's RESEARCH.md may already note this; PATTERNS reiterates it because the planner will be tempted to cache extracted frontmatters somewhere — that cache MUST live under `.planning/`, never under `hack-skills/skills/`.

### Per-phase artifact location (GSD convention)

**Source:** Phase 1 D-05 (locked in 01-CONTEXT.md), and CONTEXT.md D-15 ("phase-local only").
**Apply to:** Both `02-CLASSIFICATION.md` and `02-CLASSIFICATION.json`.
**Impact:** Both files at `.planning/phases/02-skill-classification-taxonomy/02-CLASSIFICATION.{md,json}`. No copy under `docs/`, no symlink at repo root, no shorter path alias. CLASSIFICATION.json is the integration point with Phase 3 — Phase 3 reads from this exact path.

### Verbatim-source convention (cross-cutting documentation pattern)

**Source:** Phase 1 SPECIFICS / verbatim-evidence convention (established in 01-VERIFICATION.md — see lines 60-79 for `claude plugin details` verbatim, lines 122-131 for system-reminder verbatim). Reapplied as CONTEXT.md D-14 for Phase 2.
**Apply to:** Every per-skill `summary` rendering in both 02-CLASSIFICATION.md (per-bucket member lists AND master table) and 02-CLASSIFICATION.json (no `summary` field per D-13, but the bucket `description` is similarly verbatim-from-author intent — concise scope statement, not paraphrase of member descriptions).
**Impact:** Zero Claude-authored one-liners describing what an upstream skill does. Every per-skill summary text is `cat skills/<name>/SKILL.md | <extract description frontmatter field>` output. If the description spans multiple folded YAML lines (`description: >- ...`), the planner unfolds them into a single space-separated line per the YAML scalar resolution rules — but the words themselves are not edited.

Concrete verification: the description text for `401-403-bypass-techniques` is fixed by upstream as:
```
401/403 bypass playbook. Use when encountering access-denied responses on admin panels, API endpoints, or restricted paths. Covers path manipulation, HTTP method tampering, header injection, protocol downgrade, and automated bypass tools.
```
That exact string must appear in CLASSIFICATION.md's auth-bypass section member list AND in the master table's `summary` column for that row. No truncation, no rewording. The same applies for all 101 other skills.

### Mid-phase user-review checkpoint (Phase 2-specific procedural pattern, NEW)

**Source:** CONTEXT.md D-16 ("Mid-phase user-review checkpoint required.")
**Apply to:** The plan's action sequence — between Step N (first-pass bucket assignment) and Step N+1 (final artifact write).
**Impact:** This is **the only non-trivial procedural pattern unique to Phase 2.** No prior Phase 1 artifact has a planned mid-phase pause (Phase 1's mid-phase pivot was reactive — driven by the VERIFY-01 FAIL — not a planned checkpoint). The planner MUST structure the plan(s) such that:

1. **First-pass extraction + assignment is a discrete action set** that ends in a stable, presentable intermediate state — proposed bucket names, member counts, merge/split moves, catch-all bucket shape, borderline list with alternates.
2. **A user-facing checkpoint message** surfaces that state in the compact format CONTEXT.md SPECIFICS describes: "bucket name + member count + any merge/split notes + the borderline list with alternates. Not the full member-by-member dump."
3. **User approval signal** is captured before the final artifact write. The approval can be informal (e.g. "go ahead" in the orchestrator session) but the fact that approval was granted MUST be reflected in the CLASSIFICATION.md frontmatter (`mid_phase_checkpoint: completed` + `checkpoint_approval_signal: <how recorded>`) and ideally also in the discussion log.
4. **Post-approval action set** writes both 02-CLASSIFICATION.md and 02-CLASSIFICATION.json from the approved (and possibly user-edited) bucket map.

The planner has discretion in how this splits across plans. Two reasonable shapes:
- **Single-plan with internal checkpoint:** One plan with an explicit `<checkpoint>` action between the "propose taxonomy" and "write artifacts" sections. Plan execution pauses at the checkpoint.
- **Two-plan split:** Plan A produces the proposed taxonomy + presents it to user (terminates after surfacing the checkpoint). Plan B writes the final artifacts (gated by user approval on Plan A's output). This is cleaner from a GSD-plan-completion-tracking standpoint but adds plan overhead.

PATTERNS does not prescribe which; flags the requirement.

### Extraction-tooling (mechanical, not interpretive)

**Source:** CONTEXT.md code_context + SPECIFICS bullets — frontmatter extraction is "mechanical, not interpretive" and the planner should design around extraction.
**Apply to:** The step that produces the per-skill description corpus.
**Impact:** No agent should read 102 SKILL.md files one-at-a-time and write paraphrases. Use a single shell pipeline or small script. Two recommended approaches:

1. **Shell pipeline (cheapest, recommended for default planner pick):**
   ```bash
   for d in /Users/spencerpresley/code/hack-skills-wip/hack-skills/skills/*/; do
     name=$(basename "$d")
     desc=$(awk '/^---$/{flag=!flag; next} flag && /^description:/ {sub(/^description: *>?-? */, ""); printing=1; print; next} printing && flag && !/^[a-z_]+:/ {gsub(/^ +/, ""); print} printing && flag && /^[a-z_]+:/ {exit}' "$d/SKILL.md" | tr '\n' ' ' | sed 's/  */ /g; s/ $//')
     printf '%s\t%s\n' "$name" "$desc"
   done > /tmp/skill-descriptions.tsv
   ```
   (Exact awk script will need calibration against the actual frontmatter shape. Verify on 2-3 SKILL.md files first.)

2. **Tiny Python or Node script** with proper YAML parsing — cleaner for folded scalars, slightly higher context cost. Worth it if the awk extraction proves brittle on edge-case frontmatters (e.g. multi-line folded descriptions with embedded colons).

Either way: the planner writes the extraction script INTO `.planning/phases/02-skill-classification-taxonomy/` (as `02-extract-descriptions.sh` or similar) so it's tracked alongside the artifacts and re-runnable. The extracted TSV/JSON intermediate can be temporary — the canonical record is the description text embedded in CLASSIFICATION.md and CLASSIFICATION.json.

### Bucket-naming convention (Claude's Discretion per CONTEXT.md)

**Source:** REQUIREMENTS.md BUILD-02 ("each plugin entry has a clear name `hack-skills-<topic>`") + CONTEXT.md Claude's Discretion bullet ("terse `kebab-case`").
**Apply to:** Bucket-name keys in CLASSIFICATION.json AND `##` section headings in CLASSIFICATION.md.
**Impact:** Bucket names in CLASSIFICATION should be the `<topic>` part only (e.g. `recon`, `auth-bypass`, `injection`) — NOT the full `hack-skills-recon` plugin-name. Phase 3 prefixes `hack-skills-` when emitting marketplace.json plugin entries. This keeps CLASSIFICATION.json cleaner and avoids forcing Phase 3 to strip a prefix.

Concrete naming guidance:
- Kebab-case, no underscores, no camelCase.
- Single-word where possible (`recon`, `mobile`, `binary`, `crypto`).
- Multi-word with hyphens where needed for clarity (`auth-bypass`, `web-injection`, `protocol-injection` if injection splits per D-02).
- Catch-all bucket names follow the same convention (`hack-skills-misc` if single-bucket per D-06 — but note the `hack-skills-` prefix is just for the single-misc fallback case where naming exists prominently in CONTEXT.md, NOT a general rule; themed catch-alls under D-06's preferred shape get topical names like `crypto-attacks` or `forensics-and-recovery`).

## Procedural Patterns NOT Borrowed (and Why)

### From 01-VERIFICATION.md: per-VERIFY-question evidence sections

01-VERIFICATION.md's body is built around `## VERIFY-01`, `## VERIFY-02`, `## VERIFY-03` — three sections each documenting a yes/no answer with command + evidence + conclusion. This worked for Phase 1 because the question set was small, fixed, and verbatim from PLAN.md.

Phase 2 has no analog. The "questions" of Phase 2 are "what bucket does this skill go in?" — answered 102 times, one per skill. Rendering 102 sections would be unreadable. CONTEXT.md D-12 correctly substitutes the per-bucket sections (8-10ish sections, each grouping multiple decisions) plus the master table for ctrl-F lookup. PATTERNS endorses D-12's structure.

### From marketplace.json: schema-validation external reference

marketplace.json has a recommended `$schema` field per 01-PATTERNS.md (`https://anthropic.com/claude-code/marketplace.schema.json`). CLASSIFICATION.json should NOT add a `$schema` field — there is no published schema for this file (it's a Phase-2-internal artifact), and a bogus `$schema` URL would mislead readers into thinking one exists. Phase 3 might publish a schema for CLASSIFICATION.json shape later if this artifact pattern repeats across projects, but Phase 2 is its first instance.

## No Analog Found

| File | Role | Reason |
|------|------|--------|
| (none) | — | Both files have at least partial analogs. Both are novel formats but the structural elements are borrowable. See per-file `Pattern Assignments` above for the borrowable elements and the override sections. |

## Metadata

**Analog search scope:**
- `.planning/phases/01-schema-verification/` — Phase 1 artifacts (CONTEXT, RESEARCH, PATTERNS, VERIFICATION, 4 PLANs, 4 SUMMARYs). 01-VERIFICATION.md selected as primary structural analog for the markdown artifact.
- `.claude-plugin/marketplace.json` — current Phase 1 output. Selected as primary structural analog for the JSON artifact.
- `.planning/phases/02-skill-classification-taxonomy/02-CONTEXT.md` — Phase 2 USER DECISIONS (D-01 through D-16) — primary spec for both artifacts' body structure (axes that override the analogs).
- `.planning/phases/02-skill-classification-taxonomy/02-DISCUSSION-LOG.md` — audit trail of how D-01..D-16 were chosen; not a structural analog but useful for understanding which decisions are firmer than others.
- `/Users/spencerpresley/code/hack-skills-wip/hack-skills/skills/401-403-bypass-techniques/SKILL.md` — frontmatter shape sample (verified the `---`-fenced `name:` + `description: >-` folded-scalar structure that the extraction pipeline must handle).
- `.planning/phases/01-schema-verification/01-04-PLAN.md` — sample of how the planner structures plan-level frontmatter (`must_haves`, `truths`, `artifacts`, `key_links`) — referenced so PATTERNS is aware of how Phase 2 plans will consume these pattern recommendations.

**Files NOT scanned (out of scope for pattern matching):**
- The other 101 SKILL.md files under `/Users/spencerpresley/code/hack-skills-wip/hack-skills/skills/` — those are CONTENT for Phase 2 to read during execution, not structural analogs to pattern from. PATTERNS only needed to verify the frontmatter shape (done on one sample).
- `~/.claude/plugins/marketplaces/wondelai-skills/.claude-plugin/marketplace.json` — referenced by 01-PATTERNS.md as a structural analog for the Phase 1 marketplace.json. Phase 2 produces no marketplace.json (that's Phase 3's job), so wondelai is two steps removed and not load-bearing here.
- GSD templates under `.claude/get-shit-done/templates/` — none of the templates fit the Phase 2 artifact pair (no "classification report" template exists; the closest is the verification-report template which 01-VERIFICATION.md already adapted away from). Inventing structure from scratch via CONTEXT.md D-12 + analogy to 01-VERIFICATION.md is cheaper than further template excavation.

**Files scanned:** 7

**Pattern extraction date:** 2026-05-22

## PATTERN MAPPING COMPLETE
