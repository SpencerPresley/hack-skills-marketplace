# Routing Tables

> Signal-to-category mappings derived from upstream `yaklang/hack-skills` `hack` SKILL.md's Signal/Priority table (MIT-licensed), expanded and reshaped to address this marketplace's 13-plugin topical structure rather than upstream's flat skill list. Each section is keyed by a marketplace plugin name; the install command at the top of each section doubles as the plugin-discovery surface when the destination plugin is not currently installed.

### hack-skills-active-directory-and-windows

**Install:** `/plugin install hack-skills-active-directory-and-windows@hack-skills-marketplace`

| Signal terms | Deep skill (in this plugin) |
|---|---|
| AD, Active Directory, Kerberos, Kerberoasting, AS-REP roasting, golden ticket, silver ticket | active-directory-kerberos-attacks |
| NTLM relay, PetitPotam, PrinterBug, coercion, LLMNR poisoning | ntlm-relay-coercion |
| Windows privesc, token abuse, Potato exploits, UAC bypass, DLL hijacking, registry autoruns | windows-privilege-escalation |

### hack-skills-ai-and-supply-chain

**Install:** `/plugin install hack-skills-ai-and-supply-chain@hack-skills-marketplace`

| Signal terms | Deep skill (in this plugin) |
|---|---|
| prompt injection, LLM injection, indirect injection, RAG injection, MCP injection, jailbreak | llm-prompt-injection |
| dependency confusion, supply chain, npm/pip/gem/Maven confusion, internal package name | dependency-confusion |
| AI/ML security, pickle RCE, model poisoning, model stealing, adversarial examples, autonomous agent | ai-ml-security |

### hack-skills-auth-bypass

**Install:** `/plugin install hack-skills-auth-bypass@hack-skills-marketplace`

| Signal terms | Deep skill (in this plugin) |
|---|---|
| JWT, JSON Web Token, alg=none, kid injection, JWKS, RS256 to HS256, bearer token | jwt-oauth-token-attacks |
| 401, 403, admin panel access denied, path manipulation, HTTP method tampering, header injection | 401-403-bypass-techniques |
| IDOR, BOLA, object authorization, tenant boundary, A/B account replay, writable fields | idor-broken-object-authorization |

### hack-skills-binary-exploitation

**Install:** `/plugin install hack-skills-binary-exploitation@hack-skills-marketplace`

| Signal terms | Deep skill (in this plugin) |
|---|---|
| heap exploitation, UAF, use-after-free, double free, tcache, fastbin, glibc heap | heap-exploitation |
| stack overflow, ROP, ret2libc, ret2csu, ret2dlresolve, SROP, buffer overflow exploit | stack-overflow-and-rop |

### hack-skills-crypto-attacks

**Install:** `/plugin install hack-skills-crypto-attacks@hack-skills-marketplace`

| Signal terms | Deep skill (in this plugin) |
|---|---|
| RSA attack, small exponent, shared factors, Coppersmith, padding oracle, common modulus | rsa-attack-techniques |
| smart contract, Solidity, reentrancy, flash loan, MEV, delegatecall, signature replay | smart-contract-vulnerabilities |

### hack-skills-forensics-and-misc-recovery

**Install:** `/plugin install hack-skills-forensics-and-misc-recovery@hack-skills-marketplace`

| Signal terms | Deep skill (in this plugin) |
|---|---|
| memory forensics, memory dump, Volatility, malware analysis, credential extraction from memory | memory-forensics-volatility |
| steganography, LSB, hidden data in image, EXIF, spectrogram, polyglot file, zero-width chars | steganography-techniques |
| PCAP, traffic analysis, Wireshark, tshark, protocol forensics, TLS decryption | traffic-analysis-pcap |

### hack-skills-linux-and-post-exploit

**Install:** `/plugin install hack-skills-linux-and-post-exploit@hack-skills-marketplace`

| Signal terms | Deep skill (in this plugin) |
|---|---|
| Linux privesc, SUID, capabilities, cron abuse, sudo misconfig, kernel exploit privesc | linux-privilege-escalation |
| reverse shell, bash one-liner, ncat shell, web shell, PTY upgrade, PowerShell shell | reverse-shell-techniques |

### hack-skills-mobile

**Install:** `/plugin install hack-skills-mobile@hack-skills-marketplace`

| Signal terms | Deep skill (in this plugin) |
|---|---|
| Android pentesting, SSL pinning, exported component, WebView vulnerabilities, intent redirection, root detection bypass | android-pentesting-tricks |
| iOS pentesting, keychain extraction, URL scheme hijacking, Universal Links, runtime manipulation | ios-pentesting-tricks |

### hack-skills-recon

**Install:** `/plugin install hack-skills-recon@hack-skills-marketplace`

| Signal terms | Deep skill (in this plugin) |
|---|---|
| recon, methodology, asset mapping, endpoint discovery, technology fingerprint, new target | recon-and-methodology |
| .git, .svn, .env, backup files, robots.txt, /etc/passwd, exposed VCS, config leak | insecure-source-code-management |
| GraphQL, introspection, hidden parameters, schema enumeration, batching, undocumented fields | graphql-and-hidden-parameters |

### hack-skills-server-side-execution

**Install:** `/plugin install hack-skills-server-side-execution@hack-skills-marketplace`

| Signal terms | Deep skill (in this plugin) |
|---|---|
| SSRF, server fetches URL, internal network, cloud metadata, IMDS, secondary protocol | ssrf-server-side-request-forgery |
| command injection, CMDi, shell command, OS command injection, blind OOB injection | cmdi-command-injection |
| SSTI, template injection, Jinja2, Twig, Velocity, server-side rendering | ssti-server-side-template-injection |

### hack-skills-web-client-attacks

**Install:** `/plugin install hack-skills-web-client-attacks@hack-skills-marketplace`

| Signal terms | Deep skill (in this plugin) |
|---|---|
| business logic, workflow abuse, price manipulation, coupon abuse, multi-step bypass, state machine flaw | business-logic-vulnerabilities |
| race condition, TOCTOU, one-time operation, coupon redemption, concurrent request abuse, Turbo Intruder | race-condition |
| CSRF, cross-site request forgery, SameSite, anti-CSRF token, JSON CSRF, login CSRF | csrf-cross-site-request-forgery |

### hack-skills-web-injection

**Install:** `/plugin install hack-skills-web-injection@hack-skills-marketplace`

| Signal terms | Deep skill (in this plugin) |
|---|---|
| XSS, cross-site scripting, reflected XSS, stored XSS, DOM XSS, innerHTML, JavaScript injection | xss-cross-site-scripting |
| SQL injection, SQLi, UNION, blind SQLi, boolean-based, time-based, out-of-band | sqli-sql-injection |
| XXE, XML external entity, SVG, OOXML, SOAP parser, entity expansion | xxe-xml-external-entity |

### hack-skills-web-protocol-attacks

**Install:** `/plugin install hack-skills-web-protocol-attacks@hack-skills-marketplace`

| Signal terms | Deep skill (in this plugin) |
|---|---|
| request smuggling, HTTP smuggling, CL.TE, TE.CL, HTTP/2 desync, h2c smuggling | request-smuggling |
| Host header, password reset poisoning, web cache poisoning via Host, virtual host bypass | http-host-header-attacks |
| web cache deception, CDN cache key, path confusion, cached auth content | web-cache-deception |

## Dual-load rules

### Rule 1: Recon + auth context
**Trigger:** New web/API target with user identity surface visible (login, registration, JWT in cookie, OAuth flow URLs, admin paths)
**Load both:** `recon-and-methodology` (in `hack-skills-recon`) + `api-auth-and-jwt-abuse` (in `hack-skills-auth-bypass`)
**Rationale:** Per upstream `hack` SKILL.md operating model — "Recon and context validation FIRST" before specialist work. When the surface clearly involves auth, dual-loading the auth specialist alongside the recon playbook is more efficient than sequential lookups.

### Rule 2: API testing + auth + IDOR
**Trigger:** Prompt mentions REST API testing AND mentions JWT/OAuth/tokens OR mentions object IDs in responses
**Load both:** `api-recon-and-docs` (in `hack-skills-recon`) + `api-auth-and-jwt-abuse` (in `hack-skills-auth-bypass`)
**Rationale:** API testing is the classic 3-skill chain (discover endpoints, auth flow, authz model). Per upstream intuition #4 ("BOLA = authenticated-but-unauthorized"), the IDOR/BOLA skill belongs alongside when object IDs are visible — the body keeps `api-authorization-and-bola` as the optional third when responses expose object IDs.

### Rule 3: SSRF + business-flow context
**Trigger:** Prompt mentions URL-fetching, image preview, webhook callback, OR import-from-URL endpoints AND mentions payment/coupon/checkout/inventory/business workflow
**Load both:** `ssrf-server-side-request-forgery` (in `hack-skills-server-side-execution`) + `business-logic-vulnerabilities` (in `hack-skills-web-client-attacks`)
**Rationale:** Per upstream intuition #6 ("business-logic flaws bring highest impact"), SSRF as a primitive becomes much more dangerous in a business-flow context. Cross-plugin dual-load is the right shape — neither plugin alone captures the combo.

### Rule 4: Auth bypass + JWT/OAuth
**Trigger:** Prompt mentions auth bypass, login flow attack, MFA bypass, OR session boundary AND mentions JWT, OAuth, OIDC, or SAML
**Load both:** `authbypass-authentication-flaws` (in `hack-skills-auth-bypass`) + `jwt-oauth-token-attacks` (in `hack-skills-auth-bypass`)
**Rationale:** Per upstream intuition #8 ("for JWT: verify alg, kid, JWKS, key origin BEFORE spraying payloads"), the auth-flow skill and the JWT-specific skill cover different angles of the same target. Same-plugin dual-load — no plugin install needed if `hack-skills-auth-bypass` is already installed; cleanest possible case.

### Rule 5: Business logic + race condition
**Trigger:** Prompt mentions coupon, checkout, inventory, claim, reset, or one-time operation AND mentions concurrent/timing/race
**Load both:** `business-logic-vulnerabilities` (in `hack-skills-web-client-attacks`) + `race-condition` (in `hack-skills-web-client-attacks`)
**Rationale:** Per upstream intuition #7 ("race conditions: prioritize one-time operations — coupon, claim, reset, inventory"). The two skills are siblings in the same plugin; pairing them captures the canonical e-commerce attack surface.

### Rule 6: Web target, signals unclear
**Trigger:** Vague web prompt with no clear category signal (e.g., "I have a new web app, where do I start?")
**Load both:** `recon-and-methodology` (in `hack-skills-recon`) + the relevant category skill once recon surfaces a signal
**Rationale:** Per upstream `hack` operating model step 1 — recon-first when context is unclear. This rule is a fallback, not a fixed pair; phrase it as "always start with recon if signals are ambiguous; then add a category skill once the surface is mapped."

## Plugin-recommendation template

When the router selects a deep skill whose plugin isn't currently installed, surface it in this two-line shape (don't compress into one comma-line):

> **Recommended deep skill:** jwt-oauth-token-attacks (in `hack-skills-auth-bypass`, not currently installed)
> **Install:** `/plugin install hack-skills-auth-bypass@hack-skills-marketplace`

For dual-load cases where two plugins are missing, stack two blocks — don't merge:

> **Recommended deep skill:** business-logic-vulnerabilities (in `hack-skills-web-client-attacks`, not currently installed)
> **Install:** `/plugin install hack-skills-web-client-attacks@hack-skills-marketplace`
>
> **Recommended deep skill:** ssrf-server-side-request-forgery (in `hack-skills-server-side-execution`, not currently installed)
> **Install:** `/plugin install hack-skills-server-side-execution@hack-skills-marketplace`
