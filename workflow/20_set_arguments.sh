#!/usr/bin/env bash
set -euo pipefail

COST="${COST:-middle}"                     
DEPTH_RAW="${REVIEW_DEPTH:-balanced}"  
DEPTH="${DEPTH_RAW,,}"
USE_INLINE_COMMENT="${USE_INLINE_COMMENT:-true}"

MODEL_HIGH="--model claude-sonnet-4-5-20250929"
MODEL_MIDDLE=""
MODEL_LOW="--model claude-haiku-4-5-20251001"

MODEL_TOOLS_LIST=(
  mcp__github__get_me
  mcp__github__get_pull_request
  mcp__github__get_pull_request_files
  mcp__github__get_pull_request_diff
  mcp__github__get_pull_request_reviews
  mcp__github__delete_pending_pull_request_review
  mcp__github__create_pending_pull_request_review
  mcp__github__add_comment_to_pending_review
  mcp__github__submit_pending_pull_request_review
  mcp__github_inline_comment__create_inline_comment
  mcp__github_comment__create_comment
  View
  GlobTool
  GrepTool
)

case "$DEPTH" in
  essential) base_turns=5 ;;
  balanced)  base_turns=8 ;;
  thorough)  base_turns=10 ;;
  *)         base_turns=8 ; DEPTH="balanced" ;;
esac

case "$COST" in
  low)     max_turns=$(( base_turns + 3 )) ;; 
  high)    max_turns=$(( base_turns + 2 )) ;;                            
  middle)  max_turns="$base_turns" ;;
  *)       max_turns="$base_turns"; COST="middle" ;;
esac
if [[ -n "${MAX_TURNS_INPUT:-}" && "${MAX_TURNS_INPUT}" =~ ^[0-9]+$ ]]; then
  max_turns="$MAX_TURNS_INPUT"
fi
(( max_turns<4 )) && max_turns=4
(( max_turns>12 )) && max_turns=12

if [[ "$USE_INLINE_COMMENT" = "true" ]]; then
  max_turns=$(( max_turns + 2 ))
fi


case "$COST" in
  high)   model="$MODEL_HIGH" ;;
  middle) model="$MODEL_MIDDLE" ;;
  low)    model="$MODEL_LOW" ;;
esac

MODEL_TOOLS_CSV_DEFAULT="$(IFS=,; printf '%s' "${MODEL_TOOLS_LIST[*]}")"
MODEL_TOOLS_CSV="${MODEL_TOOLS_CSV:-$MODEL_TOOLS_CSV_DEFAULT}"

{
  echo "model=$model"
  echo "max_turns=$max_turns"
  echo "model_tools=$MODEL_TOOLS_CSV"
} >> "$GITHUB_OUTPUT"