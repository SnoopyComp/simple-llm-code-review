#!/usr/bin/env bash
set -euo pipefail

COST="${COST:-middle}"                     
DEPTH_RAW="${REVIEW_DEPTH:-balanced}"  
DEPTH="${DEPTH_RAW,,}"

MODEL_HIGH="--model claude-sonnet-4-5-20250929"
MODEL_MIDDLE=""
MODEL_LOW="--model claude-3-5-haiku-20241022"

case "$DEPTH" in
  essential) base_turns=4 ;;
  balanced)  base_turns=6 ;;
  thorough)  base_turns=8 ;;
  *)         base_turns=6 ; DEPTH="balanced" ;;
esac

case "$COST" in
  low)     max_turns="$base_turns" ;; 
  high)    max_turns=$(( base_turns + 4 )) ;;                            
  middle)  max_turns=$(( base_turns + 2 )) ;;
  *)       max_turns=$(( base_turns + 2 )); COST="middle" ;;
esac
if [[ -n "${MAX_TURNS_INPUT:-}" && "${MAX_TURNS_INPUT}" =~ ^[0-9]+$ ]]; then
  max_turns="$MAX_TURNS_INPUT"
fi
(( max_turns<4 )) && max_turns=4
(( max_turns>12 )) && max_turns=12

case "$COST" in
  high)   model="$MODEL_HIGH" ;;
  middle) model="$MODEL_MIDDLE" ;;
  low)    model="$MODEL_LOW" ;;
esac

MODEL_TOOLS_CSV_DEFAULT="mcp__github__get_pull_request,mcp__github__get_pull_request_files,mcp__github__get_pull_request_diff,mcp__github__create_pending_pull_request_review,mcp__github__add_comment_to_pending_review,mcp__github__submit_pending_pull_request_review,mcp__github_inline_comment__create_inline_comment,mcp__github_comment__create_comment,View,GlobTool,GrepTool"
MODEL_TOOLS_CSV="${MODEL_TOOLS_CSV:-$MODEL_TOOLS_CSV_DEFAULT}"

{
  echo "model=$model"
  echo "max_turns=$max_turns"
  echo "model_tools=$MODEL_TOOLS_CSV"
} >> "$GITHUB_OUTPUT"