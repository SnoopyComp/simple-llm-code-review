# Simple LLM Code Review (English)

## 🌐 Language

* [English](README.md)
* [Korean](README.ko.md)

---

This is a Composite Actions designed to enable simple code reviews without requiring any additional setup.

It collects PRs + linked issues + optional reference files to generate an **LLM code review prompt**, and leaves review comments on the PR using **Claude Code**.

---

## 🚀 Quick Start

### 1) Add Anthropic Key

Create **`ANTHROPIC_API_KEY`** in the repository (or Organization) secrets.

`Anthropic API Issuance` : `https://platform.claude.com`

### 2) Create Workflow File

* `anthropic-api-key`: the secret variable name created in `1)`
* `language`: the language to receive the review in

```yml
# .github/workflows/llm-code-review.yml
name: Claude Auto PR Review
on:
  pull_request:
    types: [opened, edited, synchronize]

permissions:
  contents: read
  pull-requests: write
  checks: write
  id-token: write

jobs:
  review:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - name: Simple LLM Code Review
        uses: codingbaraGo/simple-llm-code-review@latest
        with:
          anthropic-api-key: ${{ secrets.ANTHROPIC_API_KEY }}
          language: english
```

#### You can use this as-is by only modifying the Actions trigger.

---

### 3) Trigger

It runs when **`@claude`** is included in the PR description.

(It is also recognized when added inside comments.)

#### It is recommended to insert it as a comment in the PR template as shown below.

```md

### 💻 Work Details
- Description of the work performed

### ✨ Review Points
The query seems too complex, so please focus on this part

### 📝 Memo
Notes related to the PR

### 🎯 Related Issues
closed #issue-number

<!-- If you do not want an LLM code review, please delete this line. @claude -->
```

---

### (Optional) Attach Reference Files

If you add file paths using the marker below in the PR description, those files will be added as reference files to the review request prompt.

(It is also recognized when added inside comments.)

```
reference={docs/diagram.puml, api/openapi.yaml, SPEC.md}
```
