#!/usr/bin/env bash
set -euo pipefail
source "$PROMPTDIR/_lib.sh"
: "${WORKDIR:?WORKDIR required}"
: "${OUT:?OUT required}"
: "${USE_ISSUE:?USE_ISSUE}"
: "${USE_REFERENCE:?USE_REFERENCE}"

use_issue="${USE_ISSUE,,}"
use_ref="${USE_REFERENCE,,}"

PR_TITLE=$(cat "$WORKDIR/pr_title.txt")
PR_NUMBER=$(cat "$WORKDIR/pr_number.txt")
PR_BODY_CLEAN=$(cat "$WORKDIR/pr_body_clean.txt")
PR_LABELS=$(cat "$WORKDIR/pr_labels.txt")
PR_OWNER=$(cat "$WORKDIR/pr_owner.txt" 2>/dev/null || echo "")
PR_REPO=$(cat "$WORKDIR/pr_repo.txt" 2>/dev/null || echo "")

{
  echo "## Context"

  if [[ "$use_issue" == "true" ]]; then
    echo
    echo "### Associated Issues"
    if [ -s "$WORKDIR/issues_clean.txt" ]; then
      cat "$WORKDIR/issues_clean.txt"
    else
      echo "_(no issue body fetched)_"
    fi
  fi

  echo
  echo "### PR"
  echo "Title: $PR_TITLE"
  echo "Number: $PR_NUMBER"
  echo "Owner: ${PR_OWNER:-_unknown_}"
  echo "Repo: ${PR_REPO:-_unknown_}"
  echo "Labels: ${PR_LABELS:-_none_}"
  echo "PR body:"
  printf '\n```%s\n```\n' "$PR_BODY_CLEAN"

  if [[ "$use_ref" == "true" ]]; then
    echo
    echo "### Reference files"
    if [ -s "$WORKDIR/refs.txt" ]; then
      cat "$WORKDIR/refs.txt"
    else
      echo "_(no reference files listed)_"
    fi
  fi
} > "$OUT"
