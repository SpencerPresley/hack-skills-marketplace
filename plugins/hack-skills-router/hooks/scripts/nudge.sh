#!/bin/bash
# STUB — Phase 1 mechanism spike. Real payload + in-script regex filtering lands in Phase 3.
# (UserPromptSubmit matcher in hooks.json is silently ignored by Claude Code 2.1.x —
#  this hook fires on EVERY prompt. That is INTENTIONAL for Phase 1 spike verification.
#  Phase 3 will read $PROMPT from stdin JSON and grep for the security-context regex here.)
cat <<'EOF'

=== HACK-SKILLS NUDGE (STUB) ===
[Phase 1 stub] UserPromptSubmit hook fired.
Real content + filtering land in Phase 3.
=================================

EOF
exit 0
