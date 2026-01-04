#!/usr/bin/env bash

emit_inline_policy() {
  max_reviews=$(( $2 - 7 ))
  if [ "$1" = "true" ]; then
    cat <<'EOF'
### Inline Reviews

#### Core Principles
- **NEVER** include summaries, praise, or restate code.
  Every comment must point out a problem, risk, or fix suggestion (**why it matters + how to fix**).
- **Never** use 'mcp__github_inline_comment__create_inline_comment'.
  Always add comments through 'mcp__github__add_comment_to_pending_review'.
- **Default 'side'** is "RIGHT" for new code; use "LEFT" only when referring to the old side of the diff.
- **One pending review per PR.**
  Reuse an existing one if necessary, and submit at the end using 'mcp__github__submit_pending_pull_request_review' ('event: "COMMENT"').
- The 'body' field must be **plain Markdown text**.
EOF

  printf '%s\n' "- Limit to ${max_reviews} total comments per review."
  printf '%s\n' "  If more issues exist, prioritize the most critical or representative ones."

  cat <<'EOF'

#### Canonical Tool Payload Rule (MANDATORY)
For **every** call to 'mcp__github__add_comment_to_pending_review':
- You MUST start from the canonical JSON template below.
- Do NOT remove any fields.
- Only replace placeholder values.
- If a REQUIRED field cannot be filled, **DO NOT call the tool**.


#### Canonical JSON Template (LINE comment)
```json
{
"owner": "<REQUIRED>",
"repo": "<REQUIRED>",
"pullNumber": <REQUIRED_POSITIVE_INT>,
"subjectType": "LINE",
"path": "<REQUIRED>",
"startLine": <REQUIRED>,
"line": <REQUIRED>,
"side": "RIGHT",
"body": "<REQUIRED_MARKDOWN_TEXT>"
}
```

#### Range vs Single-Line Encoding Rules
- **Single-line comments are FORBIDDEN by default.**
- A single-line comment is allowed **only if ALL conditions below are met**:
  1. The issue is a purely syntactic or mechanical problem (e.g., typo, missing import, unused variable).
  2. The fix does NOT depend on surrounding control flow or logic.
  3. Expanding the range would add no explanatory value.
  If ANY doubt exists, you MUST use a range-line comment.
- **Range-line comment (default):**
  - Fill **both** 'startLine' and 'line'.
  - Use this for logical blocks, control flow, or any issue requiring context.
- **Single-line comment (exception only):**
  - The only field that may be omitted is 'startLine', and only for a justified single-line exception.
  - If unsure, DO NOT use single-line.

#### Placement Rules
- 'startLine' = first affected line.
- 'line' = last affected line.
- If possible, extend by 1-2 lines for visibility,
but **never exceed the diff hunk**.

#### Placement Failure Policy
- If placing a comment fails once (invalid line, path, or side), retry by snapping to the nearest changed line in the same hunk.
- If it still fails, skip that comment and continue.
Never abort the entire review.

#### Submission
- Always submit at the end using 'mcp__github__submit_pending_pull_request_review' with 'event: "COMMENT"' and a short summary body such as "Automated review".
- Submit even if no inline comments were successfully added.
EOF
  else
    cat <<'EOF'
### Commenting Mode (No Inline)
 - **Do not use inline comments.**
 - Review **only code within the diff**. Do not comment on unrelated code.
 - Submit all findings as a **single consolidated review comment**.
 - Do **not** output findings as a normal message; publish them as **PR review/comment** only.
EOF
  fi
  echo
}