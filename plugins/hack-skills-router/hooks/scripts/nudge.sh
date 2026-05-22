#!/bin/bash
# Source: design spec §5.5 + Phase 1 RESEARCH §Pitfall 3 + CONTEXT.md D-01/D-03/D-07
# UserPromptSubmit hook for hack-skills-router. The matcher field in hooks.json is silently
# ignored by Claude Code 2.1.x (per Phase 1 finding) — actual gating happens here via grep -qiE.
# Non-match behavior: silent exit 0 (D-01). Malformed stdin → empty PROMPT → grep no-match
# → silent exit 0 (graceful — see Pitfall 7).

PROMPT=$(jq -r '.prompt // empty' < /dev/stdin 2>/dev/null)
echo "$PROMPT" | grep -qiE "(XSS|SQLi|SSRF|XXE|IDOR|BOLA|BFLA|CSRF|CORS|RCE|SSTI|LFI|RFI|JWT|OAuth|SAML|OIDC|NTLM|Kerberos|pentest|bug ?bounty|vulnerab|exploit\b|payload|attack surface|recon\b|enumerat|privesc|priv ?esc|reverse shell|lateral movement|burp|nmap|sqlmap|metasploit|gobuster|ffuf|hashcat|mimikatz|bloodhound|CVE-[0-9]{4}-[0-9]+|\.git/|\.env\b|robots\.txt|/etc/passwd|prototype pollution|deserialization|race condition|web cache|request smuggling|introspection|host header|alg[=:]none|JWKS|parameter pollution|type juggling|NoSQL|\bWAF\b)" || exit 0

cat <<'EOF'

=== HACK-SKILLS (security task detected) ===
Before answering:
1. Confirm scope is authorized — if not, refuse.
2. If you haven't already, load Skill(hack-skills-router) for category selection.
3. Surface 2-3 boundary conditions a baseline AI tends to miss for this attack class
   (the router's "expert intuitions" tables cover these — load patterns/expert-intuitions.md
   if the relevant ones aren't in working memory).
============================================
EOF
exit 0
