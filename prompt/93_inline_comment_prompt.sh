#!/usr/bin/env bash

emit_inline_policy() {
  if [ "$1" = "true" ]; then
    cat <<'EOF'
### Commenting Mode (Inline)
- **Always prefer range comments over single-line comments.**  
  Use a range whenever the issue spans multiple lines or a logical block.  
  Single-line comments are allowed only when the issue clearly affects a single line.
- Prefer inline comments for specific issues; comment only on code within the diff.
- **NEVER** include summaries, praise, or restate code. Each comment must report a problem/risk or give a concrete fix suggestion (why it matters + how to fix).
- Publish findings **as PR comments/review only** (no normal assistant messages).
- **One pending review per PR**. If one exists or you see “you can only have one pending review,” reuse it via 'add_comment_to_pending_review'.
- When calling **'mcp__github__add_comment_to_pending_review'**:
  - Always include 'subjectType', 'path', 'body'.
  - Prefer 'subjectType="LINE"' then "FILE"
  - If 'subjectType="LINE"', also include 'line' (**PR diff** line) and 'side' ('"RIGHT"' by default; use '"LEFT"' only to target the old side).
  - For newly added files/lines, default to 'subjectType="LINE"' and 'side="RIGHT"'.
  - For **range comments**, also include:
  - `startLine`: **start line** of the affected range.
  - `startSide`: `"RIGHT"` or `"LEFT"` (matching the start).
  - Together, `startLine/startSide` define the beginning and `line/side` define the end of the range.
- Placement failure policy (no summary fallback): if inline placement fails once (invalid line/side/path), retry once by snapping to the nearest changed line in the same hunk; if it still fails, skip that comment and continue.
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