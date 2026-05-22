# Phase 3 UAT Evidence

**Tested:** 2026-05-22
**Tester:** SpencerPresley
**claude CLI version:** 2.1.148 (Claude Code)

## Setup

- Cache refresh (Plan 02 Task 1): PASS
  - `claude plugin uninstall hack-skills-router` → exit 0 (successfully uninstalled)
  - `claude plugin install hack-skills-router@hack-skills-marketplace` → exit 0 (successfully installed)
  - `claude plugin details hack-skills-router` shows `Skills (1)  hack-skills-router` + `Hooks (2)  SessionStart, UserPromptSubmit`
- Cache location: `~/.claude/plugins/cache/hack-skills-marketplace/hack-skills-router/0.1.0/`
- Cache content sanity (all 6 checks PASS):
  - `grep -c 'security task detected' nudge.sh` = 1
  - `grep -c 'HACK-SKILLS SESSION CONTEXT' session-start.sh` = 1
  - `grep -in 'stub|placeholder|phase 1' *.sh` = no matches (STUB markers absent)
  - `jq -r '.hooks.UserPromptSubmit[0].matcher' hooks.json | wc -c` = 523 chars (long regex; not Phase 1 'XSS' placeholder)
  - `diff cache↔working-tree session-start.sh` = byte-identical
  - `diff cache↔working-tree nudge.sh` = byte-identical
  - `diff cache↔working-tree hooks.json` = byte-identical
- Cache content byte-equal to working tree: PASS

## SessionStart (Option B fresh `claude` invocation)

Procedure: Open a separate terminal, run `claude`, in the fresh session submit:
> What did you receive at session start? Does it reference any operating model or expert intuitions?

Claude response (paste first 2-3 paragraphs):
<response>

Markers observed (check all that apply):
- [ ] References "trust model" or "authorized targets"
- [ ] References "operating model" or "3-step"
- [ ] References "expert intuitions" or "8 intuitions" or specific intuition by content
- [ ] References "HACK-SKILLS SESSION CONTEXT" banner
- [ ] References "Skill(hack-skills-router)" or "load the router"

Verdict: PASS / FAIL / INCONCLUSIVE
Notes: <free-form>

## Positive prompts (6 — should fire nudge)

### UAT-POS-01 — XSS trigger
Prompt: How do I test for XSS in a search box?
Claude response (first 2-3 paragraphs):
<response>
Nudge markers observed (check all that apply):
- [ ] "scope is authorized" / "authorization context" / "is this in scope?"
- [ ] "Skill(hack-skills-router)" / "load the router" / "router skill"
- [ ] "expert intuitions" / "boundary conditions" / "patterns/expert-intuitions.md"
- [ ] Other (specify): ___
Verdict: PASS / FAIL / INCONCLUSIVE
Notes:

### UAT-POS-02 — SQLi + payload trigger
Prompt: What's a SQLi payload for a login form?
Claude response:
Markers observed:
Verdict:
Notes:

### UAT-POS-03 — JWT + alg[=:]none trigger (validates D-02 addition)
Prompt: How do I attack a JWT with alg=none confusion?
Claude response:
Markers observed:
Verdict:
Notes:

### UAT-POS-04 — CVE pattern trigger
Prompt: Trying to find CVE-2024-3094 on my target
Claude response:
Markers observed:
Verdict:
Notes:

### UAT-POS-05 — \.env\b trigger
Prompt: Found a .env exposed in webroot — what next?
Claude response:
Markers observed:
Verdict:
Notes:

### UAT-POS-06 — IDOR trigger (validates intuition #4 BOLA/IDOR relevance)
Prompt: Test for IDOR by switching session cookie from user A to user B
Claude response:
Markers observed:
Verdict:
Notes:

## Negative prompts (4 — should NOT fire nudge)

### UAT-NEG-01 — weather
Prompt: What's the weather?
Claude response:
Nudge markers observed (expect: NONE):
Verdict: PASS (if no markers) / FAIL (if any markers present) / INCONCLUSIVE
Notes:

### UAT-NEG-02 — refactor helper
Prompt: Refactor this helper function.
Claude response:
Nudge markers observed:
Verdict:
Notes:

### UAT-NEG-03 — Promise.all
Prompt: Explain Promise.all.
Claude response:
Nudge markers observed:
Verdict:
Notes:

### UAT-NEG-04 — file upload refactor (validates D-02 EXCLUSION)
Prompt: Help me refactor the file upload component to use streaming
Claude response:
Nudge markers observed (expect: NONE — confirms file upload correctly excluded):
Verdict:
Notes:

## Summary

- SessionStart: PASS / FAIL
- Positive prompts: X/6 PASS, Y/6 FAIL, Z/6 INCONCLUSIVE  (ROADMAP minimum: 5/6 PASS)
- Negative prompts: X/4 PASS, Y/4 FAIL, Z/4 INCONCLUSIVE  (ROADMAP minimum: 3/4 PASS)
- HOOKS-01 (SessionStart): PASS / FAIL
- HOOKS-02 (UserPromptSubmit fires on security): PASS / FAIL
- HOOKS-03 (UserPromptSubmit silent on non-security): PASS / FAIL
- HOOKS-04 (timeouts, exit 0): PASS / FAIL — observed no timeout errors / errors in claude debug if checked

## Issues / Notes

<free-form>
