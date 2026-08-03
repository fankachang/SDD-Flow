#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Run a technology-neutral integration-test assessment.

.DESCRIPTION
    Executes a project-supplied test command, captures each run, optionally
    parses a summary regex with named groups, and writes a starter report.
    The script does not assume a test runner, language, framework, result file,
    or deployment platform.

.PARAMETER TestCommand
    Executable or command name exposed by the current environment.

.PARAMETER TestArgument
    Arguments passed to TestCommand. Repeat the parameter for multiple values.

.PARAMETER OutputDir
    Directory for logs and the generated report. Defaults to the current directory.

.PARAMETER PassRateThreshold
    Minimum passed/total percentage. Defaults to 95 and is provisional unless
    the project defines a different threshold.

.PARAMETER RepeatRuns
    Number of independent command runs. Defaults to 1. Use at least 3 when
    investigating flakiness or shared-state risk.

.PARAMETER SummaryPattern
    Optional .NET regular expression with named groups such as
    (?<Total>\d+), (?<Passed>\d+), (?<Failed>\d+), (?<Skipped>\d+),
    (?<Pending>\d+), and (?<Blocked>\d+). Without it, metrics remain unknown.

.EXAMPLE
    ./itqa-assessment.ps1 -TestCommand dotnet -TestArgument test -OutputDir ./itqa

.EXAMPLE
    ./itqa-assessment.ps1 -TestCommand npm -TestArgument test -RepeatRuns 3 `
        -SummaryPattern '(?i)total\s*[:=]\s*(?<Total>\d+).*?passed\s*[:=]\s*(?<Passed>\d+).*?failed\s*[:=]\s*(?<Failed>\d+)'

.NOTES
    Configure UTF-8 in the calling PowerShell session when required by the host.
    The generated report is a starting point and must be completed when the
    project uses a custom result format or requires manual root-cause analysis.
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$TestCommand,

    [Parameter(Mandatory = $false)]
    [Alias('TestArgs')]
    [string[]]$TestArgument = @(),

    [Parameter(Mandatory = $false)]
    [string]$OutputDir = (Get-Location).Path,

    [Parameter(Mandatory = $false)]
    [ValidateRange(0, 100)]
    [int]$PassRateThreshold = 95,

    [Parameter(Mandatory = $false)]
    [ValidateRange(1, 20)]
    [int]$RepeatRuns = 1,

    [Parameter(Mandatory = $false)]
    [string]$SummaryPattern
)

$ErrorActionPreference = 'Stop'

# 將命令參數維持為資料，不評估拼接後的命令字串。
$command = Get-Command -Name $TestCommand -ErrorAction SilentlyContinue
if (-not $command) {
    Write-Error "找不到測試指令：$TestCommand"
    exit 1
}

New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null
$timestamp = Get-Date -Format 'yyyy-MM-dd_HH-mm-ss'
$reportFile = Join-Path $OutputDir "ITQA-Assessment-$timestamp.md"

function Get-NamedMetric {
    param(
        [Parameter(Mandatory = $true)]
        [System.Text.RegularExpressions.Match]$Match,

        [Parameter(Mandatory = $true)]
        [string]$Name
    )

    $group = $Match.Groups[$Name]
    if (-not $group -or -not $group.Success) {
        return $null
    }

    $value = 0
    if ([int]::TryParse($group.Value, [ref]$value)) {
        return $value
    }

    return $null
}

function Get-RunMetrics {
    param(
        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [string]$Output,

        [Parameter(Mandatory = $true)]
        [int]$ExitCode,

        [Parameter(Mandatory = $false)]
        [string]$Pattern
    )

    $metrics = [ordered]@{
        Total = $null
        Passed = $null
        Failed = $null
        Skipped = $null
        Pending = $null
        Blocked = $null
        PassRate = $null
        ExitCode = $ExitCode
        Parsed = $false
    }

    if ($Pattern) {
        try {
            $match = [regex]::Match(
                $Output,
                $Pattern,
                [System.Text.RegularExpressions.RegexOptions]::IgnoreCase -bor
                    [System.Text.RegularExpressions.RegexOptions]::Singleline)
        }
        catch {
            throw "SummaryPattern 無效：$($_.Exception.Message)"
        }

        if ($match.Success) {
            $metrics.Total = Get-NamedMetric -Match $match -Name 'Total'
            $metrics.Passed = Get-NamedMetric -Match $match -Name 'Passed'
            $metrics.Failed = Get-NamedMetric -Match $match -Name 'Failed'
            $metrics.Skipped = Get-NamedMetric -Match $match -Name 'Skipped'
            $metrics.Pending = Get-NamedMetric -Match $match -Name 'Pending'
            $metrics.Blocked = Get-NamedMetric -Match $match -Name 'Blocked'
            $metrics.Parsed = $null -ne $metrics.Total -and $metrics.Total -gt 0

            if ($metrics.Parsed -and $null -ne $metrics.Passed) {
                $metrics.PassRate = [math]::Round(
                    ($metrics.Passed / $metrics.Total) * 100,
                    1)
            }
        }
    }

    [pscustomobject]$metrics
}

$runResults = [System.Collections.Generic.List[object]]::new()
$allRunsPassed = $true

Write-Host 'Integration Test Quality Assessment'
Write-Host "指令：$TestCommand $($TestArgument -join ' ')"
Write-Host "執行次數：$RepeatRuns"
Write-Host "輸出目錄：$OutputDir"
Write-Host ''

for ($runNumber = 1; $runNumber -le $RepeatRuns; $runNumber++) {
    $runLogFile = Join-Path $OutputDir "test-output-$timestamp-run-$runNumber.log"
    Write-Host "執行第 $runNumber/$RepeatRuns 次..."

    $commandOutput = @(& $TestCommand @TestArgument 2>&1)
    $exitCode = $LASTEXITCODE
    if ($null -eq $exitCode) {
        $exitCode = 0
    }

    $commandOutput | ForEach-Object { $_.ToString() } | Set-Content -Path $runLogFile -Encoding utf8
    $outputText = ($commandOutput | ForEach-Object { $_.ToString() }) -join [Environment]::NewLine
    $metrics = Get-RunMetrics -Output $outputText -ExitCode $exitCode -Pattern $SummaryPattern

    if ($exitCode -ne 0 -or ($metrics.Parsed -and $metrics.PassRate -lt $PassRateThreshold)) {
        $allRunsPassed = $false
    }

    $runResults.Add([pscustomobject]@{
        Run = $runNumber
        Log = $runLogFile
        Metrics = $metrics
    })
}

$latestMetrics = $runResults[$runResults.Count - 1].Metrics
$metricsStatus = if ($latestMetrics.Parsed) { '已解析' } else { '未解析' }
$assessmentStatus = if (-not $latestMetrics.Parsed) {
    'INCONCLUSIVE'
}
elseif ($allRunsPassed) {
    'READY CANDIDATE'
}
else {
    'ESCALATION REQUIRED'
}

$runRows = foreach ($result in $runResults) {
    $metrics = $result.Metrics
    $total = if ($null -eq $metrics.Total) { 'Unknown' } else { $metrics.Total }
    $passed = if ($null -eq $metrics.Passed) { 'Unknown' } else { $metrics.Passed }
    $failed = if ($null -eq $metrics.Failed) { 'Unknown' } else { $metrics.Failed }
    $skipped = if ($null -eq $metrics.Skipped) { 'Unknown' } else { $metrics.Skipped }
    $passRate = if ($null -eq $metrics.PassRate) { 'Unknown' } else { "$($metrics.PassRate)%" }
    "| $($result.Run) | $total | $passed | $failed | $skipped | $passRate | $($metrics.ExitCode) | $($result.Log) |"
}

$reportContent = @"
# Integration Test Assessment

**日期**: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')  
**狀態**: $assessmentStatus  
**測試指令**: $TestCommand $($TestArgument -join ' ')  
**通過率門檻**: ${PassRateThreshold}%（若專案未定義門檻，此值為暫定值）  
**結果解析**: $metricsStatus  

## 執行結果

| Run | Total | Passed | Failed | Skipped | Pass Rate | Exit Code | Log |
|---:|---:|---:|---:|---:|---:|---:|---|
$($runRows -join [Environment]::NewLine)

## 判讀

- 通過率計算為 Passed / Total；Skipped、Pending 與 Blocked 不會靜默計入通過。
- 若結果未解析，請依專案結果格式補上指標；此報告不得視為通過。
- 請使用 Skill 內的決策框架分類失敗，並以品質清單檢查隔離、相依、並行與已知限制。

## 根本原因與後續

- **環境**: 待評估
- **設定／Fixture**: 待評估
- **資料／相依**: 待評估
- **並行／時序**: 待評估
- **產品缺陷**: 待評估
- **未知**: 待評估

## 驗證清單

- [ ] 結果格式與指標已確認
- [ ] 失敗已在隔離與完整套件中比較
- [ ] 已檢查序列／平行執行與清理
- [ ] 測試層修正未削弱整合 assertion
- [ ] 產品影響與已知限制已記錄
- [ ] 負責人與下一步已指定

## 產出

- 報告: $reportFile
- Logs: $OutputDir
"@

Set-Content -Path $reportFile -Value $reportContent -Encoding utf8
Write-Host "報告已生成：$reportFile"

if ($assessmentStatus -eq 'READY CANDIDATE') {
    exit 0
}

exit 1
