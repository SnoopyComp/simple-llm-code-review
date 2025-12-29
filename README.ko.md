# Simple LLM Code Review (한글)

## 🌐 언어
- [English](README.md)
- [Korean](README.ko.md)
---

코드리뷰를 별도의 설정 필요 없이 간단하게 사용하기 위한 Composite Actions입니다.

PR + 연결된 이슈 + 선택적 레퍼런스 파일들을 모아 **LLM 코드리뷰 프롬프트**를 생성하고, **Claude Code**로 PR에 리뷰 코멘트를 남깁니다.

---

## 🚀 빠른 시작

### 1) Anthropic 키 추가

리포지토리(또는 Organization) 시크릿에 **`ANTHROPIC_API_KEY`** 를 생성하세요.

`Anthropic API 발급처` : `https://platform.claude.com`

### 2) 워크플로우 파일 생성

- `anthropic-api-key`: `1)`에서 생성한 시크릿 변수명
- `language`: 리뷰 받을 언어

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
          language: korean
```
#### Actions 트리거만 수정하셔서 이대로 사용하시면 됩니다.
---
### 3) 트리거

PR 본문에 **`@claude`** 를 넣으면 동작합니다.

(주석 내부에 추가해도 인식합니다.)
#### PR 템플릿에 아래와 같이 주석으로 끼워 넣는것을 추천합니다.
```md

### 💻 작업 내용
- 진행한 작업 내용

### ✨ 리뷰 포인트
query 가 너무 복잡한 것 같은데 이 위주로 봐주세요

### 📝 메모
PR 관련 전달사항

### 🎯 관련 이슈
closed #이슈번호

<!-- 만약 LLM 코드리뷰를 원하지 않는다면 이 줄을 삭제해주세요. @claude -->
```
---

### (옵션) 레퍼런스 파일 첨부하기

PR 본문에 아래 마커를 사용해 파일 경로를 추가 시 리뷰 요청 프롬프트에 해당 파일을 레퍼런스 파일로 추가합니다.

(역시 주석 내부에 추가해도 인식합니다.)
```
reference={docs/diagram.puml, api/openapi.yaml, SPEC.md}
```
