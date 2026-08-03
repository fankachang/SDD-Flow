# RTK Token Killer - 全域啟用/關閉開關 (Windows PowerShell, sentinel 檔案機制)
# 用法：
#   .\agents\skills\rtk-token-killer\rtk-toggle.ps1 -Action disable  # 關閉 RTK
#   .\agents\skills\rtk-token-killer\rtk-toggle.ps1 -Action enable   # 啟用 RTK
#   .\agents\skills\rtk-token-killer\rtk-toggle.ps1 -Action status   # 查看狀態
#
# 原理：在 scripts/ 目錄建立/移除 .rtk-disabled 檔案。
# rtk-hook-wrapper.ps1 會檢查此檔案是否存在，決定是否套用 RTK。立即生效，無需重啟 shell。

param(
    [ValidateSet('enable', 'disable', 'status')]
    [string]$Action = 'status'
)

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$sentinel = Join-Path $scriptDir 'scripts\.rtk-disabled'

switch ($Action) {
    'disable' {
        New-Item -ItemType File -Path $sentinel -Force | Out-Null
        Write-Host "❌ RTK 已關閉（終端機命令將取得完整、未壓縮輸出）"
        Write-Host "   立即生效，無需重啟 shell。sentinel: $sentinel"
    }
    'enable' {
        Remove-Item -Path $sentinel -Force -ErrorAction SilentlyContinue
        Write-Host "✅ RTK 已啟用（終端機命令自動節省 token）"
        Write-Host "   立即生效，無需重啟 shell。"
    }
    'status' {
        if (Test-Path $sentinel) {
            Write-Host "❌ RTK 目前為關閉狀態"
        } else {
            Write-Host "✅ RTK 目前為啟用狀態（預設）"
        }
    }
    default {
        Write-Host "用法："
        Write-Host "  .\agents\skills\rtk-token-killer\rtk-toggle.ps1 -Action disable  # 關閉 RTK"
        Write-Host "  .\agents\skills\rtk-token-killer\rtk-toggle.ps1 -Action enable   # 啟用 RTK"
        Write-Host "  .\agents\skills\rtk-token-killer\rtk-toggle.ps1 -Action status   # 查看狀態"
        exit 1
    }
}
