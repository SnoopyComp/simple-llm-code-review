#!/usr/bin/env bash
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