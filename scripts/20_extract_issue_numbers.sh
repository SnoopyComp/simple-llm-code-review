#!/usr/bin/env bash
set -euo pipefail
source "$GITHUB_ACTION_PATH/scripts/_lib.sh"
: "${WORKDIR:?WORKDIR required}"
BODY="$WORKDIR/pr_body_clean.txt"
[ -f "$BODY" ] || die "Missing $BODY"

nums=()

mapfile -t nums < <(grep -Eo '#[0-9]+' "$BODY" || true)

if ((${#nums[@]})); then
  mapfile -t nums < <(
    printf '%s\n' "${nums[@]}" \
      | tr -d '#' \
      | awk '!seen[$0]++'
  )
fi

: > "$WORKDIR/issue_nums.txt"
for n in "${nums[@]}"; do
    [ -n "$n" ] && echo "$n" >> "$WORKDIR/issue_nums.txt"
done

found=false
if ((${#nums[@]})); then
  found=true
fi
echo "found=$found" >> "$GITHUB_OUTPUT"