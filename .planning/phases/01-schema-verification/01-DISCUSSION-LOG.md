# Phase 1: Schema Verification - Discussion Log

> **Audit trail only.** Do not use as input to planning, research, or execution agents.
> Decisions are captured in CONTEXT.md — this log preserves the alternatives considered.

**Date:** 2026-05-22
**Phase:** 01-Schema Verification
**Areas discussed:** Test group composition, Install source, Verification artifact, Context-isolation measurement (all delegated to Claude's discretion)

---

## Pre-discussion Framing

Claude scouted prior context: `PROJECT.md`, `REQUIREMENTS.md`, `STATE.md`, `ROADMAP.md`, `docs/PLAN.md`, `docs/PR-PLAN.md`, the empty `.claude-plugin/marketplace.json`, and the local upstream clone at `~/code/hack-skills-wip/hack-skills/` (102 skills confirmed). No prior phase CONTEXT.md exists (Phase 1 is first executable phase). No SPEC.md. No blocking anti-patterns.

Four gray areas were identified for Phase 1 (HOW to run the verification, since VERIFY-01/02/03 already lock WHAT is verified):

1. Test group composition
2. Install source for verification
3. Verification artifact location/format
4. Context-isolation measurement method

These were presented for selection. The user interrupted before answering and stated: "Do whatever you would advise. None of them seem all that significant so you have my trust to decide."

All four areas were therefore resolved as Claude's discretion. The choices made — and the alternatives considered — are recorded below for audit.

---

## Test Group Composition

| Option | Description | Selected |
|--------|-------------|----------|
| Use PLAN.md's suggested examples verbatim (`recon` + `auth-bypass`) | Pulls 3 specific individual skill paths from `docs/PLAN.md` lines 92–119. Both buckets are real PROJECT.md candidates. | ✓ |
| Pick deliberately distant topics not yet earmarked | Maximizes isolation signal but creates throwaway groups. | |
| Pick buckets you'd keep for Phase 3 regardless | Mostly subsumed by Option 1 — PLAN.md's picks already serve this. | |

**Claude's choice:** Option 1 — `hack-skills-recon` with `./skills/api-recon-and-docs`, and `hack-skills-auth-bypass` with `./skills/401-403-bypass-techniques` and `./skills/api-auth-and-jwt-abuse`.
**Rationale:** PLAN.md's picks are already implicitly endorsed (user wrote that doc). Using them removes a decision point, keeps the test mapped 1:1 to existing documentation, and still gives 3 individual paths across 2 groups — exactly what VERIFY-01 needs to exercise.

---

## Install Source for Verification

| Option | Description | Selected |
|--------|-------------|----------|
| Local path only | `/plugin marketplace add ./hack-skills-marketplace`. Fast iteration, no git push needed. | ✓ |
| Pushed to GitHub | Realistic Phase 4–style flow. Requires commit+push round-trip per iteration. | |
| Both (local first, then github) | Most coverage but doubles the work and overlaps with Phase 4 scope. | |

**Claude's choice:** Local path only.
**Rationale:** Phase 4 explicitly owns end-to-end published-repo install validation (PUB-02, PUB-03, PUB-04). Duplicating it in Phase 1 muddies the phase boundary and slows iteration during the schema unknowns. If local-path verification passes, the github install in Phase 4 is the natural extension.

---

## Verification Artifact Location/Format

| Option | Description | Selected |
|--------|-------------|----------|
| `.planning/phases/01-schema-verification/01-VERIFICATION.md` | GSD-style phase-local artifact. Lives alongside the phase's CONTEXT/PLAN/SUMMARY. | ✓ |
| `docs/VERIFICATION.md` | Sibling of PLAN.md and PR-PLAN.md. More discoverable for users browsing the repo. | |
| Appended section to `docs/PLAN.md` | Keeps open questions + answers together but bloats PLAN.md and breaks the GSD convention. | |

**Claude's choice:** Phase-local at `.planning/phases/01-schema-verification/01-VERIFICATION.md`.
**Rationale:** GSD convention is per-phase artifacts under `.planning/phases/${padded_phase}-${slug}/`. Following that convention here sets clean precedent for later phases. `docs/` stays reserved for longer-lived, user-facing plan documents (PLAN.md, PR-PLAN.md).

---

## Context-Isolation Measurement Method (for VERIFY-02)

| Option | Description | Selected |
|--------|-------------|----------|
| System reminder inspection only | Fresh Claude Code session, capture the `# available-skills` block. Ground truth. | |
| `/plugin` CLI command output only | Faster but indirect — tells you what is enabled, not what is actually injected into context. | |
| Both, system reminder as primary | Dual evidence for VERIFY-02; system reminder is authoritative, `/plugin` is sanity check. | ✓ |

**Claude's choice:** Both, with the system-reminder excerpt treated as ground truth.
**Rationale:** The system reminder is literally what the model receives — it's the only authoritative answer to "what skills does this session see." The `/plugin` snapshot is cheap and catches install/enable mismatches early. Using both keeps the evidence robust without much extra effort. VERIFY-01 and VERIFY-03 don't need dual measurement (file path resolution and cache directory inspection are direct observations).

---

## Pivot Policy (Roadmap Success Criterion #5)

Pre-decided in advance because Phase 2 cannot start until a pivot stance exists for each "no" outcome.

| VERIFY question | "No" outcome stance |
|---|---|
| VERIFY-01 (individual paths work) | Halt before Phase 2. Symlinks rejected (PROJECT.md). Restructuring upstream rejected. A "no" forces a separate decision conversation. |
| VERIFY-02 (context isolation) | Halt. The whole value-prop collapses if curated `skills` arrays still leak the full source repo. |
| VERIFY-03 (per-plugin cache) | Document the collision behavior, evaluate workaround viability. Likely allows continuation if VERIFY-01/02 pass. |

---

## Claude's Discretion

User explicitly granted full discretion on all four gray areas with the message: "Do whatever you would advise. None of them seem all that significant so you have my trust to decide."

Additional discretion-level items captured in CONTEXT.md D-section as "Claude's Discretion":
- Internal structure (headings, table-vs-prose) of `01-VERIFICATION.md` — planner picks.
- Whether to keep the test `marketplace.json` after verification or scrub for Phase 3 — planner can decide based on forward compatibility.
- Exact wording of documented install/observation commands — must be reproducible, format open.

---

## Deferred Ideas

- Github-install validation → Phase 4 (PUB-02..04).
- Full skill classification across all 102 skills → Phase 2 (GROUP-01..04).
- Full ~8-group build-out → Phase 3 (BUILD-01..03).
- Upstream-sync refresh process → v2 backlog (SYNC-01, SYNC-02).
- README listing every group's skill set → v2 backlog (DISC-01).
- Upstream PR to `yaklang/hack-skills` → tracked separately in `docs/PR-PLAN.md`, out of scope for this project.
