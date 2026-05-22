---
phase: 01-plugin-mechanism-spike
reviewed: 2026-05-22T00:00:00Z
depth: standard
files_reviewed: 6
files_reviewed_list:
  - .claude-plugin/marketplace.json
  - plugins/hack-skills-router/.claude-plugin/plugin.json
  - plugins/hack-skills-router/hooks/hooks.json
  - plugins/hack-skills-router/hooks/scripts/nudge.sh
  - plugins/hack-skills-router/hooks/scripts/session-start.sh
  - plugins/hack-skills-router/skills/hack-skills-router/SKILL.md
findings:
  critical: 0
  warning: 1
  info: 3
  total: 4
status: issues_found
---

# Phase 01: Code Review Report

**Reviewed:** 2026-05-22
**Depth:** standard
**Files Reviewed:** 6
**Status:** issues_found

## Summary

This phase is an explicit mechanism-validation spike: scripts intentionally print marker strings, `SKILL.md` is a placeholder for Phase 2, and the UserPromptSubmit `matcher` is forward-doc only (matcher is silently ignored by Claude Code 2.1.x for that event per `01-RESEARCH.md` §Pitfall 3 / §UserPromptSubmit findings). Findings below explicitly exclude the "stubness" of the artifacts — those are intended.

The implementation is functionally consistent with the design spec and with the SUMMARY's documented UAT observations (`/tmp/01-03-plugin-details.txt`, fresh-session banner echo, etc.). No security vulnerabilities, no logic errors, no correctness defects. All JSON files parse, both shell scripts have correct shebangs and `0755` permissions, and `marketplace.json` has no duplicate plugin names across its 14 entries.

The one **WARNING** is a forward-collaboration concern: `hooks.json` declares `"matcher": "XSS"` on `UserPromptSubmit` without any in-file marker explaining that the matcher is non-functional. `01-RESEARCH.md` line 249 explicitly recommended adding a `comment-on-matcher` sibling field for exactly this reason (so a Phase 3 collaborator reading only `hooks.json` doesn't conclude the matcher is doing real gating work). That recommendation was not carried into the implementation; the explanatory comment lives only in `nudge.sh` and the planning docs.

The **INFO** items are minor consistency and forward-hardening notes that should be addressed in Phase 3 when the stubs are replaced with real script bodies (in-script regex on `$PROMPT`, error handling, etc.).

## Warnings

### WR-01: hooks.json matcher pitfall is undocumented in the file itself

**File:** `plugins/hack-skills-router/hooks/hooks.json:18`
**Issue:** The `UserPromptSubmit` entry sets `"matcher": "XSS"`, but per Claude Code 2.1.x semantics this field is silently ignored for `UserPromptSubmit` — the hook fires on every prompt regardless. This is documented and intentional for Phase 1 (RESEARCH §Pitfall 3, line 320–323; SUMMARY line 208), and `nudge.sh` carries an inline comment about it, but **`hooks.json` itself contains no signal that the matcher is non-functional**. A Phase 3 collaborator reading only this file is highly likely to assume the matcher is gating execution (which is exactly the failure mode described in RESEARCH §Pitfall 3). RESEARCH line 323 specifically prescribed a remediation: add a `comment-on-matcher` sibling field (a benign unrecognized field that Claude Code warns-but-loads). That remediation was not applied.

**Fix:** Add an explanatory sibling field to the `UserPromptSubmit` entry. Claude Code logs a warning for unrecognized fields but still loads the hook block, so this is safe:

```json
"UserPromptSubmit": [
  {
    "matcher": "XSS",
    "comment-on-matcher": "UserPromptSubmit IGNORES matcher (CC 2.1.x). Forward-doc only; gating moves into nudge.sh in Phase 3.",
    "hooks": [
      {
        "type": "command",
        "command": "bash \"${CLAUDE_PLUGIN_ROOT}/hooks/scripts/nudge.sh\"",
        "timeout": 3
      }
    ]
  }
]
```

Alternatively, since `hooks.json` is JSON (not JSONC) and many tools are stricter about extra keys than Claude Code is, consider co-locating a `hooks/README.md` documenting the matcher caveat and reference it from `nudge.sh`. Either path closes the discoverability gap.

## Info

### IN-01: Shell scripts lack `set -euo pipefail` hardening

**File:** `plugins/hack-skills-router/hooks/scripts/session-start.sh:1-2`, `plugins/hack-skills-router/hooks/scripts/nudge.sh:1-5`
**Issue:** Neither stub script sets bash safety flags. For the Phase 1 stubs this is harmless because each script does exactly `cat <<EOF; exit 0` — there is no command chain to fail. However, Phase 3 will introduce `jq` parsing of stdin JSON, `grep` on `$PROMPT`, and conditional silent-exit logic (per RESEARCH line 291). Without `set -euo pipefail`, a failing `jq` invocation (e.g., malformed stdin payload in a future Claude Code release) silently continues and may emit a confusing partial message. Adding the flags now keeps Phase 3 from having to retrofit.
**Fix:** Add the standard hardening line just after the shebang in both scripts:

```bash
#!/bin/bash
set -euo pipefail
# STUB — Phase 1 mechanism spike. ...
```

This is a non-functional change for the current stubs (`cat <<EOF` cannot fail in any way these flags would catch) but it locks in the safer default before Phase 3 grows the scripts.

### IN-02: SKILL.md frontmatter description references "Phase 2" while body splits Phase 2 vs Phase 3 work

**File:** `plugins/hack-skills-router/skills/hack-skills-router/SKILL.md:2`, `:7-14`
**Issue:** The frontmatter `description` says "Phase 2 will replace this body". The body then correctly notes that **SKILL.md** content is replaced in Phase 2 (lines 7, 16) but **hook payloads** (`nudge.sh`, `session-start.sh`) are replaced in Phase 3 (line 14: "gating moves into nudge.sh in Phase 3"). The frontmatter mentions only Phase 2, which is technically correct for `SKILL.md` itself but a casual reader could conclude the entire spike completes in Phase 2. Minor — this is internal-doc phrasing only and has no functional impact.
**Fix:** Tighten the frontmatter description to scope the Phase 2 statement to SKILL.md specifically. E.g.:

```yaml
description: STUB — routing + scaffolding for security/hacking tasks. Phase 2 will replace this SKILL body with the full router; hook payloads land in Phase 3. ...
```

This is a low-priority cosmetic edit since the Phase 2 body rewrite is expected to overwrite this frontmatter wholesale anyway.

### IN-03: `marketplace.json` router entry is the only plugin with a `keywords` field

**File:** `.claude-plugin/marketplace.json:263`
**Issue:** The `hack-skills-router` plugin entry declares `"keywords": ["security", "pentest", "router", "hooks", "methodology"]`. The 13 sibling topical-skill plugins (lines 8–258) do not declare `keywords`. This is not a bug — Claude Code's marketplace schema tolerates per-entry differences — but the inconsistency is the kind of thing that grows over time if not normalized. If `keywords` carries discoverability or filtering value in the marketplace UI, the 13 topical entries should likely have them too (e.g., the `auth-bypass` entry could have `["security", "pentest", "auth", "jwt", "oauth"]`). If `keywords` does *not* carry such value, the router entry's `keywords` field is dead metadata and could be removed.
**Fix:** Decide one direction. Either:
1. Backfill `keywords` arrays into the 13 topical entries (per-group thematic terms — `auth-bypass`, `recon`, `binary-exploitation`, etc.), OR
2. Remove the router's `keywords` field for consistency, since the router's `description` already covers the searchable terms.

Defer the decision to Phase 4 (marketplace publishing) if it depends on observed discoverability behavior; this finding is filed so it isn't forgotten.

---

_Reviewed: 2026-05-22_
_Reviewer: Claude (gsd-code-reviewer)_
_Depth: standard_
