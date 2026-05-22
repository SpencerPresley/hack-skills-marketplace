# hack-skills-marketplace — Personal Marketplace Plan

This repo is a tiny Claude Code marketplace that curates
`yaklang/hack-skills` (102 skills) into smaller enable-disable plugins
grouped by topic. The marketplace itself ships no skills — it's just a
`.claude-plugin/marketplace.json` that points at the upstream repo and
cherry-picks subsets via the `skills` field on each plugin entry.

Companion effort: a separate, minimal PR is going upstream to add basic
marketplace support to `yaklang/hack-skills` itself. See
[`./PR-PLAN.md`](./PR-PLAN.md). The two are independent — this
marketplace works regardless of whether the PR is merged.

---

## The Idea / Motivation

**Use case.** `yaklang/hack-skills` is idea-fuel for the `purplehaze`
security product. It's not core tooling — it's a curated library of
hacking-skill prompts to draw from when planning new features in
`purplehaze`.

**Problem.** Even installed as a single plugin, 102 skills means 102
skill descriptions in every session's system reminder. Useful for one
topic area at a time, noise for everything else.

**Solution.** Group skills by topic. Each group is its own plugin in the
marketplace. Enable just the groups relevant to whatever feature area is
being worked on right now. Disable the rest.

**Constraints.**

- Won't modify upstream skill files. These are read-only inspiration.
- Snapshot consumption is fine — no heavy sync story needed.
- No `@branch` suffixes in install commands. Use the default ref.

---

## How It Works (Schema-Level)

Three facts from the Claude Code docs that make this approach possible
without forking or restructuring upstream:

### 1. `strict: false` makes the marketplace entry the full plugin definition

From `code.claude.com/docs/en/plugin-marketplaces#strict-mode`:

| `strict` | Behavior |
| :--- | :--- |
| `true` (default) | `plugin.json` is the authority. Marketplace entry can supplement it. Both merge. |
| `false` | Marketplace entry IS the entire definition. No `plugin.json` needed at the source. If one exists and declares components, that's a conflict and load fails. |

**Why this matters here:** `yaklang/hack-skills` doesn't have a
`plugin.json`. With `strict: false`, we don't need it to.

### 2. `skills` is a valid marketplace-entry field

Full component-field list available on a marketplace plugin entry:

| Field | Type | Description |
| :--- | :--- | :--- |
| `skills` | string \| array | Custom paths to skill directories containing `<name>/SKILL.md` |
| `commands` | string \| array | Custom paths to `.md` files or directories |
| `agents` | string \| array | Custom paths to agent files |
| `hooks` | string \| object | Hook config or path |
| `mcpServers` | string \| object | MCP config or path |
| `lspServers` | string \| object | LSP config or path |

### 3. Multiple plugin entries can share one source

The duplicate-detection rule is on `name`, not `source`. Validator
specifically warns on `Duplicate plugin name "x" found in marketplace`;
nothing about duplicate sources. So one upstream repo can be the source
for N discrete-installable plugins, each exposing a different curated
slice of its skills.

### 4. Plugins are cached per-plugin-per-marketplace

> Once a plugin is cloned or copied into the local machine, it is copied
> into the local versioned plugin cache at `~/.claude/plugins/cache`.

N plugin entries all pointing at `yaklang/hack-skills` produce N
separate clones in the cache. Storage cost is real but small for a
text-only skills repo.

---

## Marketplace Skeleton

`.claude-plugin/marketplace.json` shape:

```json
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
      "skills": [
        "./skills/api-recon-and-docs"
      ]
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

Source paths in `skills` are relative to the plugin's source root
(the cloned `yaklang/hack-skills` repo), not to this marketplace repo.

### Grouping Strategy

Organize by what's relevant to `purplehaze`'s feature surface, NOT by
yaklang's own categorization. Target **8–15 skills per group** — much
past that and the group pollutes context as much as "all on."

Suggested starting buckets (refine while reading through the 102 skills):

- `recon` — discovery, fingerprinting, info gathering
- `auth-bypass` — 401/403, JWT, session, OAuth abuse
- `injection` — SQLi, XSS, command injection, SSRF
- `payloads` — payload crafting, encoding, evasion
- `mobile` — Android/iOS
- `binary` — binary analysis, exploitation, anti-debug
- `ad` — Active Directory / Kerberos / ADCS
- `crypto` — cipher analysis, key abuse

Skills that don't fit any of `purplehaze`'s feature buckets probably
aren't worth a group at all.

---

## Open Questions To Verify Before Building Out All Groups

These are assumptions baked into the plan. Resolve them before writing
out 8+ groups, since a "no" on #1 changes the whole approach.

1. **Does `skills: ["./skills/skill-a", "./skills/skill-b"]` address two
   individual skills, or does each path need to be a parent containing
   multiple `<name>/SKILL.md` subdirs?**

   The doc wording — "Custom paths to skill directories containing
   `<name>/SKILL.md`" — is ambiguous. If individual paths work: ideal,
   no restructuring required. If parent-only: groupings would need
   symlink trees or actual fork-side regrouping.

   **Test:** marketplace with one plugin pointing at two specific
   individual skill paths. Install. Confirm only those two skills appear
   in session context.

2. **Does the install actually limit context to listed skills?**

   The whole value-prop depends on this. If `strict: false` + curated
   `skills` array still surfaces all skills present in the source repo,
   the grouping idea collapses.

   **Test:** install one group, start a session, inspect the system
   reminder skills section. Confirm only the listed skills are present.

3. **N plugins pointing at the same github source — any cache
   collision?**

   Docs imply per-plugin caching. Confirm nothing weird happens with
   3–5 plugins all referencing `yaklang/hack-skills`.

   **Test:** install 3 groups, check `~/.claude/plugins/cache/`, verify
   separate cache entries and all enable cleanly.

---

## Build Order

1. Write a minimal `.claude-plugin/marketplace.json` with TWO groups,
   each containing 2–3 specific individual skills.
2. `/plugin marketplace add ./hack-skills-marketplace` (or the github
   URL once pushed).
3. `/plugin install <group>@hack-skills-marketplace`.
4. Answer Open Question 1 (individual vs parent path).
5. Answer Open Question 2 (context isolation).
6. Answer Open Question 3 (cache).
7. **Only then** build out the full set of groups.

---

## Why Not Other Approaches

Documented so we don't re-tour them:

- **Clone upstream and pull skills in manually.** Won't happen. Friction.
- **Install all 102 as global skills.** Context pollution disaster.
- **Hook that toggles all-on via env var.** Same all-or-nothing problem
  behind a flag.
- **Fork upstream and physically regroup skills into subdirectories,
  each its own `plugin.json`, multi-plugin marketplace.json all in one
  repo.** Works but heavy: makes upstream sync painful, requires
  moving 102 files into a taxonomy specific to this use case. Defeated
  by `strict: false` + `skills` arrays — the partitioning can live
  purely in marketplace.json.

---

## Useful Links

- Plugin marketplaces (full schema):
  https://code.claude.com/docs/en/plugin-marketplaces
- Strict mode section:
  https://code.claude.com/docs/en/plugin-marketplaces#strict-mode
- Plugins reference:
  https://code.claude.com/docs/en/plugins-reference
- Upstream repo: https://github.com/yaklang/hack-skills

---

## Mental Model

> The marketplace.json is a *recipe* for plugins. Each plugin entry says
> "here's a name, here's where to get the raw materials, and here's
> exactly which of those materials to expose." With `strict: false` the
> recipe is the whole spec — the source repo is just a bag of files
> getting cherry-picked.
