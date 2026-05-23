# hack-skills-marketplace

A Claude Code marketplace that curates [`yaklang/hack-skills`](https://github.com/yaklang/hack-skills) (102 security-research skills) into 13 topical plugins, plus an optional `hack-skills-router` sidecar that adds routing and methodology scaffolding through Claude Code hooks. Install only the topical bucket(s) relevant to current work — the session's always-on context stays proportional to what you're actually doing.

## Install

Add the marketplace once:

```
/plugin marketplace add SpencerPresley/hack-skills-marketplace
```

Install any topical plugin:

```
/plugin install hack-skills-<topic>@hack-skills-marketplace
```

Optional router sidecar (see below):

```
/plugin install hack-skills-router@hack-skills-marketplace
```

## Topical plugins

13 plugins covering 95 of the 102 upstream skills. Each Claude skill adds ~100 tokens of always-on context to every session ([per the Agent Skills cost model](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview)), so installed scope should track work scope.

| Plugin | What it covers | Skills |
|--------|----------------|:------:|
| `hack-skills-recon` | Reconnaissance and attack-surface enumeration | 6 |
| `hack-skills-auth-bypass` | Authentication and authorization bypass | 9 |
| `hack-skills-web-injection` | Web-layer injection and input-driven attacks | 10 |
| `hack-skills-web-client-attacks` | Client-side and browser-context web vulnerabilities | 10 |
| `hack-skills-web-protocol-attacks` | HTTP protocol-layer attacks and request flow abuse | 7 |
| `hack-skills-server-side-execution` | Server-side code execution and trust-boundary chains | 8 |
| `hack-skills-active-directory-and-windows` | Active Directory and Windows endpoint attacks | 7 |
| `hack-skills-linux-and-post-exploit` | Linux/macOS post-exploitation and network pivoting | 10 |
| `hack-skills-binary-exploitation` | Binary exploitation and reverse engineering | 12 |
| `hack-skills-crypto-attacks` | Cryptography attacks and blockchain/DeFi exploits | 7 |
| `hack-skills-mobile` | Mobile platform pentesting | 3 |
| `hack-skills-ai-and-supply-chain` | AI/ML security and software supply chain attacks | 3 |
| `hack-skills-forensics-and-misc-recovery` | Forensics, memory analysis, and steganographic recovery | 3 |

## Router (optional sidecar)

`hack-skills-router` is a separate plugin that layers routing and methodology scaffolding on top of the topical plugins. It carries:

- A `SessionStart` hook that injects a trust model, a 3-step operating model, and 8 expert intuitions at session start
- A `UserPromptSubmit` hook that surfaces a light routing nudge on security-context prompts via a regex matcher
- A top-level router skill that maps prompt signals to the right topical plugin

It takes a progressive-disclosure approach: routing context appears at the moments it's actually useful (session start, security-flavored prompts) rather than padding the always-on prompt for every session. Install it alongside any topical plugin if you want guided routing; skip it if you'd rather just install the topical buckets directly.

```
/plugin install hack-skills-router@hack-skills-marketplace
```

## How it's organized

Grouping is by skill content, not by the upstream's own categorization. The full upstream catalog of 102 skills would cost ~10,200 always-on tokens per session — most of which is irrelevant to any given task. The 13 topical buckets split that catalog so a typical installed plugin contributes a few hundred to ~1,200 always-on tokens covering one coherent area of security work.

The router sidecar is structurally distinct from the topical plugins (it carries hooks, not topical skills) and is therefore optional. Topical plugins work standalone without it.

## Attribution

Security-research skill content is from [`yaklang/hack-skills`](https://github.com/yaklang/hack-skills), licensed MIT. This marketplace curates and exposes those skills through Claude Code's plugin system without modifying upstream content.

## License

MIT. See [LICENSE](LICENSE).
