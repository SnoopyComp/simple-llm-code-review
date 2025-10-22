#!/usr/bin/env bash
set -euo pipefail
source "$PROMPTDIR/_lib.sh"
: "${WORKDIR:?WORKDIR required}"
: "${MAX_BYTES_ISSUE:?MAX_BYTES_ISSUE required}"

ISSUE_LIST="$WORKDIR/issue_nums.txt"
OUT_RAW="$WORKDIR/issues_raw.txt"

if [ ! -s "$ISSUE_LIST" ]; then
    # no issues
    exit 0
fi

: > "$OUT_RAW"

while IFS= read -r issue_num; do
    [ -z "$issue_num" ] && continue

    if issue_json=$(gh issue view "$issue_num" \
             --repo "$GITHUB_REPOSITORY"\
             --json number,title,body,labels 2>/dev/null); then
        num=$(jq -r '.number' <<< "$issue_json")
        title=$(jq -r '.title // ""' <<< "$issue_json")
        body_raw=$(jq -r '.body // ""' <<< "$issue_json")
        labels=$(
            jq -r '
                ( .labels.nodes? // .labels // [] )
                | map( if type=="object" then (.name // "") else . end )
                | map(select(. != ""))     # drop empties
                | unique                   # de-dup
                | join(", ")
            ' <<<"$issue_json"
        )
    else
        num="$issue_num"; title=""; body_raw=""; labels=""
    fi
    {
        echo "Issue title: $title"
        echo "Labels: $labels"
        echo "Body:"
        [ -n "$body_raw" ] && printf '\n```%s\n```\n' "$body_raw" || echo "_(empty body)_"
        echo "---"
        echo
    } >> "$OUT_RAW" 
done < "$ISSUE_LIST"

python3 "$PROMPTDIR/clean_md.py" \
    "$OUT_RAW" \
    "$MAX_BYTES_ISSUE"