# Upstream PR Plan — yaklang/hack-skills

A minimal, diplomatic PR to add Claude Code marketplace support to
`yaklang/hack-skills`. Single file, single plugin, no restructuring of
the existing layout. Just gives users a one-command install.

Companion effort: the personal grouped marketplace plan lives in
[`./PLAN.md`](./PLAN.md) (alongside this doc). The two are independent —
the PR body references the marketplace as available-if-wanted, but
doesn't push it as the proposed change.

---

## Repos Involved

| Repo | Role |
| :--- | :--- |
| `yaklang/hack-skills` | Upstream. Target of the PR. |
| `SpencerPresley/hack-skills` (fork) | Vehicle for the PR. |
| `SpencerPresley/hack-skills-marketplace` (this repo) | Personal grouped marketplace. Referenced from the PR body as the diplomatic "here's what could be done with this" example. |

**Prerequisite:** fork `yaklang/hack-skills` to `SpencerPresley/hack-skills`
on GitHub, then clone the fork locally before starting the workflow steps
below.

---

## Verified Upstream Layout

Confirmed by reading the cloned repo:

```
hack-skills/
├── skills/                              # 102 skill directories
│   ├── 401-403-bypass-techniques/
│   │   └── SKILL.md
│   ├── active-directory-acl-abuse/
│   │   ├── SKILL.md
│   │   └── BLOODHOUND_PATHS.md
│   └── ... (100 more)
├── README.md
├── README_CN.md
├── LICENSE
├── assets/
├── scripts/
└── site/
```

**This is already canonical Claude Code plugin layout.** The `skills/`
directory is the conventional auto-discovery location, and each skill
is a directory containing `SKILL.md` plus optional supporting files.
**Zero path override is needed** in the marketplace.json — defaults
just work.

---

## The PR Diff (Exact)

One new file: `.claude-plugin/marketplace.json` at repo root.

```json
{
  "name": "hack-skills",
  "owner": { "name": "yaklang" },
  "description": "Hacking skills collection for Claude Code",
  "plugins": [
    {
      "name": "hack-skills",
      "source": "./",
      "description": "Full collection of 100+ hacking skills"
    }
  ]
}
```

Notes on the diff:

- `source: "./"` — same-repo relative path. Resolves to the marketplace
  root (the dir containing `.claude-plugin/`), not the `.claude-plugin/`
  directory itself.
- No `strict` field — defaults to `true`. This means yaklang has the
  option to add a `plugin.json` later if they want, without conflict.
- No `version` field on the plugin entry — every commit on the default
  branch counts as a new version. Conventional for actively-developed
  upstream repos.
- No `skills` path override — default auto-discovery picks up
  `skills/*/SKILL.md`.

**Optional alternative**: add `"strict": false` to the plugin entry and
skip the need for any future `plugin.json`. Cleaner if yaklang wants to
never maintain a plugin.json. Mention as an option in PR discussion;
default to the simpler version above.

For schema details, see
[`./PLAN.md`](./PLAN.md#how-it-works-schema-level).

---

## Branch & PR Workflow

1. Fork `yaklang/hack-skills` on GitHub and clone the fork locally.
2. On the fork, create a branch off `main`. Suggested name:
   `add-marketplace-support`.
3. Add `.claude-plugin/marketplace.json` (the file above).
4. Test locally: `/plugin marketplace add <path-to-local-fork>` then
   `/plugin install hack-skills@hack-skills`. Confirm install works and
   skills load.
5. Push branch to fork.
6. **Set the branch as the fork's default branch** (Settings → Branches
   → default). This way:
   - The personal marketplace can fall back to the fork's default ref if
     upstream takes a while.
   - Install commands against the fork work without `@branch` suffix.
7. Open PR: `SpencerPresley/hack-skills:add-marketplace-support` →
   `yaklang/hack-skills:main`. **Direct branch-to-main.** Do NOT route
   through fork's main — see Pitfalls below.

---

## PR Body Draft

```markdown
Adds basic Claude Code marketplace support so users can install
`hack-skills` via the standard plugin commands:

    /plugin marketplace add yaklang/hack-skills
    /plugin install hack-skills@hack-skills

Single file added: `.claude-plugin/marketplace.json`. No existing files
modified, no restructuring of `skills/`. The current layout is already
canonical Claude Code plugin layout, so auto-discovery picks up all 102
skills without any path configuration.

**One thing worth flagging.** With 100+ skills, enabling the plugin
loads every skill description into the session context, which is
heavier than some users may want. I've prototyped a separate marketplace
that exposes topical groups as individually-enable-able plugins, so
users can opt into only the categories relevant to their current work:

  https://github.com/SpencerPresley/hack-skills-marketplace

That marketplace points at this repo as a github source and uses
`strict: false` plus `skills` arrays to curate subsets — no
restructuring of this repo required. Happy to amend this PR to a
similar grouped layout in-place if that direction interests you,
otherwise this minimal version is mergeable as-is.
```

The phrasing gives yaklang the simple version they can merge, signals
the deeper thinking exists, and leaves the choice with them.

---

## Pitfalls / Don'ts

- **Don't PR `main → main`.** If reviewers request changes you'd commit
  to your fork's `main`, your fork's `main` then can't cleanly track
  upstream `main` for future syncs.
- **Don't merge the PR branch into your fork's `main` until the PR
  resolves.** Same reason. Use the default-branch flip instead.
- **Don't bundle the grouped layout into this PR.** Two unrelated
  changes makes review harder and lowers merge probability. Grouped
  layout is the alternative that lives in the personal marketplace
  repo.
- **Don't add a `version` field** unless yaklang asks for one. Bumping
  it on every change is overhead they probably don't want.

---

## Useful Links

- Plugin marketplaces:
  https://code.claude.com/docs/en/plugin-marketplaces
- Strict mode:
  https://code.claude.com/docs/en/plugin-marketplaces#strict-mode
- Upstream repo: https://github.com/yaklang/hack-skills
- Companion plan: [`./PLAN.md`](./PLAN.md)
