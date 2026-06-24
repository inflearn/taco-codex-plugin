@echo off
rem Codex CLI hook → ai-usage CLI (Windows). ~/.codex/sessions 증분 스캔.
where ai-usage >nul 2>nul
if errorlevel 1 exit /b 0
start "" /b ai-usage collect --provider codex >nul 2>nul
exit /b 0
