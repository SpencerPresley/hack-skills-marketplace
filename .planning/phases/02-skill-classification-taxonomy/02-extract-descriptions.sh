#!/usr/bin/env bash
# 02-extract-descriptions.sh
#
# Purpose
#   Extract the verbatim YAML-frontmatter `description` field from every
#   SKILL.md under the upstream yaklang/hack-skills clone and emit a TSV of
#   (skill-name, unfolded-description) pairs to stdout. This is the canonical
#   Phase 2 extraction tool consumed by .first-pass-classification.md.
#
# Source path (read-only, source-immutability per PROJECT.md)
#   /Users/spencerpresley/code/hack-skills-wip/hack-skills/skills/
#   Each subdirectory contains a SKILL.md whose frontmatter follows the shape:
#     ---
#     name: <slug>
#     description: >-
#       <one or more indented continuation lines>
#     ---
#   The folded-scalar form (`>-`) means continuation lines are joined with a
#   single space and the trailing newline is stripped. We replicate that join
#   behavior so the emitted text reads as one logical sentence per skill.
#
# Output format
#   One TSV row per skill, written to stdout. Two tab-separated fields:
#     <skill-name>\t<unfolded-verbatim-description>
#   Row count invariant: exactly 102 rows (matches the upstream directory
#   count). Script exits non-zero if the row count diverges.
#
# Sample row (verbatim)
#   401-403-bypass-techniques\t401/403 bypass playbook. Use when encountering access-denied responses on admin panels, API endpoints, or restricted paths. Covers path manipulation, HTTP method tampering, header injection, protocol downgrade, and automated bypass tools.
#
# Source-immutability invariant
#   The script reads from SOURCE_ROOT and writes ONLY to stdout. It never
#   redirects, writes, copies, or otherwise mutates anything under
#   SOURCE_ROOT. Outputs are consumed by piping into .planning/-tree files.

set -euo pipefail

SOURCE_ROOT="/Users/spencerpresley/code/hack-skills-wip/hack-skills/skills"

if [ ! -d "$SOURCE_ROOT" ]; then
  echo "FATAL: source directory not found: $SOURCE_ROOT" >&2
  exit 1
fi

EXPECTED_COUNT=$(find "$SOURCE_ROOT" -mindepth 1 -maxdepth 1 -type d | wc -l | tr -d ' ')

row_count=0
while IFS= read -r -d '' skill_dir; do
  skill_name=$(basename "$skill_dir")
  skill_md="$skill_dir/SKILL.md"
  if [ ! -f "$skill_md" ]; then
    echo "FATAL: missing SKILL.md in $skill_dir" >&2
    exit 1
  fi

  # awk pipeline (folded YAML scalar extractor):
  #   - Track frontmatter via the `---` fences (flag 1 = inside frontmatter).
  #   - When `description:` is seen, start capturing.
  #   - Continuation lines are any indented line that does NOT match a new
  #     top-level key (`^[a-z_]+:`) and is still inside the frontmatter block.
  #   - Stop capture on the closing `---` or the next top-level key.
  description=$(awk '
    BEGIN { flag = 0; cap = 0 }
    /^---$/ {
      if (flag == 0) { flag = 1; next }
      else { exit }
    }
    flag == 1 && cap == 0 && /^description:[[:space:]]*>-?[[:space:]]*$/ {
      cap = 1
      next
    }
    flag == 1 && cap == 0 && /^description:[[:space:]]+/ {
      # Plain-scalar form (no `>-` folding) — single-line description on key line.
      sub(/^description:[[:space:]]+/, "", $0)
      printf "%s", $0
      cap = 2
      next
    }
    flag == 1 && cap == 1 && /^[a-z_][a-zA-Z0-9_-]*:[[:space:]]/ {
      # Hit next top-level key; folded capture ends.
      exit
    }
    flag == 1 && cap == 1 && /^[[:space:]]+[^[:space:]]/ {
      # Continuation line: strip leading whitespace, emit with a separating space.
      sub(/^[[:space:]]+/, "", $0)
      if (first == 0) {
        printf "%s", $0
        first = 1
      } else {
        printf " %s", $0
      }
    }
  ' "$skill_md")

  # Collapse runs of internal whitespace, trim leading/trailing whitespace.
  # `tr -s` collapses repeated whitespace; sed trims edges.
  description=$(printf "%s" "$description" | tr -s '[:space:]' ' ' | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')

  if [ -z "$description" ]; then
    echo "FATAL: empty description extracted for $skill_name" >&2
    exit 1
  fi

  printf "%s\t%s\n" "$skill_name" "$description"
  row_count=$((row_count + 1))
done < <(find "$SOURCE_ROOT" -mindepth 1 -maxdepth 1 -type d -print0 | sort -z)

if [ "$row_count" -ne "$EXPECTED_COUNT" ]; then
  echo "FATAL: extracted $row_count rows, expected $EXPECTED_COUNT" >&2
  exit 1
fi

if [ "$row_count" -ne 102 ]; then
  echo "FATAL: extracted $row_count rows, Phase 2 invariant requires exactly 102" >&2
  exit 1
fi
