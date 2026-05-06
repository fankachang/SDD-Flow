#!/usr/bin/env pwsh
# utf8-check.ps1 — UTF-8 設定守衛
# 來源規則：copilot-instructions.md BLOCKING REQUIREMENT（UTF-8 終端機設定）
# 偵測 PowerShell 指令是否缺少 UTF-8 setup，若缺少則要求確認後再執行
[Console]::InputEncoding  = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

function Write-Allow {
    @{
        hookSpecificOutput = @{
            hookEventName      = "PreToolUse"
            permissionDecision = "allow"
        }
    } | ConvertTo-Json -Compress
}

function Write-Ask([string]$reason) {
    @{
        hookSpecificOutput = @{
            hookEventName              = "PreToolUse"
            permissionDecision         = "ask"
            permissionDecisionReason   = $reason
        }
    } | ConvertTo-Json -Depth 5 -Compress
}

# 讀取 stdin
$stdinContent = [Console]::In.ReadToEnd()
if (-not $stdinContent) { Write-Allow; exit 0 }

try   { $data = $stdinContent | ConvertFrom-Json }
catch { Write-Allow; exit 0 }

# 取出 command
$command = if ($data.tool_input.command) { $data.tool_input.command }
           elseif ($data.input.command)  { $data.input.command }
           else                          { "" }

if (-not $command) { Write-Allow; exit 0 }

# 若 UTF-8 setup 已包含，直接放行
if ($command -match 'chcp\s+65001' -or $command -match '\$OutputEncoding\s*=') {
    Write-Allow; exit 0
}

# 偵測是否為 PowerShell 指令
$isPowerShell = (
    ($command -match '(?i)^\s*(pwsh|powershell\.exe|Set-|Get-|Write-|Read-|New-|Remove-|Copy-|Move-|Invoke-|Format-|Select-|Where-|ForEach-|Import-|Export-|Test-|Start-|Stop-|Clear-|Out-|Add-|ConvertTo-|ConvertFrom-)') -or
    ($command -match '\$[A-Za-z_]\w*') -or
    ($command -match '`[ntr]')
)

if ($isPowerShell) {
    $msg = @"
⚠️ [UTF-8 Guard] 此 PowerShell 指令未包含 UTF-8 設定（copilot-instructions.md BLOCKING REQUIREMENT）。
請在指令開頭加入以下 3 行後重新執行：

  chcp 65001 > `$null
  `$OutputEncoding = [Console]::OutputEncoding = [Console]::InputEncoding = [System.Text.Encoding]::UTF8
  `$PSDefaultParameterValues['*:Encoding'] = 'utf8'

確認以現有指令繼續執行（不加入 UTF-8 設定）嗎？
"@
    Write-Ask $msg
    exit 0
}

# 非 PowerShell 指令，允許通過
Write-Allow
exit 0
