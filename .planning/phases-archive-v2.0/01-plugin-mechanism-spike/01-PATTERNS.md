# Phase 1: Plugin Mechanism Spike - Pattern Map

**Mapped:** 2026-05-22
**Files analyzed:** 6 (5 new, 1 modify)
**Analogs found:** 6 / 6 (1 in-repo, 5 external rust-skills)

## Context

Phase 1 is greenfield for the sidecar plugin pattern in THIS repo. The existing 13 v1 plugins are pure `git-subdir` curations of `yaklang/hack-skills` upstream — they have NO `plugin.json`, NO `SKILL.md` in-repo, NO `hooks.json`. There is exactly one in-repo analog file:

- `.claude-plugin/marketplace.json` — the only in-repo file with directly-mirrorable structure (the new plugin entry is appended to its `plugins` array; v1 entries are the shape ground truth even though their `source` form differs).

All other artifacts use the external reference `/Users/spencerpresley/skill-vetting/rust-skills/` as the analog (per HANDOFF §4 — "the user's intended analog and exists locally for direct inspection"). The rust-skills layout is mirrored with two intentional deviations per RESEARCH §1 recommendation:

1. Hook scripts live at `hooks/scripts/*.sh` (NOT `.claude/hooks/*.sh` like rust-skills) — cleaner; design spec §4 commits to this.
2. NO actual filtering relies on the UserPromptSubmit `matcher` field — it is silently ignored by Claude Code 2.1.x; we keep it as forward-doc only with a stub keyword.

## File Classification

| New/Modified File | Role | Data Flow | Closest Analog | Match Quality |
|-------------------|------|-----------|----------------|---------------|
| `.claude-plugin/marketplace.json` (MODIFY) | marketplace catalog | install resolution (CLI reads → finds plugin entry → resolves `source`) | `.claude-plugin/marketplace.json` lines 7–25 (existing entries are exact schema) + rust-skills marketplace.json line 11–16 (relative-path `source` form) | exact (in-repo for schema; external for relative-path source form) |
| `plugins/hack-skills-router/.claude-plugin/plugin.json` (NEW) | plugin manifest | static config read at install + every session | `/Users/spencerpresley/skill-vetting/rust-skills/.claude-plugin/plugin.json` | exact (external — no in-repo plugin.json exists) |
| `plugins/hack-skills-router/skills/hack-skills-router/SKILL.md` (NEW — STUB) | skill body | static read on Skill() invocation; description always-on | `/Users/spencerpresley/skill-vetting/rust-skills/skills/rust-router/SKILL.md` (frontmatter only — body is Phase 2 content) | exact for frontmatter; STUB body diverges (Phase 1 is ≤30 lines, Phase 2 fills the body per design spec §5.7) |
| `plugins/hack-skills-router/hooks/hooks.json` (NEW) | hook config | declarative event-binding (CC reads at plugin load → registers event handlers) | `/Users/spencerpresley/skill-vetting/rust-skills/hooks/hooks.json` | role-match (rust-skills has UserPromptSubmit only; Phase 1 adds SessionStart per design spec §5.3) |
| `plugins/hack-skills-router/hooks/scripts/session-start.sh` (NEW — STUB) | hook script | event-driven (CC invokes on session start; script writes to stdout → CC injects as system reminder) | `/Users/spencerpresley/skill-vetting/rust-skills/.claude/hooks/rust-skill-eval-hook.sh` | role-match (rust-skills script is UserPromptSubmit; same shell-script + cat-heredoc + exit pattern) — STUB diverges from final (Phase 3 inserts real ~250 tok payload per design spec §5.4) |
| `plugins/hack-skills-router/hooks/scripts/nudge.sh` (NEW — STUB) | hook script | event-driven (CC invokes on every prompt; stdout → context injection) | `/Users/spencerpresley/skill-vetting/rust-skills/.claude/hooks/rust-skill-eval-hook.sh` | exact role+event (both UserPromptSubmit) — STUB diverges from final (Phase 3 inserts real ~75 tok nudge per design spec §5.5 + in-script regex filter) |

## Data Flow Map (cross-file)

```
[user] /plugin install hack-skills-router@hack-skills-marketplace
   |
   v
CLI reads .claude-plugin/marketplace.json
   - finds entry { name: "hack-skills-router", source: "./plugins/hack-skills-router" }
   - resolves source RELATIVE TO MARKETPLACE ROOT (= repo root)
   v
CLI reads plugins/hack-skills-router/.claude-plugin/plugin.json
   - validates name/version/author
   v
CLI scans plugin tree:
   - skills/hack-skills-router/SKILL.md (frontmatter → always-on description registered)
   - hooks/hooks.json (declares SessionStart + UserPromptSubmit handlers)
   v
CLI copies to cache:
   ~/.claude/plugins/cache/hack-skills-marketplace/hack-skills-router/<sha>-<hash>/
   v
At each session start (matcher: startup|resume|clear|compact):
   CC sets CLAUDE_PLUGIN_ROOT = <cache dir>
   CC runs: bash "${CLAUDE_PLUGIN_ROOT}/hooks/scripts/session-start.sh"
   Script stdout → injected as system reminder
   v
At each user prompt (matcher silently ignored):
   CC runs: bash "${CLAUDE_PLUGIN_ROOT}/hooks/scripts/nudge.sh"
   Script stdout → appended to user prompt context
```

---

## Pattern Assignments

### 1. `.claude-plugin/marketplace.json` (MODIFY — append 14th entry)

**Role:** marketplace catalog. **Data flow:** static read by CLI at `/plugin install` and `/plugin marketplace list/update`.

**In-repo analog:** `.claude-plugin/marketplace.json` lines 1–8 (root structure) and any of the 13 existing entries lines 9–25 (entry schema).

**Existing root structure** (lines 1–8 — DO NOT MODIFY):
```json
{
  "name": "hack-skills-marketplace",
  "owner": {
    "name": "Spencer Presley"
  },
  "description": "Curated topical groups of yaklang/hack-skills — install only the topical areas you need.",
  "plugins": [
```

**Existing entry pattern** (lines 9–25 — the `hack-skills-active-directory-and-windows` v1 entry, used here for SCHEMA reference only — note its `source` is `git-subdir` object form):
```json
{
  "name": "hack-skills-active-directory-and-windows",
  "source": {
    "source": "git-subdir",
    "url": "https://github.com/yaklang/hack-skills.git",
    "path": "skills"
  },
  "strict": false,
  "description": "Active Directory and Windows endpoint attacks",
  "skills": [
    "./active-directory-acl-abuse",
    ...
  ]
}
```

**KEY DIVERGENCE from v1 entries:** The new `hack-skills-router` entry uses **relative-path `source` string form** (NOT the `git-subdir` object form). This is intentional — the router is in-repo authored content, not upstream curation. Per RESEARCH §5 Pattern 1.

**External analog for the relative-path source form** (`/Users/spencerpresley/skill-vetting/rust-skills/.claude-plugin/marketplace.json` lines 11–17):
```json
"plugins": [
  {
    "name": "rust-skills",
    "description": "38 skills covering ownership, concurrency, error handling, unsafe code, LSP code intelligence, and domain-specific patterns for Rust development",
    "source": "./",
    "category": "development"
  }
]
```

**Exact text to append** as the 14th element of the `plugins` array (matches design spec §5.1 and RESEARCH "Code Examples" section):
```json
{
  "name": "hack-skills-router",
  "source": "./plugins/hack-skills-router",
  "description": "Routing + scaffolding for hack-skills topical plugins. Adapted from yaklang/hack-skills upstream router.",
  "version": "0.1.0",
  "keywords": ["security", "pentest", "router", "hooks", "methodology"]
}
```

**Critical constraints (from RESEARCH §Pitfalls):**
- Append ONLY. The 13 existing entries (lines 8–258) must remain byte-identical (Phase 1 SC #1 — "no v1 entries removed or altered"). The executor should add a leading comma after the closing `}` of the 13th entry (`hack-skills-web-protocol-attacks`, currently at line 257) and insert the new object before the closing `]` on line 258.
- `source` MUST start with `./`. NO `../` (validator rejects path traversal).
- Path resolves relative to marketplace ROOT (= repo root), NOT `.claude-plugin/`. So `./plugins/hack-skills-router` resolves to `<repo>/plugins/hack-skills-router/`.
- Per RESEARCH Pitfall 4: `version` in BOTH this entry AND `plugin.json` is harmless (plugin.json wins) but is a future-maintenance trap. **Recommendation: keep `version` here for design-spec parity, but flag in PLAN that the long-term recommendation is to drop it from this entry.**
- v1 entries use `strict: false` because they're curating upstream. The new entry has no `strict` field and no `skills` array — it's a relative-path-source plugin where the plugin's own structure is the source of truth.

---

### 2. `plugins/hack-skills-router/.claude-plugin/plugin.json` (NEW)

**Role:** plugin manifest. **Data flow:** static read by CLI at install + every session to register plugin identity.

**No in-repo analog** (this is the first `plugin.json` in this repo — all 13 v1 plugins are `git-subdir` curations with no plugin manifest of their own).

**External analog:** `/Users/spencerpresley/skill-vetting/rust-skills/.claude-plugin/plugin.json` (entire file, 25 lines):
```json
{
  "name": "rust-skills",
  "version": "2.1.0",
  "description": "Comprehensive Rust development assistant with meta-question routing, coding guidelines, version queries, and ecosystem support",
  "author": {
    "name": "ZhangHanDong",
    "url": "https://github.com/ZhangHanDong"
  },
  "repository": "https://github.com/actionbook/rust-skills",
  "homepage": "https://github.com/actionbook/rust-skills",
  "license": "MIT",
  "keywords": [
    "rust",
    "cargo",
    "ownership",
    "borrow-checker",
    "async",
    "tokio",
    "error-handling",
    "coding-guidelines",
    "unsafe",
    "ffi"
  ]
}
```

**Pattern to mirror** (per design spec §5.2 — minimal manifest, drop optional fields rust-skills uses that we don't need yet):
```json
{
  "name": "hack-skills-router",
  "description": "Routing + scaffolding for hack-skills topical plugins.",
  "version": "0.1.0",
  "author": { "name": "Spencer Presley" }
}
```

**Critical constraints (from RESEARCH §Pattern 2):**
- Only `name` is strictly REQUIRED; all others are conventional. The new file copies the four-field minimal shape: `name`, `description`, `version`, `author`.
- `name` MUST be kebab-case, equal to the marketplace entry's `name` (`hack-skills-router`). It becomes the skill namespace prefix — the skill at `skills/hack-skills-router/SKILL.md` is invoked as `/hack-skills-router:hack-skills-router`.
- `author` accepts EITHER string OR object form — rust-skills uses object form with `name` + `url`. New file uses object with `name` only (matches design spec §5.2; `url` can be added later in a polish pass).
- Phase 1 SKIPS rust-skills' optional fields: `repository`, `homepage`, `license`, `keywords` (the `keywords` array lives in the marketplace entry instead, per design spec §5.1).
- Phase 1 SKIPS `displayName` (per RESEARCH Open Question 4 — "skip for Phase 1; can add in polish pass later").

**Divergence from rust-skills:**
- rust-skills has `version: "2.1.0"` (mature plugin); our Phase 1 stub uses `"0.1.0"`.
- rust-skills exposes `repository`/`homepage`/`license` because it's a public OSS plugin; ours is personal — skip per design spec §5.2.

---

### 3. `plugins/hack-skills-router/skills/hack-skills-router/SKILL.md` (NEW — STUB)

**Role:** skill body. **Data flow:** frontmatter `description` is always-on when plugin installed; body loads only when Claude invokes `Skill(hack-skills-router)`.

**No in-repo analog.**

**External analog:** `/Users/spencerpresley/skill-vetting/rust-skills/skills/rust-router/SKILL.md` (frontmatter, lines 1–17):
```yaml
---
name: rust-router
description: "CRITICAL: Use for ALL Rust questions including errors, design, and coding.
HIGHEST PRIORITY for: 比较, 对比, compare, vs, versus, 区别, difference, 最佳实践, best practice,
tokio vs, async-std vs, 比较 tokio, 比较 async,
Triggers on: Rust, cargo, rustc, crate, Cargo.toml,
意图分析, 问题分析, 语义分析, analyze intent, question analysis,
compile error, borrow error, lifetime error, ownership error, type error, trait error,
value moved, cannot borrow, does not live long enough, mismatched types, not satisfied,
E0382, E0597, E0277, E0308, E0499, E0502, E0596,
async, await, Send, Sync, tokio, concurrency, error handling,
编译错误, compile error, 所有权, ownership, 借用, borrow, 生命周期, lifetime, 类型错误, type error,
异步, async, 并发, concurrency, 错误处理, error handling,
问题, problem, question, 怎么用, how to use, 如何, how to, 为什么, why,
什么是, what is, 帮我写, help me write, 实现, implement, 解释, explain"
globs: ["**/Cargo.toml", "**/*.rs"]
---
```

**Frontmatter shape Phase 1 should mirror** (per design spec §5.6 + RESEARCH §Pattern 3, simplified for STUB):
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

**Critical constraints (from RESEARCH §Pattern 3):**
- `description` field is RECOMMENDED — without it Claude falls back to the first body paragraph for auto-load decisions. Phase 1 stub uses a keyword-dense description so SC #4 (`claude plugin details` lists the skill with description) is verifiable.
- `name` field is OPTIONAL — when omitted, the directory name (`hack-skills-router`) is used. Phase 1 omits `name` (matches design spec; cleaner). Rust-skills sets `name: rust-router` explicitly — that's belt-and-braces; we don't need it.
- **DO NOT set `user-invocable: false`** in Phase 1. Phase 1 SC #4 requires `claude plugin details` to list the skill — `user-invocable: false` would hide it from the listing surface we're verifying. Phase 2 will keep it visible too (the router is the user-facing entry point). The design spec uses `user-invocable: false` only for hypothetical layer skills in Phase 2; the router itself stays visible.
- **DO NOT set `disable-model-invocation: true`** — we WANT Claude to auto-invoke the router on security signals.
- `description` + body-first-paragraph is truncated at 1,536 chars in the skill listing. Phase 1 stub description is short (≤200 chars); fine.
- Frontmatter `name` (if set) MUST be lowercase letters/digits/hyphens only, max 64 chars.

**STUB vs final divergence:**
- **Phase 1 (STUB):** Body ≤ 30 lines per ROADMAP SC #3. Just enough text for `claude plugin details` and `Skill(hack-skills-router)` to return SOMETHING when invoked.
- **Phase 2 (final, per design spec §5.7):** Body is ~80 lines with: when-to-use bullets, trust model, hybrid routing strategy, 3-step operating model, plugin-availability handling, boundary-conditions quick reference, workflow examples cross-reference. Phase 2 also adds `patterns/routing-tables.md`, `patterns/expert-intuitions.md`, `examples/workflow-walkthroughs.md` (NOT Phase 1).
- **Phase 1 deliberately omits:** the keyword-heavy multi-line description from design spec §5.6 (full XSS/SQLi/SSRF/etc. trigger list). Phase 1 description is a short single-paragraph stub — design spec §5.6 description is a Phase 2 content concern.

**Divergence from rust-skills frontmatter:**
- rust-skills frontmatter uses `globs: ["**/Cargo.toml", "**/*.rs"]` for passive file-shape activation. **Security work has no clean file-shape analog** (per HANDOFF §6.1 — "for security, glob-based activation is harder"). Phase 1 STUB OMITS `globs`. Phase 2 may revisit (e.g., glob on `.env`, `robots.txt`) but is not strictly required.
- rust-skills' description is bilingual and ~15 lines; Phase 1 STUB is ~1 line. Phase 2 final description (design spec §5.6) approaches rust-skills' density.
- rust-skills has `name: rust-router` set explicitly; Phase 1 omits `name` (relies on directory name).

---

### 4. `plugins/hack-skills-router/hooks/hooks.json` (NEW)

**Role:** hook configuration (declarative event-binding). **Data flow:** static read by CC at plugin load → registers SessionStart + UserPromptSubmit handlers in CC's event loop.

**No in-repo analog.**

**External analog:** `/Users/spencerpresley/skill-vetting/rust-skills/hooks/hooks.json` (entire file, 15 lines):
```json
{
  "hooks": {
    "UserPromptSubmit": [
      {
        "matcher": "(?i)(rust|cargo|rustc|crate|Cargo\\.toml|\\.rs\\b|ownership|borrow|lifetime|...[truncated]...|对比|比较)",
        "hooks": [
          {
            "type": "command",
            "command": "${CLAUDE_PLUGIN_ROOT}/.claude/hooks/rust-skill-eval-hook.sh"
          }
        ]
      }
    ]
  }
}
```

**Pattern Phase 1 should mirror** (per design spec §5.3 + RESEARCH §Pattern 4):
```json
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

**Critical constraints (from RESEARCH §Pattern 4 — these are the most load-bearing facts of the entire phase):**

- **`${CLAUDE_PLUGIN_ROOT}` resolves to the plugin's CACHE directory at runtime** (`~/.claude/plugins/cache/hack-skills-marketplace/hack-skills-router/<sha>-<hash>/`). NEVER absolute paths, NEVER `../`.
- **In shell-form commands, `${CLAUDE_PLUGIN_ROOT}` MUST be wrapped in double quotes** — `bash "${CLAUDE_PLUGIN_ROOT}/hooks/scripts/session-start.sh"`. Without quotes, cache paths with spaces tokenize incorrectly under `sh -c`.
- **SessionStart `matcher` accepts `startup|resume|clear|compact`** — these ARE honored. Design spec §5.3 uses `*` but RESEARCH recommends the explicit four-event matcher for clarity. Either form is correct.
- **UserPromptSubmit `matcher` is SILENTLY IGNORED in Claude Code 2.1.x.** The hook fires on EVERY prompt regardless of what's in `matcher`. This is THE single most consequential fact of this phase. Phase 1 uses a deliberately-trivial placeholder `"matcher": "XSS"` to document Phase 3 intent — Phase 3 moves the full regex from design spec §5.3 INTO `nudge.sh` (read `$PROMPT` from stdin JSON, grep, exit 0 silently if no match).
- **`timeout` is in SECONDS, not milliseconds.** `5` = 5 seconds (SessionStart), `3` = 3 seconds (UserPromptSubmit). Default for command hooks is 600s; UserPromptSubmit default is 30s. Echo-only stubs need ≪1s, so 3s/5s are safe margins.
- **`type: "command"` is the hook type.** Other types (`http`, `mcp_tool`, `prompt`, `agent`) are not used here.
- **Exit code semantics:** Phase 1 stubs `exit 0` after their `cat <<EOF` — stdout is auto-injected as system reminder. Exit 2 = blocking error. Other non-zero = non-blocking (stderr only with `--verbose`).

**Divergence from rust-skills hooks.json:**
- rust-skills declares **only** UserPromptSubmit. Phase 1 declares **both** SessionStart and UserPromptSubmit (design spec §5.3).
- rust-skills' command is `${CLAUDE_PLUGIN_ROOT}/.claude/hooks/rust-skill-eval-hook.sh` (script path under `.claude/hooks/`). Phase 1 uses `bash "${CLAUDE_PLUGIN_ROOT}/hooks/scripts/<name>.sh"` (script path under `hooks/scripts/`, explicit `bash` invocation, quoted env var). The path-difference is intentional (design spec §4 file tree commits to `hooks/scripts/`). The explicit `bash` + quoting is the RESEARCH-recommended best-practice shape.
- rust-skills' regex is huge and bilingual. Phase 1 STUB uses `"matcher": "XSS"` — a single keyword placeholder. The full security regex moves into Phase 3 (and Phase 3 moves it INTO `nudge.sh`, not the matcher field, per the silently-ignored finding).
- rust-skills' hook has no `timeout` field (defaults to 30s for UserPromptSubmit). Phase 1 sets explicit `timeout: 3` and `timeout: 5` per design spec.
- Phase 1 adds an optional top-level `"description"` field — purely documentation; CC validators ignore unrecognized top-level keys with a warning (not an error).

---

### 5. `plugins/hack-skills-router/hooks/scripts/session-start.sh` (NEW — STUB)

**Role:** hook script (executable). **Data flow:** event-driven — CC invokes on session start with empty stdin; script writes payload to stdout; CC injects stdout as system reminder into Claude's context.

**No in-repo analog.**

**External analog:** `/Users/spencerpresley/skill-vetting/rust-skills/.claude/hooks/rust-skill-eval-hook.sh` (the shebang + cat-heredoc + exit pattern). Key excerpt (lines 1–13 of 121):
```bash
#!/bin/bash
# Rust Skills Meta-Cognition Hook
# Forces Claude to use meta-cognition routing with mandatory tracing

cat << 'EOF'

=== RUST SKILLS DISPLAY FORMAT ===
When showing Rust Skills loaded, display in this EXACT order:
1. FIRST: "🦀 Rust Skills Loaded" text
2. THEN: The Ferris crab ASCII art BELOW the text
The text must be ABOVE the crab, not below.
===

[... ~108 more lines of meta-cognition instructions ...]

EOF
```

**Pattern Phase 1 STUB should mirror** (per design spec §5.4 simplified for STUB):
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

**Critical constraints (from RESEARCH §Pitfalls + §Pattern 4):**

- **Shebang `#!/bin/bash`** — first line. Required because hooks run under `sh -c` and we need bash features (heredoc with single-quoted `'EOF'` delimiter to suppress variable expansion).
- **Single-quoted `<<'EOF'` heredoc** — prevents shell from expanding `$variables` or backticks inside the body. Critical when the stub text contains anything that could look like shell syntax. Both rust-skills and design spec use this form.
- **`exit 0`** — explicit exit-zero at the end. The cache layer preserves the exit semantics; explicit > implicit.
- **Pitfall 2 (executable bit):** The Write tool authors files with mode 644 (no +x) by default. The plan MUST include an explicit `chmod +x plugins/hack-skills-router/hooks/scripts/*.sh` task action. Without +x, the hook silently fails to fire. Verify with `ls -l ... | grep rwx`.
- **No stdin reading in Phase 1.** SessionStart hooks receive a JSON envelope on stdin (`{ "session_id": "...", "cwd": "...", ... }`) but Phase 1 STUB ignores stdin and just emits static text. Phase 3 may read stdin to extract session metadata.

**STUB vs final divergence (per ROADMAP Phase 3 SC #1 + design spec §5.4):**
- **Phase 1 (STUB):** ~5 line static echo via `cat <<'EOF'`.
- **Phase 3 (final, ~250 tok):** Three sections — TRUST MODEL (authorized targets only), OPERATING MODEL (3 steps from upstream `hack` SKILL.md: Recon → Route by behavior → Apply test in standard order), EXPERT INTUITIONS (8 boundary conditions paraphrased from upstream — BOLA, JWT pre-payload checks, race conditions, etc.).

**Divergence from rust-skills script:**
- rust-skills script is 121 lines of mandatory routing instructions (Phase 3 of our roadmap is closer to this scale).
- rust-skills uses `<< 'EOF'` (space between `<<` and `'EOF'`); Phase 1 uses `<<'EOF'` (no space). Both are valid bash; consistency with design spec preferred.
- rust-skills script does NOT explicitly `exit 0`. Phase 1 should — RESEARCH §Pattern 4 recommends explicit exit codes for clarity.

---

### 6. `plugins/hack-skills-router/hooks/scripts/nudge.sh` (NEW — STUB)

**Role:** hook script (executable). **Data flow:** event-driven — CC invokes on EVERY user prompt (matcher silently ignored in CC 2.1.x); script writes payload to stdout; CC appends stdout to user prompt context.

**No in-repo analog.**

**External analog:** Same as #5 — `/Users/spencerpresley/skill-vetting/rust-skills/.claude/hooks/rust-skill-eval-hook.sh` (in rust-skills, this IS the UserPromptSubmit hook). Same shebang + cat-heredoc + exit pattern.

**Pattern Phase 1 STUB should mirror** (per design spec §5.5 simplified for STUB):
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

**Critical constraints:** Same five as #5 (shebang, single-quoted heredoc, explicit `exit 0`, +x bit, no stdin reading in Phase 1).

**Plus one nudge-specific constraint:**
- **Phase 1 EXPECTS this to fire on every prompt** (the matcher is silently ignored). This is the desired behavior for SC #5 verification — we want to type ANY prompt and see the stub text appear. If Phase 1 verification shows the hook NOT firing on every prompt, something is wrong (most likely +x bit missing; less likely the plugin didn't install).
- **Phase 3 inverts this expectation** — Phase 3's `nudge.sh` reads `$PROMPT` from stdin JSON, greps for the full security-context regex from design spec §5.3, and `exit 0` silently if no match. Phase 3 SC #4 verifies the hook fires on 5 security prompts AND does NOT inject on 3 non-security prompts.

**STUB vs final divergence (per ROADMAP Phase 3 SC #2 + design spec §5.5):**
- **Phase 1 (STUB):** ~5 line static echo. Fires on every prompt.
- **Phase 3 (final, ~75 tok):** Three-step nudge — (1) confirm authorized scope, (2) load Skill(hack-skills-router), (3) surface 2–3 boundary conditions. PLUS in-script regex filter — `PROMPT=$(jq -r '.prompt' < /dev/stdin); echo "$PROMPT" | grep -qiE "<regex>" || exit 0`.

**Divergence from rust-skills script:** Same as #5 — rust-skills is longer, slightly different heredoc style, no explicit exit.

---

## Shared Patterns

### Path Resolution

**Source:** Claude Code docs (no in-repo analog yet)
**Apply to:** `hooks/hooks.json`, both shell scripts
**Pattern:** ALWAYS use `${CLAUDE_PLUGIN_ROOT}` for plugin-local file references. NEVER absolute paths or `../`. The plugin's cache path includes a versioned `<sha>-<hash>` subdir that changes on every plugin update — absolute paths break across updates.

```text
bash "${CLAUDE_PLUGIN_ROOT}/hooks/scripts/session-start.sh"
                                                       ^
                                              double-quoted to survive spaces in cache path
```

### Stub Echo Pattern

**Source:** `/Users/spencerpresley/skill-vetting/rust-skills/.claude/hooks/rust-skill-eval-hook.sh` (lines 1, 5–6, 121)
**Apply to:** `hooks/scripts/session-start.sh`, `hooks/scripts/nudge.sh`
**Pattern:** Shell script with `#!/bin/bash` shebang, single-quoted heredoc body, explicit `exit 0`.

```bash
#!/bin/bash
cat <<'EOF'

=== [SECTION HEADER] ===
[stub text or final payload]
=========================

EOF
exit 0
```

### Executable Bit Discipline

**Source:** RESEARCH Pitfall 2 — silent failure mode
**Apply to:** Both shell scripts
**Pattern:** Every new `.sh` file authored via the Write tool needs an explicit follow-up `chmod +x` task. The plan should list this as a discrete action, not as a footnote.

```bash
chmod +x plugins/hack-skills-router/hooks/scripts/session-start.sh
chmod +x plugins/hack-skills-router/hooks/scripts/nudge.sh
# or in one call:
chmod +x plugins/hack-skills-router/hooks/scripts/*.sh
# verify:
ls -l plugins/hack-skills-router/hooks/scripts/  # all three files should show rwx for owner
```

### JSON Schema Validation

**Source:** RESEARCH §Standard Stack
**Apply to:** `marketplace.json` (after edit), `plugin.json`, `hooks.json`
**Pattern:** Run `claude plugin validate <dir>` before attempting install. Catches missing required fields, bad JSON syntax, frontmatter errors.

```bash
# After all files created:
claude plugin validate .                              # checks marketplace.json
claude plugin validate ./plugins/hack-skills-router   # checks plugin.json, SKILL.md, hooks.json
```

### Marketplace Re-Registration (for spike iteration)

**Source:** RESEARCH §Runtime State Inventory + v1 Phase 1 archived evidence
**Apply to:** Pre-install setup
**Pattern:** The marketplace is currently registered as GitHub-source (`Source: GitHub (SpencerPresley/hack-skills-marketplace)`). For local Phase 1 iteration WITHOUT pushing to GitHub between attempts, re-register as a local path:

```bash
claude plugin marketplace list                              # see current state
claude plugin marketplace remove hack-skills-marketplace    # remove GitHub form
claude plugin marketplace add ./                            # register repo as local path
# verify
claude plugin marketplace list                              # should now show local source
```

This is exactly what v1 Phase 1 did per `.planning/phases-archive-v1.0/03-marketplace-build-out/03-01-SUMMARY.md`.

---

## STUB vs Final Body Map (executor cheat sheet)

| File | Phase 1 STUB shape | Final shape (and which phase) |
|------|--------------------|-------------------------------|
| `marketplace.json` entry | Full final form (5 fields) | Same — Phase 1 is final shape (Pitfall 4: consider dropping `version` later) |
| `plugin.json` | Full final form (4 fields) | Same — Phase 1 is final shape |
| `SKILL.md` frontmatter | Short keyword-stub description (≤ 1 paragraph) | Phase 2: keyword-dense multi-paragraph description per design spec §5.6 |
| `SKILL.md` body | ≤ 30 lines stub announcing Phase 2 will replace it | Phase 2: ~80 lines per design spec §5.7 (when-to-use, trust, hybrid routing, 3-step ops, plugin availability, boundary conditions, examples cross-ref); PLUS new files `patterns/routing-tables.md`, `patterns/expert-intuitions.md`, `examples/workflow-walkthroughs.md` |
| `hooks/hooks.json` | Final structural shape; placeholder `"matcher": "XSS"` on UserPromptSubmit | Phase 3: full security-context regex per design spec §5.3 (vulnerability acronyms, verb stems, tool names, CVE pattern, file artifacts) — BUT note matcher is silently ignored, so the regex moves into `nudge.sh` instead |
| `hooks/scripts/session-start.sh` | ~5 line echo announcing Phase 3 will replace it | Phase 3: ~250 tok payload per design spec §5.4 — TRUST MODEL + OPERATING MODEL + 8 EXPERT INTUITIONS |
| `hooks/scripts/nudge.sh` | ~5 line echo announcing Phase 3 will replace it; fires on EVERY prompt | Phase 3: ~75 tok payload per design spec §5.5 + in-script regex filter (read `$PROMPT` from stdin JSON, grep, exit 0 silently if no match) — only fires on security-context prompts |

---

## No Analog Found

| File | Why no in-repo analog |
|------|----------------------|
| All except marketplace.json | Phase 1 introduces the FIRST sidecar plugin in this repo. The 13 existing v1 plugins are pure `git-subdir` curations with no `plugin.json`, no in-repo `SKILL.md`, no `hooks/`. External rust-skills reference fills the analog gap for plugin.json, SKILL.md frontmatter, hooks.json, and hook script shape — flagged explicitly per pattern assignment above. |

---

## Metadata

**Analog search scope:**
- In-repo: `.claude-plugin/`, `plugins/` (does not exist yet), repo root for any orphaned plugin shells
- External: `/Users/spencerpresley/skill-vetting/rust-skills/` (HANDOFF §4 reference)

**Files scanned:**
- In-repo: 1 (`.claude-plugin/marketplace.json`)
- External: 5 (rust-skills `.claude-plugin/plugin.json`, `.claude-plugin/marketplace.json`, `hooks/hooks.json`, `.claude/hooks/rust-skill-eval-hook.sh`, `skills/rust-router/SKILL.md`)

**Pattern extraction date:** 2026-05-22

**Confidence:** HIGH for all six file assignments. The rust-skills analog is structurally complete for Phase 1's STUB scope, and the in-repo marketplace.json defines the exact schema the new entry must conform to. The only judgment call in Phase 1 is the deliberate two-deviation from rust-skills (hook-script path = `hooks/scripts/` not `.claude/hooks/`; matcher field treated as forward-doc only) — both deviations are RESEARCH-justified and codified above.
