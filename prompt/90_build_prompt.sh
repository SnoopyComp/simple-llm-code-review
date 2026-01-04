#!/usr/bin/env bash
set -euo pipefail
source "$PROMPTDIR/_lib.sh"
source "$PROMPTDIR/91_instruction.sh"
source "$PROMPTDIR/92_review_depth.sh"
source "$PROMPTDIR/93_2_inline_comment_prompt.sh"
source "$PROMPTDIR/93_1_overall_review.sh"
source "$PROMPTDIR/94_model_cost_prompt.sh"

: "${OUT:?OUT required}"
: "${MODEL_COST:?MODEL_COST required}"
: "${REVIEW_DEPTH:?REVIEW_DEPTH required}"
: "${USE_INLINE_COMMENT:?USE_INLINE_COMMENT required}"
: "${LANGUAGE:?LANGUAGE required}"
: "${USE_ISSUE:?USE_ISSUE required}"
: "${USE_REFERENCE:?USE_REFERENCE required}"
: "${MAX_TURNS:= required}"
: "${REVIEW_INSTRUCTIONS:=}"

use_issue="${USE_ISSUE,,}"
use_ref="${USE_REFERENCE,,}"

scope_line="Use the PR details included below."
if [[ "$use_issue" == "true" && "$use_ref" == "true" ]]; then
  scope_line="Use the PR details, the linked issue(s), and the reference files included below."
elif [[ "$use_issue" == "true" && "$use_ref" != "true" ]]; then
  scope_line="Use the PR details and the linked issue(s) included below."
elif [[ "$use_issue" != "true" && "$use_ref" == "true" ]]; then
  scope_line="Use the PR details and the reference files included below."
fi

# --- Normalize REVIEW_DEPTH & map aliases ---
depth_raw="$REVIEW_DEPTH"
depth_norm="${depth_raw,,}"  # lowercase

case "$depth_norm" in
  essential|min|minimal|critical|crit|ess)
    DEPTH="essential"
    ;;
  thorough|full|comprehensive|deep|max)
    DEPTH="thorough"
    ;;
  balanced|standard|middle|medium|mid|default|"")
    DEPTH="balanced"
    ;;
  *)
    DEPTH="balanced"
    ;;
esac

# --- Normalize USE_INLINE_COMMENT -> USE_INLINE ---
uic_norm="${USE_INLINE_COMMENT,,}"
if [[ "$uic_norm" == "true" || "$uic_norm" == "1" || "$uic_norm" == "yes" ]]; then
  USE_INLINE="true"
else
  USE_INLINE="false"
fi

# --- Write prompt file ---
{
  echo
  echo "# LLM Code Review Prompt"
  echo
  echo "## Role"
  echo "You are a senior software engineer acting as a code reviewer."
  echo "Follow the instructions below to perform the code review."
  echo "$scope_line"
  echo "Use $LANGUAGE in all review comments."
  echo
  common_instructions

  if [ -n "$REVIEW_INSTRUCTIONS" ]; then
    echo "## User Instructions"
    echo "User Instructions override any conflicting guidance below."
    printf '%s\n\n' "$REVIEW_INSTRUCTIONS"
  fi

  echo
  select_prompt "$DEPTH"
  echo

  emit_cost_guidance "$MODEL_COST"
  
  overall_review
  emit_inline_policy "$USE_INLINE_COMMENT" $MAX_TURNS

} > "$OUT"