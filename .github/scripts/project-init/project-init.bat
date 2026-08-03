@echo off
REM 專案初始化工具（Windows cmd 薄殼層，轉呼叫 PowerShell 版本 project-init.ps1）。
REM 建議透過 AI 代理程式執行 `/project-init` 呼叫；也可直接手動執行本檔案。
setlocal
set "SCRIPT_DIR=%~dp0"

where pwsh >nul 2>nul
if %ERRORLEVEL% EQU 0 (
    pwsh -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_DIR%project-init.ps1"
) else (
    powershell -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_DIR%project-init.ps1"
)

endlocal
