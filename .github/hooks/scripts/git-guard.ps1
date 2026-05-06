#!/usr/bin/env pwsh
# git-guard.ps1 — Git 受保護分支守衛
# 來源規則：.github/instructions/git-workflow.instructions.md
# 攔截：force push、--no-verify、直接推送受保護分支、rm -rf、reset --hard
[Console]::InputEncoding  = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

function Write-Allow {
    @{
        hookSpecificOutput = @{
            hookEventName      = "PreToolUse"
            permissionDecision = "allow"
        }
    } | ConvertTo-Json -Depth 5 -Compress
}

function Write-Deny([string]$reason) {
    @{
        continue   = $false
        stopReason = "[Git Guard] $reason"
        hookSpecificOutput = @{
            hookEventName              = "PreToolUse"
            permissionDecision         = "deny"
            permissionDecisionReason   = $reason
        }
    } | ConvertTo-Json -Depth 5 -Compress
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

# 取出 command（相容多種 JSON 結構）
$command = if ($data.tool_input.command) { $data.tool_input.command }
           elseif ($data.input.command)  { $data.input.command }
           else                          { "" }

if (-not $command) { Write-Allow; exit 0 }

# ========== 絕對禁止操作 ==========
$deniedRules = @(
    @{
        regex  = 'git\s+push\s+(--force|-f)\b'
        reason = '絕對禁止：git push --force / -f 可能損壞受保護分支歷史。請使用 PR 流程合併。'
    },
    @{
        regex  = '\bgit\b.*\s--no-verify\b'
        reason = '絕對禁止：--no-verify 會跳過 git hooks 安全檢查，不得使用。'
    },
    @{
        regex  = 'git\s+push\s+\S+\s+(main|master|production|release|prod)\b'
        reason = '絕對禁止：不得直接推送到受保護分支（main/master/production/release/prod）。請建立 feature branch 並透過 PR 合併。'
    }
)

foreach ($rule in $deniedRules) {
    if ($command -match $rule.regex) {
        Write-Deny $rule.reason
        exit 2
    }
}

# ========== 需要使用者確認操作 ==========
$askRules = @(
    @{
        regex  = 'git\s+reset\s+--hard\b'
        reason = 'git reset --hard 是不可逆操作，將丟失工作目錄所有未提交變更。確認要繼續嗎？'
    },
    @{
        regex  = '\brm\s+(-rf|-fr|-r\s+-f|-f\s+-r)\b'
        reason = 'rm -rf 是破壞性指令，需明確使用者授權（AGENTS.md 規定）。確認要繼續嗎？'
    },
    @{
        regex  = 'Remove-Item\b.*(-Recurse|-r)\b.*(-Force|-fo)\b|Remove-Item\b.*(-Force|-fo)\b.*(-Recurse|-r)\b'
        reason = 'Remove-Item 強制遞迴刪除是不可逆操作。確認要繼續嗎？'
    },
    @{
        regex  = 'git\s+(merge|rebase|cherry-pick)\b'
        reason = '此 git 操作在受保護分支（main/master/production/release/prod）上執行前須確認。請確認目前分支為 feature branch。'
    }
)

foreach ($rule in $askRules) {
    if ($command -match $rule.regex) {
        Write-Ask "⚠️ [Git Guard] $($rule.reason)"
        exit 0
    }
}

# 允許通過
Write-Allow
exit 0
