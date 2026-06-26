# taco-codex-plugin

Inflab 사내 LLM 사용량 트래커의 **Codex CLI 플러그인**. Codex 세션 이벤트
(hook)마다 `taco` CLI 를 호출해 Codex 사용량을 수집한다.

이 레포는 **hook 등록 + 얇은 래퍼 스크립트**만 담는다. 파싱/필터/전송 로직은
전부 `taco` CLI (`inflearn/taco`, brew 설치) 안에 있고, Claude
플러그인과 동일한 CLI·설정(`~/.config/taco/config.json`)·필터를 공유한다.

> Codex 는 Claude Code 와 달리 hook stdin 에 transcript 경로를 주지 않으므로,
> CLI 가 `~/.codex/sessions/**/rollout-*.jsonl` 를 watermark 기반으로 증분
> 스캔한다 (`taco collect --provider codex`). wakatime/codex-cli-wakatime
> 과 동일한 방식.

## 사전 조건

`taco` CLI v0.2.1+ 가 PATH 에 있어야 한다.

```sh
brew tap inflearn/internal git@github.com:inflearn/homebrew-internal
brew install taco
taco init     # git email/name, 수집 org/디렉터리, auto_sync 설정
```

## 설치

```sh
codex plugin marketplace add git@github.com:inflearn/taco-codex-plugin.git
codex plugin add taco@inflearn
```

설치 후 Codex 를 다시 시작하면 hook 이 등록된다. 이후 세션마다
`SessionStart` / `UserPromptSubmit` / `PostToolUse` 이벤트에서 Codex 사용량이
증분 수집된다.

## 동작

```
Codex hook (SessionStart/UserPromptSubmit/PostToolUse)
  → $PLUGIN_ROOT/scripts/run            (백그라운드)
    → taco collect --provider codex (~/.codex/sessions 증분 스캔 → 로컬 버퍼)
      → auto_sync 켜진 경우에만 → devops-api
```

- **자동 sync 는 기본 OFF.** 기본은 로컬 버퍼에만 쌓이고, 전송은 `taco sync`
  또는 `taco init` 에서 auto_sync 활성화 시.
- 수집 대상은 `taco init` 의 `allowed_orgs` / `allowed_dirs` 필터를 따른다.
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
- 적재/읽기 API: `inflearn/devops-api` (`pkg/aiusage`)
- 대시보드: `inflearn/taco-dashboard`
