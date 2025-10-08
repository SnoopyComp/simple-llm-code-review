#!/usr/bin/env bash
set -euo pipefail
source "$PROMPTDIR/_lib.sh"
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
PR_OWNER=$(
  jq -r '
    .repository.owner.login
    // .pull_request.base.repo.owner.login
    // empty
  ' "$GITHUB_EVENT_PATH"
)
PR_REPO=$(
  jq -r '
    .repository.name
    // .pull_request.base.repo.name
    // empty
  ' "$GITHUB_EVENT_PATH"
)

printf '%s' "$PR_TITLE" > "$WORKDIR/pr_title.txt"
printf '%s' "$PR_BODY_RAW" > "$WORKDIR/pr_body_raw.txt"
printf '%s' "$PR_LABELS" > "$WORKDIR/pr_labels.txt"
printf '%s' "$PR_NUMBER" > "$WORKDIR/pr_number.txt"
printf '%s' "$PR_OWNER" > "$WORKDIR/pr_owner.txt"
printf '%s' "$PR_REPO" > "$WORKDIR/pr_repo.txt"

python3 "$PROMPTDIR/clean_md.py" \
    "$WORKDIR/pr_body_raw.txt" \
    "$MAX_BYTES_PR"