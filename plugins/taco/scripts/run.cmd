@echo off
rem Codex CLI hook → taco CLI (Windows). ~/.codex/sessions 증분 스캔.
where taco >nul 2>nul
if errorlevel 1 exit /b 0
start "" /b taco collect --provider codex >nul 2>nul
exit /b 0
