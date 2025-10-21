#!/usr/bin/env bash
common_instructions() {
    cat <<'EOF'
## Instructions
- If the PR body includes any specific requests or questions for the reviewer — such as asking for feedback on certain parts or suggestions for improvement — please focus your review on those points.
- **Do not include meaningless summaries or restatements of the code.**; forcus on problems, risks, or actionable suggestions.
- Review **only code within the diff**. Do not comment on unrelated code.
- **Avoid vague or abstract feedback.** All comments should be clear, direct, and specific to the code being reviewed.
EOF
    echo
}