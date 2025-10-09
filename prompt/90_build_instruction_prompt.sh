#!/usr/bin/env bash
set -euo pipefail
source "$PROMPTDIR/_lib.sh"

: "${OUT:?OUT required}"
: "${MODEL_COST:?MODEL_COST required}"
: "${REVIEW_DEPTH:?REVIEW_DEPTH required}"
: "${USE_INLINE_COMMENT:?USE_INLINE_COMMENT required}"
: "${LANGUAGE:?LANGUAGE required}"
: "${USE_ISSUE:?USE_ISSUE required}"
: "${USE_REFERENCE:?USE_REFERENCE required}"
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

# --- Select prompt text by DEPTH ---
select_prompt() {
  case "$1" in
    essential)
      cat <<'EOF'
**Goal:** Identify only **critical issues** as quickly as possible.  

Scope of review:
- Bugs that can cause runtime errors
- Security vulnerabilities
- Clear logic flaws
- Risk of data loss
- Incorrect API usage or missing exception handling

⚠️ Ignore performance, readability, or code style issues.  
Focus only on: **"Can this code cause serious failures in production?"**
EOF
      ;;
    balanced)
      cat <<'EOF'
**Goal:** Ensure both **safety and efficiency** of the code.  

Scope of review:
- Bugs that can cause runtime errors
- Security vulnerabilities
- Clear logic flaws
- Risk of data loss
- Incorrect API usage or missing exception handling
- Inefficient operations or algorithms that may hurt performance
- Memory waste or unnecessary computations
- Duplicate code or structural flaws affecting maintainability
- Refactoring opportunities that improve stability and efficiency

⚠️ Do not comment on minor style, naming, or formatting issues.  
Focus on: **“Will this code run reliably while being efficient and maintainable?”**
EOF
      ;;
    thorough)
      cat <<'EOF'
**Goal:** Provide a **comprehensive quality review** of the code.  

Scope of review:
- Bugs that can cause runtime errors
- Security vulnerabilities
- Clear logic flaws
- Risk of data loss
- Incorrect API usage or missing exception handling
- Inefficient operations or algorithms that may hurt performance
- Memory waste or unnecessary computations
- Duplicate code or structural flaws affecting maintainability
- Refactoring opportunities that improve stability and efficiency
- Performance, scalability, and resource efficiency
- Code structure, modularity, and maintainability
- Naming conventions for variables, functions, and classes
- Readability, consistency, and unnecessary complexity
- Documentation and comments
- Adherence to team/industry standards (e.g., Clean Code, PEP8, Google Style)

Focus on: **“Is this code production-ready in terms of correctness, efficiency, readability, and maintainability?”**
EOF
      ;;
  esac
}

# --- High-cost guidance (under ## Instructions) ---
emit_cost_guidance() {
  if [[ "${MODEL_COST,,}" == "high" ]]; then
    cat <<'EOF'
### Resource/Depth Guidance
- Explore the problem **as deeply as necessary**; provide alternatives with clear rationale.
- Treat **token/time budget as lower priority** and conduct a thorough examination.
EOF
    echo
  fi
}

# --- Inline comment policy (under ## Instructions) ---
emit_inline_policy() {
  if [ "$USE_INLINE" = "true" ]; then
    cat <<'EOF'
### Commenting Mode (Inline)
- Prefer **inline comments** for specific issues.
- Review **only code within the diff**; do not comment on unrelated code.
- Publish findings **as PR comments/review only** (no normal assistant messages).
- **One pending review per PR**. If one exists or you see “you can only have one pending review,” reuse it via 'add_comment_to_pending_review'.
- When calling **'mcp__github__add_comment_to_pending_review'**:
  - Always include 'subjectType', 'path', 'body'.
  - If 'subjectType="LINE"', also include 'line' (**PR diff** line) and 'side' ('"RIGHT"' by default; use '"LEFT"' only to target the old side).
  - For newly added files/lines, default to 'subjectType="LINE"' and 'side="RIGHT"'.
  - If inline placement fails once (invalid line/side/path), retry as 'subjectType="FILE"' (no line/side). If that also fails, post **a single summary review comment** at submit.
- Fallback order: **LINE → FILE → summary-only**.
- Submit **once at the end** ('COMMENT' or 'REQUEST_CHANGES').

EOF
  else
    cat <<'EOF'
### Commenting Mode (No Inline)
 - **Do not use inline comments.**
 - Review **only code within the diff**. Do not comment on unrelated code.
 - Submit all findings as a **single consolidated review comment**.
 - Do **not** output findings as a normal message; publish them as **PR review/comment** only.
 EOF
EOF
  fi
  echo
}

# --- Write prompt file ---
{
  echo "# LLM Code Review Prompt"
  echo
  echo "## Role"
  echo "You are a senior software engineer acting as a code reviewer."
  echo "Follow the instructions below to perform the code review."
  echo "$scope_line"
  echo "Use $LANGUAGE in all review comments."
  echo

  if [ -n "$REVIEW_INSTRUCTIONS" ]; then
    echo "## User Instructions"
    echo "User Instructions override any conflicting guidance below."
    printf '%s\n\n' "$REVIEW_INSTRUCTIONS"
  fi

  echo "## Instructions"
  echo "If the PR includes requested review points, **prioritize those points over general checks**."
  echo "Do **not** summarize or restate code; provide only problems, risks, or actionable suggestions."
  echo "Review **only code within the diff**. Do not comment on unrelated code."
  echo "Quote a minimal snippet, state the issue, explain why it matters, and give a concrete, directional fix suggestion."
  echo "Avoid vague comments; provide clear and precise feedback."
  echo
  select_prompt "$DEPTH"
  echo

  emit_cost_guidance
  emit_inline_policy

} > "$OUT"
