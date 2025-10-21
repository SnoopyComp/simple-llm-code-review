#!/usr/bin/env bash
common_instructions() {
    cat <<'EOF'
## Instructions
- If the PR body includes any specific requests or questions for the reviewer — such as asking for feedback on certain parts or suggestions for improvement — please focus your review on those points.
- **NEVER** include summaries or restate code; provide only problems, risks, or actionable suggestions.
- Review **only code within the diff**. Do not comment on unrelated code.
- Quote a minimal snippet, state the issue, explain why it matters, and give a concrete, directional fix suggestion.
- Avoid vague comments; provide clear and precise feedback.
EOF
    echo
}