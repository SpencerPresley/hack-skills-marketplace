---
plan: 01-03
phase: 01-schema-verification
status: completed-via-research-detour
completed: 2026-05-22
supersedes_via: 01-VERIFICATION.md
---

# Plan 01-03 Summary: VERIFY-03 Cache Evidence

## What this plan was originally for

Install both `hack-skills-recon` and `hack-skills-auth-bypass` plugins concurrently (the D-10 explicit teardown exception) and capture the cache-layout evidence required to answer VERIFY-03: do multiple plugin entries sharing the same `yaklang/hack-skills` source produce separate cache entries without collision?

## What actually happened

During Plan 01-02's research detour (see `01-02-SUMMARY.md`), both plugins ended up installed concurrently as part of validating the `git-subdir` fix. VERIFY-03's evidence — two parallel cache subdirs under `~/.claude/plugins/cache/hack-skills-marketplace/<plugin-name>/c6f732befcae-32c1cf49/`, both enabling cleanly, no collision — was captured incidentally during that validation.

The result is recorded in `01-VERIFICATION.md` §VERIFY-03, which includes:
- The cache tree (`find -maxdepth 3 -type d`)
- The note that both plugins share the same `<sha>-<path-hash>` version token because they sparse-clone the same upstream `skills/` subdir at the same SHA — this is NOT a collision (parent dirs partition by plugin name)
- The disk-cost note (each plugin's cache materializes all 102 upstream skill subdirs; at ~8 groups in Phase 3 expect ~8× duplication of the `skills/` directory in the cache — acceptable per PROJECT.md "storage is small for a text-only repo")
- The concurrent-enable check (`claude plugin list` shows both enabled simultaneously, no errors)

## Files modified or created

None directly attributable to this plan. Cache evidence is documented in `01-VERIFICATION.md` and `.task01-evidence-after-fix.txt`.

## Outstanding items: NONE
