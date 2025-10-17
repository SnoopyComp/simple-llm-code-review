#!/usr/bin/env bash
common_instructions() {
    cat <<'EOF'
## Instructions
- If the PR includes requested review points, **prioritize those points over general checks**.
- **NEVER** include summaries, praise, or restate code; provide only problems, risks, or actionable suggestions.
- Review **only code within the diff**. Do not comment on unrelated code.
- Quote a minimal snippet, state the issue, explain why it matters, and give a concrete, directional fix suggestion.
- Avoid vague comments; provide clear and precise feedback.
EOF
    echo
}