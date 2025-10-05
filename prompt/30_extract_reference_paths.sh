#!/usr/bin/env bash
set -euo pipefail
source "$PROMPTDIR/_lib.sh"
: "${WORKDIR:?WORKDIR required}"

PR_BODY_FILE="$WORKDIR/pr_body_raw.txt"
[ -f "$PR_BODY_FILE" ] || die "Missing PR body file"

: > "$WORKDIR/refs_path.txt"

python3 "$PROMPTDIR/parse_reference_paths.py" "$PR_BODY_FILE" > "$WORKDIR/refs_path.txt" || true

mapfile -t refs < "$WORKDIR/refs_path.txt" || true

echo "found=$([ "${#refs[@]}" -gt 0 ] && echo true || echo false)" >> "$GITHUB_OUTPUT"
