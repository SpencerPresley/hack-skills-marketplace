# Phase 1: Plugin Mechanism Spike - Research

**Researched:** 2026-05-22
**Domain:** Claude Code plugin marketplace mechanics — local-relative-path sidecar plugin with hooks
**Confidence:** HIGH

## Summary

Phase 1 stands up a sidecar `hack-skills-router` plugin authored in-repo at `plugins/hack-skills-router/`, referenced via relative-path `source` in the marketplace catalog, with stub SKILL.md + hooks/hooks.json declaring SessionStart and UserPromptSubmit hooks (stub shell scripts). The goal is mechanism verification, not content.

The Claude Code official docs at `code.claude.com/docs/en` give an authoritative schema for every artifact this phase produces — relative-path source semantics, plugin.json fields, SKILL.md frontmatter, hooks.json structure, `${CLAUDE_PLUGIN_ROOT}` resolution, and the CLI commands the executor will use to verify (`claude plugin install`, `claude plugin details`, `claude plugin marketplace list`).

**Two load-bearing surprises surfaced during research that the planner must internalise:**

1. **UserPromptSubmit does NOT support `matcher`.** It is silently ignored — the hook fires on EVERY prompt. This invalidates the design spec's §5.3 regex-in-hooks.json approach as a *Claude-side filter*. The regex still belongs in `hooks.json` as documentation/intent, but the actual gating must happen inside the hook script (read `$PROMPT` from stdin JSON, grep, exit 0 silently if no match). This is fine for Phase 1 stubs (we WANT them to fire to verify mechanism), but Phase 3 must absorb this change.
2. **SessionStart fires every session, NOT at install time.** Phase 1 SC #5 ("stub SessionStart inject is observable") requires installing the plugin and then either starting a fresh session OR triggering one of the matchers (`startup|resume|clear|compact`). The first install session is the post-install session start, so observability is achievable, but the planner needs to spell out the session boundary clearly.

**Primary recommendation:** Mirror the rust-skills layout precisely (it's the user's intended analog and exists locally for direct inspection) but with two substitutions: (a) shell scripts under `hooks/scripts/` instead of `.claude/hooks/` (the design spec §4 file tree is correct — `.claude/hooks/` is what rust-skills happens to do, but `hooks/scripts/` is cleaner and the design spec already commits to it), and (b) NO matcher on UserPromptSubmit (matcher field can stay for forward-doc purposes per design spec but won't filter — be explicit in the plan that this is documentation-only until Phase 3 moves filtering into the script).

## Architectural Responsibility Map

| Capability | Primary Tier | Secondary Tier | Rationale |
|------------|-------------|----------------|-----------|
| Marketplace catalog entry (`marketplace.json`) | Marketplace root | — | Marketplace owns the catalog; entries point at plugins. Phase 1 adds the 14th entry alongside 13 existing v1 entries. |
| Plugin shell (`plugins/hack-skills-router/`) | In-repo authored content | — | Sidecar pattern (PROJECT.md constraint at v2.0): original-authored content lives under `plugins/<name>/`, NOT mixed into v1's curation. |
| Plugin manifest (`.claude-plugin/plugin.json`) | Plugin root | — | Standard Claude Code layout. Declares plugin identity (name, version, author). |
| Skill body (`skills/hack-skills-router/SKILL.md`) | Plugin's `skills/` dir | — | Standard skill location. SKILL.md is required entry point; supporting files (patterns/, examples/) can sit alongside but are Phase 2 content. |
| Hook declarations (`hooks/hooks.json`) | Plugin's `hooks/` dir | — | Default location for hook config. Loaded automatically when plugin is enabled. |
| Hook scripts (stub `.sh` files) | Plugin's `hooks/scripts/` dir | — | Plugin-bundled shell scripts referenced via `${CLAUDE_PLUGIN_ROOT}/hooks/scripts/<name>.sh`. Stays inside plugin cache after install. |
| Verification (CLI invocations) | Claude Code CLI | — | `claude plugin install`, `claude plugin details`, `claude plugin marketplace list`/`update` — read-only inspection of the installed plugin. |

## Standard Stack

### Core
| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| Claude Code CLI | 2.1.148 (installed) | Plugin host + verification tool | [VERIFIED] `claude --version` returned `2.1.148 (Claude Code)`. This is the runtime that consumes marketplace.json and the plugin manifest. Required for `claude plugin install / details / marketplace list / update` commands. |
| `bash` (POSIX) | system | Stub hook script runtime | [CITED: code.claude.com/docs/en/hooks] Command hooks run under `sh -c` (macOS/Linux); plain bash scripts with `#!/bin/bash` shebang are the standard. |
| `jq` (optional, not required for Phase 1 stubs) | any recent | JSON validation of hooks.json + plugin.json | [VERIFIED: used by Phase 3 of v1, see `.planning/phases-archive-v1.0/03-marketplace-build-out/03-01-SUMMARY.md`] `jq` was used in v1 Phase 3 for marketplace.json validation. Phase 1 doesn't strictly need it (Claude's own validator handles JSON syntax), but having it available is helpful for spot-checking. |

### Supporting
| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| `claude plugin validate <dir>` | bundled with CLI | Schema validation for marketplace + plugin | Run BEFORE attempting install. Catches missing required fields, bad JSON syntax, and frontmatter errors before they cause install failures. [CITED: code.claude.com/docs/en/plugin-marketplaces#validation-and-testing] |
| `claude plugin validate <dir> --strict` | bundled with CLI | Treat warnings as errors | [CITED: code.claude.com/docs/en/plugins-reference#unrecognized-fields] Useful in CI; promotes warnings (e.g., unrecognized fields) to hard failures. Optional for Phase 1 manual run. |

### Alternatives Considered
| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| `source: "./plugins/hack-skills-router"` (relative path) | `source: { source: "github", repo: "SpencerPresley/hack-skills-marketplace", path: "plugins/hack-skills-router" }` (git+path) | Locked decision (CONTEXT N/A — locked in design spec §3 decision 1 and SC #1). The relative-path form requires the marketplace to be Git-hosted (which it is) and clones the WHOLE repo, while git+path could sparse-clone. Relative-path is what `simple-but-powerful` uses and is the documented idiomatic shape for in-repo plugins. Constraint: relative paths only work for Git-hosted marketplaces, NOT URL-direct-to-marketplace.json marketplaces. We're using Git, so fine. [CITED: code.claude.com/docs/en/plugin-marketplaces#relative-paths] |
| Stub `echo` script | JSON envelope script (`jq -n '{...additionalContext...}'`) | Echo (plain stdout) works for stub purposes — anything stdout from a SessionStart or UserPromptSubmit hook is automatically injected as a system reminder. Phase 1 can use plain echo. Phase 3 may upgrade to JSON envelope for the `additionalContext` discrete-injection mode if more control is wanted. [CITED: code.claude.com/docs/en/hooks#sessionstart-hook-details] |
| Phase 1 puts hook scripts at `hooks/scripts/*.sh` | rust-skills puts them at `.claude/hooks/*.sh` | Design spec §4 already commits to `hooks/scripts/*.sh`. This is cleaner: `${CLAUDE_PLUGIN_ROOT}/hooks/scripts/<name>.sh` is one resolution path; rust-skills' `.claude/hooks/` is an artifact of how rust-skills layered itself over an existing `.claude/` dir. We don't have that constraint. Stay with design spec. |

**Installation (nothing to npm/pip install — all files are hand-authored):**

```bash
# Nothing to install — Phase 1 creates files directly. Verification uses the bundled CLI.
claude --version   # confirms 2.1.x runtime is available
```

**Version verification:** No external packages installed in this phase. The only runtime dependency is the already-installed `claude` CLI (verified 2.1.148 on 2026-05-22).

## Package Legitimacy Audit

Not applicable — Phase 1 does not install any external packages. All files (marketplace entry, plugin.json, SKILL.md, hooks.json, stub shell scripts) are authored in-repo. No npm/PyPI/cargo dependencies.

## Architecture Patterns

### System Architecture Diagram

```
                           ┌─────────────────────────────────────────────┐
                           │ User runs                                   │
                           │   /plugin install hack-skills-router@       │
                           │   hack-skills-marketplace                   │
                           └─────────────────┬───────────────────────────┘
                                             │
                                             ▼
        ┌──────────────────────────────────────────────────────────┐
        │ Claude Code reads .claude-plugin/marketplace.json        │
        │ (already registered as marketplace `hack-skills-         │
        │  marketplace`)                                           │
        │                                                          │
        │ Finds entry with name="hack-skills-router"               │
        │ source="./plugins/hack-skills-router" (relative path)    │
        └──────────────────────────┬───────────────────────────────┘
                                   │ resolves source path relative to
                                   │ marketplace ROOT (NOT to .claude-plugin/)
                                   ▼
        ┌──────────────────────────────────────────────────────────┐
        │ Filesystem read: <repo>/plugins/hack-skills-router/      │
        │   ├── .claude-plugin/plugin.json                         │
        │   ├── skills/hack-skills-router/SKILL.md                 │
        │   └── hooks/                                             │
        │       ├── hooks.json                                     │
        │       └── scripts/                                       │
        │           ├── session-start.sh   (stub)                  │
        │           └── nudge.sh           (stub)                  │
        └──────────────────────────┬───────────────────────────────┘
                                   │ COPY to local cache (not in-place)
                                   ▼
        ┌──────────────────────────────────────────────────────────┐
        │ ~/.claude/plugins/cache/hack-skills-marketplace/         │
        │   hack-skills-router/<sha>-<hash>/                       │
        │     (mirror of plugin dir, scripts retain +x bit)        │
        └──────────────────────────┬───────────────────────────────┘
                                   │
              ┌────────────────────┼──────────────────────────┐
              │                    │                          │
              ▼                    ▼                          ▼
   ┌─────────────────┐  ┌─────────────────────┐   ┌──────────────────────┐
   │ Skill           │  │ SessionStart hook   │   │ UserPromptSubmit     │
   │ registered:     │  │ registered to fire  │   │ hook registered to   │
   │ hack-skills-    │  │ on session events   │   │ fire on EVERY        │
   │ router:hack-    │  │ (startup/resume/    │   │ prompt (matcher is   │
   │ skills-router   │  │ clear/compact)      │   │ silently ignored)    │
   │ (description    │  │ Stub: prints text   │   │ Stub: prints text    │
   │  available)     │  │  to stdout          │   │  to stdout           │
   └─────────────────┘  └──────────┬──────────┘   └──────────┬───────────┘
                                   │                          │
                                   ▼                          ▼
                       ┌──────────────────────────────────────────────────┐
                       │ At session start: stdout from script is added    │
                       │ to Claude's context as system reminder           │
                       │ (verifiable via Claude's behavior / transcript)  │
                       │                                                  │
                       │ On user prompts: stdout from nudge.sh added next │
                       │ to user prompt before Claude processes it        │
                       └──────────────────────────────────────────────────┘
```

### Recommended Project Structure

```
hack-skills-marketplace/                         (repo root = marketplace root)
├── .claude-plugin/
│   └── marketplace.json                         (add 14th entry — existing 13 untouched)
├── plugins/                                     (NEW directory — first time)
│   └── hack-skills-router/                      (NEW plugin authored in-repo)
│       ├── .claude-plugin/
│       │   └── plugin.json                      (minimal manifest)
│       ├── skills/
│       │   └── hack-skills-router/
│       │       └── SKILL.md                     (STUB — frontmatter + ≤30 lines body)
│       └── hooks/
│           ├── hooks.json                       (SessionStart + UserPromptSubmit declared)
│           └── scripts/
│               ├── session-start.sh             (STUB — echo "[stub] SessionStart fired")
│               └── nudge.sh                     (STUB — echo "[stub] UserPromptSubmit fired")
└── .planning/                                   (existing GSD artifacts — untouched)
```

**Key constraint from docs:** [CITED: code.claude.com/docs/en/plugins#plugin-structure-overview] "Only `plugin.json` goes inside `.claude-plugin/`. All other directories must be at the plugin root level." So `skills/` and `hooks/` MUST be at `plugins/hack-skills-router/skills/` and `plugins/hack-skills-router/hooks/`, NOT inside `.claude-plugin/`.

### Pattern 1: Marketplace entry with relative-path source
**What:** A marketplace.json entry pointing at an in-repo plugin via relative path.
**When to use:** When the plugin's source is co-located with the marketplace catalog in the same Git repo (our case — sidecar pattern).
**Example:**
```json
// Source: code.claude.com/docs/en/plugin-marketplaces#create-the-marketplace-file
{
  "name": "hack-skills-router",
  "source": "./plugins/hack-skills-router",
  "description": "Routing + scaffolding for hack-skills topical plugins. Adapted from yaklang/hack-skills upstream router.",
  "version": "0.1.0",
  "keywords": ["security", "pentest", "router", "hooks", "methodology"]
}
```

**Critical points from docs:**
- Path MUST start with `./`. [CITED: code.claude.com/docs/en/plugin-marketplaces#plugin-sources — table row "Relative path"]
- Path resolves relative to the **marketplace ROOT** (`<repo>/`), NOT to `<repo>/.claude-plugin/`. So `./plugins/hack-skills-router` points at `<repo>/plugins/hack-skills-router`. [CITED: same source]
- Do NOT use `../` (path traversal outside marketplace root is rejected at validate time). [CITED: code.claude.com/docs/en/plugin-marketplaces#troubleshooting — "Path contains .."]
- Relative paths only work when users add the marketplace via Git (which we are). If added via direct URL to marketplace.json, relative paths break. Phase 4 (publish) needs to confirm Git-add path, but Phase 1 is local and Git-aware, so fine.

### Pattern 2: Minimal plugin.json manifest
**What:** Declares plugin identity. The `name` is the skill namespace prefix.
**When to use:** Always — every plugin needs one (except trivial single-skill plugins per v2.1.142+, but we have hooks + a skill in a `skills/` subdir, so we need plugin.json).
**Example:**
```json
// Source: code.claude.com/docs/en/plugins-reference#plugin-manifest-schema
{
  "name": "hack-skills-router",
  "description": "Routing + scaffolding for hack-skills topical plugins.",
  "version": "0.1.0",
  "author": { "name": "Spencer Presley" }
}
```

**Critical points:**
- Only `name` is strictly REQUIRED. Everything else is optional but conventional. [CITED: code.claude.com/docs/en/plugins-reference#required-fields]
- `name` MUST be kebab-case, no spaces. Becomes the skill namespace (skill at `skills/hack-skills-router/SKILL.md` is invoked as `/hack-skills-router:hack-skills-router`). [CITED: code.claude.com/docs/en/plugins#quickstart-create-your-first-plugin]
- `name` SHOULD match the marketplace entry's `name`. If they differ, install still works but Claude Code namespaces by plugin.json's `name`, which is confusing. Keep them identical: `hack-skills-router`.
- `version` is optional but if set, users only receive updates when you bump it. For Phase 1 stub, `"0.1.0"` is fine. [CITED: code.claude.com/docs/en/plugins-reference#version-management]
- `author` accepts EITHER a string OR an object `{ "name": "...", "email": "...", "url": "..." }`. Object form is cleaner. [CITED: code.claude.com/docs/en/plugins-reference#metadata-fields]

### Pattern 3: SKILL.md stub with required frontmatter
**What:** Skill entry point with YAML frontmatter + body.
**When to use:** Every skill needs one in `<plugin-root>/skills/<skill-name>/SKILL.md`.
**Example:**
```markdown
---
description: STUB — routing + scaffolding for security/hacking tasks. Phase 2 will replace this body with the full router. Triggers: hack, security, pentest, vulnerability.
---

# Hack-Skills Router (STUB)

This is a Phase 1 mechanism-spike stub. The full router skill body lands in Phase 2.

When loaded, the router will route security tasks to the correct deep skill from the
hack-skills marketplace and surface boundary conditions a baseline AI often misses.

Phase 1 success criterion: this file loads, its description appears in Claude's
always-on context when the plugin is installed, and the file is invokable via
`Skill(hack-skills-router)` (returning this stub body).
```

**Critical points:**
- `description` is RECOMMENDED (not strictly required, but without it Claude can't decide when to auto-load — the first paragraph of body is used as fallback). [CITED: code.claude.com/docs/en/skills#frontmatter-reference]
- `name` is OPTIONAL — when omitted, the directory name (`hack-skills-router`) is used. Setting it explicitly is a nice belt-and-braces but redundant.
- `user-invocable: false` HIDES the skill from the `/` menu but Claude can still load it programmatically. The design spec uses this in Phase 2 for the router's internal layer skills. **Phase 1 should NOT use `user-invocable: false`** — we want SC #4 (`claude plugin details` lists the skill) to be observable. [CITED: code.claude.com/docs/en/skills#control-who-invokes-a-skill]
- `disable-model-invocation: true` would prevent Claude from auto-loading. We do NOT want this in Phase 1 — the design wants Claude to auto-invoke the router when relevant. Leave it absent (default = false).
- The combined `description` + `when_to_use` text is truncated at 1,536 characters in the skill listing. Phase 1 stub's description is short; Phase 2's will need to stay under this cap.
- Frontmatter `name` MUST be lowercase letters, digits, hyphens only (max 64 chars). Same kebab-case rule as plugin name.

### Pattern 4: hooks.json with SessionStart + UserPromptSubmit
**What:** Hook configuration declaring which lifecycle events trigger which scripts.
**When to use:** In `<plugin-root>/hooks/hooks.json` (the default location — auto-discovered).
**Example:**
```json
// Source: code.claude.com/docs/en/hooks
{
  "hooks": {
    "SessionStart": [
      {
        "matcher": "startup|resume|clear|compact",
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
        "matcher": "XSS",
        "comment-on-matcher": "UserPromptSubmit IGNORES matcher (CC 2.1.148). This field is for forward-doc only; gating moves into nudge.sh in Phase 3.",
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

**Critical points (these are the most load-bearing facts of this entire research):**

- **`${CLAUDE_PLUGIN_ROOT}` resolves to the plugin's CACHE directory** at runtime (under `~/.claude/plugins/cache/<marketplace>/<plugin>/<sha>-<hash>/`). NOT the source dir, NOT the marketplace root. [CITED: code.claude.com/docs/en/plugins-reference#environment-variables] — "the absolute path to your plugin's installation directory."
- In shell-form commands (no `args` array), `${CLAUDE_PLUGIN_ROOT}` MUST be wrapped in double quotes: `"${CLAUDE_PLUGIN_ROOT}"`. [CITED: same source]
- **SessionStart `matcher` accepts `startup|resume|clear|compact`.** [VERIFIED: code.claude.com/docs/en/hooks#when-it-fires] Setting `*` matches all four; setting `startup|resume` would skip `/clear` and compaction events. Spec §5.3 has `"matcher": "*"` which is fine — fires on every session boundary. For Phase 1, the `*` matcher is correct (we want it to fire whenever a session starts so SC #5 is verifiable).
- **UserPromptSubmit `matcher` is SILENTLY IGNORED.** [VERIFIED: code.claude.com/docs/en/hooks — section "Events Without Matcher Support" lists UserPromptSubmit explicitly: "do not support matchers; they always fire on every occurrence. If a `matcher` field is added, it is silently ignored."] This is the single most consequential finding in this research. The design spec §5.3 builds a complex regex into the matcher — that regex will not filter. The hook will fire on EVERY prompt. For Phase 1 this is actually FINE (we want it to fire to verify mechanism). For Phase 3, the regex must be implemented INSIDE `nudge.sh` (read stdin JSON, extract `prompt`, grep, exit 0 silently if no match).
- **`timeout` is in SECONDS, not milliseconds.** [CITED: code.claude.com/docs/en/hooks — "Seconds before canceling."] So `"timeout": 5` is 5 seconds. Default for command hooks is 600s, but UserPromptSubmit lowers to 30s default. Design spec's `5` (SessionStart) and `3` (UserPromptSubmit) are safe margins for echo-only stubs.
- **`type: "command"` is the hook type.** Other types exist (`http`, `mcp_tool`, `prompt`, `agent`) but command is what we want. [CITED: code.claude.com/docs/en/plugins-reference#hooks]
- **Exit code semantics for stubs:** exit 0 = success, stdout is injected as context. Exit 2 = blocking error (stderr shown to user, session/prompt still proceeds for SessionStart, prompt continues for UserPromptSubmit unless `decision:"block"` JSON returned). Any other non-zero = non-blocking error (stderr only shown with `--verbose`). [CITED: code.claude.com/docs/en/hooks#exit-code-semantics] Stubs should `exit 0` after their `cat <<EOF` block.
- **Three context-injection methods for both hooks:** (1) plain stdout (simplest — what design spec uses), (2) JSON envelope with `hookSpecificOutput.additionalContext` (more discrete — no "Hook output:" prefix in transcript), (3) JSON with `initialUserMessage` for SessionStart (creates first user message; less useful for our case). [CITED: code.claude.com/docs/en/hooks#context-injection-mechanism] For Phase 1 stubs, plain stdout is correct and simplest.

### Anti-Patterns to Avoid

- **Putting components inside `.claude-plugin/`:** A common mistake. Only `plugin.json` goes in `.claude-plugin/`. `skills/`, `hooks/` etc. must be at plugin root. [CITED: code.claude.com/docs/en/plugins#plugin-structure-overview]
- **Relying on UserPromptSubmit `matcher` to filter:** It's silently ignored. The hook WILL fire on every prompt regardless. (Phase 1 stub: this is acceptable. Phase 3: filtering must move into the script.)
- **Forgetting `chmod +x` on hook scripts:** Symptom is "Hook not firing." [CITED: code.claude.com/docs/en/plugins-reference — common issues table] In our case, since we author the files via `Write` tool, the planner must include an explicit `chmod +x plugins/hack-skills-router/hooks/scripts/*.sh` task. The cache layer preserves the +x bit on copy.
- **Using `../` in source paths:** Marketplace validator rejects it (`Path contains ".."`). [CITED: code.claude.com/docs/en/plugin-marketplaces#marketplace-validation-errors]
- **Bumping `version` in `plugin.json` AND in the marketplace entry:** Per [CITED: code.claude.com/docs/en/plugins-reference#version-management]: "Avoid setting `version` in both `plugin.json` and the marketplace entry. The `plugin.json` value always wins silently." Design spec §5.1 and §5.2 BOTH set `"version": "0.1.0"`. They match here, so silently-wins is benign for Phase 1, but flag this for ongoing maintenance — choose one source of truth (recommend: keep version in `plugin.json` only; remove from marketplace entry).
- **Mixing absolute and relative paths in commands:** Always use `${CLAUDE_PLUGIN_ROOT}` for plugin-local files, NEVER absolute paths or `../`. The plugin gets copied to a cache dir so absolute paths break.

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Hook event delivery | Custom file-watching script that polls for session events | Claude Code's built-in hooks system (SessionStart, UserPromptSubmit) | Claude Code already fires hooks at the right moments with proper input JSON on stdin. Polling is fragile and adds latency. |
| Path resolution for plugin-local files | Compute absolute paths from `$0` or `pwd` inside the script | `${CLAUDE_PLUGIN_ROOT}` environment variable | Plugin lives in a versioned cache dir (`~/.claude/plugins/cache/<marketplace>/<plugin>/<sha>-<hash>/`). The path changes on plugin update. Claude Code sets `CLAUDE_PLUGIN_ROOT` for every hook invocation. [CITED: code.claude.com/docs/en/plugins-reference#environment-variables] |
| Context injection mechanism | Custom MCP server that injects via tool calls | Plain stdout from the hook script OR JSON envelope with `additionalContext` | Stdout is automatically captured and injected as a system reminder. No protocol layer needed for the stub. |
| Plugin manifest validation | Hand-rolled JSON-schema check | `claude plugin validate <dir>` (bundled) | Validates marketplace.json, plugin.json, SKILL.md frontmatter, hooks.json schema all in one shot. [CITED: code.claude.com/docs/en/plugin-marketplaces#validation-and-testing] |
| UserPromptSubmit prompt filtering | Regex in `matcher` field | Read `$PROMPT` from stdin JSON inside the hook script, grep, exit 0 silently if no match | (Phase 3 concern.) `matcher` is silently ignored for UserPromptSubmit. The only working mechanism is in-script filtering: `PROMPT=$(jq -r '.prompt' < /dev/stdin); echo "$PROMPT" \| grep -qiE "<regex>" \|\| exit 0`. [CITED: code.claude.com/docs/en/hooks#userpromptsubmit-hook-details] |

**Key insight:** Phase 1 is fundamentally about wiring up Claude Code's built-in plugin + hook infrastructure. We're not building infrastructure — we're configuring it. The only judgment calls are file layout (mirroring rust-skills as the analog), stub script content, and a single regex placeholder in the UserPromptSubmit matcher (knowing it'll be ignored).

## Runtime State Inventory

Not applicable — Phase 1 is greenfield additive (adds new files; does not rename, refactor, or migrate any runtime state).

That said, two CACHE-related notes the planner should be aware of:

1. **The local marketplace is currently registered as the GitHub-hosted form**, not as a local path. `claude plugin marketplace list` shows `hack-skills-marketplace` with `Source: GitHub (SpencerPresley/hack-skills-marketplace)`. This means Phase 1 has two possible install paths:
   - (a) `/plugin marketplace update hack-skills-marketplace` to pull the latest from GitHub (requires Phase 1 changes to be pushed first — not ideal for an iterative spike).
   - (b) Re-register the marketplace as a local path: `claude plugin marketplace remove hack-skills-marketplace; claude plugin marketplace add ./` (pointing at the repo's working-tree state). This is what v1 Phase 1 used. **Recommend (b) for the spike** so changes are picked up without a push.
2. **Plugin cache uses per-plugin subdirectories**: `~/.claude/plugins/cache/hack-skills-marketplace/<plugin-name>/<sha>-<hash>/`. After Phase 1 install, expect a new `~/.claude/plugins/cache/hack-skills-marketplace/hack-skills-router/<sha>-<hash>/` directory to appear. This is observable evidence the install worked.

## Common Pitfalls

### Pitfall 1: SessionStart hook content not injecting because of session timing
**What goes wrong:** User installs the plugin in an existing session, then runs `claude plugin details` to verify, and concludes the hook didn't fire because they don't see the SessionStart text.
**Why it happens:** SessionStart fires on `startup|resume|clear|compact`. Installing a plugin does NOT trigger any of these — the existing session doesn't restart. The hook fires the NEXT time a session begins (new `claude` invocation, `/resume`, `/continue`, `/clear`, or compaction).
**How to avoid:** After installing, start a FRESH session (`exit` and `claude` again, or `/clear` in the same session) and observe Claude's context for the stub text.
**Warning signs:** "Installed but SessionStart didn't fire" → check whether a new session was started after install.

### Pitfall 2: Hook scripts not executable
**What goes wrong:** Install succeeds, declarations look correct, but hooks don't run.
**Why it happens:** Hook scripts need the executable bit (`chmod +x`). When files are authored via the Write tool, they may not get +x by default depending on umask. [CITED: code.claude.com/docs/en/plugins-reference#hook-troubleshooting]
**How to avoid:** Include `chmod +x plugins/hack-skills-router/hooks/scripts/*.sh` as an explicit task action in the plan. Verify with `ls -l plugins/hack-skills-router/hooks/scripts/*.sh` showing `rwx` for owner.
**Warning signs:** No output from hooks, no errors, hook just silently doesn't run.

### Pitfall 3: UserPromptSubmit `matcher` field treated as functional
**What goes wrong:** Developer writes a careful regex in the matcher expecting it to gate hook firing. The hook fires on every prompt anyway. Phase 3 then has to scramble to add in-script filtering.
**Why it happens:** UserPromptSubmit does not support matchers; the field is silently ignored. (Plain confusion between hook events that DO support matchers like PostToolUse and ones that don't.) [CITED: code.claude.com/docs/en/hooks — "Events Without Matcher Support"]
**How to avoid:** Phase 1 plan should INCLUDE the matcher field in hooks.json for forward-doc purposes (it'll become the documentation for Phase 3's in-script grep), but should ADD an explicit comment in the plan and a `comment-on-matcher` JSON sibling field (a benign unrecognized field — Claude Code logs warnings for unrecognized fields but still loads). The Phase 1 stub script just `echo "[stub] UserPromptSubmit fired"` — it fires on every prompt, which is desired for spike verification.
**Warning signs:** Phase 3 planner is surprised when the regex doesn't filter; or, observed hook firing on totally unrelated prompts in Phase 1 (which IS expected for the stub).

### Pitfall 4: `version` set in both `plugin.json` and marketplace entry
**What goes wrong:** Future maintenance: bump the version in `marketplace.json` but forget to bump `plugin.json`. Users don't get the update because `plugin.json`'s version silently wins.
**Why it happens:** [CITED: code.claude.com/docs/en/plugins-reference#version-management] "The `plugin.json` value always wins silently."
**How to avoid:** Pick ONE source of truth. Recommend: keep `version` in `plugin.json` only; omit from the marketplace entry. (The design spec §5.1 sets it in BOTH — this should be corrected in the plan: remove `version` from the marketplace entry; keep in `plugin.json`.)
**Warning signs:** Users on stale versions despite marketplace appearing to be updated.

### Pitfall 5: Relative-path source breaks if marketplace is added via direct URL
**What goes wrong:** Marketplace is hosted at a URL pointing at marketplace.json (not a Git repo). When users add via `/plugin marketplace add https://example.com/marketplace.json`, the relative-path source fails because the plugin files weren't downloaded — only marketplace.json was.
**Why it happens:** [CITED: code.claude.com/docs/en/plugin-marketplaces — "Plugins with relative paths fail in URL-based marketplaces"]
**How to avoid:** Marketplace MUST be Git-hosted (it is — `github.com/SpencerPresley/hack-skills-marketplace`). Users must add via `/plugin marketplace add SpencerPresley/hack-skills-marketplace` (or local-dir form for Phase 1 spike). This is fine for us; flag for Phase 4 publication that the GitHub form is the only supported install path.
**Warning signs:** "path not found" errors during install from a URL-source marketplace.

### Pitfall 6: Hook script syntax requires double quotes around `${CLAUDE_PLUGIN_ROOT}`
**What goes wrong:** In shell-form hook command (no `args` array), `bash ${CLAUDE_PLUGIN_ROOT}/hooks/scripts/x.sh` — if the cache path has spaces or special chars, tokenization breaks.
**Why it happens:** Shell form passes the command string to `sh -c`, which tokenizes by whitespace.
**How to avoid:** Always wrap: `bash "${CLAUDE_PLUGIN_ROOT}/hooks/scripts/session-start.sh"`. [CITED: code.claude.com/docs/en/plugins-reference#environment-variables] (Design spec §5.3 already does this correctly. Plan must preserve the double quotes.)
**Warning signs:** Plugin fails to load with "file not found" when cache path contains a space — rare but real on macOS user paths.

## Code Examples

### Marketplace entry (add to existing array — do NOT replace)
```json
// Source: code.claude.com/docs/en/plugin-marketplaces (mirrored from design spec §5.1)
// Append to the existing "plugins" array in .claude-plugin/marketplace.json
// (DO NOT remove or modify any of the existing 13 v1 entries.)
{
  "name": "hack-skills-router",
  "source": "./plugins/hack-skills-router",
  "description": "Routing + scaffolding for hack-skills topical plugins. Adapted from yaklang/hack-skills upstream router.",
  "version": "0.1.0",
  "keywords": ["security", "pentest", "router", "hooks", "methodology"]
}
```

Note: Design spec sets `version` here. Per Pitfall 4 above, the plan should consider dropping `version` from this entry and keeping it only in `plugin.json` to avoid silent-wins maintenance trap. Both forms are valid for Phase 1; the question is style.

### plugin.json
```json
// Source: code.claude.com/docs/en/plugins-reference#plugin-manifest-schema
// Path: plugins/hack-skills-router/.claude-plugin/plugin.json
{
  "name": "hack-skills-router",
  "description": "Routing + scaffolding for hack-skills topical plugins.",
  "version": "0.1.0",
  "author": { "name": "Spencer Presley" }
}
```

### SKILL.md (stub)
```markdown
---
description: STUB — routing + scaffolding for security/hacking tasks. Phase 2 will replace this body with the full router that picks the right deep skill from the hack-skills marketplace and surfaces boundary conditions a baseline AI often misses. Triggers: security, hacking, pentest, vulnerability, XSS, SQLi, CVE.
---

# Hack-Skills Router (STUB)

This is a Phase 1 mechanism-spike stub. The full router skill body lands in Phase 2.

When loaded, the router will route security tasks to the correct deep skill from the
hack-skills marketplace and surface boundary conditions a baseline AI often misses.

Phase 1 verifies the plugin shell loads and hooks fire. Real content lands in Phase 2.
```

Note: Total body ≤ 30 lines per SC #3. The frontmatter `description` carries enough keywords to verify the skill appears in always-on context and is discoverable.

### hooks/hooks.json
```json
// Source: code.claude.com/docs/en/hooks + plugins-reference#hooks
// Path: plugins/hack-skills-router/hooks/hooks.json
{
  "description": "Hack-skills router hooks. SessionStart for one-time setup; UserPromptSubmit for per-prompt security-context nudge.",
  "hooks": {
    "SessionStart": [
      {
        "matcher": "startup|resume|clear|compact",
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
        "matcher": "XSS",
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

**Important:** the `"matcher": "XSS"` on UserPromptSubmit is for future-doc only (Phase 3 will move the regex into the script). Per [CITED: code.claude.com/docs/en/hooks], UserPromptSubmit matcher is silently ignored, so the hook will fire on EVERY prompt during Phase 1. This is DESIRED for SC #5 verification — we want to see the stub text appear regardless of what we type.

### hooks/scripts/session-start.sh (stub)
```bash
#!/bin/bash
# STUB — Phase 1 mechanism spike. Real payload lands in Phase 3 (~250 tok trust + ops + intuitions).
cat <<'EOF'

=== HACK-SKILLS ROUTER (STUB) ===
[Phase 1 stub] SessionStart hook fired.
Real content lands in Phase 3.
=================================

EOF
exit 0
```

### hooks/scripts/nudge.sh (stub)
```bash
#!/bin/bash
# STUB — Phase 1 mechanism spike. Real payload + in-script regex filtering lands in Phase 3.
# (UserPromptSubmit matcher in hooks.json is silently ignored by Claude Code 2.1.x —
#  Phase 3 will read $PROMPT from stdin JSON and grep for the security-context regex here.)
cat <<'EOF'

=== HACK-SKILLS NUDGE (STUB) ===
[Phase 1 stub] UserPromptSubmit hook fired.
Real content + filtering land in Phase 3.
=================================

EOF
exit 0
```

### Verification commands (the executor runs these)

```bash
# 0. Pre-flight: ensure marketplace is registered with local source for the spike
#    (avoids needing a GitHub push between iterations)
claude plugin marketplace list                                  # see current registrations
claude plugin marketplace remove hack-skills-marketplace        # if currently registered as GitHub
claude plugin marketplace add ./                                # register repo as local marketplace

# 1. Validate the marketplace + new plugin
claude plugin validate .                                        # checks marketplace.json schema
claude plugin validate ./plugins/hack-skills-router             # checks plugin.json, SKILL.md, hooks.json

# 2. Install
claude plugin install hack-skills-router@hack-skills-marketplace

# 3. Verify (SC #4)
claude plugin list | grep hack-skills-router                    # appears in installed list
claude plugin details hack-skills-router                        # shows skill + hooks

# 4. Verify v1 coexistence (SC #5)
claude plugin install hack-skills-auth-bypass@hack-skills-marketplace
claude plugin list | grep -E "hack-skills-(router|auth-bypass)" # both present
claude plugin marketplace list                                  # marketplace still listed cleanly

# 5. Observe SessionStart inject (SC #5 — requires fresh session)
#    Exit current session, start new one, observe Claude's context for "[Phase 1 stub] SessionStart hook fired."
#    OR: /clear in current session (triggers SessionStart with matcher="clear")

# 6. Observe UserPromptSubmit inject (SC #5 — fires on next prompt regardless of content)
#    Type any prompt. Observe "[Phase 1 stub] UserPromptSubmit hook fired." appears in Claude's context.

# 7. Cleanup (optional, for re-running)
claude plugin uninstall hack-skills-router
claude plugin uninstall hack-skills-auth-bypass
```

Expected output shape for `claude plugin details hack-skills-router` per [CITED: code.claude.com/docs/en/plugins-reference#plugin-details]:
```
hack-skills-router 0.1.0
  Routing + scaffolding for hack-skills topical plugins.
  Source: hack-skills-router@hack-skills-marketplace

Component inventory
  Skills (1)  hack-skills-router
  Agents (0)
  Hooks (2)  (harness-only — no model context cost)
  MCP servers (0)
  LSP servers (0)

Projected token cost
  Always-on:   ~150 tok   added to every session

Per-component (rounded)
  component            always-on  on-invoke
  hack-skills-router      ~150      ~50
```

Hooks lines in the inventory confirm both SessionStart and UserPromptSubmit declarations. Per the doc the inventory groups hooks but doesn't always list event-name-by-event-name. If the planner needs event-level visibility, also run `claude --debug` and grep for "loading plugin" + "hooks" output during session start.

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| `commands/` directory for flat-file slash commands | `skills/` directory with `<name>/SKILL.md` structure | Phased in across Claude Code 2.x (skills are the recommended pattern) | We use `skills/` per current best practice. `commands/` still works for backward compat. [CITED: code.claude.com/docs/en/skills — "Custom commands have been merged into skills."] |
| Plugin manifest in marketplace.json only (`strict: false`) | Plugin manifest in `plugin.json` AND optionally marketplace entry | Continuously supported, both modes work | We use plugin.json (the cleaner, single-source-of-truth pattern). v1 uses `strict: false` because v1 plugins are pure curations of upstream — they have no `plugin.json` because we can't write into the upstream. v2 sidecar is authored by us, so it gets its own `plugin.json`. |
| `--plugin-dir` flag for local testing | Local marketplace registered via `claude plugin marketplace add ./` | Stable for many versions | Local marketplace add is what v1 Phase 1 used and what we'll use for Phase 1 v2. `--plugin-dir` is a faster alternative for single-shot loading but doesn't exercise the marketplace install path, so it's less faithful for a spike. |

**Deprecated/outdated:**
- Nothing relevant to Phase 1 is deprecated. The plugin/marketplace/skill/hooks APIs are all current as of CC 2.1.148 (the runtime we'll be testing against).

## Assumptions Log

| # | Claim | Section | Risk if Wrong |
|---|-------|---------|---------------|
| A1 | The user's local `claude` CLI is 2.1.148 (or compatible recent version) | Standard Stack | Low — `claude --version` returned 2.1.148 on 2026-05-22. If CLI version drift is significant before Phase 1 execution, re-verify the schema. |
| A2 | `claude plugin details <name>` prints the hooks inventory line clearly enough to count both SessionStart + UserPromptSubmit | Code Examples | Medium — the docs example shows `Hooks (1)` aggregated as a count, not event-by-event. If verification needs per-event observability, the plan must use `claude --debug` mode or check the cached `hooks.json` directly. Doc example shows the count covers ALL hook entries, not events. |
| A3 | The local marketplace can be re-registered from GitHub-source to local-path source via `remove` + `add ./` cleanly without losing state | Pitfalls + Verification | Low — this is exactly what v1 Phase 1 did per archived artifacts. Re-doable. |
| A4 | Plain `echo` / `cat <<EOF` from a hook script is sufficient to inject visible text into Claude's session context (not requiring JSON envelope) | Pattern 4 + stubs | Low — explicitly documented at [CITED: code.claude.com/docs/en/hooks#context-injection-mechanism]: "Plain text printed to stdout is automatically added to Claude's context at the start of the conversation." Both methods (plain stdout + JSON envelope) work; plain stdout is simpler for stubs. |
| A5 | The marketplace.json `version` field is genuinely optional (omitting won't break Phase 1 install or break parity with the 13 existing v1 entries) | Code Examples + Pitfall 4 | Low — v1's 13 entries don't have `version` either (verified by reading the file). Omitting from new entry is consistent. If we keep `version` in marketplace entry per design spec §5.1, it's also fine (just an ongoing maintenance trap per Pitfall 4). Plan can choose either. |

## Open Questions

1. **Should `version` live in `plugin.json` only or in BOTH `plugin.json` and marketplace entry?**
   - What we know: Both are accepted; `plugin.json` wins silently if both are set.
   - What's unclear: Design spec §5.1 sets it in both. Is that intentional (belt-and-braces) or an oversight?
   - Recommendation: Drop `version` from the marketplace entry, keep in `plugin.json` only. Single source of truth, eliminates Pitfall 4. The plan should reflect this. (Discuss-phase / planner judgment call.)

2. **Should the UserPromptSubmit `matcher` field be included in Phase 1's hooks.json, even though it'll be silently ignored?**
   - What we know: Including it does no harm (treated as forward-doc); excluding it makes the JSON cleaner.
   - What's unclear: The design spec §5.3 includes a full regex matcher. Phase 3 will move that to the script.
   - Recommendation: Include a SIMPLE placeholder matcher (e.g., `"matcher": "XSS"`) for Phase 1 — it serves as a visible signal that "filtering belongs here intent-wise but works elsewhere in this version." Phase 3 can drop it once in-script grep is implemented.

3. **Should Phase 1 add `chmod +x` as an explicit task action, or rely on the system umask?**
   - What we know: Hook scripts need +x or they don't fire. The Write tool's default file mode is OS-dependent.
   - What's unclear: Whether the user's macOS umask sets +x by default for newly-written files (likely NOT, since default is 644).
   - Recommendation: ALWAYS include `chmod +x plugins/hack-skills-router/hooks/scripts/*.sh` as an explicit task in the plan. Belt-and-braces; cheap to run; failure mode without it is silent.

4. **Is `displayName` worth setting in plugin.json for nicer UI?**
   - What we know: `displayName` (min CC 2.1.143) is a human-readable name shown in the `/plugin` picker, falls back to `name` if omitted.
   - What's unclear: Whether the user values UI niceness for a personal marketplace.
   - Recommendation: SKIP for Phase 1. The `name` "hack-skills-router" reads fine. Can add in a polish pass later if desired.

## Environment Availability

| Dependency | Required By | Available | Version | Fallback |
|------------|------------|-----------|---------|----------|
| `claude` CLI (Claude Code) | Plugin install + verification | ✓ | 2.1.148 | — |
| `bash` | Stub hook scripts | ✓ (system) | macOS default | — |
| `jq` (optional) | Manual JSON inspection if desired | likely ✓ (was used in v1 Phase 3) | — | Plain `cat`/`grep` work for stubs; jq not required. |
| Git | Marketplace publish (Phase 4) + clone semantics | ✓ (the repo is a Git repo) | — | — |

**Missing dependencies with no fallback:** None.

**Missing dependencies with fallback:** None — Phase 1 doesn't introduce new deps.

## Validation Architecture

Skipped — `.planning/config.json` has `workflow.nyquist_validation: false`. No test-architecture section required.

## Security Domain

Skipped — Phase 1 is a mechanism spike for a personal marketplace; no production secrets, no auth flows, no PII handling, no untrusted input. The stub hook scripts emit static `echo` text; they accept no user input from stdin (Phase 3 introduces that). The plugin itself runs inside Claude Code's own trust boundary; PROJECT.md and the design spec do call out a "trust model" for the *content* the router promotes (security work must be authorized), but that's a Phase 2/3 content concern, not a Phase 1 mechanism concern.

(If `security_enforcement` is explicitly enabled in config and this section is required: ASVS categories V5 Input Validation and V14 Configuration could apply to Phase 3's regex + script, but NOT to Phase 1's `echo`-only stubs.)

## Sources

### Primary (HIGH confidence)
- [code.claude.com/docs/en/plugin-marketplaces](https://code.claude.com/docs/en/plugin-marketplaces) — marketplace.json schema, plugin sources (relative path semantics), validation
- [code.claude.com/docs/en/plugins](https://code.claude.com/docs/en/plugins) — plugin layout, plugin.json basics, directory structure
- [code.claude.com/docs/en/plugins-reference](https://code.claude.com/docs/en/plugins-reference) — full plugin.json schema, plugin caching, CLI commands (`claude plugin install/list/details`), debugging
- [code.claude.com/docs/en/hooks](https://code.claude.com/docs/en/hooks) — hooks.json schema, SessionStart + UserPromptSubmit details, matcher support table (the load-bearing source for the "UserPromptSubmit matcher silently ignored" finding), `${CLAUDE_PLUGIN_ROOT}` semantics, exit code semantics
- [code.claude.com/docs/en/skills](https://code.claude.com/docs/en/skills) — SKILL.md frontmatter reference, `user-invocable` vs `disable-model-invocation`, skill lifecycle

### Secondary (MEDIUM confidence)
- [code.claude.com/docs/en/hooks-guide](https://code.claude.com/docs/en/hooks-guide) — walkthrough-style hooks doc, matcher behavior examples; cross-confirmed the matcher-support-table finding from primary docs
- Local repo: `.planning/specs/2026-05-22-v2-router-design.md` — design spec (§4 file tree, §5.x component shapes); validated against Claude Code docs and matches except for the UserPromptSubmit-matcher caveat noted above
- Local repo: `.planning/phases-archive-v1.0/03-marketplace-build-out/03-01-SUMMARY.md` — v1 install evidence (`claude plugin install hack-skills-mobile@hack-skills-marketplace` worked end-to-end); confirms the install flow we'll re-exercise in Phase 1
- Local filesystem: `/Users/spencerpresley/skill-vetting/rust-skills/` — user's intended analog; `hooks/hooks.json` confirms `${CLAUDE_PLUGIN_ROOT}` + matcher-in-UserPromptSubmit pattern (note: rust-skills HAS a matcher set on UserPromptSubmit too — it's also silently ignored there per same finding; rust-skills works because its hook script unconditionally injects useful content); `.claude-plugin/plugin.json` confirms minimal-manifest shape; `skills/rust-router/SKILL.md` confirms terse-frontmatter pattern

### Tertiary (LOW confidence — verify before relying on)
- [WebSearch result](https://www.morphllm.com/claude-code-hooks) and several other third-party blog posts on Claude Code hooks — cross-confirm the no-matcher-on-UserPromptSubmit finding but they're not authoritative; primary docs cover it.

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH — every artifact is authoritatively documented at code.claude.com/docs/en/*. CLI version verified locally.
- Architecture: HIGH — file layout matches both the design spec and the rust-skills analog; doc-confirmed.
- Pitfalls: HIGH — every pitfall has a citation; the load-bearing UserPromptSubmit-matcher pitfall is triple-confirmed (primary docs + secondary docs + observed rust-skills design that has the same trap).

**Research date:** 2026-05-22
**Valid until:** ~2026-06-22 (30 days for stable Claude Code plugin APIs; the schemas are unlikely to change in a breaking way within that window, but re-verify CLI version if the user updates `claude` significantly before execution).
