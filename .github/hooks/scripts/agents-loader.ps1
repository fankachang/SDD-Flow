#!/usr/bin/env pwsh
# agents-loader.ps1 — AGENTS.md SessionStart 自動注入
# 來源規則：copilot-instructions.md BLOCKING REQUIREMENT（AGENTS.md 自動載入）
# 在每次新對話開始時，讀取根目錄 AGENTS.md 並注入為 systemMessage
[Console]::InputEncoding  = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# 取得 workspace 根目錄（優先用 git root，fallback 用當前目錄）
try {
    $gitRoot = git rev-parse --show-toplevel 2>$null
    $workspaceRoot = if ($LASTEXITCODE -eq 0 -and $gitRoot) { $gitRoot.Trim() } else { (Get-Location).Path }
} catch {
    $workspaceRoot = (Get-Location).Path
}

$agentsMd = Join-Path $workspaceRoot "AGENTS.md"

if (-not (Test-Path $agentsMd)) {
    @{ continue = $true } | ConvertTo-Json
    exit 0
}

$content = Get-Content $agentsMd -Raw -Encoding UTF8

$systemMessage = @"
=== [agents-loader Hook] AGENTS.md 自動載入 ===
以下為本工作區的強制規則（與 copilot-instructions.md 同等效力）：

$content

================================================
"@

@{
    continue      = $true
    systemMessage = $systemMessage
} | ConvertTo-Json -Depth 5

exit 0
