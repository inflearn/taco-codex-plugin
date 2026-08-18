# taco-codex-plugin

taco(AI 코딩 사용량·비용 트래커)의 **Codex CLI 플러그인**. Codex 세션 이벤트(hook)마다 `taco` CLI 를 호출해 Codex 사용량을 수집한다.

이 레포는 **hook 등록 + 얇은 래퍼 스크립트**만 담는다. 파싱/필터/전송 로직은 전부 `taco` CLI 안에 있고, Claude Code 플러그인과 동일한 CLI·설정(`~/.config/taco/config.json`)·필터를 공유한다.

> Codex 는 Claude Code 와 달리 hook stdin 에 transcript 경로를 주지 않으므로, CLI 가 `~/.codex/sessions/**/rollout-*.jsonl` 를 watermark 기반으로 증분 스캔한다 (`taco collect --provider codex`).

## 사전 조건: taco CLI

`taco` CLI 가 PATH 에 있어야 한다.

```sh
# macOS / Linux
curl -fsSL https://inf.run/taco | sh

# Windows (PowerShell)
irm https://inf.run/taco.ps1 | iex
```

전송을 시작하려면 로그인:

```sh
taco login
```

## 설치

대부분은 **설치 스크립트가 `taco plugins` 로 자동 연동**하므로 따로 할 필요가 없다. 수동으로 하려면:

```sh
taco plugins        # 감지된 도구(Claude Code·Codex 등) 플러그인 설치
```

또는 Codex 플러그인 매니저로 직접:

```sh
codex plugin marketplace add https://github.com/inflearn/taco-codex-plugin.git
codex plugin add taco@inflearn
```

설치 후 Codex 를 다시 시작하면 hook 이 등록된다. 이후 세션마다 `SessionStart` / `UserPromptSubmit` / `PostToolUse` 이벤트에서 Codex 사용량이 증분 수집된다.

## 동작

```
Codex hook (SessionStart/UserPromptSubmit/PostToolUse)
  → $PLUGIN_ROOT/scripts/run            (백그라운드)
    → taco collect --provider codex (~/.codex/sessions 증분 스캔 → 로컬 버퍼)
      → 로그인돼 있으면 → taco 서버
```

- **자동 전송은 기본 ON**(`auto_sync`). 로그인 전에는 로컬 버퍼에만 쌓이고, `taco login` 후부터 서버로 전송된다.
- 수집 대상은 `allowed_orgs` / `allowed_dirs` 필터를 따른다.
- 래퍼는 CLI 를 못 찾아도 조용히 종료 — Codex 를 절대 막지 않는다.

## 구성

| 파일 | 역할 |
|---|---|
| `.agents/plugins/marketplace.json` | Codex marketplace 레지스트리 매니페스트 |
| `plugins/taco/.codex-plugin/plugin.json` | 플러그인 매니페스트 (`hooks` 참조) |
| `plugins/taco/hooks/hooks.json` | hook 이벤트 → `scripts/run` 등록 |
| `plugins/taco/scripts/run` | `taco collect --provider codex` 백그라운드 실행 (POSIX) |
| `plugins/taco/scripts/run.cmd` | 동일 (Windows) |

## 관련 레포

- CLI: `inflearn/taco`
- Claude Code 플러그인: `inflearn/taco-claude-plugin`
- API 서버: `inflearn/taco-api`
- 대시보드: `inflearn/taco-dashboard`

## 문서 · 대시보드

- 문서: https://taco.inflearn.com/docs
- 대시보드: https://taco.inflearn.com
