@echo off
if exist "%ProgramFiles%\NextGenz\uninstall.exe" (
  start "" "%ProgramFiles%\NextGenz\uninstall.exe" --silent
) else (
  start "" "%LOCALAPPDATA%\NextGenz\uninstall.exe" --silent
)
