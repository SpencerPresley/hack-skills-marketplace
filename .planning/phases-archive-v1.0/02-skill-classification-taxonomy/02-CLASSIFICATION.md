---
status: passed
phase: 02-skill-classification-taxonomy
classified: 2026-05-22
requirements: GROUP-01, GROUP-02, GROUP-03, GROUP-04
total_skills: 102
bucket_count: 14
catch_all_shape: multiple_themed
sized_within_8_15: "true with documented exceptions in web-protocol-attacks, crypto-attacks, active-directory-and-windows, recon, mobile per D-02"
mid_phase_checkpoint: completed
checkpoint_approval_signal: "approved as-is — 2026-05-22 (see .first-pass-classification.md ## Checkpoint Approval section)"
---

# Phase 2 Classification: Skill Taxonomy

## Summary

All 102 skills classified into 14 buckets (11 primary topical + 3 themed catch-alls per D-06); 3 catch-all buckets applied (D-06 preferred shape — `ai-and-supply-chain`, `forensics-and-misc-recovery`, `hack-skills-routers`); 10 `also_relevant_to` close-call entries logged in the Decision Log below and in `skill_metadata` of `02-CLASSIFICATION.json`.

**Bucket overview** (sorted by member count desc, then alphabetical within tier):

| bucket | member_count | sized_within_8_15 | notes |
|---|---|---|---|
| `binary-exploitation` | 12 | yes |  |
| `linux-and-post-exploit` | 10 | yes |  |
| `web-client-attacks` | 10 | yes |  |
| `web-injection` | 10 | yes |  |
| `auth-bypass` | 9 | yes |  |
| `server-side-execution` | 8 | yes |  |
| `active-directory-and-windows` | 7 | no — sized-with-reason per D-02 | sized-with-reason |
| `crypto-attacks` | 7 | no — sized-with-reason per D-02 | sized-with-reason |
| `hack-skills-routers` | 7 | no — catch-all per D-06 | catch-all per D-06 |
| `web-protocol-attacks` | 7 | no — sized-with-reason per D-02 | sized-with-reason |
| `recon` | 6 | no — sized-with-reason per D-02 | sized-with-reason |
| `ai-and-supply-chain` | 3 | no — catch-all per D-06 | catch-all per D-06 |
| `forensics-and-misc-recovery` | 3 | no — catch-all per D-06 | catch-all per D-06 |
| `mobile` | 3 | no — sized-with-reason per D-02 | sized-with-reason |
| **TOTAL** | **102** | — | **14 buckets** |

**D-07 invariant:** every one of the 102 skills appears exactly once across all 14 buckets above. Verified by set equality of the assignment-list against `ls /Users/spencerpresley/code/hack-skills-wip/hack-skills/skills/` (102 entries, `sort -u` count == 102, empty diff with source). The Master Table at the bottom of this document is the auditable enumeration; row count MUST equal 102.

## `active-directory-and-windows`

Active Directory and Windows endpoint attacks — skills covering AD-specific attack chains (ACL abuse, ADCS template attacks, Kerberos roasting/ticketing, NTLM relay coercion) plus the broader Windows-platform post-exploitation cluster (lateral movement, privilege escalation, AV/EDR evasion) that shares the same OS substrate and tooling.

**Members (7):**

- `active-directory-acl-abuse`: Active Directory ACL abuse playbook. Use when exploiting misconfigured AD permissions including GenericAll, WriteDACL, DCSync rights, shadow credentials, LAPS reading, GPO abuse, and BloodHound-guided attack paths.
- `active-directory-certificate-services`: AD Certificate Services attack playbook. Use when targeting misconfigured AD CS for privilege escalation via ESC1-ESC13 template abuse, NTLM relay to enrollment, CA officer abuse, and certificate-based persistence.
- `active-directory-kerberos-attacks`: Kerberos attack playbook for Active Directory. Use when targeting AD authentication via AS-REP roasting, Kerberoasting, golden/silver/diamond tickets, delegation abuse, or pass-the-ticket attacks.
- `ntlm-relay-coercion`: NTLM relay and authentication coercion playbook. Use when capturing and relaying NTLM authentication to escalate privileges via SMB, LDAP, HTTP, or MSSQL relay targets, combined with PetitPotam, PrinterBug, and other coercion methods.
- `windows-av-evasion`: AV/EDR evasion playbook for Windows. Use when bypassing AMSI, ETW, .NET assembly detection, shellcode execution, process injection, API hooking, and signature-based detection on Windows endpoints.
- `windows-lateral-movement`: Windows lateral movement playbook. Use when pivoting between Windows hosts via PsExec, WMI, WinRM, DCOM, RDP, pass-the-hash, overpass-the-hash, or pass-the-ticket techniques.
- `windows-privilege-escalation`: Windows local privilege escalation playbook. Use when you have low-privilege shell access on Windows and need to escalate via token abuse, Potato exploits, service misconfigurations, DLL hijacking, UAC bypass, or registry autoruns.

**Count:** 7 skills.

**Sizing note (D-02 sized-with-reason):** sized-with-reason — 7 members (below 8 target). Reason: this is the Windows-platform cluster. The natural further-merge candidate would be `linux-and-post-exploit` (10) for an OS-agnostic "post-exploit" bucket, but that mixes Windows and Linux/macOS tooling which is the wrong topical axis (per D-04 — skill-content topicality is platform-shaped here). Keep at 7 sized-with-reason.

**Origin note:** D-01-renamed (from `ad` — expanded scope to include Windows lateral movement, privilege escalation, and AV evasion because the AD-only subset is only 4 skills and the broader Windows post-exploitation cluster shares the same OS substrate and tooling)

## `auth-bypass`

Authentication and authorization bypass — skills for defeating access controls at multiple layers: 401/403 path-level bypasses, API authentication and JWT abuse, object-level authorization (IDOR/BOLA), session/MFA/recovery flow weaknesses, OAuth/OIDC and SAML SSO assertion attacks, and PHP-style type-juggling against loose-equality auth checks.

**Members (9):**

- `401-403-bypass-techniques`: 401/403 bypass playbook. Use when encountering access-denied responses on admin panels, API endpoints, or restricted paths. Covers path manipulation, HTTP method tampering, header injection, protocol downgrade, and automated bypass tools.
- `api-auth-and-jwt-abuse`: API authentication and JWT abuse playbook. Use when testing bearer tokens, API keys, claim trust, header spoofing, rate limits, and API auth boundary weaknesses.
- `api-authorization-and-bola`: API authorization and BOLA testing playbook. Use when APIs expose object identifiers, nested resources, hidden writable fields, or weak function-level authorization.
- `authbypass-authentication-flaws`: Authentication bypass testing playbook. Use when assessing login flows, password reset logic, account recovery, MFA bypass, token predictability, brute-force resistance, and session boundary flaws.
- `idor-broken-object-authorization`: IDOR and broken object authorization testing playbook. Use when requests expose object identifiers, tenant boundaries, writable fields, or missing object-level authorization checks.
- `jwt-oauth-token-attacks`: JWT and OAuth token attack playbook. Use when validating token trust, signing algorithms, key handling, claim abuse, bearer flows, and OAuth account-binding weaknesses.
- `oauth-oidc-misconfiguration`: OAuth and OIDC misconfiguration testing playbook. Use when reviewing redirect URI handling, state and nonce validation, PKCE, token audience, callback binding, and identity-provider trust flaws.
- `saml-sso-assertion-attacks`: SAML SSO assertion attack playbook. Use when testing signature validation, assertion wrapping, audience restrictions, ACS handling, XML trust boundaries, and enterprise SSO flaws.
- `type-juggling`: PHP type juggling and weak comparison (`==`) bypass. Use when authentication, HMAC/signature checks, or token validation uses loose equality, numeric coercion, or hash comparisons without strict types — common in legacy PHP and CTF-style code paths.

**Count:** 9 skills.

**Note:** `type-juggling` was reassigned from `web-injection` to `auth-bypass` during first-pass review based on the D-09 primary signal — its own description explicitly emphasizes "authentication, HMAC/signature checks, or token validation uses loose equality" rather than generic input-injection framing.

## `binary-exploitation`

Binary exploitation and reverse engineering — skills covering both the exploitation primitives (heap, stack/ROP, format string, arbitrary-write-to-RCE, browser V8) and the reverse-engineering/analysis tooling (anti-debugging, deobfuscation, symbolic execution, VM/bytecode reversing, binary protection bypass, kernel exploitation, sandbox escape) that share the same skill substrate.

**Members (12):**

- `anti-debugging-techniques`: Anti-debugging detection and bypass playbook. Use when reversing protected binaries that detect debuggers via ptrace, PEB flags, timing checks, or signal/exception handlers on Linux and Windows.
- `arbitrary-write-to-rce`: Arbitrary write to RCE playbook. Use when you have an arbitrary write primitive (from heap exploitation, format string, or OOB write) and need to convert it into code execution by targeting GOT, hooks, _IO_FILE vtable, exit_funcs, TLS_dtor_list, modprobe_path, .fini_array, or C++ vtables.
- `binary-protection-bypass`: Binary protection bypass playbook. Use when identifying and bypassing ASLR, PIE, NX/DEP, stack canary, RELRO, FORTIFY_SOURCE, CET, and MTE protections in ELF binaries to enable exploitation.
- `browser-exploitation-v8`: Browser and V8 exploitation playbook. Use when exploiting JavaScript engine vulnerabilities including JIT type confusion, incorrect bounds elimination, and V8 sandbox bypass to achieve renderer RCE and sandbox escape in Chrome/Chromium.
- `code-obfuscation-deobfuscation`: Code obfuscation analysis and deobfuscation playbook. Use when reversing binaries protected by junk code, opaque predicates, self-modifying code, control flow flattening, VM protection, or string encryption.
- `format-string-exploitation`: Format string exploitation playbook. Use when printf-family functions receive user-controlled format strings, enabling arbitrary stack reads (%p/%s), arbitrary memory writes (%n/%hn/%hhn), GOT/hook overwrites, and canary/libc/PIE leaks.
- `heap-exploitation`: Heap exploitation playbook. Use when targeting ptmalloc2/glibc heap vulnerabilities including UAF, double free, overflow, off-by-one/null, and leveraging tcache/fastbin/unsortedbin attacks for arbitrary write or code execution.
- `kernel-exploitation`: Linux kernel exploitation playbook. Use when exploiting kernel vulnerabilities (UAF, OOB, race condition, type confusion) for privilege escalation via commit_creds, modprobe_path overwrite, or kernel ROP chains in CTF and real-world scenarios.
- `sandbox-escape-techniques`: Sandbox escape playbook. Use when breaking out of Python sandbox, Lua sandbox, seccomp filter, chroot jail, container/Docker, browser sandbox, or namespace isolation to achieve unrestricted code execution or file access.
- `stack-overflow-and-rop`: Stack overflow and ROP playbook. Use when exploiting buffer overflows to hijack control flow via return address overwrite, ROP chains, ret2libc, ret2csu, ret2dlresolve, or SROP on Linux userland binaries.
- `symbolic-execution-tools`: Symbolic execution and constraint solving playbook. Use when solving CTF reversing challenges, recovering keys, bypassing checks, or automating binary analysis with angr, Z3, or Unicorn Engine.
- `vm-and-bytecode-reverse`: Custom VM and bytecode reverse engineering playbook. Use when CTF challenges or protected software implement custom virtual machines with proprietary bytecode, dispatcher loops, or maze-style challenges.

**Count:** 12 skills.

**Origin note:** D-01-renamed (from `binary` — renamed to make scope explicit; includes both exploitation primitives AND analysis/reversing tooling because the two halves share the same skill substrate)

## `crypto-attacks`

Cryptography attacks and blockchain/DeFi exploits — skills covering classical cryptanalysis (classical cipher, hash, lattice, RSA, symmetric cipher attacks) plus blockchain/web3 attacks (smart contract vulnerabilities, DeFi attack patterns) that cluster naturally under the broader "crypto" terminology as the security community uses it.

**Members (7):**

- `classical-cipher-analysis`: Classical cipher analysis playbook. Use when encountering substitution ciphers, Vigenere, transposition, XOR, or encoded text in CTF challenges that requires frequency analysis, Kasiski examination, or known-plaintext cryptanalysis.
- `defi-attack-patterns`: DeFi attack pattern playbook. Use when analyzing flash loan attacks, price oracle manipulation, MEV sandwich attacks, governance exploits, bridge vulnerabilities, and token standard edge cases in decentralized finance protocols.
- `hash-attack-techniques`: Hash attack playbook. Use when exploiting length extension, MD5/SHA1 collisions, HMAC timing leaks, birthday attacks, or hash-based proof of work in CTF and authorized testing scenarios.
- `lattice-crypto-attacks`: Lattice-based cryptanalysis playbook. Use when attacking RSA via Coppersmith small roots, recovering DSA/ECDSA nonces from bias, solving knapsack problems, or applying LLL/BKZ reduction to cryptographic constructions.
- `rsa-attack-techniques`: RSA attack playbook for CTF and real-world cryptanalysis. Use when given RSA parameters (n, e, c) and need to recover plaintext by exploiting weak keys, small exponents, shared factors, or padding oracles.
- `smart-contract-vulnerabilities`: Smart contract vulnerability playbook. Use when auditing Solidity/EVM contracts for reentrancy, integer overflow, access control, delegatecall, flash loan, signature replay, and MEV-related attack patterns.
- `symmetric-cipher-attacks`: Symmetric cipher attack playbook. Use when exploiting block cipher mode weaknesses (CBC padding oracle, ECB cut-and-paste, bit flipping), stream cipher key reuse, or meet-in-the-middle attacks.

**Count:** 7 skills.

**Sizing note (D-02 sized-with-reason):** sized-with-reason — 7 members (below 8 target). Reason: classical cryptography (5 skills) + blockchain crypto (2 skills) cluster naturally under the shared "crypto" terminology. Splitting them would leave a 2-skill blockchain bucket that violates D-02's <5 merge threshold. Keep combined at 7 sized-with-reason; if Plan 02-02 or downstream curation later wants to separate them, the move is trivial.

**Origin note:** D-01-renamed (from `crypto`) + scope-expanded to include blockchain/web3 attack skills (only 2 skills — too small to be their own bucket, and "crypto" as commonly used in the security community spans both classical cryptography and blockchain "crypto")

## `linux-and-post-exploit`

Linux/macOS post-exploitation and network pivoting — skills covering Linux/macOS post-access workflows (privilege escalation, lateral movement, security-mechanism bypass, macOS process injection and security bypass), the cloud/container post-exploit cluster (container escape, Kubernetes pentesting), network-layer attacks and pivoting (network protocol attacks, tunneling), and reverse shell techniques. Absorbs the original `payloads` D-01 starter via D-02 merge.

**Members (10):**

- `container-escape-techniques`: Container escape playbook. Use when operating inside a Docker container, LXC, or Kubernetes pod and need to escape to the host via privileged mode, capabilities, Docker socket, cgroup abuse, namespace tricks, or runtime vulnerabilities.
- `kubernetes-pentesting`: Kubernetes penetration testing playbook. Use when targeting Kubernetes clusters via API server, RBAC enumeration, service account abuse, etcd access, Kubelet API, pod escape, cloud-specific metadata, admission webhook bypass, and registry secrets.
- `linux-lateral-movement`: Linux lateral movement playbook. Use after gaining initial access to pivot across Linux hosts via SSH hijacking, credential harvesting, internal pivoting, D-Bus exploitation, sudo token reuse, and shared filesystem abuse.
- `linux-privilege-escalation`: Linux privilege escalation playbook. Use when you have low-privilege shell access and need to escalate to root via SUID/SGID binaries, capabilities, cron abuse, kernel exploits, misconfigurations, or credential harvesting on Linux systems.
- `linux-security-bypass`: Linux security mechanism bypass playbook. Use when facing restricted bash/rbash, read-only or noexec filesystems, AppArmor, SELinux, seccomp filters, or audit logging that must be evaded during post-exploitation.
- `macos-process-injection`: macOS process injection playbook. Use when you need to inject code into running or launching macOS processes via dylib hijacking, DYLD environment variables, XPC exploitation, Mach port manipulation, or Electron/Chromium abuse.
- `macos-security-bypass`: macOS security bypass playbook. Use when targeting macOS endpoints and need to bypass TCC, Gatekeeper, SIP, sandbox, code signing, or entitlement-based protections during authorized red team or pentest engagements.
- `network-protocol-attacks`: Network protocol attack playbook. Use when exploiting layer 2/3 protocols including ARP spoofing, LLMNR/NBT-NS/mDNS poisoning, WPAD abuse, DHCPv6 attacks, VLAN hopping, STP manipulation, DNS spoofing, IPv6 attacks, and IDS/IPS evasion.
- `reverse-shell-techniques`: Reverse shell techniques playbook. Use when establishing remote shells including language one-liners, encrypted shells (OpenSSL/socat/ncat), web shells, PTY upgrades, file transfer methods, PowerShell shells, and Windows payload generation.
- `tunneling-and-pivoting`: Tunneling and pivoting playbook. Use when establishing network tunnels through compromised hosts including SSH tunneling, Chisel, Ligolo-ng, socat, DNS/ICMP/HTTP tunneling, ProxyChains, and multi-layer pivoting strategies.

**Count:** 10 skills.

**Origin note:** D-02-merge (absorbs the original `payloads` D-01 starter — only 2 payloads-shaped skills existed, both below the <5 merge threshold) + D-03-coalesced (10 skills clustering around Linux/macOS post-access workflows, network protocol attacks, container escape, and tunneling)

**Note:** the D-01 `payloads` starter only had 2 candidate members in this corpus (`reverse-shell-techniques`, `unauthorized-access-common-services`). `reverse-shell-techniques` folded here under the post-exploit umbrella; `unauthorized-access-common-services` folded into `recon` because its description leads with "common exposed services" enumeration. No standalone `payloads` bucket survives.

## `mobile`

Mobile platform pentesting — skills covering Android and iOS application testing plus the cross-platform SSL pinning bypass tooling that gates traffic interception on both platforms.

**Members (3):**

- `android-pentesting-tricks`: Android pentesting playbook. Use when testing Android applications for SSL pinning bypass, exported component abuse, WebView vulnerabilities, intent redirection, root detection bypass, tapjacking, and backup extraction during authorized mobile security assessments.
- `ios-pentesting-tricks`: iOS pentesting playbook. Use when testing iOS applications for keychain extraction, URL scheme hijacking, Universal Links exploitation, runtime manipulation, binary protection analysis, data storage issues, and transport security bypass during authorized mobile security assessments.
- `mobile-ssl-pinning-bypass`: Mobile SSL pinning bypass playbook. Use when intercepting HTTPS traffic from mobile applications that implement certificate pinning, public key pinning, or SPKI hash pinning on Android and iOS, including React Native, Flutter, and Xamarin frameworks.

**Count:** 3 skills.

**Sizing note (D-02 sized-with-reason):** sized-with-reason — 3 members (below 8 target, and below D-02's <5 merge threshold). Reason: mobile platform pentesting is topically distinct from desktop/server attack surface (per D-04). The natural merge candidates (`active-directory-and-windows` for OS-platform parity, `linux-and-post-exploit` for post-exploit umbrella) would mix mobile and desktop/server platforms in a single bucket, violating skill-content topicality. The cluster is small because upstream coverage of mobile is genuinely modest, not because the taxonomy is mis-shaped. Acceptable as a small primary bucket per D-06's note that themed buckets can be sized small when coherent.

## `recon`

Reconnaissance and attack-surface enumeration — skills covering the find/enumerate phase of a target assessment: API/endpoint discovery, source-code-exposure recon, methodology playbooks, subdomain takeover detection, and unauthorized-access enumeration against commonly-exposed services. Maps to the pre-exploitation phase of any pentest workflow.

**Members (6):**

- `api-recon-and-docs`: API reconnaissance and documentation review playbook. Use when discovering endpoints, schemas, versions, OpenAPI specs, hidden docs, and surface area for API testing.
- `graphql-and-hidden-parameters`: GraphQL and hidden parameter testing playbook. Use when exploring introspection, batching, undocumented fields, hidden parameters, schema abuse, and GraphQL authorization gaps.
- `insecure-source-code-management`: Source control and artifact exposure (.git, .svn, .hg, backups, .env). Use when recon finds VCS paths, 403 on hidden dirs, or backup/config leaks during authorized testing.
- `recon-and-methodology`: Reconnaissance and methodology playbook. Use when mapping assets, discovering endpoints, fingerprinting technology, and building a structured testing plan for a new target.
- `subdomain-takeover`: Subdomain takeover detection and exploitation playbook. Use when targets have dangling CNAME/NS/MX records pointing to deprovisioned cloud resources, expired third-party services, or unclaimed SaaS tenants that an attacker can register to serve content under the victim's domain.
- `unauthorized-access-common-services`: Unauthorized access playbook for common exposed services. Use when Redis, Rsync, PHP-FPM, AJP/Ghostcat, Hadoop YARN, H2 Console, or similar management interfaces are exposed without authentication.

**Count:** 6 skills.

**Sizing note (D-02 sized-with-reason):** sized-with-reason — 6 members (below 8 target). Reason: this is the bucket whose contents map cleanly to the "find/enumerate the target" phase. Forcing a merge into another bucket would violate D-04 (skill-content topicality) by mixing recon with attack execution. Keeping at 6 sized-with-reason is the cleaner taxonomic call than diluting either side.

## `server-side-execution`

Server-side code execution and trust-boundary chains — skills covering server-side execution primitives and the chains that reach them: command injection, insecure deserialization, expression-language and JNDI injection, path traversal/LFI, SSRF, SSTI, and insecure file upload (often the final link in upload-to-RCE chains). Carved out from the original `injection` D-01 starter along the server-side-execution subtopic axis.

**Members (8):**

- `cmdi-command-injection`: Command injection playbook. Use when user input may reach shell commands, process execution, converters, import pipelines, or blind out-of-band command sinks.
- `deserialization-insecure`: Insecure deserialization playbook. Use when Java, PHP, or Python applications deserialize untrusted data via ObjectInputStream, unserialize, pickle, or similar mechanisms that may lead to RCE, file access, or privilege escalation.
- `expression-language-injection`: Expression Language injection playbook. Use when Java EL, SpEL, OGNL, or MVEL expressions may evaluate attacker-controlled input in Spring, Struts2, Confluence, or similar frameworks.
- `jndi-injection`: JNDI injection playbook. Use when Java applications perform JNDI lookups with attacker-controlled names, especially via Log4j2, Spring, or any code path reaching InitialContext.lookup().
- `path-traversal-lfi`: Path traversal and LFI playbook. Use when file paths, download endpoints, include operations, archive extraction, or wrapper behavior may expose filesystem control.
- `ssrf-server-side-request-forgery`: SSRF playbook. Use when the server fetches URLs, resolves hostnames, imports remote content, or can be driven toward internal networks, cloud metadata, or secondary protocols.
- `ssti-server-side-template-injection`: SSTI playbook. Use when template expressions, server-side rendering, preview features, or templating engines may evaluate attacker-controlled content.
- `upload-insecure-files`: Insecure file upload playbook. Use when testing upload validation, storage paths, processing pipelines, preview behavior, overwrite risks, and upload-to-RCE chains.

**Count:** 8 skills.

**Origin note:** D-02-split (from `injection` — server-side execution / SSRF / template / RCE subset)

## `web-client-attacks`

Client-side and browser-context web vulnerabilities — skills covering attacks that depend on browser/client behavior: business logic and race-condition abuse, clickjacking, CORS/CSP misconfigurations and bypass, CSRF, DNS rebinding, open redirect, and prototype pollution (basic + advanced). Carved out from the original `injection` D-01 starter along the client-driven and browser-policy subtopic axis.

**Members (10):**

- `business-logic-vulnerabilities`: Business logic vulnerability playbook. Use when reasoning about workflows, race conditions, price manipulation, coupon abuse, state machines, and multi-step authorization gaps.
- `clickjacking`: Clickjacking playbook. Use when testing whether target pages can be framed, whether X-Frame-Options or CSP frame-ancestors are properly configured, and whether UI redress attacks can trigger sensitive actions.
- `cors-cross-origin-misconfiguration`: CORS misconfiguration testing playbook. Use when analyzing cross-origin trust, credentialed browser reads, origin reflection, preflight policy bugs, and browser-based access to authenticated APIs.
- `csp-bypass-advanced`: Advanced Content Security Policy bypass techniques. Use when XSS or data exfiltration is blocked by CSP and you need to find policy weaknesses, trusted endpoint abuse, nonce leakage, or exfiltration channels that CSP cannot block.
- `csrf-cross-site-request-forgery`: CSRF testing playbook. Use when reviewing state-changing web flows, anti-CSRF defenses, SameSite behavior, JSON CSRF, login CSRF, and OAuth state handling.
- `dns-rebinding-attacks`: DNS rebinding attack playbook. Use when testing applications that trust DNS resolution for origin checks, interact with internal services from browser context, or when SSRF is not possible server-side but the target has client-side fetch/XHR to attacker-controlled domains.
- `open-redirect`: Open redirect playbook. Use when URL parameters, form actions, or JavaScript sinks control navigation targets and may redirect users to attacker-controlled destinations.
- `prototype-pollution`: Prototype pollution testing for JavaScript stacks. Use when user input is merged into objects (query parsers, JSON bodies, deep assign), when configuring libraries via untrusted keys, or when hunting RCE gadgets via polluted Object.prototype in Node or the browser.
- `prototype-pollution-advanced`: Advanced prototype pollution playbook — server-side RCE, client-side gadgets, filter bypasses, and detection techniques. Companion to ../prototype-pollution/ for basics. Use when you've confirmed pollution and need to escalate to code execution or find framework-specific gadgets.
- `race-condition`: Race condition and TOCTOU testing for web apps. Use when testing one-time operations, concurrent HTTP abuse, rate-limit bypass, Turbo Intruder gates, HTTP/2 single-packet attacks, and CWE-362-style synchronization gaps.

**Count:** 10 skills.

**Origin note:** D-02-split (from `injection` — client-driven and browser-policy subset)

## `web-injection`

Web-layer injection and input-driven attacks — skills covering attacks where attacker-controlled data flows into parsers/sinks: SQL/NoSQL injection, XSS, XXE, XSLT injection, dangling markup, CSV/spreadsheet formula injection, email header injection, the Java Ghost Bits cast-attack WAF-bypass meta-technique, and WAF bypass methodology. Carved out from the original `injection` D-01 starter along the input-data-shaped subtopic axis.

**Members (10):**

- `csv-formula-injection`: CSV/spreadsheet formula injection (DDE, Excel/LibreOffice, Google Sheets IMPORT*). Use when exports, imports, or user fields feed spreadsheets or reporting tools.
- `dangling-markup-injection`: Dangling markup injection playbook. Use when HTML injection is possible but JavaScript execution is blocked (CSP, sanitizer strips event handlers, WAF blocks script tags) — exfiltrate CSRF tokens, session data, and page content by injecting unclosed HTML tags that capture subsequent page content.
- `email-header-injection`: Email header injection and spoofing playbook. Use when testing contact forms, email APIs, password reset flows, or any feature that constructs SMTP messages with user-controlled fields. Covers CRLF injection in headers, SPF/DKIM/DMARC bypass, and phishing amplification.
- `ghost-bits-cast-attack`: Java "Ghost Bits" / Cast Attack playbook (Black Hat Asia 2026). Use when attacking Java services where 16-bit char is silently narrowed to 8-bit byte to bypass WAF/IDS for SQL injection, deserialization RCE, file upload (Webshell), path traversal, CRLF injection, request smuggling, and SMTP injection. Affects Tomcat, Spring, Jetty, Undertow, Vert.x, Jackson, Fastjson, Apache Commons BCEL, Apache HttpClient, Angus Mail, JDK HttpServer, Lettuce, Jodd, XMLWriter and re-enables many "patched" CVEs through WAF bypass.
- `nosql-injection`: NoSQL injection playbook. Use when MongoDB-style operators, JSON query objects, flexible search filters, or backend query DSLs may allow data or logic abuse.
- `sqli-sql-injection`: SQL injection playbook. Use when input reaches SQL queries, authentication logic, sorting, filtering, reporting, or DB-specific blind and out-of-band execution paths.
- `waf-bypass-techniques`: WAF bypass methodology and generic evasion techniques. Use when a web application firewall blocks injection payloads (SQLi, XSS, RCE) and you need to craft bypasses using encoding, protocol-level tricks, or WAF-specific weaknesses.
- `xslt-injection`: XSLT injection testing: processor fingerprinting, XXE and document() SSRF, EXSLT write primitives, PHP/Java/.NET extension RCE surfaces. Use when user-controlled XSLT/stylesheet input or transform endpoints are in scope.
- `xss-cross-site-scripting`: XSS playbook. Use when user-controlled content reaches HTML, attributes, JavaScript, DOM sinks, uploads, or multi-context rendering paths.
- `xxe-xml-external-entity`: XXE playbook. Use when XML, SVG, OOXML, SOAP, or parser-driven imports may resolve external entities, files, or internal network resources.

**Count:** 10 skills.

**Origin note:** D-02-split (from the `injection` D-01 starter — split along the natural subtopic axis: input-data-shaped injection vs. HTTP-protocol-layer attacks vs. client-side-driven attacks vs. server-side-execution chains)

## `web-protocol-attacks`

HTTP protocol-layer attacks and request flow abuse — skills covering attacks that pivot on HTTP message framing and protocol behavior rather than payload content: CRLF injection, Host header injection, parameter pollution, HTTP/2-specific attacks, request smuggling, web cache deception, and WebSocket security. Carved out from the original `injection` D-01 starter along the protocol-layer subtopic axis.

**Members (7):**

- `crlf-injection`: CRLF injection playbook. Use when user input reaches HTTP response headers, Location redirects, Set-Cookie values, or log files where carriage-return/line-feed characters can split or inject content.
- `http-host-header-attacks`: HTTP Host header injection and routing abuse playbook. Use when the application trusts the Host header for generating URLs, routing requests, or access control — enabling password reset poisoning, web cache poisoning, SSRF via routing, and virtual host bypass.
- `http-parameter-pollution`: HTTP Parameter Pollution (HPP): duplicate query/body keys parsed differently by servers, proxies, WAFs, and app frameworks. Use when filters and application layers disagree on which value wins, enabling bypass, SSRF second URL, logic abuse, or CSRF token confusion.
- `http2-specific-attacks`: HTTP/2 protocol-specific attack playbook. Use when the target supports HTTP/2 and you need to exploit binary framing, HPACK compression, h2c upgrade smuggling, pseudo-header injection, stream multiplexing abuse, or H2→H1 downgrade translation flaws.
- `request-smuggling`: HTTP request smuggling and desynchronization testing. Use when front proxies, CDNs, or load balancers disagree with the origin on message framing (Content-Length vs Transfer-Encoding), on HTTP/2→HTTP/1 translation, or when exploring client-side desync via browser fetch pipelines.
- `web-cache-deception`: Web cache deception and poisoning playbook. Use when CDN, reverse proxy, or application caching may serve sensitive authenticated content to other users due to path confusion or cache key manipulation.
- `websocket-security`: WebSocket handshake, CSWSH, tooling (wsrepl, ws-harness, Burp), and common flaws. Use when apps use real-time channels, chat, notifications, or WS-backed APIs.

**Count:** 7 skills.

**Sizing note (D-02 sized-with-reason):** sized-with-reason — 7 members (below 8 target). Reason: this is the subset that pivots on HTTP message-framing and protocol behavior rather than payload content. Merging into `web-injection` (10) would push that bucket to 17 and force another split along essentially the same axis. Standalone at 7 preserves D-04 topical coherence.

**Origin note:** D-02-split (from `injection` — protocol-layer subset)

## Catch-all bucket(s)

Multiple themed catch-alls applied (D-06 preferred shape): `ai-and-supply-chain`, `forensics-and-misc-recovery`, `hack-skills-routers`. Each is a thin coherent theme that doesn't fit any primary topical bucket; per D-06, misfits are assigned to a catch-all bucket rather than being absent from `marketplace.json` (GROUP-04 reframe). Per-member reason tags (`standalone` or `redundant` per D-05) appended to each skill's verbatim description below.

### `ai-and-supply-chain`

AI/ML security and software supply chain attacks — thin coherent theme covering attacks against AI/ML model supply chains and outputs (model pickle RCE, adversarial examples, prompt injection against LLM applications) plus dependency-confusion supply-chain attacks. The shared frame is "trust boundaries in modern software pipelines" — these don't fit any primary topical bucket but cluster as a themed catch-all per D-06.

**Members (3):**

- `ai-ml-security`: AI/ML security playbook. Use when assessing model supply chain attacks (pickle RCE, poisoned weights), adversarial examples, model poisoning, model stealing, data privacy attacks (membership inference, model inversion), and autonomous agent security risks. (standalone)
- `dependency-confusion`: Supply-chain testing via package-manager dependency confusion: when internal package names resolve to attacker-controlled public registries, leading to malicious install and script execution. Use for npm/pip/gem/Maven/Composer/Docker manifest review and authorized red-team supply-chain exercises. (standalone)
- `llm-prompt-injection`: LLM prompt injection playbook. Use when testing AI/LLM applications for direct injection, indirect injection via RAG/browsing, tool abuse, data exfiltration, MCP security risks, and defense bypass techniques. (standalone)

**Count:** 3 skills.

**Sizing note (D-06 catch-all):** catch-all per D-06 (below the 8+ D-03 emergent threshold; clusters as a themed catch-all rather than dispersing into other buckets where these skills would not topically belong)

### `forensics-and-misc-recovery`

Forensics, memory analysis, and steganographic recovery — thin coherent theme covering forensics-flavored skills (memory analysis with Volatility, network forensics via PCAP analysis, steganographic extraction). The shared frame is "recover hidden state from collected artifacts" rather than the offensive-playbook shape of the primary topical buckets — a themed catch-all per D-06.

**Members (3):**

- `memory-forensics-volatility`: Memory forensics playbook using Volatility 2/3. Use when analyzing memory dumps for malware analysis, credential extraction, process investigation, code injection detection, and incident response timeline reconstruction. (standalone)
- `steganography-techniques`: Steganography detection and extraction playbook. Use when analyzing images (LSB, PNG chunks, JPEG DCT, EXIF), audio (spectrogram, DTMF), files (polyglots, appended data, ADS), and text (whitespace, zero-width, homoglyphs) for hidden data. (standalone)
- `traffic-analysis-pcap`: Traffic analysis and PCAP forensics playbook. Use when analyzing network captures including Wireshark filters, protocol analysis (HTTP/DNS/FTP/SMTP/USB/WiFi), data extraction, covert channel detection, PCAP repair, TLS decryption, and tshark command-line analysis. (standalone)

**Count:** 3 skills.

**Sizing note (D-06 catch-all):** catch-all per D-06 (below 8+ D-03 emergent threshold; themed-catch-all per D-06 preferred shape)

### `hack-skills-routers`

Category routing and skill-selection entry points — thin coherent theme covering the upstream's meta-navigation skills (the seven `*-sec` / `*-vuln` / top-level `hack` router skills) that route between topic skills rather than themselves being topical playbooks. Per D-05(b) these are "too generic / redundant" misfits. Whether this bucket should be exposed as its own `marketplace.json` plugin OR excluded entirely is a Phase 3 decision flagged here for downstream consideration — for Phase 2's D-07 invariant they need a home, and this themed catch-all is that home.

**Members (7):**

- `api-sec`: Entry P1 category router for API security. Use when choosing between API recon, authorization, token abuse, and hidden-parameter workflows before any deeper API topic skill. (redundant)
- `auth-sec`: Entry P1 category router for authentication and authorization. Use when testing login flows, sessions, object authorization, JWT, OAuth, CORS, CSRF, and enterprise SSO weaknesses before any deeper auth topic skill. (redundant)
- `business-logic-vuln`: Entry P1 category router for business logic testing. Use when workflow abuse, race conditions, pricing flaws, or multi-step state attacks matter more than parser-level input injection. (redundant)
- `file-access-vuln`: Entry P1 category router for file access and upload workflows. Use when testing download endpoints, file paths, local file inclusion, upload flows, preview pipelines, archive extraction, or storage and sharing boundaries. (redundant)
- `hack`: Entry P0 primary router for HackSkills. Use when the task involves web application testing, API security assessment, recon, vulnerability triage, exploit path planning, or choosing the right next category skill before any deep topic skill. (redundant)
- `injection-checking`: Entry P1 category router for injection testing. Use when routing between XSS, SQLi, SSRF, XXE, SSTI, command injection, and NoSQL injection workflows based on how attacker-controlled input is consumed. (redundant)
- `recon-for-sec`: Entry P1 category router for reconnaissance and methodology. Use when mapping scope, discovering assets, fingerprinting technology, building endpoint inventory, and choosing the first high-value security testing path. (redundant)

**Count:** 7 skills.

**Sizing note (D-06 catch-all):** catch-all per D-06 (D-05(b) misfit: these are router/index skills, not topical playbooks; they cluster around the "entry point" theme rather than around a security topic)

**Note:** Whether this bucket should be exposed as its own marketplace plugin OR excluded from `marketplace.json` entirely is a Phase 3 question. For Phase 2's D-07 invariant (every skill assigned exactly once) they need a home; `hack-skills-routers` is that home, with the understanding that Plan 02-02 / Phase 3 may revisit whether to expose this bucket as a marketplace plugin.

## Master Table

One row per skill, alphabetical by `name`. Row count MUST equal 102 (D-07 invariant). The `name` column matches the upstream directory name; the `summary` column is the verbatim `description` from each skill's SKILL.md YAML frontmatter (D-14); `assigned_bucket` matches a bucket name in the per-bucket or catch-all sections above; `also_relevant_to` is empty for routine assignments and populated per D-10 for borderline skills only.

| name | summary | assigned_bucket | also_relevant_to |
|---|---|---|---|
| `401-403-bypass-techniques` | 401/403 bypass playbook. Use when encountering access-denied responses on admin panels, API endpoints, or restricted paths. Covers path manipulation, HTTP method tampering, header injection, protocol downgrade, and automated bypass tools. | `auth-bypass` |  |
| `active-directory-acl-abuse` | Active Directory ACL abuse playbook. Use when exploiting misconfigured AD permissions including GenericAll, WriteDACL, DCSync rights, shadow credentials, LAPS reading, GPO abuse, and BloodHound-guided attack paths. | `active-directory-and-windows` |  |
| `active-directory-certificate-services` | AD Certificate Services attack playbook. Use when targeting misconfigured AD CS for privilege escalation via ESC1-ESC13 template abuse, NTLM relay to enrollment, CA officer abuse, and certificate-based persistence. | `active-directory-and-windows` |  |
| `active-directory-kerberos-attacks` | Kerberos attack playbook for Active Directory. Use when targeting AD authentication via AS-REP roasting, Kerberoasting, golden/silver/diamond tickets, delegation abuse, or pass-the-ticket attacks. | `active-directory-and-windows` |  |
| `ai-ml-security` | AI/ML security playbook. Use when assessing model supply chain attacks (pickle RCE, poisoned weights), adversarial examples, model poisoning, model stealing, data privacy attacks (membership inference, model inversion), and autonomous agent security risks. | `ai-and-supply-chain` |  |
| `android-pentesting-tricks` | Android pentesting playbook. Use when testing Android applications for SSL pinning bypass, exported component abuse, WebView vulnerabilities, intent redirection, root detection bypass, tapjacking, and backup extraction during authorized mobile security assessments. | `mobile` |  |
| `anti-debugging-techniques` | Anti-debugging detection and bypass playbook. Use when reversing protected binaries that detect debuggers via ptrace, PEB flags, timing checks, or signal/exception handlers on Linux and Windows. | `binary-exploitation` |  |
| `api-auth-and-jwt-abuse` | API authentication and JWT abuse playbook. Use when testing bearer tokens, API keys, claim trust, header spoofing, rate limits, and API auth boundary weaknesses. | `auth-bypass` |  |
| `api-authorization-and-bola` | API authorization and BOLA testing playbook. Use when APIs expose object identifiers, nested resources, hidden writable fields, or weak function-level authorization. | `auth-bypass` |  |
| `api-recon-and-docs` | API reconnaissance and documentation review playbook. Use when discovering endpoints, schemas, versions, OpenAPI specs, hidden docs, and surface area for API testing. | `recon` |  |
| `api-sec` | Entry P1 category router for API security. Use when choosing between API recon, authorization, token abuse, and hidden-parameter workflows before any deeper API topic skill. | `hack-skills-routers` |  |
| `arbitrary-write-to-rce` | Arbitrary write to RCE playbook. Use when you have an arbitrary write primitive (from heap exploitation, format string, or OOB write) and need to convert it into code execution by targeting GOT, hooks, _IO_FILE vtable, exit_funcs, TLS_dtor_list, modprobe_path, .fini_array, or C++ vtables. | `binary-exploitation` |  |
| `auth-sec` | Entry P1 category router for authentication and authorization. Use when testing login flows, sessions, object authorization, JWT, OAuth, CORS, CSRF, and enterprise SSO weaknesses before any deeper auth topic skill. | `hack-skills-routers` |  |
| `authbypass-authentication-flaws` | Authentication bypass testing playbook. Use when assessing login flows, password reset logic, account recovery, MFA bypass, token predictability, brute-force resistance, and session boundary flaws. | `auth-bypass` |  |
| `binary-protection-bypass` | Binary protection bypass playbook. Use when identifying and bypassing ASLR, PIE, NX/DEP, stack canary, RELRO, FORTIFY_SOURCE, CET, and MTE protections in ELF binaries to enable exploitation. | `binary-exploitation` |  |
| `browser-exploitation-v8` | Browser and V8 exploitation playbook. Use when exploiting JavaScript engine vulnerabilities including JIT type confusion, incorrect bounds elimination, and V8 sandbox bypass to achieve renderer RCE and sandbox escape in Chrome/Chromium. | `binary-exploitation` |  |
| `business-logic-vuln` | Entry P1 category router for business logic testing. Use when workflow abuse, race conditions, pricing flaws, or multi-step state attacks matter more than parser-level input injection. | `hack-skills-routers` |  |
| `business-logic-vulnerabilities` | Business logic vulnerability playbook. Use when reasoning about workflows, race conditions, price manipulation, coupon abuse, state machines, and multi-step authorization gaps. | `web-client-attacks` | `auth-bypass` |
| `classical-cipher-analysis` | Classical cipher analysis playbook. Use when encountering substitution ciphers, Vigenere, transposition, XOR, or encoded text in CTF challenges that requires frequency analysis, Kasiski examination, or known-plaintext cryptanalysis. | `crypto-attacks` |  |
| `clickjacking` | Clickjacking playbook. Use when testing whether target pages can be framed, whether X-Frame-Options or CSP frame-ancestors are properly configured, and whether UI redress attacks can trigger sensitive actions. | `web-client-attacks` |  |
| `cmdi-command-injection` | Command injection playbook. Use when user input may reach shell commands, process execution, converters, import pipelines, or blind out-of-band command sinks. | `server-side-execution` |  |
| `code-obfuscation-deobfuscation` | Code obfuscation analysis and deobfuscation playbook. Use when reversing binaries protected by junk code, opaque predicates, self-modifying code, control flow flattening, VM protection, or string encryption. | `binary-exploitation` |  |
| `container-escape-techniques` | Container escape playbook. Use when operating inside a Docker container, LXC, or Kubernetes pod and need to escape to the host via privileged mode, capabilities, Docker socket, cgroup abuse, namespace tricks, or runtime vulnerabilities. | `linux-and-post-exploit` |  |
| `cors-cross-origin-misconfiguration` | CORS misconfiguration testing playbook. Use when analyzing cross-origin trust, credentialed browser reads, origin reflection, preflight policy bugs, and browser-based access to authenticated APIs. | `web-client-attacks` |  |
| `crlf-injection` | CRLF injection playbook. Use when user input reaches HTTP response headers, Location redirects, Set-Cookie values, or log files where carriage-return/line-feed characters can split or inject content. | `web-protocol-attacks` |  |
| `csp-bypass-advanced` | Advanced Content Security Policy bypass techniques. Use when XSS or data exfiltration is blocked by CSP and you need to find policy weaknesses, trusted endpoint abuse, nonce leakage, or exfiltration channels that CSP cannot block. | `web-client-attacks` | `web-injection` |
| `csrf-cross-site-request-forgery` | CSRF testing playbook. Use when reviewing state-changing web flows, anti-CSRF defenses, SameSite behavior, JSON CSRF, login CSRF, and OAuth state handling. | `web-client-attacks` |  |
| `csv-formula-injection` | CSV/spreadsheet formula injection (DDE, Excel/LibreOffice, Google Sheets IMPORT*). Use when exports, imports, or user fields feed spreadsheets or reporting tools. | `web-injection` | `server-side-execution` |
| `dangling-markup-injection` | Dangling markup injection playbook. Use when HTML injection is possible but JavaScript execution is blocked (CSP, sanitizer strips event handlers, WAF blocks script tags) — exfiltrate CSRF tokens, session data, and page content by injecting unclosed HTML tags that capture subsequent page content. | `web-injection` |  |
| `defi-attack-patterns` | DeFi attack pattern playbook. Use when analyzing flash loan attacks, price oracle manipulation, MEV sandwich attacks, governance exploits, bridge vulnerabilities, and token standard edge cases in decentralized finance protocols. | `crypto-attacks` |  |
| `dependency-confusion` | Supply-chain testing via package-manager dependency confusion: when internal package names resolve to attacker-controlled public registries, leading to malicious install and script execution. Use for npm/pip/gem/Maven/Composer/Docker manifest review and authorized red-team supply-chain exercises. | `ai-and-supply-chain` |  |
| `deserialization-insecure` | Insecure deserialization playbook. Use when Java, PHP, or Python applications deserialize untrusted data via ObjectInputStream, unserialize, pickle, or similar mechanisms that may lead to RCE, file access, or privilege escalation. | `server-side-execution` |  |
| `dns-rebinding-attacks` | DNS rebinding attack playbook. Use when testing applications that trust DNS resolution for origin checks, interact with internal services from browser context, or when SSRF is not possible server-side but the target has client-side fetch/XHR to attacker-controlled domains. | `web-client-attacks` | `server-side-execution` |
| `email-header-injection` | Email header injection and spoofing playbook. Use when testing contact forms, email APIs, password reset flows, or any feature that constructs SMTP messages with user-controlled fields. Covers CRLF injection in headers, SPF/DKIM/DMARC bypass, and phishing amplification. | `web-injection` |  |
| `expression-language-injection` | Expression Language injection playbook. Use when Java EL, SpEL, OGNL, or MVEL expressions may evaluate attacker-controlled input in Spring, Struts2, Confluence, or similar frameworks. | `server-side-execution` |  |
| `file-access-vuln` | Entry P1 category router for file access and upload workflows. Use when testing download endpoints, file paths, local file inclusion, upload flows, preview pipelines, archive extraction, or storage and sharing boundaries. | `hack-skills-routers` |  |
| `format-string-exploitation` | Format string exploitation playbook. Use when printf-family functions receive user-controlled format strings, enabling arbitrary stack reads (%p/%s), arbitrary memory writes (%n/%hn/%hhn), GOT/hook overwrites, and canary/libc/PIE leaks. | `binary-exploitation` |  |
| `ghost-bits-cast-attack` | Java "Ghost Bits" / Cast Attack playbook (Black Hat Asia 2026). Use when attacking Java services where 16-bit char is silently narrowed to 8-bit byte to bypass WAF/IDS for SQL injection, deserialization RCE, file upload (Webshell), path traversal, CRLF injection, request smuggling, and SMTP injection. Affects Tomcat, Spring, Jetty, Undertow, Vert.x, Jackson, Fastjson, Apache Commons BCEL, Apache HttpClient, Angus Mail, JDK HttpServer, Lettuce, Jodd, XMLWriter and re-enables many "patched" CVEs through WAF bypass. | `web-injection` | `server-side-execution` |
| `graphql-and-hidden-parameters` | GraphQL and hidden parameter testing playbook. Use when exploring introspection, batching, undocumented fields, hidden parameters, schema abuse, and GraphQL authorization gaps. | `recon` |  |
| `hack` | Entry P0 primary router for HackSkills. Use when the task involves web application testing, API security assessment, recon, vulnerability triage, exploit path planning, or choosing the right next category skill before any deep topic skill. | `hack-skills-routers` |  |
| `hash-attack-techniques` | Hash attack playbook. Use when exploiting length extension, MD5/SHA1 collisions, HMAC timing leaks, birthday attacks, or hash-based proof of work in CTF and authorized testing scenarios. | `crypto-attacks` |  |
| `heap-exploitation` | Heap exploitation playbook. Use when targeting ptmalloc2/glibc heap vulnerabilities including UAF, double free, overflow, off-by-one/null, and leveraging tcache/fastbin/unsortedbin attacks for arbitrary write or code execution. | `binary-exploitation` |  |
| `http-host-header-attacks` | HTTP Host header injection and routing abuse playbook. Use when the application trusts the Host header for generating URLs, routing requests, or access control — enabling password reset poisoning, web cache poisoning, SSRF via routing, and virtual host bypass. | `web-protocol-attacks` |  |
| `http-parameter-pollution` | HTTP Parameter Pollution (HPP): duplicate query/body keys parsed differently by servers, proxies, WAFs, and app frameworks. Use when filters and application layers disagree on which value wins, enabling bypass, SSRF second URL, logic abuse, or CSRF token confusion. | `web-protocol-attacks` |  |
| `http2-specific-attacks` | HTTP/2 protocol-specific attack playbook. Use when the target supports HTTP/2 and you need to exploit binary framing, HPACK compression, h2c upgrade smuggling, pseudo-header injection, stream multiplexing abuse, or H2→H1 downgrade translation flaws. | `web-protocol-attacks` |  |
| `idor-broken-object-authorization` | IDOR and broken object authorization testing playbook. Use when requests expose object identifiers, tenant boundaries, writable fields, or missing object-level authorization checks. | `auth-bypass` |  |
| `injection-checking` | Entry P1 category router for injection testing. Use when routing between XSS, SQLi, SSRF, XXE, SSTI, command injection, and NoSQL injection workflows based on how attacker-controlled input is consumed. | `hack-skills-routers` |  |
| `insecure-source-code-management` | Source control and artifact exposure (.git, .svn, .hg, backups, .env). Use when recon finds VCS paths, 403 on hidden dirs, or backup/config leaks during authorized testing. | `recon` |  |
| `ios-pentesting-tricks` | iOS pentesting playbook. Use when testing iOS applications for keychain extraction, URL scheme hijacking, Universal Links exploitation, runtime manipulation, binary protection analysis, data storage issues, and transport security bypass during authorized mobile security assessments. | `mobile` |  |
| `jndi-injection` | JNDI injection playbook. Use when Java applications perform JNDI lookups with attacker-controlled names, especially via Log4j2, Spring, or any code path reaching InitialContext.lookup(). | `server-side-execution` |  |
| `jwt-oauth-token-attacks` | JWT and OAuth token attack playbook. Use when validating token trust, signing algorithms, key handling, claim abuse, bearer flows, and OAuth account-binding weaknesses. | `auth-bypass` |  |
| `kernel-exploitation` | Linux kernel exploitation playbook. Use when exploiting kernel vulnerabilities (UAF, OOB, race condition, type confusion) for privilege escalation via commit_creds, modprobe_path overwrite, or kernel ROP chains in CTF and real-world scenarios. | `binary-exploitation` |  |
| `kubernetes-pentesting` | Kubernetes penetration testing playbook. Use when targeting Kubernetes clusters via API server, RBAC enumeration, service account abuse, etcd access, Kubelet API, pod escape, cloud-specific metadata, admission webhook bypass, and registry secrets. | `linux-and-post-exploit` |  |
| `lattice-crypto-attacks` | Lattice-based cryptanalysis playbook. Use when attacking RSA via Coppersmith small roots, recovering DSA/ECDSA nonces from bias, solving knapsack problems, or applying LLL/BKZ reduction to cryptographic constructions. | `crypto-attacks` |  |
| `linux-lateral-movement` | Linux lateral movement playbook. Use after gaining initial access to pivot across Linux hosts via SSH hijacking, credential harvesting, internal pivoting, D-Bus exploitation, sudo token reuse, and shared filesystem abuse. | `linux-and-post-exploit` |  |
| `linux-privilege-escalation` | Linux privilege escalation playbook. Use when you have low-privilege shell access and need to escalate to root via SUID/SGID binaries, capabilities, cron abuse, kernel exploits, misconfigurations, or credential harvesting on Linux systems. | `linux-and-post-exploit` |  |
| `linux-security-bypass` | Linux security mechanism bypass playbook. Use when facing restricted bash/rbash, read-only or noexec filesystems, AppArmor, SELinux, seccomp filters, or audit logging that must be evaded during post-exploitation. | `linux-and-post-exploit` |  |
| `llm-prompt-injection` | LLM prompt injection playbook. Use when testing AI/LLM applications for direct injection, indirect injection via RAG/browsing, tool abuse, data exfiltration, MCP security risks, and defense bypass techniques. | `ai-and-supply-chain` |  |
| `macos-process-injection` | macOS process injection playbook. Use when you need to inject code into running or launching macOS processes via dylib hijacking, DYLD environment variables, XPC exploitation, Mach port manipulation, or Electron/Chromium abuse. | `linux-and-post-exploit` |  |
| `macos-security-bypass` | macOS security bypass playbook. Use when targeting macOS endpoints and need to bypass TCC, Gatekeeper, SIP, sandbox, code signing, or entitlement-based protections during authorized red team or pentest engagements. | `linux-and-post-exploit` |  |
| `memory-forensics-volatility` | Memory forensics playbook using Volatility 2/3. Use when analyzing memory dumps for malware analysis, credential extraction, process investigation, code injection detection, and incident response timeline reconstruction. | `forensics-and-misc-recovery` |  |
| `mobile-ssl-pinning-bypass` | Mobile SSL pinning bypass playbook. Use when intercepting HTTPS traffic from mobile applications that implement certificate pinning, public key pinning, or SPKI hash pinning on Android and iOS, including React Native, Flutter, and Xamarin frameworks. | `mobile` |  |
| `network-protocol-attacks` | Network protocol attack playbook. Use when exploiting layer 2/3 protocols including ARP spoofing, LLMNR/NBT-NS/mDNS poisoning, WPAD abuse, DHCPv6 attacks, VLAN hopping, STP manipulation, DNS spoofing, IPv6 attacks, and IDS/IPS evasion. | `linux-and-post-exploit` |  |
| `nosql-injection` | NoSQL injection playbook. Use when MongoDB-style operators, JSON query objects, flexible search filters, or backend query DSLs may allow data or logic abuse. | `web-injection` |  |
| `ntlm-relay-coercion` | NTLM relay and authentication coercion playbook. Use when capturing and relaying NTLM authentication to escalate privileges via SMB, LDAP, HTTP, or MSSQL relay targets, combined with PetitPotam, PrinterBug, and other coercion methods. | `active-directory-and-windows` |  |
| `oauth-oidc-misconfiguration` | OAuth and OIDC misconfiguration testing playbook. Use when reviewing redirect URI handling, state and nonce validation, PKCE, token audience, callback binding, and identity-provider trust flaws. | `auth-bypass` |  |
| `open-redirect` | Open redirect playbook. Use when URL parameters, form actions, or JavaScript sinks control navigation targets and may redirect users to attacker-controlled destinations. | `web-client-attacks` |  |
| `path-traversal-lfi` | Path traversal and LFI playbook. Use when file paths, download endpoints, include operations, archive extraction, or wrapper behavior may expose filesystem control. | `server-side-execution` |  |
| `prototype-pollution` | Prototype pollution testing for JavaScript stacks. Use when user input is merged into objects (query parsers, JSON bodies, deep assign), when configuring libraries via untrusted keys, or when hunting RCE gadgets via polluted Object.prototype in Node or the browser. | `web-client-attacks` |  |
| `prototype-pollution-advanced` | Advanced prototype pollution playbook — server-side RCE, client-side gadgets, filter bypasses, and detection techniques. Companion to ../prototype-pollution/ for basics. Use when you've confirmed pollution and need to escalate to code execution or find framework-specific gadgets. | `web-client-attacks` | `server-side-execution` |
| `race-condition` | Race condition and TOCTOU testing for web apps. Use when testing one-time operations, concurrent HTTP abuse, rate-limit bypass, Turbo Intruder gates, HTTP/2 single-packet attacks, and CWE-362-style synchronization gaps. | `web-client-attacks` |  |
| `recon-and-methodology` | Reconnaissance and methodology playbook. Use when mapping assets, discovering endpoints, fingerprinting technology, and building a structured testing plan for a new target. | `recon` |  |
| `recon-for-sec` | Entry P1 category router for reconnaissance and methodology. Use when mapping scope, discovering assets, fingerprinting technology, building endpoint inventory, and choosing the first high-value security testing path. | `hack-skills-routers` |  |
| `request-smuggling` | HTTP request smuggling and desynchronization testing. Use when front proxies, CDNs, or load balancers disagree with the origin on message framing (Content-Length vs Transfer-Encoding), on HTTP/2→HTTP/1 translation, or when exploring client-side desync via browser fetch pipelines. | `web-protocol-attacks` |  |
| `reverse-shell-techniques` | Reverse shell techniques playbook. Use when establishing remote shells including language one-liners, encrypted shells (OpenSSL/socat/ncat), web shells, PTY upgrades, file transfer methods, PowerShell shells, and Windows payload generation. | `linux-and-post-exploit` | `active-directory-and-windows` |
| `rsa-attack-techniques` | RSA attack playbook for CTF and real-world cryptanalysis. Use when given RSA parameters (n, e, c) and need to recover plaintext by exploiting weak keys, small exponents, shared factors, or padding oracles. | `crypto-attacks` |  |
| `saml-sso-assertion-attacks` | SAML SSO assertion attack playbook. Use when testing signature validation, assertion wrapping, audience restrictions, ACS handling, XML trust boundaries, and enterprise SSO flaws. | `auth-bypass` |  |
| `sandbox-escape-techniques` | Sandbox escape playbook. Use when breaking out of Python sandbox, Lua sandbox, seccomp filter, chroot jail, container/Docker, browser sandbox, or namespace isolation to achieve unrestricted code execution or file access. | `binary-exploitation` |  |
| `smart-contract-vulnerabilities` | Smart contract vulnerability playbook. Use when auditing Solidity/EVM contracts for reentrancy, integer overflow, access control, delegatecall, flash loan, signature replay, and MEV-related attack patterns. | `crypto-attacks` |  |
| `sqli-sql-injection` | SQL injection playbook. Use when input reaches SQL queries, authentication logic, sorting, filtering, reporting, or DB-specific blind and out-of-band execution paths. | `web-injection` |  |
| `ssrf-server-side-request-forgery` | SSRF playbook. Use when the server fetches URLs, resolves hostnames, imports remote content, or can be driven toward internal networks, cloud metadata, or secondary protocols. | `server-side-execution` |  |
| `ssti-server-side-template-injection` | SSTI playbook. Use when template expressions, server-side rendering, preview features, or templating engines may evaluate attacker-controlled content. | `server-side-execution` |  |
| `stack-overflow-and-rop` | Stack overflow and ROP playbook. Use when exploiting buffer overflows to hijack control flow via return address overwrite, ROP chains, ret2libc, ret2csu, ret2dlresolve, or SROP on Linux userland binaries. | `binary-exploitation` |  |
| `steganography-techniques` | Steganography detection and extraction playbook. Use when analyzing images (LSB, PNG chunks, JPEG DCT, EXIF), audio (spectrogram, DTMF), files (polyglots, appended data, ADS), and text (whitespace, zero-width, homoglyphs) for hidden data. | `forensics-and-misc-recovery` |  |
| `subdomain-takeover` | Subdomain takeover detection and exploitation playbook. Use when targets have dangling CNAME/NS/MX records pointing to deprovisioned cloud resources, expired third-party services, or unclaimed SaaS tenants that an attacker can register to serve content under the victim's domain. | `recon` | `web-injection` |
| `symbolic-execution-tools` | Symbolic execution and constraint solving playbook. Use when solving CTF reversing challenges, recovering keys, bypassing checks, or automating binary analysis with angr, Z3, or Unicorn Engine. | `binary-exploitation` |  |
| `symmetric-cipher-attacks` | Symmetric cipher attack playbook. Use when exploiting block cipher mode weaknesses (CBC padding oracle, ECB cut-and-paste, bit flipping), stream cipher key reuse, or meet-in-the-middle attacks. | `crypto-attacks` |  |
| `traffic-analysis-pcap` | Traffic analysis and PCAP forensics playbook. Use when analyzing network captures including Wireshark filters, protocol analysis (HTTP/DNS/FTP/SMTP/USB/WiFi), data extraction, covert channel detection, PCAP repair, TLS decryption, and tshark command-line analysis. | `forensics-and-misc-recovery` |  |
| `tunneling-and-pivoting` | Tunneling and pivoting playbook. Use when establishing network tunnels through compromised hosts including SSH tunneling, Chisel, Ligolo-ng, socat, DNS/ICMP/HTTP tunneling, ProxyChains, and multi-layer pivoting strategies. | `linux-and-post-exploit` |  |
| `type-juggling` | PHP type juggling and weak comparison (`==`) bypass. Use when authentication, HMAC/signature checks, or token validation uses loose equality, numeric coercion, or hash comparisons without strict types — common in legacy PHP and CTF-style code paths. | `auth-bypass` | `web-injection` |
| `unauthorized-access-common-services` | Unauthorized access playbook for common exposed services. Use when Redis, Rsync, PHP-FPM, AJP/Ghostcat, Hadoop YARN, H2 Console, or similar management interfaces are exposed without authentication. | `recon` | `auth-bypass` |
| `upload-insecure-files` | Insecure file upload playbook. Use when testing upload validation, storage paths, processing pipelines, preview behavior, overwrite risks, and upload-to-RCE chains. | `server-side-execution` |  |
| `vm-and-bytecode-reverse` | Custom VM and bytecode reverse engineering playbook. Use when CTF challenges or protected software implement custom virtual machines with proprietary bytecode, dispatcher loops, or maze-style challenges. | `binary-exploitation` |  |
| `waf-bypass-techniques` | WAF bypass methodology and generic evasion techniques. Use when a web application firewall blocks injection payloads (SQLi, XSS, RCE) and you need to craft bypasses using encoding, protocol-level tricks, or WAF-specific weaknesses. | `web-injection` |  |
| `web-cache-deception` | Web cache deception and poisoning playbook. Use when CDN, reverse proxy, or application caching may serve sensitive authenticated content to other users due to path confusion or cache key manipulation. | `web-protocol-attacks` |  |
| `websocket-security` | WebSocket handshake, CSWSH, tooling (wsrepl, ws-harness, Burp), and common flaws. Use when apps use real-time channels, chat, notifications, or WS-backed APIs. | `web-protocol-attacks` |  |
| `windows-av-evasion` | AV/EDR evasion playbook for Windows. Use when bypassing AMSI, ETW, .NET assembly detection, shellcode execution, process injection, API hooking, and signature-based detection on Windows endpoints. | `active-directory-and-windows` |  |
| `windows-lateral-movement` | Windows lateral movement playbook. Use when pivoting between Windows hosts via PsExec, WMI, WinRM, DCOM, RDP, pass-the-hash, overpass-the-hash, or pass-the-ticket techniques. | `active-directory-and-windows` |  |
| `windows-privilege-escalation` | Windows local privilege escalation playbook. Use when you have low-privilege shell access on Windows and need to escalate via token abuse, Potato exploits, service misconfigurations, DLL hijacking, UAC bypass, or registry autoruns. | `active-directory-and-windows` |  |
| `xslt-injection` | XSLT injection testing: processor fingerprinting, XXE and document() SSRF, EXSLT write primitives, PHP/Java/.NET extension RCE surfaces. Use when user-controlled XSLT/stylesheet input or transform endpoints are in scope. | `web-injection` |  |
| `xss-cross-site-scripting` | XSS playbook. Use when user-controlled content reaches HTML, attributes, JavaScript, DOM sinks, uploads, or multi-context rendering paths. | `web-injection` |  |
| `xxe-xml-external-entity` | XXE playbook. Use when XML, SVG, OOXML, SOAP, or parser-driven imports may resolve external entities, files, or internal network resources. | `web-injection` |  |

## Decision Log

One entry per non-obvious close call (per CONTEXT.md D-12 + SPECIFICS bullet on `also_relevant_to` — routine assignments are skipped, only D-09 borderline decisions are logged). The same 10 entries are recorded in `02-CLASSIFICATION.json`'s `skill_metadata` map for machine consumption.

- `type-juggling`: assigned to `auth-bypass` over `web-injection`; reason: the skill's own description literally says "authentication, HMAC/signature checks, or token validation uses loose equality" — the D-09 primary signal points to `auth-bypass` even though the technique is technically a coercion/injection variant.
- `unauthorized-access-common-services`: assigned to `recon` over `auth-bypass`; reason: the skill's description leads with "Use when Redis, Rsync, PHP-FPM... management interfaces are exposed without authentication" — the "exposed" framing points to `recon` (find/enumerate) more than to `auth-bypass` (defeat the auth that's there). Marginal call.
- `subdomain-takeover`: assigned to `recon` over `web-injection`; reason: the description is half enumeration ("Subdomain takeover detection") and half attack ("exploitation playbook"). Description framing leads with detection → `recon`.
- `prototype-pollution-advanced`: assigned to `web-client-attacks` over `server-side-execution`; reason: description: "Advanced prototype pollution playbook — server-side RCE, client-side gadgets". Companion to `prototype-pollution`; keeping both in `web-client-attacks` for cohesion, but the server-side-RCE angle is real.
- `ghost-bits-cast-attack`: assigned to `web-injection` over `server-side-execution`; reason: description is a WAF-bypass meta-technique that enables SQLi + deserialization RCE + webshell + path-traversal + smuggling. Cataloged under `web-injection` because the bypass enables injection primitives; could also live under `server-side-execution` for the deserialization RCE / webshell impact.
- `csv-formula-injection`: assigned to `web-injection` over `server-side-execution`; reason: spreadsheet formula injection can lead to RCE on the client opening the file (DDE, IMPORT*). Treating as `web-injection` because the entry point is web-export/upload; the impact is client-RCE.
- `business-logic-vulnerabilities`: assigned to `web-client-attacks` over `auth-bypass`; reason: description mentions "multi-step authorization gaps" which is auth-bypass-adjacent, but the broader frame is workflow/race/state-machine abuse. `web-client-attacks` better reflects the broader app-behavior framing.
- `reverse-shell-techniques`: assigned to `linux-and-post-exploit` over `active-directory-and-windows`; reason: covers Linux AND Windows reverse-shell payloads (including PowerShell). Linux umbrella is the broader fit; Windows-specific PowerShell content is a meaningful subset.
- `csp-bypass-advanced`: assigned to `web-client-attacks` over `web-injection`; reason: CSP is a browser-enforced policy; bypassing it enables XSS. Keep under `web-client-attacks` (browser policy) over `web-injection` (XSS as injection).
- `dns-rebinding-attacks`: assigned to `web-client-attacks` over `server-side-execution`; reason: description: "When SSRF is not possible server-side but the target has client-side fetch/XHR". The browser-driven angle wins; SSRF angle is the alternate.

Composite borderline (no `skill_metadata` entry — both members already in the same bucket):

- `defi-attack-patterns` + `smart-contract-vulnerabilities`: both assigned to `crypto-attacks` (no concrete alternate bucket). A future `blockchain-attacks` split would be the alternate, but with only 2 candidate members it would violate the D-02 < 5 merge threshold. Folded under the shared "crypto" terminology as the security community uses it. If Plan 02-02 or downstream curation later wants to separate them, the move is a trivial JSON edit (no `skill_metadata` cross-reference recorded because both skills currently share the same bucket assignment).

## Roadmap Success Criteria (Phase 2)

Checking against the 5 success criteria listed in ROADMAP.md §Phase 2:

1. ✓ A classification artifact exists in the repo listing all 102 skills with one-line summaries from each `SKILL.md` — see the Master Table above (102 rows, verbatim `summary` column per D-14).
2. ✓ A final topical group taxonomy is documented with scope + rationale per bucket — see the per-bucket `##` sections above; each has a scope paragraph stating what unifies its members.
3. ✓ Each proposed group's membership is within 8-15 OR explicitly flagged as a catch-all per D-06 OR documented as sized-outside-range with reason per D-02 — see the Summary bucket-overview table; 6 buckets within 8-15, 5 sized-with-reason per D-02, 3 catch-all per D-06.
4. ✓ Misfit skills are explicitly listed with reason tags (`standalone` or `redundant` per D-05) — see the Catch-all section (D-06 reframe: assigned to a catch-all bucket rather than absent from `marketplace.json` for GROUP-04).
5. ✓ Every one of the 102 skills appears exactly once — D-07 invariant verified; total count matches `ls /Users/spencerpresley/code/hack-skills-wip/hack-skills/skills/ | wc -l = 102` and the Master Table above has exactly 102 data rows.

**All 5 success criteria met. Phase 2 unlocks Phase 3.**
