@echo off
rem Codex CLI hook → taco CLI (Windows). ~/.codex/sessions 증분 스캔.
rem TACO_HOOK=1: 락 + throttle 로 동시/연속 실행이 쌓이지 않게 한다(구버전 CLI 호환 env).
where taco >nul 2>nul
if errorlevel 1 exit /b 0
set TACO_HOOK=1
start "" /b taco collect --provider codex >nul 2>nul
exit /b 0
