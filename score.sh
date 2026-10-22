#!/usr/bin/env bash
# Score the project, write both forms of the badge and expose the score and
# the grade as outputs.
set -euo pipefail

mkdir -p "$KM_BADGE_DIR"
# The SVG to commit or serve as is, the JSON for a shields.io endpoint badge.
summary=$(km score "$KM_PATH" --format short --badge "$KM_BADGE_DIR/km-score.svg")
km score "$KM_PATH" --format terse --badge "$KM_BADGE_DIR/km-score.json" >/dev/null

# The short format reads "score s:91.4 g:A files:..."
score=$(sed -E 's/.* s:([0-9.]+) .*/\1/' <<<"$summary")
grade=$(sed -E 's/.* g:([^ ]+) .*/\1/' <<<"$summary")
{
  echo "score=$score"
  echo "grade=$grade"
  echo "badge-dir=$KM_BADGE_DIR"
} >> "$GITHUB_OUTPUT"
echo "### km score: $grade ($score)" >> "$GITHUB_STEP_SUMMARY"
echo "$summary"
