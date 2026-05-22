# Phase 1: Schema Verification - Research

**Researched:** 2026-05-22
**Domain:** Claude Code plugin marketplace runtime mechanics — `strict: false` + curated `skills` array against a multi-skill source repo
**Confidence:** HIGH (all VERIFY questions backed by official docs + observed cache layout on this exact machine + a real-world parallel marketplace using the same pattern)

## Summary

Phase 1 must answer three yes/no questions about how Claude Code's plugin runtime treats a marketplace entry that combines `strict: false` + `{ source: github, repo: yaklang/hack-skills }` + a curated `skills` array of *individual* skill subdirectory paths. The mechanics are observable on this machine: the `claude plugin` CLI is installed and produces JSON/structured output, the cache directory `~/.claude/plugins/cache/` already contains real plugin caches whose layout reveals the per-plugin partitioning model, and a real-world marketplace (`wondelai-skills`) on disk uses the *exact same pattern* we're testing — `strict: false` with a `skills` array of individual subdirectory paths sharing one source — which provides an existence proof that the mechanic is viable in production.

The three answers should be provable via three concrete artifacts: (1) `claude plugin details <plugin>@<marketplace>` output's `Skills (N)` line listing curated skills only (VERIFY-01), (2) the in-session `# available-skills` system reminder block excerpt + `claude plugin details` (VERIFY-02), and (3) `find ~/.claude/plugins/cache/hack-skills-marketplace -maxdepth 3 -type d` showing two parallel `<marketplace>/<plugin>/<version-or-sha>/` entries (VERIFY-03).

**Primary recommendation:** Drive Phase 1 from the `claude plugin` CLI, not the in-session `/plugin` TUI. The CLI is non-interactive, scriptable, JSON-capable, and the bug tracker (issue #52456) explicitly flags the TUI as unreliable for uninstall. The TUI is fine for the *system-reminder ground-truth* capture in VERIFY-02 (because that's a TUI-side artifact by definition), but everything else — install, list, details, uninstall, marketplace add/remove — should go through `claude plugin ...` CLI for reproducibility and copy-pasteable evidence.

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions

#### Test Marketplace Composition

- **D-01:** Two test groups, both real candidate buckets from `PROJECT.md` (not throwaways):
  - `hack-skills-recon` → `./skills/api-recon-and-docs` (1 skill)
  - `hack-skills-auth-bypass` → `./skills/401-403-bypass-techniques`, `./skills/api-auth-and-jwt-abuse` (2 skills)
- **D-02:** Three skill paths total across the two groups. Picks two specific individual paths in one group (auth-bypass) — that is what directly exercises VERIFY-01. Topically distant groups make VERIFY-02 isolation easy to eyeball.
- **D-03:** Both groups use `strict: false` and `{ "source": "github", "repo": "yaklang/hack-skills" }` per the PROJECT.md key decisions. No `plugin.json` is added to the source repo.

#### Install Source

- **D-04:** Local-path install only for Phase 1: `/plugin marketplace add ./hack-skills-marketplace` (or absolute path to this repo). No git push, no GitHub install during verification.
  - Rationale: Phase 4 owns end-to-end published-repo validation. Duplicating it here would muddy phase boundaries and slow iteration. If a local-path test passes, a github-install test is incremental.

#### Verification Artifact

- **D-05:** Verification output goes to `.planning/phases/01-schema-verification/01-VERIFICATION.md` — phase-local, matches GSD's per-phase artifact convention. Keeps `docs/` reserved for longer-lived user-facing plan documents.
- **D-06:** Artifact contains one section per VERIFY question (01/02/03) with: a yes/no answer, the install command used, the exact observation evidence (system-reminder excerpt, `/plugin` output, `ls ~/.claude/plugins/cache/` listing), and a one-line conclusion. Plus a "Pivot Policy" section (see D-09).

#### Context-Isolation Measurement Method (for VERIFY-02)

- **D-07:** Use BOTH measurements, with the system-reminder excerpt as ground truth:
  - Primary evidence: a fresh Claude Code session after install, capturing the `# available-skills` system-reminder block — that IS the context the model sees.
  - Secondary evidence: `/plugin` command output (or equivalent) snapshotted as a sanity check on enabled state.
  - Both go in the verification artifact for VERIFY-02 specifically. VERIFY-01 and VERIFY-03 don't need the dual measurement.

#### Pivot Policy (Roadmap Success Criterion #5)

- **D-08:** Record the pivot decision for each "no" outcome in the verification artifact BEFORE Phase 2 starts, even if every answer is "yes" (in which case each entry reads "N/A — answer was yes").
- **D-09:** Pre-decided pivot stances:
  - **VERIFY-01 (individual paths) "no":** Halt before Phase 2. Symlinks are rejected by PROJECT.md; restructuring/forking upstream is also out of scope. A "no" here forces a separate decision conversation about whether to abandon the strategy or accept parent-only grouping with a redesigned bucket model — not auto-executed.
  - **VERIFY-02 (context isolation) "no":** Halt. The whole value proposition is selective context activation; if curated `skills` arrays still leak the full source repo, the marketplace concept collapses for this use case.
  - **VERIFY-03 (cache collision) "no":** Document the actual collision behavior and decide whether a workaround (e.g., dedupe by hash, separate sources) is viable. Likely allows continuation if VERIFY-01/02 pass.

#### Test Hygiene

- **D-10:** Between verification sub-tests, uninstall the previous test plugin(s) and remove the test marketplace (`/plugin marketplace remove` + `/plugin uninstall`) to keep `~/.claude/plugins/cache/` observable. Final VERIFY-03 step requires both groups installed concurrently — that's the one case where cleanup is deferred until after evidence is captured.

### Claude's Discretion

- Filename/structure inside `01-VERIFICATION.md` (headings, table vs prose for evidence) — planner picks readable conventions.
- Whether to keep the test `.claude-plugin/marketplace.json` after verification or scrub it for Phase 3 to author cleanly — planner can decide based on whether the test config is forward-compatible with the eventual full set.
- Exact wording of the install/observation commands documented in the artifact — must be reproducible, format is open.

### Deferred Ideas (OUT OF SCOPE)

- **Github-install validation** — explicitly deferred to Phase 4 (PUB-02, PUB-03, PUB-04). Not a substitute for the local-path test in Phase 1.
- **Full skill classification / final taxonomy** — Phase 2 (GROUP-01..04). Phase 1's two test buckets are placeholders for verification, not the final list.
- **All ~8 marketplace entries** — Phase 3 (BUILD-01..03). Phase 1 stays at 2 groups regardless of how easy the build-out looks.
- **Sync / refresh process for upstream changes** — v2 (SYNC-01, SYNC-02).
- **README listing every group's skill set** — v2 (DISC-01).
</user_constraints>

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|------------------|
| VERIFY-01 | User can address individual skill subdirectories in the `skills` array (e.g. `["./skills/skill-a", "./skills/skill-b"]`) rather than being limited to parent directories | Official docs ([CITED: code.claude.com/docs/en/plugin-marketplaces]) describe `skills` as "Custom paths to skill directories containing `<name>/SKILL.md`" — i.e. each path is a *skill directory*, not a parent. Real-world precedent [VERIFIED: `wondelai-skills` marketplace.json on this disk] uses identical pattern: `skills: ["./jobs-to-be-done", "./negotiation", "./mom-test"]` with `strict: false`. `claude plugin details` output explicitly lists `Skills (N) name1, name2, ...` which is the observable evidence point. |
| VERIFY-02 | After installing a single group plugin built with `strict: false` + curated `skills` array, the session's system reminder lists only the curated skills — not all skills present in the source repo | System reminder format is `- {plugin-name}:{skill-id}: {description}` per line ([CITED: github.com/anthropics/claude-code/issues/57515]). Captured in a fresh session by reading the `# available-skills` (or equivalent) block. Secondary check: `claude plugin details` enumerates exposed skills directly. Both methods are needed because of known issue #57515 where descriptions may be silently dropped — the *count* and *names* are the load-bearing evidence. |
| VERIFY-03 | Multiple plugin entries sharing `yaklang/hack-skills` as their `source` produce separate cache entries in `~/.claude/plugins/cache/` and all install/enable cleanly without collision | Cache layout pattern observed on this exact machine: `~/.claude/plugins/cache/<marketplace-name>/<plugin-name>/<version-or-sha-or-"unknown">/` — see real entries `claude-plugins-official/plugin-dev/unknown/`, `claude-plugins-official/vercel/0.43.0/`, `rust-skills/rust-skills/2.1.0/`, etc. Per-plugin partitioning by directory means two plugins in our marketplace pointing at the same `github` source MUST resolve into two distinct cache subdirs under `~/.claude/plugins/cache/hack-skills-marketplace/`. The observable artifact is a `find ... -maxdepth 3 -type d` listing showing two parallel `hack-skills-recon/<...>/` and `hack-skills-auth-bypass/<...>/` directories. |
</phase_requirements>

## Architectural Responsibility Map

This phase has no multi-tier application architecture in the conventional sense — it is verifying behavior of a developer tool (Claude Code) against authored configuration. Map below shows where each verification observation lives in Claude Code's own tier model.

| Capability | Primary Tier | Secondary Tier | Rationale |
|------------|-------------|----------------|-----------|
| Authored configuration | Marketplace JSON (`.claude-plugin/marketplace.json` in this repo) | — | Single source of truth for what plugins exist and what skills they expose. |
| Marketplace registration | Claude Code user state (`~/.claude/plugins/known_marketplaces.json`) | — | `claude plugin marketplace add` writes here. |
| Installed-plugin registration | Claude Code user state (`~/.claude/plugins/installed_plugins.json`) | — | `claude plugin install` writes here. Contains `installPath`, `version`, `scope`, `gitCommitSha`. |
| Source repo materialization | Claude Code plugin cache (`~/.claude/plugins/cache/<marketplace>/<plugin>/<version>/`) | — | `claude plugin install` clones the source repo here. This is what VERIFY-03 inspects. |
| Skill exposure to session | Claude Code runtime (system reminder injection in active session) | `claude plugin details` (out-of-session inspection) | The runtime decides what skills appear in the model's context. VERIFY-02 measures this. |
| Verification artifact | Repo file (`.planning/phases/01-schema-verification/01-VERIFICATION.md`) | — | Persisted human-readable record of yes/no + evidence. |

## Standard Stack

This phase doesn't install software libraries; it authors JSON and observes a CLI. The "stack" is the toolchain already present on the target machine.

### Core

| Tool | Version | Purpose | Why Standard |
|------|---------|---------|--------------|
| Claude Code CLI | 2.1.148 [VERIFIED: `claude --version` on this machine] | Drives marketplace add, plugin install, plugin details, plugin uninstall — non-interactively | The `claude plugin` subcommand surface is the documented, supported way to manage plugins programmatically. [CITED: code.claude.com/docs/en/plugin-marketplaces#manage-marketplaces-from-the-cli] |
| `.claude-plugin/marketplace.json` schema | per [CITED: code.claude.com/docs/en/plugin-marketplaces#marketplace-schema] | Configuration to verify | Standard, documented format. Already empty placeholder file exists in repo. |
| Local-path marketplace source | per [CITED: code.claude.com/docs/en/plugin-marketplaces#test-locally-before-distribution] | Eliminates github-push as a Phase 1 dependency | Officially supported testing workflow: `claude plugin marketplace add ./<dir>`. |

### Supporting

| Tool | Version | Purpose | When to Use |
|------|---------|---------|-------------|
| `claude plugin validate <path>` | 2.1.148 | Validate marketplace.json syntax + schema before install | Run before `marketplace add`; cheap pre-flight. |
| `find ~/.claude/plugins/cache -maxdepth N -type d` | system | Inspect cache layout directly | VERIFY-03 evidence collection. |
| `cat ~/.claude/plugins/installed_plugins.json` | system | Inspect install metadata (gitCommitSha, version slot, scope) | Sanity-check that install actually wrote what we expect, esp. version resolution. |
| `claude plugin list --json` | 2.1.148 | Machine-readable list of installed plugins, scope, enabled state | VERIFY-02 secondary evidence; VERIFY-03 sanity check on enablement. |
| `claude plugin details <id>@<mkt>` | 2.1.148 | Per-plugin "Component inventory" → `Skills (N) name1, name2, ...` | **Critical evidence for VERIFY-01 and VERIFY-02 secondary.** Direct, unambiguous, copy-pasteable. |

### Alternatives Considered

| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| `claude plugin install` CLI | In-session `/plugin install` TUI | TUI is officially flagged unreliable for uninstall (issue #52456). Use CLI for hygiene operations. TUI acceptable only for system-reminder capture in VERIFY-02. |
| Local-path install | Push to github first, install from there | Locked out by D-04. Phase 4 owns github install. Local-path is faster, more deterministic, and produces the same `installed_plugins.json` shape as github install (both end up at `~/.claude/plugins/cache/<marketplace>/<plugin>/<version>/`). |
| Verifying via running session | Verifying via cache inspection only | Required dual-measurement per D-07 for VERIFY-02. Cache only proves what was cloned, not what's exposed to the model. |

**Installation:** No new tools required. `claude` is already at 2.1.148. The marketplace.json is authored in `.claude-plugin/marketplace.json` (path already exists, file is empty placeholder).

**Version verification:**

```bash
claude --version               # observed: 2.1.148 (Claude Code) [VERIFIED]
claude plugin --help           # observed: full subcommand surface present [VERIFIED]
```

## Package Legitimacy Audit

Not applicable — this phase installs no npm/pip/cargo packages. The "installs" are Claude Code plugins (declarative skill loading), which are explicitly skill-only curations (no `mcpServers`, no `hooks` scripts, per project Out of Scope). Source repo `yaklang/hack-skills` is already trusted upstream per PROJECT.md.

## Architecture Patterns

### System Architecture Diagram

```
Author/edit                              Run-once observation                       Persistent state on disk
───────────                              ────────────────────                       ────────────────────────

repo/.claude-plugin/         ──read──>   claude plugin                              ~/.claude/plugins/
  marketplace.json                       marketplace add                              known_marketplaces.json   <─append entry
  (2 entries:                            ./hack-skills-                               marketplaces/
   hack-skills-recon,                    marketplace                                    hack-skills-marketplace/  <─git-clone or copy
   hack-skills-auth-                                                                      .claude-plugin/
   bypass — both                                                                            marketplace.json
   strict: false,
   skills: [individual                  claude plugin                              ~/.claude/plugins/
   ./skills/<name>                       install hack-skills-                        installed_plugins.json    <─entry per install:
   paths])                               recon@hack-skills-                            { installPath, version,
                                         marketplace --scope user                        gitCommitSha, scope }
                                                                       │
                                                                       ▼
                                         marketplace runtime          ~/.claude/plugins/cache/         ◄── VERIFY-03 inspects
                                         consults `source`              hack-skills-marketplace/         this tree shape:
                                         descriptor for the              hack-skills-recon/                 expects ONE subdir
                                         plugin, fetches                   <version-or-sha>/                per installed plugin
                                         yaklang/hack-skills                .claude-plugin/                 (no collision).
                                         repo, materializes                 skills/
                                         the full repo into                   api-recon-and-docs/SKILL.md  Whole repo is cloned;
                                         the cache subdir                     401-403-bypass-techniques/...   the `skills` array
                                                                              ... (all 102) ...                does NOT prune the
                                                                              api-auth-and-jwt-abuse/...      filesystem — it
                                                                                                              prunes what's EXPOSED.

                                         claude plugin enable          (in-memory: marketplace runtime decides
                                         hack-skills-recon@...           which SKILL.md files are surfaced to
                                                                         the next session's system reminder
                                                                         based on plugin's `skills` array)

                                         start Claude Code             session's system reminder injected:    ◄── VERIFY-02 inspects
                                         session                         # available-skills                      this block (D-07
                                                                          - hack-skills-recon:api-recon-and-docs:  ground truth):
                                                                            description text...                    expects ONLY
                                                                                                                   curated skills.

                                         claude plugin details         stdout: Skills (N) name1, name2, ...   ◄── VERIFY-01 (primary)
                                         hack-skills-recon@...                                                    + VERIFY-02 (secondary)

                                         claude plugin uninstall       installed_plugins.json entry removed
                                         hack-skills-recon@... -y      (cache subdir may persist 7 days; see   ◄── D-10 hygiene
                                         claude plugin marketplace      Common Pitfalls — orphaned cache)
                                         remove hack-skills-
                                         marketplace
```

### Recommended Project Structure

```
hack-skills-marketplace/                                  # marketplace root (this repo)
├── .claude-plugin/
│   └── marketplace.json                                  # ONLY file modified in this phase
├── .planning/
│   └── phases/
│       └── 01-schema-verification/
│           ├── 01-CONTEXT.md                             # (already present, locked decisions)
│           ├── 01-RESEARCH.md                            # this document
│           ├── 01-PLAN-*.md                              # planner output
│           └── 01-VERIFICATION.md                        # the artifact produced by Phase 1
└── docs/PLAN.md                                          # untouched
```

External (read-only inspection targets):

```
~/.claude/plugins/
├── known_marketplaces.json                               # appended/edited by `marketplace add/remove`
├── installed_plugins.json                                # appended/edited by `plugin install/uninstall`
├── marketplaces/<name>/.claude-plugin/marketplace.json   # marketplace clone
└── cache/<marketplace-name>/<plugin-name>/<version>/...  # per-plugin cache — VERIFY-03 target
```

### Pattern 1: Authored marketplace.json shape per D-01/D-03

```jsonc
// Source: combination of docs/PLAN.md lines 92-119 and CONTEXT.md D-01/D-03
// Verified shape: matches schema in code.claude.com/docs/en/plugin-marketplaces#marketplace-schema
// Real-world parallel: wondelai-skills marketplace.json on disk uses same pattern
{
  "name": "hack-skills-marketplace",
  "owner": { "name": "Spencer Presley" },
  "description": "Curated topical groups of yaklang/hack-skills",
  "plugins": [
    {
      "name": "hack-skills-recon",
      "source": { "source": "github", "repo": "yaklang/hack-skills" },
      "strict": false,
      "description": "Reconnaissance and information gathering",
      "skills": ["./skills/api-recon-and-docs"]
    },
    {
      "name": "hack-skills-auth-bypass",
      "source": { "source": "github", "repo": "yaklang/hack-skills" },
      "strict": false,
      "description": "Authentication and authorization bypass",
      "skills": [
        "./skills/401-403-bypass-techniques",
        "./skills/api-auth-and-jwt-abuse"
      ]
    }
  ]
}
```

Critical: skill paths in `skills` are relative to **the plugin's source root** (the cloned `yaklang/hack-skills` repo's root, where `skills/` is a top-level directory), NOT to this marketplace repo. [CITED: code.claude.com/docs/en/plugin-marketplaces — "Source paths in `skills` are relative to the plugin's source root"]

### Pattern 2: Install / observe / uninstall cycle per VERIFY question

```bash
# Source: claude plugin --help on this machine (2.1.148) [VERIFIED]
# Pre-flight
claude plugin validate /Users/spencerpresley/code/hack-skills-wip/hack-skills-marketplace

# VERIFY-01 + VERIFY-02 phase (one group at a time, per D-10)
claude plugin marketplace add /Users/spencerpresley/code/hack-skills-wip/hack-skills-marketplace --scope user
claude plugin install hack-skills-recon@hack-skills-marketplace --scope user
claude plugin enable hack-skills-recon@hack-skills-marketplace
claude plugin details hack-skills-recon@hack-skills-marketplace   # captures Skills (N) line
# Then: start `claude` interactive session, capture system reminder

# Tear down (between sub-tests, per D-10)
claude plugin disable hack-skills-recon@hack-skills-marketplace
claude plugin uninstall hack-skills-recon@hack-skills-marketplace --scope user -y
claude plugin marketplace remove hack-skills-marketplace

# VERIFY-03 phase (both installed concurrently, no teardown between)
claude plugin marketplace add /Users/spencerpresley/code/hack-skills-wip/hack-skills-marketplace --scope user
claude plugin install hack-skills-recon@hack-skills-marketplace --scope user
claude plugin install hack-skills-auth-bypass@hack-skills-marketplace --scope user
claude plugin enable hack-skills-recon@hack-skills-marketplace
claude plugin enable hack-skills-auth-bypass@hack-skills-marketplace
find ~/.claude/plugins/cache/hack-skills-marketplace -maxdepth 3 -type d
du -sh ~/.claude/plugins/cache/hack-skills-marketplace/*/* 2>/dev/null
# Final teardown
claude plugin disable hack-skills-recon@hack-skills-marketplace
claude plugin disable hack-skills-auth-bypass@hack-skills-marketplace
claude plugin uninstall hack-skills-recon@hack-skills-marketplace --scope user -y
claude plugin uninstall hack-skills-auth-bypass@hack-skills-marketplace --scope user -y
claude plugin marketplace remove hack-skills-marketplace
```

### Pattern 3: System-reminder capture (D-07 primary evidence for VERIFY-02)

The system reminder block injected into a fresh session lists skills as `- {plugin-name}:{skill-id}: {description}` lines under a header section (in practice `# available-skills` or similar — exact heading varies by Claude Code version; capture verbatim). [CITED: github.com/anthropics/claude-code/issues/57515]

To capture: start a fresh `claude` session with the test plugin enabled, then ask the model to dump the available-skills section of its system reminder verbatim. The model can see its own system reminder — this is the recursively-observable property the phase exploits. Paste the verbatim block into 01-VERIFICATION.md as a fenced code block (per D-06 "exact observation evidence" and SPECIFICS "verbatim quote block, not paraphrased").

### Anti-Patterns to Avoid

- **Using the `/plugin` in-session TUI for uninstall.** [CITED: github.com/anthropics/claude-code/issues/52456] The TUI is unreliable for uninstall; use `claude plugin uninstall` CLI with `-y`.
- **Assuming uninstall cleans the cache directory.** [CITED: github.com/anthropics/claude-code/issues/37865, #35691, #15369, #29074] Uninstall removes the entry from `installed_plugins.json` but the cache subdirectory persists (orphaned, auto-deleted after 7 days). For VERIFY-03 observability, the planner must either inspect immediately while installed (the canonical path) or document that residual cache dirs from earlier sub-tests do NOT count as "collision" — only same-test cache contention does.
- **Mixing scopes between sub-tests.** Install always at `--scope user` for all of Phase 1. Mixing `project` and `user` scopes produces duplicated entries in `claude plugin list` (already observed locally for `frontend-design` and `pyright-lsp`) and muddies the cache inspection.
- **Inferring version slot before observing it.** With `strict: false`, no upstream `plugin.json`, no `version` in marketplace entry, and a `github` source without a pinned `sha`, the resolved version is the github commit SHA. [CITED: code.claude.com/docs/en/plugin-marketplaces#version-resolution-and-release-channels] Currently `yaklang/hack-skills@HEAD` = `c6f732befcae6daba2c327e73766a96ed16c0078` [VERIFIED via local sibling clone]. The cache dir will be `~/.claude/plugins/cache/hack-skills-marketplace/hack-skills-recon/<some-version-token>/` — read it, don't predict it; document the exact token observed.
- **Authoring `skills` paths without the `./` prefix.** Per schema, marketplace entry paths must start with `./`. Real-world wondelai-skills, claude-plugins-official examples all use `./skills/...` form. A path like `"skills/api-recon-and-docs"` (no leading `./`) is invalid syntax.

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| List installed plugins for evidence | A custom directory walker | `claude plugin list --json` | Provides exact `installPath`, `version`, `scope`, `enabled` fields. JSON-shaped, ready for paste-into-artifact. |
| Enumerate exposed skills of a plugin | Parsing the cached SKILL.md files manually | `claude plugin details <id>@<mkt>` | Returns a single "Skills (N) name1, ..." line that *is* the runtime's view, which is precisely what VERIFY-01 demands. |
| Validate marketplace.json before install | Hand-checking schema | `claude plugin validate <path>` | Official validator — catches duplicate names, path traversal, JSON syntax, and version mismatches. Fast pre-flight. |
| Build a "what does the model see" probe | Hand-rolled prompt scaffolding | The Claude Code session itself, with the model asked to dump its own system reminder | The system reminder is recursively observable from inside the session. No external instrumentation needed. |

**Key insight:** The Claude Code CLI already provides exactly the inspection surface this phase needs. The verification artifact should consist mostly of copy-pasted CLI output (with version/SHA/path tokens preserved), not synthesized prose summarizing what was seen.

## Runtime State Inventory

> This is a verification phase that *modifies* runtime state (installs/uninstalls plugins, edits cache). Listing what state will be touched so the planner can write defensive cleanup steps.

| Category | Items Touched | Action Required |
|----------|---------------|------------------|
| Stored data | None — no user data, no databases, no application state. | None. |
| Live service config | `~/.claude/plugins/known_marketplaces.json` (new entry `hack-skills-marketplace` added/removed); `~/.claude/plugins/installed_plugins.json` (2 entries added/removed); per-scope enablement state. | D-10 teardown commands handle this. Planner should include a final "post-Phase-1 cleanup" verification step confirming `claude plugin list --json` has no `hack-skills-*` entries and `claude plugin marketplace list --json` does not contain `hack-skills-marketplace` after the phase completes — UNLESS the user wants to keep the test marketplace around as a starting point for Phase 3, which is Claude's discretion per CONTEXT.md. |
| OS-registered state | None — no systemd, launchd, Task Scheduler, pm2 entries. | None. |
| Secrets/env vars | None. (Could mention `GITHUB_TOKEN` — but `yaklang/hack-skills` is public, so unauthenticated `git clone` works. Document only if observed to fail.) | None expected. |
| Build artifacts / installed packages | Cache subdirs under `~/.claude/plugins/cache/hack-skills-marketplace/<plugin>/<version>/` — created by install, orphaned (not deleted) by uninstall, auto-removed 7 days later. [CITED: issue #37865] | Planner notes this as a known landmine, not an action item. For repeated phase runs, manually `rm -rf ~/.claude/plugins/cache/hack-skills-marketplace/` after the final teardown if a clean baseline is needed for re-verification. |

## Common Pitfalls

### Pitfall 1: Skill descriptions silently dropped from system reminder

**What goes wrong:** Some skills appear in the `# available-skills` block as `- {plugin}:{skill}` with NO description text, while others appear as `- {plugin}:{skill}: {full description...}`. [CITED: github.com/anthropics/claude-code/issues/57515]

**Why it happens:** Unknown — root cause not isolated by the maintainers. The issue specifically implicates "deduplication logic across coexisting cache directories" — meaning a plugin's cache existing in multiple version subdirs simultaneously can trigger description dropouts. This is directly relevant to VERIFY-02 and VERIFY-03.

**How to avoid:**
- Use a clean cache subdir for the marketplace. If `~/.claude/plugins/cache/hack-skills-marketplace/` already exists from a previous test, delete it before the canonical install.
- Treat description-dropout as a non-blocker for VERIFY-02: the load-bearing evidence is the COUNT and the LIST of skill *names* in the system reminder, not whether each one carries its description text. Document this caveat in 01-VERIFICATION.md.

**Warning signs:**
- A skill that you know has a description in its `SKILL.md` shows in the system reminder as only `- hack-skills-recon:api-recon-and-docs` with no trailing text.
- Two different cache subdirs exist for the same plugin under `~/.claude/plugins/cache/hack-skills-marketplace/hack-skills-recon/` (e.g. one named with a SHA, another with `unknown` or an older SHA).

### Pitfall 2: Disabled plugins' skills still appear in `/skills`

**What goes wrong:** Setting a plugin's `enabledPlugins` entry to `false` in `~/.claude/settings.json` does NOT prevent its skills from being registered and shown in the system reminder. [CITED: github.com/anthropics/claude-code/issues/40789]

**Why it happens:** Open bug — disabled-but-installed plugins are still loaded for skill enumeration. Uninstall, not just disable, is required to remove a plugin's skills from session context.

**How to avoid:**
- For VERIFY-02 isolation tests, do not rely on "disable" between sub-tests. *Uninstall* per D-10. The hygiene commands in Pattern 2 already use `uninstall`, not `disable`-only, so this is mostly a sanity warning.
- When inspecting the system reminder, confirm BOTH that expected skills appear AND that no skills from previously-installed-but-now-disabled test plugins appear.

**Warning signs:** A skill name from a previous test run (e.g., from `hack-skills-recon` after running `hack-skills-auth-bypass` next) appears in the system reminder of the next session.

### Pitfall 3: Uninstall leaves orphaned cache directories

**What goes wrong:** `claude plugin uninstall` removes the entry from `installed_plugins.json` but the cache subdir at `~/.claude/plugins/cache/<marketplace>/<plugin>/<version>/` persists on disk for ~7 days (configurable grace period). [CITED: github.com/anthropics/claude-code/issues/37865, #35691]

**Why it happens:** Intentional grace period to allow concurrent Claude Code sessions to keep running after an uninstall. Not a bug — but it is surprising behavior that affects VERIFY-03 evidence collection.

**How to avoid:**
- Inspect `~/.claude/plugins/cache/hack-skills-marketplace/` **immediately while plugins are installed**, before any teardown. That's the canonical observation point for VERIFY-03 success.
- Document in 01-VERIFICATION.md (and the pivot policy section) that residual cache dirs visible AFTER teardown are not the VERIFY-03 evidence — they're a known artifact of grace-period orphaning.
- For complete cache reset between phase runs: `rm -rf ~/.claude/plugins/cache/hack-skills-marketplace/` after the final teardown. Safe because no other plugins share that directory tree.

**Warning signs:** After running all teardown commands, `ls ~/.claude/plugins/cache/hack-skills-marketplace/` still shows directories. This is expected, not a failure.

### Pitfall 4: TUI uninstall is unreliable

**What goes wrong:** Using `/plugin uninstall ...` from inside an interactive Claude Code session may report success but leave the plugin partially registered. [CITED: github.com/anthropics/claude-code/issues/52456]

**Why it happens:** Known UI bug — the TUI and CLI paths diverge. CLI is the canonical, tested path.

**How to avoid:** Always use `claude plugin uninstall <id>@<mkt> --scope user -y` from a shell, NOT the in-session TUI. This is already baked into the D-10 commands in Pattern 2 above.

**Warning signs:** `claude plugin list --json` continues to show the plugin after a TUI uninstall reported success.

### Pitfall 5: Misinterpreting "what got cached" vs "what got exposed"

**What goes wrong:** Observing the cache subdir and seeing **all 102 skills** in `~/.claude/plugins/cache/hack-skills-marketplace/hack-skills-recon/<sha>/skills/` and concluding VERIFY-01 has failed.

**Why it happens:** `strict: false` does NOT prune the source repo on clone. The full repo is materialized into the cache (this is unavoidable given the source descriptor points at the whole repo). What `strict: false` + the `skills` array prunes is what gets **exposed to the model's session** — i.e., what shows up in the system reminder.

**How to avoid:**
- Frame VERIFY-01 as "what does `claude plugin details` say about exposed skill count?", NOT "what does `ls cache/<plugin>/<sha>/skills/` show?". The cache will always show the full repo. The details command shows the curated subset.
- Add an explicit note in 01-VERIFICATION.md: "All 102 skill subdirectories are present in the on-disk cache — this is expected and does not constitute a VERIFY-01 failure. VERIFY-01 evidence is the `Skills (N) ...` line from `claude plugin details` and the system reminder's exposed-skill list, both of which must show only curated skills."

**Warning signs:** Confusion between cache contents (full source repo) and runtime exposure (curated subset). Reviewer pushback on "but I see 102 skills in the cache."

### Pitfall 6: Version slot ambiguity confuses VERIFY-03

**What goes wrong:** Two cache subdirs appear (one per plugin) but their version slots collide on the same SHA (`c6f732befcae6daba2c327e73766a96ed16c0078`) — and someone confuses this with cache collision.

**Why it happens:** Both plugins source from the same `yaklang/hack-skills` repo at the same default-branch HEAD. So both subdirs share the same SHA version token: `cache/hack-skills-marketplace/hack-skills-recon/c6f732be.../` and `cache/hack-skills-marketplace/hack-skills-auth-bypass/c6f732be.../`. This is **separate cache entries with matching version slots** — not a collision. The directory tree is partitioned by plugin name (the level above version), not by version.

**How to avoid:**
- The VERIFY-03 acceptance criterion is "two parallel `<plugin-name>/<version>/` subdirs exist under `cache/hack-skills-marketplace/`", NOT "two distinct version tokens".
- Use this exact assertion shape: `find ~/.claude/plugins/cache/hack-skills-marketplace -mindepth 2 -maxdepth 2 -type d | wc -l` should output `2`.

**Warning signs:** Confusion expressed as "both plugins resolved to the same version, isn't that a collision?" — no, it's not, because the `<plugin-name>` directory level above `<version>` provides the partitioning.

## Code Examples

### Example 1: marketplace.json authored to D-01/D-03 spec

```jsonc
// Source: docs/PLAN.md lines 92-119, CONTEXT.md D-01/D-03
// Verified: matches schema in code.claude.com/docs/en/plugin-marketplaces#marketplace-schema
// Real-world parallel pattern: wondelai-skills marketplace (multiple plugins, one source, strict: false, individual skill paths)
{
  "name": "hack-skills-marketplace",
  "owner": { "name": "Spencer Presley" },
  "description": "Curated topical groups of yaklang/hack-skills",
  "plugins": [
    {
      "name": "hack-skills-recon",
      "source": { "source": "github", "repo": "yaklang/hack-skills" },
      "strict": false,
      "description": "Reconnaissance and information gathering",
      "skills": ["./skills/api-recon-and-docs"]
    },
    {
      "name": "hack-skills-auth-bypass",
      "source": { "source": "github", "repo": "yaklang/hack-skills" },
      "strict": false,
      "description": "Authentication and authorization bypass",
      "skills": [
        "./skills/401-403-bypass-techniques",
        "./skills/api-auth-and-jwt-abuse"
      ]
    }
  ]
}
```

### Example 2: Validate before install

```bash
# Source: claude plugin validate --help (2.1.148) [VERIFIED on this machine]
claude plugin validate /Users/spencerpresley/code/hack-skills-wip/hack-skills-marketplace
# Expected on success: silent or "All checks passed" / equivalent.
# Expected on failure: error messages about duplicate names, path traversal, JSON syntax,
# or skill paths not found in the source (latter MAY require post-install validation,
# since the source repo isn't cloned until install).
```

### Example 3: VERIFY-01 evidence collection

```bash
# Source: claude plugin commands documented at code.claude.com/docs/en/plugin-marketplaces
#         + observed shape of `claude plugin details` output for plugin-dev@claude-plugins-official
claude plugin marketplace add /Users/spencerpresley/code/hack-skills-wip/hack-skills-marketplace --scope user
claude plugin install hack-skills-auth-bypass@hack-skills-marketplace --scope user
claude plugin enable hack-skills-auth-bypass@hack-skills-marketplace

# Primary evidence:
claude plugin details hack-skills-auth-bypass@hack-skills-marketplace
# EXPECTED OUTPUT SHAPE (verified shape from plugin-dev real example):
#
#   hack-skills-auth-bypass
#     Authentication and authorization bypass
#     Source: hack-skills-auth-bypass@hack-skills-marketplace
#
#   Component inventory
#     Skills (2)  401-403-bypass-techniques, api-auth-and-jwt-abuse
#     Agents (0)
#     Hooks (0)
#     MCP servers (0)
#     LSP servers (0)
#   ...
#
# VERIFY-01 PASSES if and only if "Skills (2)" line lists exactly these two and no others.
# VERIFY-01 FAILS if "Skills (102)" or any number other than 2 appears, OR if other skill
# names from yaklang/hack-skills appear.

# Secondary evidence (install metadata):
cat ~/.claude/plugins/installed_plugins.json | jq '.plugins["hack-skills-auth-bypass@hack-skills-marketplace"]'
# Expected: an array with one entry having installPath, version (likely the github commit SHA
# c6f732befcae6daba2c327e73766a96ed16c0078 or similar), scope: "user", gitCommitSha.
```

### Example 4: VERIFY-02 dual evidence (D-07)

```bash
# After install + enable as in Example 3:

# PRIMARY evidence (D-07): start a fresh interactive session and capture the system reminder
claude
# Then inside the session, prompt:
#   "Dump verbatim the section of your system reminder that lists available skills."
# Paste the model's verbatim response into 01-VERIFICATION.md as a fenced ``` code block.
#
# EXPECTED FORMAT [CITED: issue #57515]:
#   # available-skills (or similar heading — capture verbatim)
#   - hack-skills-auth-bypass:401-403-bypass-techniques: <description text>
#   - hack-skills-auth-bypass:api-auth-and-jwt-abuse: <description text>
#
# VERIFY-02 PASSES if and only if exactly these two skill entries appear and no others
# from yaklang/hack-skills (e.g., no `active-directory-acl-abuse`, no `crypto-...`).
# VERIFY-02 FAILS if any of the other 100 skills appear.
#
# Note on description dropout (Pitfall 1): if one entry shows as
#   - hack-skills-auth-bypass:401-403-bypass-techniques
# (no description text), that is NOT a VERIFY-02 failure — it's known issue #57515.
# Document the dropout in 01-VERIFICATION.md but count the verification as PASS if the
# names + count match.

# SECONDARY evidence (D-07): claude plugin details (sanity check on enabled state)
claude plugin details hack-skills-auth-bypass@hack-skills-marketplace
# Same Skills (2) line as Example 3.
```

### Example 5: VERIFY-03 cache layout inspection

```bash
# After both plugins installed concurrently (D-10 exception — no teardown between):
claude plugin install hack-skills-recon@hack-skills-marketplace --scope user
claude plugin install hack-skills-auth-bypass@hack-skills-marketplace --scope user
claude plugin enable hack-skills-recon@hack-skills-marketplace
claude plugin enable hack-skills-auth-bypass@hack-skills-marketplace

# Capture cache tree:
find ~/.claude/plugins/cache/hack-skills-marketplace -maxdepth 3 -type d
# EXPECTED OUTPUT (paste verbatim into 01-VERIFICATION.md):
#
#   /Users/spencerpresley/.claude/plugins/cache/hack-skills-marketplace
#   /Users/spencerpresley/.claude/plugins/cache/hack-skills-marketplace/hack-skills-recon
#   /Users/spencerpresley/.claude/plugins/cache/hack-skills-marketplace/hack-skills-recon/<version-token>
#   /Users/spencerpresley/.claude/plugins/cache/hack-skills-marketplace/hack-skills-auth-bypass
#   /Users/spencerpresley/.claude/plugins/cache/hack-skills-marketplace/hack-skills-auth-bypass/<version-token>
#
# where <version-token> is the github commit SHA (e.g., c6f732be...). Both plugins likely
# share the same SHA — this is expected, not a collision. See Pitfall 6.
#
# VERIFY-03 PASSES if and only if both `hack-skills-recon/<version>/` and
# `hack-skills-auth-bypass/<version>/` exist as separate subdirectories.
# VERIFY-03 FAILS if only one subdir exists, or if the directories collapse into one
# shared `<sha>/` slot at the same level as the plugin names.

# Strict pass-assertion:
[ "$(find ~/.claude/plugins/cache/hack-skills-marketplace -mindepth 2 -maxdepth 2 -type d | wc -l)" -eq 2 ] \
  && echo "VERIFY-03: 2 separate plugin cache subdirs ✓" \
  || echo "VERIFY-03: FAIL — expected 2 subdirs"

# Size sanity (per SPECIFICS note: "confirms small for text-only repo"):
du -sh ~/.claude/plugins/cache/hack-skills-marketplace/*/* 2>/dev/null

# Enabled state sanity:
claude plugin list --json | jq '.[] | select(.id | startswith("hack-skills-")) | {id, version, scope, enabled}'
# Expected: 2 entries, both enabled: true.
```

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| `/plugin` TUI for all plugin management | `claude plugin` CLI with subcommands | Claude Code 2.x added the non-interactive CLI surface | This phase uses the CLI for all hygiene and evidence-gathering operations. TUI only used (optionally) for system-reminder capture in VERIFY-02. |
| `strict: true` (default) — plugin.json is authoritative | `strict: false` — marketplace entry is authoritative | Schema feature; not a recent change | This is what makes our approach (using `yaklang/hack-skills` upstream WITHOUT modifying it) possible. Without `strict: false` we'd need to add a `plugin.json` to upstream, which violates source-immutability constraint. |
| Marketplace plugin sources are paths inside the same repo | Marketplace plugin sources can be external git repos (github, url, git-subdir, npm) | Schema feature | Lets one marketplace catalog point at multiple external sources. Lets multiple plugin entries share one source — the exact mechanic Phase 1 verifies. |

**Deprecated/outdated:**
- Reliance on the in-session `/plugin uninstall` TUI: superseded by `claude plugin uninstall` CLI; TUI flagged unreliable per issue #52456. The plan should use the CLI.

## Assumptions Log

| # | Claim | Section | Risk if Wrong |
|---|-------|---------|---------------|
| A1 | The exact heading text for the system-reminder block is `# available-skills` (or close variant). [ASSUMED — based on issue #57515 phrasing and project's CONTEXT.md D-07 mention] | Pattern 3, Example 4 | LOW. The planner instructs capture-verbatim; the actual heading text in the recorded artifact will be whatever Claude Code 2.1.148 emits. Any heading variant still serves as evidence as long as the per-skill entries follow the `- {plugin}:{skill}: {desc}` format. |
| A2 | The version token in the cache path will resolve to the github commit SHA `c6f732be...` (current `yaklang/hack-skills@HEAD` per local clone). [ASSUMED — based on docs version-resolution rules: no `plugin.json` in source, no `version` in marketplace entry, `github` source without pinned `sha`] | Pattern 2, Example 5, Pitfall 6 | LOW. If the actual token is something else (e.g., `"unknown"` like `plugin-dev/unknown/` or a different SHA), VERIFY-03 still passes — the pass condition is "2 parallel subdirs", not "specific SHA value". The planner should record the actual token, not predict it. |
| A3 | Both plugins resolving from the same source repo at the same default-branch HEAD will produce the same version token in their respective cache paths. [ASSUMED — same-source same-ref logically implies same SHA resolution] | Pitfall 6, Example 5 | LOW. Even if they somehow resolve to different tokens, VERIFY-03 still passes — the per-plugin partitioning is by *plugin name*, not by version. Different tokens would just mean two different subdirs at slightly different paths. |
| A4 | `claude plugin install` against a `github` source without a `GITHUB_TOKEN` set will succeed because `yaklang/hack-skills` is public. [ASSUMED — based on docs "private repositories" section which only requires tokens for private repos] | Example 3, Runtime State Inventory | LOW. If clone fails, error message will be explicit (auth failure). Planner can document the fallback (`export GITHUB_TOKEN=...`) if needed. |
| A5 | The `claude plugin details` command's `Skills (N)` line lists ONLY the curated skills when `strict: false` + `skills` array is used (not all 102). [ASSUMED — extrapolating from documented `strict: false` semantics and the fact that `details` reports "Component inventory"] | VERIFY-01 evidence | **MEDIUM.** This is the central thing VERIFY-01 is trying to prove. If `details` reports all 102, VERIFY-01 fails by definition. The verification exists precisely because this is a critical assumption — that is why Phase 1 is gated. |
| A6 | The `# available-skills` block in the session's system reminder is sourced from the same internal data as `claude plugin details` (i.e., respects `strict: false` curation). [ASSUMED — both surfaces should consult the same enabled-component registry] | VERIFY-02 evidence | **MEDIUM.** Same as A5 but for the in-session surface. The dual-measurement in D-07 is precisely to catch a divergence here (e.g., details reports curated 2, system reminder reports all 102 — that's a "no" on VERIFY-02 even if VERIFY-01 passes). |

## Open Questions

1. **Does `claude plugin install` on a local-path marketplace whose plugin source is `github` actually network-fetch the github repo, or refuse because the marketplace itself is local-path?**
   - What we know: Real-world `claude-plugins-official` marketplace (added via github) has plugins with `github`, `url`, `git-subdir` sources that all successfully cache under `~/.claude/plugins/cache/claude-plugins-official/<plugin>/<version>/`. Local-path marketplaces are documented to work for testing.
   - What's unclear: Whether a *local-path* marketplace's *github-sourced* plugin behaves the same way as a *github-marketplace*'s *github-sourced* plugin.
   - Recommendation: Test in Phase 1 directly. Wave 0 / first sub-test of VERIFY-01 will reveal this. If it fails, the planner can fall back to publishing the marketplace to a private/local-only git remote first — but this would conflict with D-04. More likely: it just works, given the documented separation between "marketplace source" and "plugin source" (the docs explicitly call out that these are independent).

2. **Does Claude Code 2.1.148's system reminder block use the heading `# available-skills` or a different label?**
   - What we know: Issue #57515 implies a header with per-skill list entries. CONTEXT.md D-07 uses `# available-skills` as the canonical label.
   - What's unclear: The exact verbatim heading text in 2.1.148.
   - Recommendation: Capture-verbatim is already in the plan. The planner's instruction should be "capture whatever heading precedes the list of `- {plugin}:{skill}` lines", not "capture the line that says `# available-skills`". Any heading variant is fine as long as the per-skill list is captured.

3. **When uninstalling between sub-tests (per D-10), is `claude plugin disable` + `claude plugin uninstall` sufficient, or does `claude plugin marketplace remove` also need to run?**
   - What we know: D-10 says both. `marketplace remove` warns it "also uninstalls any plugins you installed from it". Running `uninstall` first then `marketplace remove` is safe and explicit.
   - What's unclear: Whether `marketplace remove` alone would do the trick (per docs it should).
   - Recommendation: Run both, in the order shown in Pattern 2. Explicit > clever. Avoids ambiguity in the evidence trail.

## Environment Availability

| Dependency | Required By | Available | Version | Fallback |
|------------|------------|-----------|---------|----------|
| `claude` CLI | All install/observe/uninstall operations | ✓ | 2.1.148 | — (this phase cannot proceed without it) |
| `claude plugin` subcommand surface | All plugin operations | ✓ | 2.1.148 | — |
| `~/.claude/plugins/cache/` writable | Plugin installs | ✓ | n/a (already populated with real plugins) | — |
| `git` (used internally by claude plugin install) | Cloning `yaklang/hack-skills` for the `github` source | ✓ (presumed; required by Claude Code itself) | system git | — |
| Internet connectivity to github.com | First-time clone of `yaklang/hack-skills` into the new cache subdir | Required at install time | — | If offline, abort Phase 1 — fundamental dependency. |
| `jq` (for parsing `installed_plugins.json` evidence) | Pretty-printing JSON evidence in the artifact | ✓ (presumed; standard on dev macOS) | system | Plain `cat` of the JSON file is sufficient if `jq` unavailable. |

**Missing dependencies with no fallback:** None.

**Missing dependencies with fallback:** None.

## Security Domain

> `security_enforcement` is not explicitly set in `.planning/config.json`; treating as enabled.

### Applicable ASVS Categories

| ASVS Category | Applies | Standard Control |
|---------------|---------|-----------------|
| V2 Authentication | yes (lightly) | Github clone uses optional `GITHUB_TOKEN` env var for private repos. `yaklang/hack-skills` is public, so unauthenticated clone is the standard path. No additional control needed for this phase. |
| V3 Session Management | no | n/a — this phase touches no user sessions outside Claude Code's own. |
| V4 Access Control | no | n/a — no multi-user surface. |
| V5 Input Validation | yes | `claude plugin validate` runs against marketplace.json before install. Catches duplicate names, path traversal (`..` in source paths), and schema violations. |
| V6 Cryptography | no | n/a — no crypto operations. |

### Known Threat Patterns for marketplace.json authoring

| Pattern | STRIDE | Standard Mitigation |
|---------|--------|---------------------|
| Plugin source pointing outside the marketplace repo via `..` (path traversal) | Tampering | Validator rejects `..` in source paths. Our plugins use `github` sources, not relative paths, so this is moot here. |
| Duplicate plugin names in `plugins` array | Tampering (state corruption) | Validator reports "Duplicate plugin name 'x' found in marketplace". Our two test plugin names are distinct (`hack-skills-recon`, `hack-skills-auth-bypass`). |
| Malicious upstream skill content executed during plugin install | Spoofing/Tampering | Skill files are markdown — not executed at install. Risk surfaces only when the model is given access to tools that act on skill instructions, which is downstream of Phase 1 verification. `yaklang/hack-skills` is trusted upstream per PROJECT.md. |

## Sources

### Primary (HIGH confidence)

- **Official Claude Code marketplace docs** [CITED: code.claude.com/docs/en/plugin-marketplaces — also available locally at `/Users/spencerpresley/code/hack-skills-wip/reference/cc-docs-plugin-marketplace-page-content.md`] — Full schema, `strict` semantics, plugin sources (github/url/git-subdir/npm), cache location, CLI commands, validation. The exact `skills` field description: "Custom paths to skill directories containing `<name>/SKILL.md`".
- **Local `claude` CLI 2.1.148** [VERIFIED via `claude --version`, `claude plugin --help`, `claude plugin list --json`] — Subcommand surface and JSON output shapes observed directly.
- **Local cache layout** [VERIFIED via direct filesystem inspection] — `~/.claude/plugins/cache/<marketplace>/<plugin>/<version>/` pattern confirmed across 9 real plugin cache entries.
- **Local `wondelai-skills` marketplace.json** [VERIFIED via direct file read at `~/.claude/plugins/marketplaces/wondelai-skills/.claude-plugin/marketplace.json`] — Real-world parallel using `strict: false` + curated `skills` array of individual subdir paths sharing one source. Existence proof that the pattern is viable.
- **plugin-structure SKILL.md from claude-plugins-official `plugin-dev` plugin** [CITED: `/Users/spencerpresley/.claude/plugins/cache/claude-plugins-official/plugin-dev/unknown/skills/plugin-structure/SKILL.md`] — Anthropic's own guidance on marketplace.json structure, skills array, strict mode.

### Secondary (MEDIUM confidence)

- **Github issue #57515** [CITED: github.com/anthropics/claude-code/issues/57515] — Skill description dropouts in system reminder. Source for the exact `- {plugin}:{skill}: {description}` format.
- **Github issue #40789** [CITED: github.com/anthropics/claude-code/issues/40789] — Disabled-plugin skills still appearing. Source for the uninstall-vs-disable distinction in hygiene.
- **Github issue #52456** [CITED: github.com/anthropics/claude-code/issues/52456] — TUI uninstall unreliable. Source for "use CLI not TUI" guidance.
- **Github issues #37865, #35691, #15369, #29074** [CITED via WebSearch summary] — Orphaned cache directories after uninstall. Source for grace-period landmine in Pitfall 3.

### Tertiary (LOW confidence)

- **Various WebSearch results on `/skills` autocomplete behavior** — Lower-confidence info on skill autocomplete; not load-bearing for Phase 1's three VERIFY questions. Flagged in case Phase 1 surface area expands.

## Metadata

**Confidence breakdown:**
- Standard stack: **HIGH** — `claude plugin` CLI fully documented and verified working on this exact machine at 2.1.148.
- Architecture: **HIGH** — cache layout, install metadata shape, and per-plugin partitioning all observed directly in `~/.claude/plugins/` on this machine across 9 real plugin entries.
- Pitfalls: **HIGH** — known issues backed by official github tracker entries; no inference.
- A5/A6 assumptions (the VERY thing VERIFY-01/02 prove): **MEDIUM** — extrapolating from documented `strict: false` semantics and the existence of `wondelai-skills` as a parallel pattern. Resolving these to HIGH is precisely the purpose of Phase 1 execution.

**Research date:** 2026-05-22
**Valid until:** 2026-06-21 (30 days; Claude Code release cadence is fast but the marketplace schema is stable)

## RESEARCH COMPLETE

---

## Phase 1 Empirical Findings (Appendix — added 2026-05-22 post-execution)

This appendix records research conducted DURING Phase 1 execution after Plan 01-02's Task 1 produced a VERIFY-01 FAIL evidence (Skills (102), ~10,503 always-on tokens). The pre-execution research above assumed the github+nested-skills pattern would work — empirical observation invalidated that assumption. The investigation that followed identified the structural difference between working and failing patterns and produced a fix.

### Observed FAIL (original pattern)

Marketplace shape:
```json
{
  "source": { "source": "github", "repo": "yaklang/hack-skills" },
  "strict": false,
  "skills": ["./skills/401-403-bypass-techniques", "./skills/api-auth-and-jwt-abuse"]
}
```
Result of `claude plugin details hack-skills-auth-bypass@hack-skills-marketplace`:
- `Skills (102)` — all upstream skills listed, not the curated 2
- `Always-on: ~10,503 tok` — full bloat, not the expected ~200 tok

### Reference marketplaces tested

Three real-world marketplaces on disk were tested to triangulate the failure:

**wondelai-skills** (github.com/wondelai/skills):
- Pattern: `source: "./"` (marketplace IS the source), `strict: false`, skill dirs at SOURCE ROOT (e.g. `./drive-motivation`)
- Test: installed `team-motivation` (1 curated skill from a 42-skill source)
- Result: `Skills (1) drive-motivation`, ~219 tok — CURATION WORKS
- Test: installed `product-strategy` (3 curated skills from same 42-skill source)
- Result: `Skills (3) jobs-to-be-done, mom-test, negotiation`, ~662 tok — CURATION WORKS

**claude-plugins-official/box** (github.com/box/box-for-ai):
- Pattern: `source: { source: "url", url: "...git", sha: "..." }`, NO `strict` set (defaults to `true`), skill dirs nested under `./skills/`, upstream has a `plugin.json` declaring metadata only (no `skills:` field)
- Test: installed `box`
- Result: `Skills (5)` — matches the 5 entries in the marketplace's `skills` array
- **INCONCLUSIVE for our question:** the box upstream has exactly 5 skills, all of which are in the marketplace entry. There's nothing for the curation to filter out — both "filter works" and "filter is a no-op + auto-discovery finds all 5" produce the same observation.

**claude-plugins-official/netsuite-suitecloud** (github.com/oracle/netsuite-suitecloud-sdk):
- Pattern: `source: { source: "git-subdir", url: "...git", path: "packages/agent-skills", ref, sha }`, `strict: false`, skill dirs at the ROOT of the cloned subdir
- Test: installed `netsuite-suitecloud`
- Result: `Skills (3) netsuite-ai-connector-instructions, ...` — matches the 3 entries
- Also INCONCLUSIVE strictly (the cloned subdir contains exactly those 3 skills) — but pattern-wise this is the closest analog to wondelai (root-level paths) using an external git source.

### Identified structural difference

The working patterns (wondelai, netsuite) have skill directories at the ROOT of the cloned source content. The failing pattern (ours, with `source: github`) has skill directories nested one level deep under `./skills/`. The hypothesis is that Claude Code 2.1.148 auto-discovers `./skills/*/SKILL.md` at the source root regardless of the explicit `skills` array — when there IS a `./skills/` directory, auto-discovery wins; when there isn't (because the source was sparse-cloned at the `skills/` subdir, or because skills live at the source root naturally), the explicit array is honored.

### Fix tested and validated

Marketplace shape changed to:
```json
{
  "source": {
    "source": "git-subdir",
    "url": "https://github.com/yaklang/hack-skills.git",
    "path": "skills"
  },
  "strict": false,
  "skills": ["./401-403-bypass-techniques", "./api-auth-and-jwt-abuse"]
}
```
Two changes:
1. Source descriptor: `github` → `git-subdir` with `path: "skills"`. Sparse-clones only the `skills/` subdir of yaklang/hack-skills, so each skill directory becomes addressable at the clone root.
2. Skill paths: `./skills/X` → `./X`. Aligned with the new clone-root location.

Source repository `yaklang/hack-skills` was NOT modified (Constraint: Source immutability is preserved).

Validation:
- `claude plugin details hack-skills-auth-bypass@hack-skills-marketplace` → `Skills (2) 401-403-bypass-techniques, api-auth-and-jwt-abuse`, ~205 tok ✓
- `claude plugin details hack-skills-recon@hack-skills-marketplace` → `Skills (1) api-recon-and-docs`, ~87 tok ✓
- Fresh `claude -p` session's system reminder lists only the 3 curated skills total, no leakage ✓
- Per-plugin cache subdirs distinct under `~/.claude/plugins/cache/hack-skills-marketplace/<plugin-name>/c6f732befcae-32c1cf49/` ✓

Token reduction vs failed pattern: 10,503 → 205 always-on for the auth-bypass plugin (~98% reduction), matching the project's stated value proposition.

### Implications for downstream phases

- **Phase 3 BUILD-03 (requirement) and Phase 3 Success Criterion 3 (roadmap):** originally specified `source: github`. Both updated to require `source: git-subdir` with `path: "skills"`. Skill paths in `skills` arrays are root-level.
- **Phase 4 PUB-* requirements:** unaffected. The install commands users run (`/plugin install <group>@hack-skills-marketplace`) don't change. Only the marketplace.json shape changes.
- **PROJECT.md Key Decisions:** updated to add the git-subdir decision and mark the original `strict: false` / `skills array` / `multiple plugins one source` decisions as Validated (with the corrected source descriptor).
- **PROJECT.md Constraints:** Source immutability holds. Group sizing 8–15 still holds. Grouping axis still holds.

### Lessons for future research

- Citing a "real-world precedent" requires comparing the precedent's structural shape, not just its surface attributes. The pre-execution research cited wondelai-skills as "exactly the same pattern" but missed that wondelai uses `source: "./"` (local) while we planned `source: github` (remote) — a difference that turned out to matter.
- `claude plugin details` is the right surface for VERIFY-01 evidence (Pitfall 5 was correct on this) — the bug isn't that details was misleading, the bug was that our original pattern truly didn't curate, and the cache materialization happened to also produce 102 dirs.
- When a verification FAILS, the right first move is to triangulate against working precedents (which working pattern does ours diverge from, and where?) before pivoting away from the strategy. The pivot policy D-09 said "halt before Phase 2" on VERIFY-01 no, and that was the right gate — but "halt" can include "re-investigate whether the failure is mechanism or strategy" before committing to a strategy pivot.
