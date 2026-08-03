# Copilot terminal 與 sandbox 內層 PowerShell 共用的專案暫存目錄與編碼初始化。
# 對應 macOS/Linux 版本：.vscode/copilot-terminal-init.bash

# UTF-8 編碼設定，避免中文字元顯示亂碼（見 RunPowerShell skill）。
chcp 65001 > $null
$OutputEncoding = [Console]::OutputEncoding = [Console]::InputEncoding = [System.Text.Encoding]::UTF8
$PSDefaultParameterValues['*:Encoding'] = 'utf8'

$_copilotProjectRoot = Split-Path -Parent $PSScriptRoot
$_copilotTmpDir = Join-Path $_copilotProjectRoot 'tmp'

if (-not (Test-Path -LiteralPath $_copilotTmpDir)) {
    New-Item -ItemType Directory -Path $_copilotTmpDir -Force | Out-Null
}

$env:TMPDIR = $_copilotTmpDir
$env:CLAUDE_TMPDIR = $_copilotTmpDir

Remove-Variable _copilotProjectRoot, _copilotTmpDir
