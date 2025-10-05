#!/usr/bin/env bash
set -euo pipefail

PR_BODY=""
if [[ -f "${GITHUB_EVENT_PATH:-}" ]]; then
  PR_BODY="$(jq -r '.pull_request.body // ""' "$GITHUB_EVENT_PATH" 2>/dev/null || echo "")"
fi

if printf '%s' "$PR_BODY" | grep -qi '@claude'; then
  echo "run=true" >> "$GITHUB_OUTPUT"
else
  echo "run=false" >> "$GITHUB_OUTPUT"
fi
