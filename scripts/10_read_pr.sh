#!/usr/bin/env bash
set -euo pipefail
source "$GITHUB_ACTION_PATH/scripts/_lib.sh"
: "${WORKDIR:?WORKDIR required}"
: "${MAX_BYTES_PR:?MAX_BYTES_PR required}"
ensure_dir "$WORKDIR"

PR_TITLE=$(jq -r '.pull_request.title // ""' "$GITHUB_EVENT_PATH")
PR_BODY_RAW=$(jq -r '.pull_request.body // ""' "$GITHUB_EVENT_PATH")
PR_NUMBER=$(jq -r '.pull_request.number // empty' "$GITHUB_EVENT_PATH")
PR_LABELS=$(
  jq -r '
    ( .pull_request.labels // [] )
    | ( if type=="object" and has("nodes") then .nodes else . end )
    | map( if type=="object" then (.name // empty) else . end )
    | map(select(. != "")) | unique | join(", ")
  ' "$GITHUB_EVENT_PATH"
)
[ -z "${PR_NUMBER:-}" ] && die "No pull_request context. Run on pull_request events."


printf '%s' "$PR_TITLE" > "$WORKDIR/pr_title.txt"
printf '%s' "$PR_BODY_RAW" > "$WORKDIR/pr_body_raw.txt"
printf '%s' "$PR_LABELS" > "$WORKDIR/pr_labels.txt"
printf '%s' "$PR_NUMBER" > "$WORKDIR/pr_number.txt"

python3 "$GITHUB_ACTION_PATH/scripts/clean_md.py" \
    "$WORKDIR/pr_body_raw.txt" \
    "$MAX_BYTES_PR"