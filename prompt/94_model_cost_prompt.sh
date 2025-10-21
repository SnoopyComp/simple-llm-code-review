#!/usr/bin/env bash

emit_cost_guidance() {
  if [[ "$$1" == "high" ]]; then
    cat <<'EOF'
### Resource/Depth Guidance
- Explore the problem **as deeply as necessary**; provide alternatives with clear rationale.
- Treat **token/time budget as lower priority** and conduct a thorough examination.
EOF
    echo
  fi
}
