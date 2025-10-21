#!/usr/bin/env bash

emit_inline_policy() {
  max_reviews=$(( $2 - 6 ))
  if [ "$1" = "true" ]; then
    cat <<EOF
### Inline Reviews

#### Core Principles
- The comment type priority must always follow this order → Range-line comments > Single-line comments > File comments.
  Always choose the **most specific and contextually appropriate** comment type.
- **NEVER** include summaries, praise, or restate code.
  Every comment must point out a problem, risk, or fix suggestion (**why it matters + how to fix**).
- **Never** use 'mcp__github_inline_comment__create_inline_comment'.
  Always add comments through 'mcp__github__add_comment_to_pending_review'.
- **Default 'side'** is "RIGHT" for new code; use "LEFT" only when referring to the old side of the diff.
- **One pending review per PR.**
  Reuse an existing one if necessary, and submit at the end using 'mcp__github__submit_pending_pull_request_review' ('event: "COMMENT"').
- Limit to '${max_reviews}' total comments per review.
  If more issues exist, prioritize the most critical or representative ones.

#### 1. Range-Line Comment  *(Highest Priority)*
**When to use:**
Use a range-line comment whenever the issue spans multiple lines, covers a logical block (loop, condition, function body, etc.), or requires additional context to explain clearly.

**Definition:**
A comment is considered a range comment **only if both** 'startLine' **and** 'line' **are included.**
If 'startLine' is missing, it will be treated as a single-line comment.

**Placement rule:**
'startLine' marks the first affected line; 'line' should be placed about **two lines below** the last affected line to improve visibility in diffs.

**Example JSON:**
```json
{
  "subjectType": "LINE",
  "path": "<file path>",
  "startLine": <start line>,
  "line": <end line>,
  "side": "RIGHT",
  "body": "<your comment here>"
}
```

#### 2. Single-Line Comment  *(Second Priority)*
**When to use:**
If the issue affects **exactly one line** and no surrounding context is needed.

**Rule for 'line':**
'line' must point exactly to the line that contains the code being discussed or reviewed.

**Example JSON:**
```json
{
  "subjectType": "LINE",
  "path": "<file path>",
  "line": <line number>,
  "side": "RIGHT",
  "body": "<your comment here>"
}
```

#### 3. File Comment  *(Lowest Priority)*
**When to use:**
Use this when feedback applies to the **entire file** or a structural/design aspect rather than any specific line.
Do not use it for code issues tied to individual lines.

**Example JSON:**
```json
{
  "subjectType": "FILE",
  "path": "<file path>",
  "body": "<your comment here>"
}
```

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
EOF
  fi
  echo
}