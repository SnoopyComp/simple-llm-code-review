# Simple LLM Code Review — 한국어 README

PR + 연결된 이슈 + 선택적 레퍼런스 파일들을 모아 **LLM 코드리뷰 프롬프트**를 생성하고, **Claude Code**로 PR에 리뷰 코멘트를 남기는 가벼운 컴포지트 액션입니다.

---

## 🚀 빠른 시작

### 1) Anthropic 키 추가

리포지토리(또는 조직) 시크릿에 **`ANTHROPIC_API_KEY`** 를 생성하세요.

### 2) 워크플로우 파일 생성: `.github/workflows/llm-code-review.yml`

`SnoopyComp/simple-llm-code-review@latest` 사용


```yaml
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
        uses: SnoopyComp/simple-llm-code-review@latest
        with:
          anthropic-api-key: ${{ secrets.ANTHROPIC_API_KEY }}
```

### 3) 트리거

PR 본문에 **`@claude`** 를 넣으면 동작합니다.
(리뷰 코멘트가 PR에 달립니다.)

### (옵션) 레퍼런스 파일 첨부

PR 본문에 아래 마커를 추가하면 파일 내용을 프롬프트에 인라인합니다:

```
reference={docs/diagram.puml, api/openapi.yaml, SPEC.md}
```