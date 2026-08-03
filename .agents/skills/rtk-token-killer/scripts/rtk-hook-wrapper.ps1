# RTK Hook Wrapper (Windows PowerShell)
# 攔截 VS Code Copilot 與 GitHub Copilot CLI shell hook，依 sentinel 檔案決定是否套用 RTK。
#
# 全域關閉：建立 scripts/.rtk-disabled（用 rtk-toggle.ps1 -Action disable）
# 單次繞過：直接呼叫 rtk proxy <cmd>

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$sentinel = Join-Path $scriptDir '.rtk-disabled'

$stdin = [Console]::In.ReadToEnd()

if ((Test-Path $sentinel) -or ($env:COPILOT_RTK_ENABLED -eq 'false')) {
    # 空輸出表示保留原始工具呼叫，不套用 RTK。
    exit 0
} else {
    $rtkOnPath = Get-Command rtk -CommandType Application -ErrorAction SilentlyContinue
    $rtkExe = if ($rtkOnPath) { $rtkOnPath.Source } else { Join-Path $scriptDir 'rtk.exe' }
    $stdin | & $rtkExe hook copilot
    exit $LASTEXITCODE
}
