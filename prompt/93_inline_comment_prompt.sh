#!/usr/bin/env bash

emit_inline_policy() {
  max_reviews=$(( $2 - 6 ))
  if [ "$1" = "true" ]; then
    cat <<EOF
### Commenting Mode (Inline)
- **One pending review per PR**. If one exists or you see “you can only have one pending review,” reuse it via 'mcp__github__add_comment_to_pending_review'.
- **Always prefer range comments over single-line comments when using 'mcp__github__add_comment_to_pending_review'.(Never use 'mcp__github_inline_comment__create_inline_comment')**  
    Use a range whenever the issue spans multiple lines or a logical block.  
    Single-line comments are allowed only when the issue clearly affects a single line.
- **NEVER** include summaries, praise, or restate code. Each comment must report a problem/risk or give a concrete fix suggestion (why it matters + how to fix).
- When calling **'mcp__github__add_comment_to_pending_review'**:
  - Always include 'subjectType', 'path', 'body'.
  - Prefer 'subjectType="LINE"' then "FILE"
  - If 'subjectType' is "LINE", include 'line' (the target line to comment on) and 'side' ("RIGHT" by default; use "LEFT" only for the old side).  
    - For **single-line comments**, set 'line' to the exact line where the issue occurs.  
    - For **range comments**, set 'line' approximately **2 lines below** the last affected line to improve readability.
  - For **range comments**, also include 'startLine'(start line of the affected range).
- Placement failure policy (no summary fallback): if inline placement fails once (invalid line/side/path), retry once by snapping to the nearest changed line in the same hunk; if it still fails, skip that comment and continue.
- Limit the total number of inline comments to ${max_reviews} per review. If more than n issues are found, prioritize the most critical or representative ones and omit the rest.
- Always submit at the end via 'mcp__github__submit_pending_pull_request_review' with event: "COMMENT" and a brief body (e.g., “Automated review”). Submit even if zero comments were ultimately placed.

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