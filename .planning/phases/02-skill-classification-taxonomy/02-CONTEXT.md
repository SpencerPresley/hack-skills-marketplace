# Phase 2: Skill Classification & Taxonomy - Context

**Gathered:** 2026-05-22
**Status:** Ready for planning

<domain>
## Phase Boundary

Read all 102 upstream `SKILL.md` files in `yaklang/hack-skills/skills/`, capture a one-line summary per skill (verbatim from each `SKILL.md`'s YAML frontmatter `description` field), derive the final topical group taxonomy via the hybrid approach described below, and produce two committed artifacts at `.planning/phases/02-skill-classification-taxonomy/`: `02-CLASSIFICATION.md` (human-readable) and `02-CLASSIFICATION.json` (machine-readable, consumed by Phase 3's executor to author marketplace.json).

**In scope:** reading 102 SKILL.md files, summarizing them verbatim, assigning each to exactly one bucket via the hybrid taxonomy approach, surfacing the proposed taxonomy at a mid-phase checkpoint for user review, finalizing the artifact pair, capturing also-relevant-to metadata for close calls.

**Out of scope:** authoring `.claude-plugin/marketplace.json` (Phase 3 BUILD-01/02/03), GitHub publish/install validation (Phase 4), per-skill content edits (source immutability — `yaklang/hack-skills` stays untouched), purplehaze-specific tailoring (Spencer does that in normal sessions; this phase produces a general-purpose topical decomposition).

**Reframe from PROJECT.md:** PROJECT.md says "group by purplehaze feature surface." During discussion, the user clarified that purplehaze-specific tailoring is NOT the optimization target — they handle that in normal sessions. **The decomposition's job is clean topical slicing by skill-content topicality so any session can pull in only the relevant slice.** PROJECT.md's framing was directional (size + relevance heuristic), not a precise mapping target. Downstream agents should treat "skill-content topicality" as the operative grouping lens.

</domain>

<decisions>
## Implementation Decisions

### Taxonomy Derivation Approach
- **D-01:** Hybrid derivation. Use PLAN.md's 8 suggested buckets (`recon`, `auth-bypass`, `injection`, `payloads`, `mobile`, `binary`, `ad`, `crypto`) as a starting scaffold. Read all 102 SKILL.md `description` fields, assign each skill to one starter bucket, then refine based on what the data shows.
- **D-02:** Resize policy when a bucket lands outside 8–15 after first-pass assignment is **aggressive merge + split**:
  - `< 5`: merge into the closest related bucket (e.g., a 3-skill bucket folds into a topically-adjacent neighbor).
  - `> 15`: split along the natural subtopic axis (e.g., `injection` → `web-injection` + `protocol-injection`).
  - Bucket names may diverge from PLAN.md's 8 starters as a result. Cleanly-sized buckets matter more than name fidelity to PLAN.md.
- **D-03:** Allow new buckets that PLAN.md didn't list. **Threshold for spawning a new bucket: 8+ skills clustering around a coherent topic that doesn't fit existing buckets.** Final bucket count is derived, not preordained — could be 8, 9, 10, or more. PLAN.md explicitly says "refine while reading," and this implements that.
- **D-04:** **Grouping lens = skill-content topicality.** Group by what each skill teaches/covers, not by session-use ('web app pentest') or attack-stage ('kill-chain'). The decomposition's value is "Spencer enables whichever bucket matches the topic of the current session, regardless of which product it's for." This supersedes PROJECT.md's loose "purplehaze feature surface" framing.

### Catch-all / Excluded Strategy
- **D-05:** Misfit criteria: a skill is a "misfit" if it is **(a) standalone / no cluster** (too topically isolated to share a bucket without diluting it) OR **(b) too generic / redundant** (overlaps heavily with multiple others, or is a thin wrapper over content already in better-shaped skills).
- **D-06:** Misfits do NOT get dropped from marketplace.json. They go into a **catch-all bucket** (or multiple). **Preferred shape: multiple themed catch-alls** — if the misfit set naturally splits into 2–3 thin clusters (e.g., `crypto-attacks`, `forensics-and-recovery`), each becomes its own catch-all bucket aiming for ~8–15. If misfits really don't cluster, fall back to a single oversized `hack-skills-misc` bucket. The classification artifact must document which case applied.
- **D-07:** Every one of the 102 skills appears in the classification artifact exactly once, with exactly one assigned bucket (whether a primary topical bucket or a catch-all bucket).

### Cross-Bucket Overlap
- **D-08:** **Hard assignment**: each skill appears in exactly ONE bucket in marketplace.json. No multi-membership. (Phase 3 BUILD-02 emits a `skills` array per plugin entry; D-08 says a given `./<skill-name>` path appears in at most one such array across the entire marketplace.json.)
- **D-09:** Tiebreaker for borderline skills (skill fits two buckets ~equally well): use the **primary attack surface in the skill's own SKILL.md** as the strongest signal — the YAML `description` field plus the skill's intro framing wins. Where the skill's framing is itself ambiguous, **use best judgment given the totality of circumstances** (semantic neighbors via `RELATED ROUTING` cross-references in the skill body, current bucket sizes, the broader taxonomy shape). The executor has discretion here; the user is NOT pre-approving every borderline call.
- **D-10:** For close calls, the classification artifact records **`also_relevant_to: [other bucket]`** as metadata on the affected skill. This does NOT change marketplace.json (the skill still appears only in its assigned bucket's `skills` array) — it's metadata for human auditing and future refinement.

### Classification Artifact Format
- **D-11:** **Two committed files** at `.planning/phases/02-skill-classification-taxonomy/`:
  - `02-CLASSIFICATION.md` — human-readable
  - `02-CLASSIFICATION.json` — machine-readable, consumed directly by Phase 3's executor
- **D-12:** **Markdown sections** (Claude's discretion, recommended layout):
  1. **Per-bucket sections** — one `##` section per group with: bucket name, scope (one paragraph), member list with verbatim one-line summaries from SKILL.md, member count, sizing note for any special cases (catch-all flag, sized outside 8–15 with reason).
  2. **Catch-all section** — `##` section listing the catch-all bucket(s), member list, and per-member reason (standalone / redundant).
  3. **Master 102-row table** — single table at bottom for ctrl-F lookup. Columns: `name`, `summary`, `assigned_bucket`, `also_relevant_to`.
  4. **Decision log** — limited to **non-obvious close calls only** (skip routine assignments). Format: `<skill-name>: assigned to <bucket> over <other>; reason: <skill's own framing emphasized X>`. Keeps the log scannable, not verbose.
- **D-13:** **JSON shape**: **bucket-keyed with rich metadata**. Top-level keys are bucket names. Each bucket has:
  - `description` (one-line, lifted into marketplace.json's plugin `description` field)
  - `skills` (array of `./<skill-name>` paths — root-level per Phase 1 D-03-REVISED — ready to drop into marketplace.json's `skills` array verbatim)
  - `notes` (sizing exceptions, catch-all flag, any other special-case metadata)
  Plus a top-level `excluded` array (likely empty under D-06, since misfits go into catch-alls) and per-skill `also_relevant_to` metadata exposed via a separate `skill_metadata` map or inlined per-bucket entry — exact JSON nesting is Claude's discretion as long as the executor can read it without ambiguity.
- **D-14:** **Summary source: verbatim** from each SKILL.md's YAML frontmatter `description` field. No paraphrasing, no truncation, no Claude-written one-liners. Maintains fidelity to upstream wording and removes a layer of interpretive work. (Consistent with Phase 1's "verbatim evidence" convention.)
- **D-15:** **Artifact location: phase-local only.** Both files live at `.planning/phases/02-skill-classification-taxonomy/`. No copy under `docs/`, no symlink at repo root. Follows Phase 1 D-05's GSD convention.

### Mid-Phase Review Checkpoint
- **D-16:** **Mid-phase user-review checkpoint required.** After all 102 SKILL.md descriptions are extracted AND a first-pass bucket assignment is proposed, the executor PAUSES and surfaces:
  - the proposed bucket names and member counts
  - any merge/split moves it made (e.g., "crypto had 4 skills, merged into payloads as `payloads/crypto`")
  - the catch-all bucket shape (multiple themed or single misc)
  - any skills it flagged as borderline with the candidate alternates
  The user approves or requests changes before the final artifact pair is written. This catches bad assignments before they harden into the artifact and propagate to Phase 3.

### Claude's Discretion
- The exact section ordering inside `02-CLASSIFICATION.md` (per-bucket → catch-all → master table → decision log is recommended in D-12 but not load-bearing).
- The exact JSON nesting structure for `also_relevant_to` metadata in `02-CLASSIFICATION.json` (inlined per-bucket vs. a separate top-level map) — must be unambiguous and self-describing.
- Bucket naming convention specifics (terse `recon` vs. descriptive `reconnaissance-and-discovery`) — recommend terse `kebab-case` to match the existing `hack-skills-<topic>` plugin-name convention from REQUIREMENTS.md BUILD-02. Final names emerge from D-02 resize moves anyway.
- Tooling used to extract YAML frontmatter (Bash `awk`/`sed`, a small Node script, subagent dispatch, etc.) — the planner picks based on what minimizes context cost.
- Ordering of skills within each bucket section (alphabetical vs. by-summary-length vs. clustered) — alphabetical recommended for ctrl-F predictability.

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Project context
- `.planning/PROJECT.md` — Core value, constraints (source immutability, group sizing 8–15, group-by-purplehaze-surface — **note: D-04 above clarifies this as a directional heuristic, NOT a precise mapping target**), key decisions table.
- `.planning/REQUIREMENTS.md` §Grouping — GROUP-01/02/03/04 exact wording. **Note: GROUP-04 "intentionally excluded from groups" reads under D-06 as "assigned to a catch-all bucket" rather than "absent from marketplace.json" — see Decisions above.**
- `.planning/ROADMAP.md` §Phase 2 — Goal, dependencies (Phase 1 complete), 5 success criteria. **Success criterion #5 ("every skill appears exactly once") is preserved under D-07.**

### Prior phase context (locked decisions carried forward)
- `.planning/phases/01-schema-verification/01-CONTEXT.md` — Phase 1 implementation decisions, particularly D-03-REVISED.
- `.planning/phases/01-schema-verification/01-VERIFICATION.md` — Schema verification evidence. D-03-REVISED locked the source descriptor and skill-path format for ALL future plugin entries: `source: { source: "git-subdir", url: "https://github.com/yaklang/hack-skills.git", path: "skills" }` with skill paths as root-level `./<skill-name>` (NOT `./skills/<skill-name>`). This is what Phase 3 will emit, and the JSON artifact's `skills` arrays must use that root-level form.

### Pre-existing plan documents
- `docs/PLAN.md` — Marketplace skeleton, grouping strategy (lines 124–142, including the 8 suggested starter buckets), Why Not Other Approaches. The PLAN.md grouping strategy section is the seed for the hybrid derivation in D-01/D-02/D-03.
- `docs/PR-PLAN.md` — Sibling upstream PR effort. Out of scope for this phase, but referenced for context.

### Upstream source (read-only)
- `/Users/spencerpresley/code/hack-skills-wip/hack-skills/skills/` — Local sibling clone of `yaklang/hack-skills`. **102 directories, each containing a `SKILL.md` with YAML frontmatter (`name`, `description`).** The `description` field is the verbatim summary source per D-14. Do NOT modify any file here (PROJECT.md source immutability).
- `https://github.com/yaklang/hack-skills` — Upstream canonical source. Local clone is for reading convenience; the marketplace install path goes through `git-subdir` against the github URL.

### Claude Code platform docs (external, applicable to Phase 3 not Phase 2)
- https://code.claude.com/docs/en/plugin-marketplaces — Full marketplace schema. Phase 3 reads this when authoring plugin entries from the classification artifact.

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- **Local upstream clone** at `/Users/spencerpresley/code/hack-skills-wip/hack-skills/skills/` — 102 subdirs, each with a `SKILL.md`. **Total ~33,384 lines across all SKILL.md files** (full body is too large for context-level read; per-file frontmatter extraction is cheap and what D-14 calls for). Frontmatter shape (verified on `401-403-bypass-techniques/SKILL.md` and `recon-and-methodology/SKILL.md`):
  ```yaml
  ---
  name: <slug>
  description: >-
    <one or more lines of verbatim summary, sometimes folded YAML scalar>
  ---
  ```
  Extracting just the frontmatter yields ~100 chars/skill × 102 skills ≈ ~10KB of summary content total — fits comfortably in any agent's context budget.
- **`RELATED ROUTING` cross-references inside each SKILL.md body** (visible in section "0. RELATED ROUTING" of skills that have one) — these are explicit semantic neighbors authored by the upstream maintainers. They are useful signal for the D-09 tiebreaker (which bucket does the skill consider itself adjacent to?). The planner may choose to extract these into structured per-skill neighbor lists as a secondary input.
- **Current `.claude-plugin/marketplace.json`** — already contains Phase 1's two test plugins (`hack-skills-recon` with 1 skill, `hack-skills-auth-bypass` with 2 skills) using `git-subdir` source with root-level skill paths. Useful as a **schema reference** for Phase 3, but **NOT** load-bearing for Phase 2 — Phase 2 produces the classification artifacts only and does not edit `marketplace.json`.

### Established Patterns
- **Phase 1 D-05 (GSD convention):** phase artifacts live under `.planning/phases/${padded_phase}-${slug}/`. D-15 follows this — both classification files at `.planning/phases/02-skill-classification-taxonomy/`.
- **Phase 1 SPECIFICS / verbatim-evidence convention:** verbatim quote blocks beat paraphrase for any externally-sourced text. D-14 (verbatim SKILL.md descriptions) is a direct application.
- **Phase 1 verification artifact** (`01-VERIFICATION.md`) is the existing precedent for "phase produces a structured report consumed by the next phase." The classification artifact pair plays a similar role for Phase 3.

### Integration Points
- `02-CLASSIFICATION.json` is the integration point with Phase 3. Phase 3's executor reads it, iterates over the bucket-keyed map, and emits one marketplace.json plugin entry per bucket using D-13's structure.
- The mid-phase checkpoint (D-16) is the only user-facing interaction during execution.
- No code changes to non-planning files in Phase 2. `.claude-plugin/marketplace.json` is untouched; only `.planning/phases/02-.../` files are written.

</code_context>

<specifics>
## Specific Ideas

- **Sourcing one-line summaries is mechanical, not interpretive.** Each upstream `SKILL.md` already has the answer in its frontmatter `description`. The planner should design around extraction (e.g., `awk` over frontmatter blocks, a tiny Node script, or `find … -print0 | xargs … head`) rather than asking an agent to read each skill and paraphrase.
- **Suggested starter buckets from PLAN.md as the scaffold seed for D-01:** `recon`, `auth-bypass`, `injection`, `payloads`, `mobile`, `binary`, `ad`, `crypto`. Plus an emergent-bucket allowance under D-03 (e.g., visible upstream candidates that could plausibly meet the 8+ cluster bar: `cloud/container/k8s`, `supply-chain`, `forensics`, `ai-ml-security` — these are NOT pre-locked, just observed in `ls`).
- **`RELATED ROUTING` blocks in SKILL.md bodies are a useful but secondary signal.** Frontmatter `description` is the primary signal per D-09. The planner may choose to extract `RELATED ROUTING` cross-references during the read pass to feed into D-09 judgment calls, OR defer that as a later optimization. Keeping the first pass to "frontmatter only" minimizes context cost.
- **Mid-phase checkpoint format (D-16) should be compact**: bucket name + member count + any merge/split notes + the borderline list with alternates. Not the full member-by-member dump. The full dump is the final artifact; the checkpoint is the proposed shape.
- **`also_relevant_to` should be rare, not pervasive.** It is for genuine close calls, not for every skill that has tangential overlap with another bucket. The decision log section in D-12 is the place to surface only the non-obvious calls.

</specifics>

<deferred>
## Deferred Ideas

- **Bucket-name finalization**: the actual list of final bucket names won't be known until execution. They emerge from D-01 + D-02 + D-03 + the mid-phase checkpoint. Plan should not pre-lock bucket names — the artifact's bucket list is the load-bearing output, not a planning input.
- **purplehaze-feature-surface mapping** — explicitly out of scope per D-04. Spencer handles purplehaze-specific tailoring in normal sessions. If a future milestone needs that mapping (e.g., "which buckets to default-enable when starting a purplehaze session"), that's its own work — likely v2 if it ever exists.
- **Soft assignment / multi-membership** — explicitly rejected via D-08. Could be revisited in a future taxonomy refinement if hard-assignment proves limiting in practice.
- **Bucket descriptions for marketplace.json** — D-13 says the JSON `description` field per bucket is lifted into marketplace.json's plugin `description`. Generating those descriptions is part of Phase 2's output. They should be concise (one line, mirrors the wondelai-skills tone observed in Phase 1 PATTERNS.md) and downstream of the bucket shape, not pre-locked.
- **Sync/refresh process for upstream changes** — already deferred to v2 (`SYNC-01`, `SYNC-02` in REQUIREMENTS.md). Out of scope for Phase 2.
- **README listing each group's skill set** — already deferred to v2 (`DISC-01`). Could later be auto-generated from `02-CLASSIFICATION.json`, but that's a v2 concern.
- **Extraction of `RELATED ROUTING` cross-references as a structured neighbor graph** — useful potential input but not load-bearing for the first pass. Could be added if first-pass classification reveals too many ambiguous D-09 calls.

</deferred>

---

*Phase: 02-Skill Classification & Taxonomy*
*Context gathered: 2026-05-22*
