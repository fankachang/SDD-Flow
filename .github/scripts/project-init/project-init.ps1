# 專案初始化工具（Windows pwsh / PowerShell）。
# 建議透過 AI 代理程式執行 `/project-init` 呼叫本腳本；也可直接手動執行。
# 偵測開發環境、設定 git hooks 與 RTK，並列出候選語言/建置工具供 AI 助理與使用者確認。
# 對應版本：project-init.sh（macOS/Linux/WSL）、project-init.bat（cmd 薄殼層）
#
# 本腳本只做「偵測」與「決定性設定」（git hooks、RTK 安裝檢查），
# 不會自動寫入 .github/copilot-instructions.md — 候選建置工具清單須由 AI 助理
# 與使用者確認後，再用編輯工具寫入「專案技術棧與環境」區段。

$ErrorActionPreference = 'Stop'
$scriptDir = Split-Path -Parent $PSCommandPath
$rootDir = Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $scriptDir))
Set-Location $rootDir

Write-Output "=== 專案初始化偵測結果 ==="
Write-Output "作業系統: $([System.Environment]::OSVersion.VersionString)"
Write-Output "Shell: PowerShell $($PSVersionTable.PSVersion)"

if (Test-Path -LiteralPath (Join-Path $rootDir '.git')) {
    git config core.hooksPath .githooks
    Write-Output "Git hooks path: 已設定為 .githooks"
} else {
    Write-Output "Git hooks path: 略過（非 git repository）"
}

$rtkCmd = Get-Command rtk -ErrorAction SilentlyContinue
if ($rtkCmd) {
    $rtkVersion = & rtk --version 2>$null
    Write-Output "RTK: 已安裝（$rtkVersion）via $($rtkCmd.Source)"
} else {
    Write-Output "RTK: 未安裝，嘗試執行 install-check.ps1"
    $installCheck = Join-Path $rootDir '.agents/skills/rtk-token-killer/scripts/install-check.ps1'
    if (Test-Path -LiteralPath $installCheck) {
        try { & $installCheck } catch { Write-Output "RTK 安裝檢查未完成，請手動查看 rtk-token-killer skill" }
    }
}

Write-Output ""
Write-Output "候選語言/建置工具（僅供參考，可能誤判，需與使用者確認後才可寫入 copilot-instructions.md）:"

# 排除建置產物與範本自身基礎設施目錄（非下游專案的實際程式碼）。
$excludePattern = 'node_modules|\.git|[\\/]bin[\\/]|[\\/]obj[\\/]|dist|build|\.venv|vendor|[\\/]\.agents[\\/]|[\\/]\.github[\\/]|[\\/]\.specify[\\/]|[\\/]\.vscode[\\/]|[\\/]Docs[\\/]'
$manifests = @(
    @{ Label = 'Node.js'; Pattern = 'package.json' },
    @{ Label = 'Python (pyproject)'; Pattern = 'pyproject.toml' },
    @{ Label = 'Python (requirements)'; Pattern = 'requirements.txt' },
    @{ Label = '.NET (專案)'; Pattern = '*.csproj' },
    @{ Label = '.NET (方案)'; Pattern = '*.sln' },
    @{ Label = 'Rust'; Pattern = 'Cargo.toml' },
    @{ Label = 'Go'; Pattern = 'go.mod' },
    @{ Label = 'Java (Maven)'; Pattern = 'pom.xml' },
    @{ Label = 'Java (Gradle)'; Pattern = 'build.gradle*' },
    @{ Label = 'Ruby'; Pattern = 'Gemfile' },
    @{ Label = 'PHP'; Pattern = 'composer.json' }
)

$foundAny = $false
foreach ($m in $manifests) {
    $matches = Get-ChildItem -Path $rootDir -Recurse -Depth 3 -Filter $m.Pattern -ErrorAction SilentlyContinue |
        Where-Object { $_.FullName -notmatch $excludePattern } |
        Select-Object -First 5
    if ($matches) {
        $paths = ($matches | ForEach-Object { $_.FullName.Substring($rootDir.Length + 1) }) -join ' '
        Write-Output "  - $($m.Label)（發現: $paths）"
        $foundAny = $true
    }
}

if (-not $foundAny) {
    Write-Output "  (未偵測到常見語言 manifest 檔案)"
}

Write-Output ""
Write-Output "其他初始化狀態:"

# Python 虛擬環境（僅在偵測到 Python manifest 時回報）
$pythonManifests = Get-ChildItem -Path $rootDir -Recurse -Depth 3 -Include 'pyproject.toml', 'requirements.txt' -ErrorAction SilentlyContinue |
    Where-Object { $_.FullName -notmatch $excludePattern }
if ($pythonManifests) {
    if (Test-Path -LiteralPath (Join-Path $rootDir '.venv')) {
        Write-Output "  - Python .venv: 已存在（依 python-venv-check skill 直接使用，不得重建）"
    } else {
        Write-Output "  - Python .venv: 不存在（Python 專案建議建立，見 python-venv-check skill）"
    }
}

# SpecKit 憲章是否仍為 placeholder
$constitution = Join-Path $rootDir '.specify/memory/constitution.md'
if (Test-Path -LiteralPath $constitution) {
    if (Select-String -LiteralPath $constitution -Pattern '\[PROJECT_NAME\]' -Quiet) {
        Write-Output "  - SpecKit 憲章: 仍為 placeholder，請執行 /speckit.constitution 初始化"
    } else {
        Write-Output "  - SpecKit 憲章: 已初始化"
    }
}

Write-Output ""
Write-Output "=== 偵測完成 ==="
Write-Output "若非透過 /project-init 呼叫：請將以上結果交給 AI 助理，由其與你確認候選項目後，寫入 .github/copilot-instructions.md 的「專案技術棧與環境」區段。"
