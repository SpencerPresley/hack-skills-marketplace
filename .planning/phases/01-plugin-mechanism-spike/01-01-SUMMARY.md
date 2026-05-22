---
phase: 01-plugin-mechanism-spike
plan: 01
subsystem: infra
tags: [plugin, marketplace, hooks, session-start, user-prompt-submit, claude-plugin-root, bash, stub]

requires:
  - phase: 01-plugin-mechanism-spike
    provides: research + patterns spec for sidecar plugin tree

provides:
  - plugins/hack-skills-router/ sidecar plugin directory (first plugin in this repo authored in-repo)
  - .claude-plugin/plugin.json — minimal four-field manifest (name, description, version, author)
  - skills/hack-skills-router/SKILL.md — stub router skill with keyword-dense STUB description (≤30-line body)
  - hooks/hooks.json — declarative SessionStart + UserPromptSubmit wiring via bash + double-quoted ${CLAUDE_PLUGIN_ROOT}
  - hooks/scripts/session-start.sh + nudge.sh — stub bash scripts emitting Phase-marker text via single-quoted heredoc
  - Executable bit (0755) set on both hook scripts so Pitfall 2 (silent hook non-fire) is mitigated before Plan 03 UAT
affects:
  - 01-02 (marketplace entry append — points at this tree)
  - 01-03 (install UAT — verifies the tree this plan built)
  - 02-* (Phase 2 SKILL.md body + patterns/ + examples/ rewrite)
  - 03-* (Phase 3 hook script payload rewrite + in-script regex for nudge.sh)

tech-stack:
  added:
    - bash (system) — hook script runtime
    - jq (already available) — used for JSON shape verification only, no runtime dep
  patterns:
    - "Sidecar plugin pattern: original-authored content under plugins/<name>/ (not bundled into v1's curation plugins)"
    - "Relative-path plugin source: marketplace entry points at in-repo dir via './plugins/<name>' (Plan 02 owns the actual entry)"
    - "Double-quoted ${CLAUDE_PLUGIN_ROOT} in shell-form hook commands — survives spaces in cache paths"
    - "Single-quoted heredoc 'cat <<'\\''EOF'\\''' — suppresses variable expansion in stub bodies"
    - "Discrete chmod task — never a footnote (per PATTERNS.md §Executable Bit Discipline)"
    - "STUB vs FINAL boundary: plugin.json + hooks.json structural shape final in Phase 1; SKILL.md body and .sh script bodies are stubs replaced by Phase 2 and Phase 3 respectively"

key-files:
  created:
    - plugins/hack-skills-router/.claude-plugin/plugin.json
    - plugins/hack-skills-router/skills/hack-skills-router/SKILL.md
    - plugins/hack-skills-router/hooks/hooks.json
    - plugins/hack-skills-router/hooks/scripts/session-start.sh
    - plugins/hack-skills-router/hooks/scripts/nudge.sh
  modified: []

key-decisions:
  - "SessionStart matcher: explicit four-event form 'startup|resume|clear|compact' chosen over design spec's equivalent '*' for documentation clarity (RESEARCH §Pattern 4 — both forms equivalent)"
  - "UserPromptSubmit matcher: 'XSS' placeholder kept as forward-doc only — Phase 3 moves filtering into nudge.sh because CC 2.1.x silently ignores the matcher on this event (RESEARCH §Pitfall 3)"
  - "SKILL.md frontmatter: 'name' omitted (directory name supplies it). 'user-invocable: false' and 'disable-model-invocation: true' both forbidden in Phase 1 — the first would hide the skill from claude plugin details (Phase 1 SC #4 requires it visible), the second would block desired auto-load"
  - "Executable bit handled as its own discrete task (Task 4) — Pitfall 2 is silent-failure-mode; PATTERNS.md §Executable Bit Discipline calls for never burying chmod as a footnote"

patterns-established:
  - "Sidecar plugin layout: plugins/<name>/{.claude-plugin/plugin.json, skills/<name>/SKILL.md, hooks/hooks.json, hooks/scripts/*.sh}"
  - "Stub echo pattern: #!/bin/bash shebang + cat <<'EOF' single-quoted heredoc + explicit exit 0"
  - "Stub marker convention: '[Phase N stub] <Event> hook fired.' lines provide grep-anchor strings for downstream UAT plans"

requirements-completed:
  - PLUGIN-01

duration: 3m
completed: 2026-05-22
---

# Phase 1 Plan 01: Author hack-skills-router plugin tree (stubs) Summary

**Created the entire plugins/hack-skills-router/ sidecar tree: minimal plugin.json, stub SKILL.md, hooks.json wiring both SessionStart + UserPromptSubmit, two stub bash scripts (executable, single-quoted heredoc, explicit exit 0).**

## Performance

- **Duration:** 3m 3s
- **Started:** 2026-05-22T15:40:01Z
- **Completed:** 2026-05-22T15:43:04Z
- **Tasks:** 4
- **Files created:** 5 (5 new, 0 modified)

## Accomplishments

- First sidecar plugin under `plugins/` directory ever committed to this repo — the v1 milestone shipped 13 pure curations with no in-repo plugin tree; Phase 1 introduces the layout pattern Phase 2 (SKILL.md body) and Phase 3 (hook payloads) will build on.
- `plugin.json` manifest declares plugin identity with the four-field minimal shape from design spec §5.2 — no rust-skills optional fields, no `displayName`, single source of truth for `version`.
- `SKILL.md` stub frontmatter ships a STUB-tagged keyword-dense description so `claude plugin details` will see and list the skill once Plan 02's marketplace entry lands; body is 25 lines (cap = 30 per ROADMAP SC #3).
- `hooks/hooks.json` declares both SessionStart (matcher `startup|resume|clear|compact`, timeout 5) and UserPromptSubmit (matcher `XSS` placeholder, timeout 3); commands use `bash "${CLAUDE_PLUGIN_ROOT}/hooks/scripts/<name>.sh"` with double-quoted env var per RESEARCH Pitfall 6.
- Both hook scripts use the canonical shape: shebang `#!/bin/bash`, `cat <<'EOF'` single-quoted heredoc body (suppresses variable expansion in stub text), explicit `exit 0`, and grep-anchor markers `[Phase 1 stub] SessionStart hook fired.` / `[Phase 1 stub] UserPromptSubmit hook fired.` that Plan 03 UAT can match.
- Executable bit `0755` set on both `.sh` scripts via discrete Task 4 — mitigating RESEARCH Pitfall 2 (silent hook non-fire) before Plan 03 runs the live install UAT. Git records `mode change 100644 => 100755` for both files.

## Task Commits

Each task was committed atomically:

1. **Task 1: Author plugin.json** — `e2939ae` (feat)
2. **Task 2: Author SKILL.md stub** — `6ef1d68` (feat)
3. **Task 3: Author hooks.json + both stub scripts** — `726e6ba` (feat)
4. **Task 4: chmod +x on both hook scripts** — `a48e6a6` (chore — mode-only change, content sha256 byte-identical)

## Files Created/Modified

- `plugins/hack-skills-router/.claude-plugin/plugin.json` — 8 lines (181 bytes); minimal four-field manifest declaring plugin identity (name, description, version, author).
- `plugins/hack-skills-router/skills/hack-skills-router/SKILL.md` — 28 lines total (1577 bytes); YAML frontmatter with STUB description + 25-line body announcing Phase 2 will replace it (≤30 cap).
- `plugins/hack-skills-router/hooks/hooks.json` — 29 lines (712 bytes); declarative SessionStart + UserPromptSubmit configuration with explicit timeouts and double-quoted `${CLAUDE_PLUGIN_ROOT}` paths.
- `plugins/hack-skills-router/hooks/scripts/session-start.sh` — 11 lines (279 bytes); stub bash emitting `=== HACK-SKILLS ROUTER (STUB) ===` banner + `[Phase 1 stub] SessionStart hook fired.` marker; mode 0755.
- `plugins/hack-skills-router/hooks/scripts/nudge.sh` — 14 lines (552 bytes); stub bash emitting `=== HACK-SKILLS NUDGE (STUB) ===` banner + `[Phase 1 stub] UserPromptSubmit hook fired.` marker with comment documenting Phase 1's intentional fires-on-every-prompt behavior; mode 0755.

## chmod outcome

`ls -l plugins/hack-skills-router/hooks/scripts/` after Task 4:

```
-rwxr-xr-x@ 1 spencerpresley  staff  552 May 22 11:41 nudge.sh
-rwxr-xr-x@ 1 spencerpresley  staff  279 May 22 11:41 session-start.sh
```

Both files at mode `0755` (rwxr-xr-x). Owner-octal digit is `7` (odd → +x for owner). Content unchanged across the chmod (sha256 byte-identical pre/post). Git records the mode bump as `mode change 100644 => 100755` for both files.

## Decisions Made

- **SessionStart matcher form:** Used the explicit four-event form `startup|resume|clear|compact` rather than the equivalent `*` from design spec §5.3. Both forms are accepted (per RESEARCH §Pattern 4) and behave identically; the explicit form documents which events fire the hook without requiring a docs round-trip. Phase 3 can revisit if a narrower subset becomes desirable.
- **UserPromptSubmit matcher kept as `XSS` placeholder:** The matcher is silently ignored in Claude Code 2.1.x (RESEARCH Pitfall 3) — kept as a forward-doc signal of "filtering belongs here intent-wise but works elsewhere in this version." Phase 3 will move the full security-context regex into `nudge.sh` (read `$PROMPT` from stdin JSON, grep, exit 0 silently on no match).
- **`version` kept in `plugin.json` only:** Marketplace entry (Plan 02 owns) carries `version` too per design spec §5.1, but per Pitfall 4 `plugin.json` silently wins if both are set. This plan keeps `version` in `plugin.json` as the single source of truth; Plan 02's marketplace entry can still carry `version` for design-spec parity, but the maintenance recommendation flagged in research is to drop it from the marketplace entry on a future polish pass.
- **chmod as its own task:** Task 4 is intentionally a discrete one-action task rather than appended to Task 3. PATTERNS.md §Executable Bit Discipline calls this out explicitly — the failure mode (Pitfall 2) is silent and the trap is easy to overlook if buried.

## Deviations from Plan

None - plan executed exactly as written.

The plan's per-task acceptance criteria and the plan-level verification block both pass without auto-fixes. No CLAUDE.md directives required adjustment; no missing critical functionality discovered; no blocking issues encountered.

## Issues Encountered

None. All four tasks were straightforward Write/chmod operations with explicit verifications attached at every step.

## Verification

All five plan-level verification probes pass:

1. Directory structure: `plugins/hack-skills-router/{.claude-plugin,skills/hack-skills-router,hooks/scripts}` all exist.
2. Five files present (loop test): all five paths exist as regular files.
3. JSON validity: `jq empty` succeeds on both `plugin.json` and `hooks.json`.
4. Executable bit: `test -x` succeeds on both `session-start.sh` and `nudge.sh`.
5. `.claude-plugin/marketplace.json` untouched: `git diff --name-only HEAD .claude-plugin/marketplace.json` returns empty; `git log --oneline -5 -- .claude-plugin/marketplace.json` shows no commits from this plan touched it (Plan 02 owns that edit).

Additionally, the per-task `<automated>` verify probes (jq expressions, head/grep on shebangs, awk frontmatter line count) all pass.

## Self-Check: PASSED

- All five created files exist at their declared paths (file-existence loop confirmed in plan-level check 2).
- All four task commits are present and reachable from HEAD: `e2939ae`, `6ef1d68`, `726e6ba`, `a48e6a6` (verified via `git log --oneline -5`).
- Both hook scripts have the executable bit set (verified via `test -x` and via the stat octal mode being `755`).
- No file outside `plugins/hack-skills-router/` was modified by this plan (verified via `git diff --name-only HEAD .claude-plugin/marketplace.json` returning empty).

## Next Phase Readiness

- **Plan 02 ready:** appends the 14th marketplace entry pointing at `./plugins/hack-skills-router` with `name=hack-skills-router`, `version=0.1.0`, `description="Routing + scaffolding for hack-skills topical plugins. Adapted from yaklang/hack-skills upstream router."`, `keywords=["security","pentest","router","hooks","methodology"]`. This plan touched zero bytes of `.claude-plugin/marketplace.json`, so Plan 02 can merge cleanly.
- **Plan 03 ready:** executes the live install UAT — `claude plugin install hack-skills-router@hack-skills-marketplace`, then `claude plugin details hack-skills-router`, then a fresh-session check for the SessionStart marker text and an any-prompt check for the UserPromptSubmit marker text. Both marker strings (`[Phase 1 stub] SessionStart hook fired.` and `[Phase 1 stub] UserPromptSubmit hook fired.`) are present in this plan's scripts and the executable bit is set, so Plan 03 has every input it needs.
- **Phase 2 ready:** Will replace SKILL.md frontmatter description + body (~80 lines per design spec §5.7) and add `skills/hack-skills-router/patterns/{routing-tables,expert-intuitions}.md` + `examples/workflow-walkthroughs.md`. The directory `skills/hack-skills-router/` already exists; Phase 2 just adds children and rewrites SKILL.md in place.
- **Phase 3 ready:** Will replace both `hooks/scripts/*.sh` script bodies with the real ~250 tok (SessionStart) and ~75 tok (UserPromptSubmit) payloads + the in-script regex for nudge.sh. The shebang + heredoc + exit-0 shape and the `0755` mode persist across the rewrite; Phase 3 only changes script content.

---
*Phase: 01-plugin-mechanism-spike*
*Plan: 01*
*Completed: 2026-05-22*
