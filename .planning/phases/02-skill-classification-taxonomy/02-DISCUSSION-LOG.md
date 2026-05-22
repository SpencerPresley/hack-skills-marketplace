# Phase 2: Skill Classification & Taxonomy - Discussion Log

> **Audit trail only.** Do not use as input to planning, research, or execution agents.
> Decisions are captured in CONTEXT.md — this log preserves the alternatives considered.

**Date:** 2026-05-22
**Phase:** 02-Skill Classification & Taxonomy
**Areas discussed:** Taxonomy derivation approach, Cross-bucket overlap policy, Classification artifact format

---

## Taxonomy derivation approach

### Q1: How should we derive the final group taxonomy from the 102 skills?

| Option | Description | Selected |
|--------|-------------|----------|
| Hybrid | Use PLAN.md's 8 starters as scaffold; assign each skill, then refine (merge/split). | ✓ |
| Top-down strict | Lock the 8 PLAN buckets, force every skill into one or 'excluded'. | |
| Bottom-up clustering | Ignore PLAN entirely, cluster organically from what's read. | |

**User's choice:** Hybrid (Recommended).

---

### Q2: When a PLAN-suggested bucket lands outside 8–15 after first-pass assignment, what's the policy?

| Option | Description | Selected |
|--------|-------------|----------|
| Aggressive merge + split | <5 merges into closest related; >15 splits along subtopic. | ✓ |
| Merge only, never split | <5 merges; >15 stays oversized (violates GROUP-03). | |
| Split only, never merge | <5 stays as standalone; >15 splits. | |
| Strict 8–15, prefer drop over merge | <5 drops to excluded/distributes; >15 splits. | |

**User's choice:** Aggressive merge + split (Recommended).

---

### Q3: If 8+ skills cluster around a theme that PLAN.md didn't list, do we add a new bucket?

| Option | Description | Selected |
|--------|-------------|----------|
| Yes, add if 8+ cluster | Hybrid in both directions; new buckets emerge from data. | ✓ |
| Strict 8 from PLAN.md | Force into original 8 or excluded; no new buckets. | |
| Add only if I approve case-by-case | Surface emergent clusters as checkpoint decisions. | |

**User's choice:** Yes, add if 8+ cluster (Recommended).

---

### Q4: Before the classification artifact is committed and Phase 3 unlocks, do you want to review/edit the proposed taxonomy?

| Option | Description | Selected |
|--------|-------------|----------|
| Yes — mid-phase checkpoint | Executor pauses, shows proposed taxonomy, user approves/edits. | ✓ |
| No — executor commits autonomously | One-pass write; review only via final artifact. | |
| Yes, but only on conflicts | Pause only on hard judgment calls. | |

**User's choice:** Yes — mid-phase checkpoint (Recommended).

---

### Q5: Continuation check — More questions or move on?

| Option | Description | Selected |
|--------|-------------|----------|
| Next area | Taxonomy locked. | |
| More questions | Still gray areas. | |

**User's choice (free-text via Other):** *"you dont need to worry about purplehaze specifically for this, ill do that in normal sessions, this decomposition is to just make that better. If you need to ask more questions then feel free."*
**Notes:** This was a substantive reframe. Surfaced two follow-up questions to firm up the new framing — see Q6 and Q7 below.

---

### Q6: If 'purplehaze-relevance' isn't the grouping lens, what IS the lens for deciding buckets?

| Option | Description | Selected |
|--------|-------------|----------|
| Skill-content topicality | Group by what the skill teaches/covers. | ✓ |
| Session-use clustering | Group by "what would you want loaded together in a session". | |
| Attack-stage / kill-chain | Group by recon → access → exploit → post-ex → persistence. | |

**User's choice:** Skill-content topicality (Recommended).

---

### Q7: Does the 'excluded skills' bucket (GROUP-04) still apply, or do all 102 skills get bucketed somewhere?

| Option | Description | Selected |
|--------|-------------|----------|
| Still exclude misfits | Skills that don't cluster go into an excluded list. | ✓ |
| Bucket everything — create a 'misc' group | All 102 land in a group; misc may exceed 15. | |
| Bucket everything — no misc, force-fit | Every skill in a topical bucket even with weak fit. | |

**User's choice:** Still exclude misfits (Recommended). Refined later in Q8 below.

---

### Q8: What criteria put a skill in the excluded list?

| Option | Description | Selected |
|--------|-------------|----------|
| Standalone / no cluster | Too topically isolated to share a bucket. | ✓ |
| Too generic / redundant | Overlaps heavily with multiple others or thin wrapper. | ✓ |
| Out-of-domain | Not really offensive-security topical content. | |
| Niche / low-likelihood-of-use | Real but narrow topic unlikely to come up. | |

**User's choice (multi-select + free-text via Other):** Standalone + Too generic/redundant, plus the note: *"for those in the excluded ones could make a catch all bucket for them"*.
**Notes:** This refined Q7 — misfits are NOT dropped from marketplace.json. They go into a catch-all bucket. CONTEXT.md D-06 captures the refinement.

---

### Q9: On the catch-all bucket: shape and sizing rules?

| Option | Description | Selected |
|--------|-------------|----------|
| One bucket, ignore 8–15 cap | Single `hack-skills-misc`, accept oversize. | |
| One bucket, must fit 8–15 | Single misc, force-fit overage back into topical buckets. | |
| Multiple themed catch-alls | 2–3 thin clusters each as a bucket aiming for 8–15-ish. | ✓ |
| Drop the catch-all idea | Go back to pure excluded list. | |

**User's choice:** Multiple themed catch-alls (Recommended). With fallback to single oversized misc if misfits don't cluster.

---

## Cross-bucket overlap policy

### Q10: Can a single skill appear in multiple marketplace buckets, or does each skill belong to exactly one?

| Option | Description | Selected |
|--------|-------------|----------|
| Hard assignment — one bucket per skill | Each skill in exactly one group in marketplace.json. | ✓ |
| Soft assignment — explicit multi-membership | A skill can appear in multiple plugin entries. | |
| Hard primary + tag for related | One bucket in marketplace.json, but artifact tracks alternates. | |

**User's choice:** Hard assignment (Recommended).

---

### Q11: When a skill fits two buckets ~equally well, how do we decide?

| Option | Description | Selected |
|--------|-------------|----------|
| Primary attack surface in SKILL.md | Skill's own description + intro framing wins. | ✓ |
| Smaller bucket gets the skill | Balancing rule for sizing. | |
| Surface conflict at mid-phase checkpoint | User decides per-case. | |

**User's choice (free-text via Other):** *"Number 1 and just your best judgement given the totality of circumstances"*.
**Notes:** Primary rule = SKILL.md's own framing; secondary = Claude's judgment using all available context (semantic neighbors, bucket sizes, taxonomy shape). User is delegating discretion on borderline calls. Captured in CONTEXT.md D-09.

---

### Q12: For close calls, should the artifact note 'also-relevant-to'?

| Option | Description | Selected |
|--------|-------------|----------|
| Yes — note alternates for close calls | Metadata in artifact, doesn't change marketplace.json. | ✓ |
| No — single bucket assignment only | No alternates tracked. | |
| Only for true conflicts (60/40 fit) | Reduce metadata noise, harder threshold. | |

**User's choice:** Yes — note alternates for close calls (Recommended).

---

### Q13: Continuation check — More questions or move on?

| Option | Description | Selected |
|--------|-------------|----------|
| Next area | Overlap locked. | ✓ |
| More questions | Still gray areas. | |

**User's choice:** Next area.

---

## Classification artifact format

### Q14: What does the classification artifact actually look like — single file, multiple, machine-readable?

| Option | Description | Selected |
|--------|-------------|----------|
| Markdown + JSON sibling | Two files; markdown for humans, JSON for Phase 3 executor. | ✓ |
| Single markdown only | Phase 3 parses markdown table/sections. | |
| Single JSON only | Executor-ready, less human-readable. | |
| Markdown table only, no JSON | One 102-row table, no per-bucket prose. | |

**User's choice:** Markdown + JSON sibling (Recommended).

---

### Q15: What sections live in `02-CLASSIFICATION.md`?

| Option | Description | Selected |
|--------|-------------|----------|
| Per-bucket sections | One section per group with member list. | (deferred) |
| Catch-all / excluded section | Dedicated section for misfits. | (deferred) |
| Master 102-row table | Single ctrl-F-able table. | (deferred) |
| Decision log / rationale section | Notes on tough calls. | (deferred) |

**User's choice (free-text via Other):** *"whichever you recommend"*.
**Notes:** Delegated to Claude's discretion. Recommendation captured in CONTEXT.md D-12: include all four sections, in order (per-bucket → catch-all → master table → decision log), with decision log limited to non-obvious close calls only.

---

### Q16: What's the shape of `02-CLASSIFICATION.json`?

| Option | Description | Selected |
|--------|-------------|----------|
| Bucket-keyed with rich metadata | Top-level keys = buckets; each has description, skills array, notes. | ✓ |
| Flat skill list | Single array of skill objects; Phase 3 groups itself. | |
| Both bucket-keyed AND flat skill list | Dual representation, no parsing ambiguity. | |

**User's choice:** Bucket-keyed with rich metadata (Recommended).

---

### Q17: Where does each skill's one-line summary come from?

| Option | Description | Selected |
|--------|-------------|----------|
| Verbatim from SKILL.md frontmatter `description` | Mechanical extraction, no paraphrasing. | ✓ |
| Paraphrased / Claude-written | Claude reads + writes tighter one-liners. | |
| Verbatim, then truncate if too long | Hybrid for length-bounded fidelity. | |

**User's choice:** Verbatim from SKILL.md frontmatter `description` (Recommended).

---

### Q18: Where do the two artifact files live?

| Option | Description | Selected |
|--------|-------------|----------|
| Phase-local only | `.planning/phases/02-skill-classification-taxonomy/`. | ✓ |
| Phase-local + copy in `docs/` | Two copies, drift risk. | |
| Phase-local + symlink in repo root | Visible but tooling-fragile. | |

**User's choice:** Phase-local only (Recommended).

---

### Q19: Final check — ready for context, or explore more?

| Option | Description | Selected |
|--------|-------------|----------|
| I'm ready for context | Decisions clear enough; write CONTEXT.md. | ✓ |
| Explore more gray areas | Pick up unaddressed gray areas. | |

**User's choice:** I'm ready for context.

---

## Claude's Discretion

Areas where the user delegated or explicitly said "you decide":

- **Markdown section ordering and content** (Q15): user said "whichever you recommend". Recommendation captured in CONTEXT.md D-12.
- **Tiebreaker for borderline bucket assignments** (Q11): "just your best judgement given the totality of circumstances" — Claude has discretion on close calls after applying the primary rule (SKILL.md's own framing).
- **Bucket naming convention specifics** (not directly asked, deferred to Claude): recommend terse `kebab-case` matching `hack-skills-<topic>` plugin-name shape.
- **JSON nesting for `also_relevant_to` metadata** (D-13 / Q16): exact structure left to Claude as long as the executor can read it without ambiguity.
- **Extraction tooling** (D-14 follow-up): planner picks `awk`/`sed`/Node-script/subagent-dispatch based on context-cost minimization.
- **Skill ordering inside bucket sections**: alphabetical recommended, not load-bearing.

## Deferred Ideas

- **Bucket-name finalization** — emerges from execution; not pre-lockable.
- **`RELATED ROUTING` neighbor graph extraction** — useful but secondary signal; first pass uses frontmatter only.
- **Soft assignment / multi-membership** — rejected via D-08; could revisit in future taxonomy refinement.
- **purplehaze-feature-surface mapping** — explicitly out of scope per D-04 reframe; Spencer handles in normal sessions.
- **Auto-generated README listing each group's skills** — v2 (`DISC-01`).
- **Sync/refresh process for upstream changes** — v2 (`SYNC-01`, `SYNC-02`).
