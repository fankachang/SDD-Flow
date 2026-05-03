# RTK 安裝驗證與自動安裝（Windows PowerShell）
# 執行方式：
#   Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force
#   .\.agents\skills\rtk-token-killer\scripts\install-check.ps1

$ErrorActionPreference = "Stop"

Write-Host "=== RTK 安裝檢查 ===" -ForegroundColor Cyan

# 1. 檢查 rtk 是否存在
$rtkCmd = Get-Command rtk -ErrorAction SilentlyContinue

if ($rtkCmd) {
    $installedVersion = (& rtk --version) -replace "rtk ", ""
    Write-Host "✅ RTK 已安裝：v$installedVersion" -ForegroundColor Green

    # 2. 驗證是否為正確的 rtk（非 Rust Type Kit）
    try {
        $null = & rtk gain 2>&1
        Write-Host "✅ RTK 功能驗證通過（rtk gain 可執行）" -ForegroundColor Green
    } catch {
        Write-Host "⚠️  警告：rtk gain 失敗。" -ForegroundColor Yellow
        Write-Host "   可能安裝的是 reachingforthejack/rtk（Rust Type Kit）而非 Rust Token Killer。"
        Write-Host "   請移除後重新安裝：見下方安裝步驟。"
        Write-Host ""
        Write-Host "=== 手動安裝步驟 ===" -ForegroundColor Cyan
        Write-Host "1. 前往 https://github.com/rtk-ai/rtk/releases"
        Write-Host "2. 下載 rtk-x86_64-pc-windows-msvc.zip（或 arm64 版本）"
        Write-Host "3. 解壓縮並將 rtk.exe 放至 PATH 目錄（例如 C:\Windows\System32 或自訂目錄）"
        exit 1
    }
    exit 0
}

# 3. 未安裝，自動安裝
Write-Host "❌ RTK 未安裝，開始自動安裝..." -ForegroundColor Red

# 取得最新版本號
Write-Host "→ 查詢最新版本..."
try {
    $release = Invoke-RestMethod -Uri "https://api.github.com/repos/rtk-ai/rtk/releases/latest" -Headers @{
        "User-Agent" = "rtk-install-script"
    }
    $tagName = $release.tag_name  # e.g. "v0.38.0"
    $version = $tagName -replace "^v", ""
    Write-Host "  最新版本：$tagName"
} catch {
    Write-Host "❌ 無法查詢最新版本，請手動安裝：" -ForegroundColor Red
    Write-Host "   https://github.com/rtk-ai/rtk/releases"
    exit 1
}

# 判斷架構
$arch = if ([System.Environment]::Is64BitOperatingSystem) {
    if ($env:PROCESSOR_ARCHITECTURE -eq "ARM64") { "aarch64" } else { "x86_64" }
} else {
    Write-Host "❌ 不支援 32 位元 Windows" -ForegroundColor Red
    exit 1
}

$assetName = "rtk-${arch}-pc-windows-msvc.zip"
$downloadUrl = "https://github.com/rtk-ai/rtk/releases/download/${tagName}/${assetName}"

# 安裝至使用者 AppData 目錄（不需要管理員權限）
$installDir = "$env:LOCALAPPDATA\rtk"
$zipPath = "$env:TEMP\rtk-install.zip"

Write-Host "→ 下載 $assetName ..."
try {
    Invoke-WebRequest -Uri $downloadUrl -OutFile $zipPath -UseBasicParsing
} catch {
    Write-Host "❌ 下載失敗：$_" -ForegroundColor Red
    Write-Host "   請手動前往 https://github.com/rtk-ai/rtk/releases 下載。"
    exit 1
}

Write-Host "→ 解壓縮至 $installDir ..."
if (-not (Test-Path $installDir)) { New-Item -ItemType Directory -Path $installDir | Out-Null }
Expand-Archive -Path $zipPath -DestinationPath $installDir -Force
Remove-Item $zipPath -ErrorAction SilentlyContinue

# 加入 PATH（目前 Session）
$env:PATH = "$installDir;$env:PATH"

# 永久加入使用者 PATH
$userPath = [System.Environment]::GetEnvironmentVariable("PATH", "User")
if ($userPath -notlike "*$installDir*") {
    [System.Environment]::SetEnvironmentVariable("PATH", "$installDir;$userPath", "User")
    Write-Host "✅ 已將 $installDir 加入使用者 PATH（重新開啟終端機後生效）"
}

# 4. 驗證
if (Get-Command rtk -ErrorAction SilentlyContinue) {
    Write-Host "✅ RTK 安裝成功：$(rtk --version)" -ForegroundColor Green
    Write-Host ""
    Write-Host "=== 下一步 ===" -ForegroundColor Cyan
    Write-Host "設定 Hook 自動代理（在專案目錄執行）："
    Write-Host "  Claude Code CLI : Copy-Item .agents\skills\rtk-token-killer\settings-claude.json .github\settings.json"
    Write-Host "  VS Code Copilot : Copy-Item .agents\skills\rtk-token-killer\settings-vscode.json .github\settings.json"
} else {
    Write-Host "❌ 安裝後仍無法找到 rtk.exe，請確認 $installDir 中有 rtk.exe，並重新開啟終端機。" -ForegroundColor Red
    exit 1
}
