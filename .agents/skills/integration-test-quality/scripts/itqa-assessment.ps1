#!/usr/bin/env pwsh
<#
.SYNOPSIS
    ITQA Assessment Automation Script
    
.DESCRIPTION
    Automates Integration Test Quality Assessment for ASP.NET MVC projects.
    Runs test suite, collects metrics, diagnoses failures, generates report.
    
.PARAMETER TestDll
    Path to test assembly (e.g., Online.Tests.dll)
    
.PARAMETER TestRunner
    Test runner to use: 'vstest' or 'nunit3-console'
    Default: 'vstest'
    
.PARAMETER OutputDir
    Directory for test results and reports
    Default: Current directory
    
.PARAMETER PassRateThreshold
    Minimum acceptable pass rate (0-100)
    Default: 95
    
.EXAMPLE
    .\itqa-assessment.ps1 -TestDll "C:\path\to\Online.Tests.dll" -OutputDir "C:\results"
    
.NOTES
    Requires: vstest.console.exe or nunit3-console in PATH
    UTF-8 Output: Supports Chinese characters in test names and report
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$TestDll,
    
    [Parameter(Mandatory=$false)]
    [ValidateSet('vstest', 'nunit3-console')]
    [string]$TestRunner = 'vstest',
    
    [Parameter(Mandatory=$false)]
    [string]$OutputDir = (Get-Location).Path,
    
    [Parameter(Mandatory=$false)]
    [int]$PassRateThreshold = 95
)

# UTF-8 Setup
chcp 65001 > $null
$OutputEncoding = [Console]::OutputEncoding = [Console]::InputEncoding = [System.Text.Encoding]::UTF8
$PSDefaultParameterValues['*:Encoding'] = 'utf8'

# ============================================================================
# MAIN ASSESSMENT FLOW
# ============================================================================

Write-Host "╔════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║  Integration Test Quality Assessment (ITQA)                  ║" -ForegroundColor Cyan
Write-Host "║  OnlineService_SG Skill                                      ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# Validation
if (-not (Test-Path $TestDll)) {
    Write-Host "❌ 錯誤: 找不到測試組件: $TestDll" -ForegroundColor Red
    exit 1
}

Write-Host "📋 評估參數:" -ForegroundColor Green
Write-Host "  • 測試組件: $TestDll"
Write-Host "  • 測試執行器: $TestRunner"
Write-Host "  • 輸出目錄: $OutputDir"
Write-Host "  • 通過率門檻: ${PassRateThreshold}%"
Write-Host ""

# ============================================================================
# PHASE 1: BASELINE - Run Full Test Suite
# ============================================================================

Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Yellow
Write-Host "Phase 1️⃣  基線 (Baseline)" -ForegroundColor Yellow
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Yellow
Write-Host ""

$timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$testResultsFile = Join-Path $OutputDir "test-results-$timestamp.trx"
$testLogFile = Join-Path $OutputDir "test-output-$timestamp.log"

Write-Host "⏳ 執行測試套件..." -ForegroundColor Cyan
Write-Host "  開始時間: $(Get-Date -Format 'HH:mm:ss')" -ForegroundColor Gray

# Run tests based on runner type
if ($TestRunner -eq 'vstest') {
    $vstest = Get-Command vstest.console.exe -ErrorAction SilentlyContinue
    if (-not $vstest) {
        Write-Host "❌ 錯誤: 找不到 vstest.console.exe" -ForegroundColor Red
        exit 1
    }
    
    & vstest.console.exe "$TestDll" /Logger:trx /Logger:console > $testLogFile 2>&1
    $exitCode = $LASTEXITCODE
} else {
    $nunit = Get-Command nunit3-console -ErrorAction SilentlyContinue
    if (-not $nunit) {
        Write-Host "❌ 錯誤: 找不到 nunit3-console" -ForegroundColor Red
        exit 1
    }
    
    & nunit3-console "$TestDll" "--result=$testResultsFile" > $testLogFile 2>&1
    $exitCode = $LASTEXITCODE
}

$endTime = Get-Date -Format 'HH:mm:ss'
Write-Host "  結束時間: $endTime" -ForegroundColor Gray
Write-Host ""

# ============================================================================
# PARSE TEST RESULTS
# ============================================================================

Write-Host "📊 解析結果..." -ForegroundColor Cyan

# Read test output
$testOutput = Get-Content $testLogFile -Raw -Encoding UTF8

# Parse metrics
$metricsRegex = 'Test\s+(?:Run\s+)?Summary.*?Total\s*=\s*(\d+).*?Passed\s*=\s*(\d+).*?Failed\s*=\s*(\d+).*?Skipped\s*=\s*(\d+)'
$matches = [regex]::Matches($testOutput, $metricsRegex, 'IgnoreCase, Singleline')

if ($matches.Count -eq 0) {
    # Alternative parsing for different output format
    if ($testOutput -match 'Test\s+execution\s+time:.*?(\d+)\s+tests?\s+executed' -or 
        $testOutput -match '成功:\s*(\d+)' -or
        $testOutput -match 'Tests\s+run:\s*(\d+)') {
        
        # Extract individual metrics
        $total = if ($testOutput -match '成功:\s*(\d+)|Tests\s+run:\s*(\d+)') { [int]$matches[1] } else { 0 }
        $passed = if ($testOutput -match '成功:\s*(\d+)') { [int]$matches[1] } else { 0 }
        $failed = if ($testOutput -match '失敗:\s*(\d+)') { [int]$matches[1] } else { 0 }
        $skipped = if ($testOutput -match '略過:\s*(\d+)') { [int]$matches[1] } else { 0 }
    } else {
        Write-Host "⚠️ 警告: 無法解析完整的測試結果。檢查日誌文件:" -ForegroundColor Yellow
        Write-Host "  $testLogFile" -ForegroundColor Yellow
        Write-Host ""
        
        $total = 0
        $passed = 0
        $failed = 0
        $skipped = 0
    }
} else {
    $match = $matches[0]
    $total = [int]$match.Groups[1].Value
    $passed = [int]$match.Groups[2].Value
    $failed = [int]$match.Groups[3].Value
    $skipped = [int]$match.Groups[4].Value
}

# Calculate metrics
$passRate = if ($total -gt 0) { [math]::Round((($passed + $skipped) / $total) * 100, 1) } else { 0 }
$statusEmoji = if ($passRate -ge $PassRateThreshold) { "✅" } else { "❌" }

Write-Host "📈 測試指標:" -ForegroundColor Green
Write-Host "  • 總計: $total 個"
Write-Host "  • 通過: $passed 個 ($(($passed / $total * 100).ToString('F1'))%)" -ForegroundColor Green
Write-Host "  • 失敗: $failed 個 ($(($failed / $total * 100).ToString('F1'))%)" -ForegroundColor $(if ($failed -gt 0) { 'Red' } else { 'Green' })
Write-Host "  • 略過: $skipped 個 ($(($skipped / $total * 100).ToString('F1'))%)" -ForegroundColor Yellow
Write-Host "  • 通過率: $($statusEmoji) ${passRate}% (門檻: ${PassRateThreshold}%)" -ForegroundColor $(if ($passRate -ge $PassRateThreshold) { 'Green' } else { 'Red' })
Write-Host ""

# Gate check
if ($passRate -lt $PassRateThreshold) {
    Write-Host "⚠️ 警告: 通過率低於門檻!" -ForegroundColor Red
    Write-Host "  • 當前: ${passRate}%"
    Write-Host "  • 門檻: ${PassRateThreshold}%"
    Write-Host ""
    Write-Host "💡 建議: 查看詳細日誌進行根本原因分析:" -ForegroundColor Yellow
    Write-Host "  $testLogFile" -ForegroundColor Cyan
}

# ============================================================================
# GENERATE REPORT
# ============================================================================

Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Yellow
Write-Host "📄 生成評估報告" -ForegroundColor Yellow
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Yellow
Write-Host ""

$reportFile = Join-Path $OutputDir "ITQA-Assessment-$timestamp.md"

$reportContent = @"
# 整合測試品質評估報告 (ITQA Report)

**日期**: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')  
**評估程式**: Integration Test Quality Assessor (ITQA)  
**測試組件**: $(Split-Path $TestDll -Leaf)  

---

## 📊 執行摘要

| 指標 | 值 |
|------|-----|
| **狀態** | $statusEmoji $(if ($passRate -ge $PassRateThreshold) { '✅ 符合標準' } else { '❌ 未符合標準' }) |
| **測試總數** | $total 個 |
| **通過數** | $passed 個 ($(($passed / $total * 100).ToString('F1'))%) |
| **失敗數** | $failed 個 ($(($failed / $total * 100).ToString('F1'))%) |
| **略過數** | $skipped 個 ($(($skipped / $total * 100).ToString('F1'))%) |
| **通過率** | **${passRate}%** (門檻: ${PassRateThreshold}%) |
| **執行時間** | 請查看詳細日誌 |

---

## 🔍 根本原因分析

**狀態**: 待進一步診斷

若要進行詳細的根本原因分析，請參考以下文件：
- 測試日誌: \`$testLogFile\`
- 測試結果 (TRX): \`$testResultsFile\`

根據 ITQA 決策框架，失敗可歸類為：
1. **基礎設施** (Infrastructure): MapPath, HttpContext, 環境特定 API
2. **資料** (Data): 測試身份不在 DB、缺少設定記錄
3. **邏輯** (Logic): 業務規則異常、無效狀態
4. **產品缺陷** (Product Defect): NHibernate 類型不匹配、架構漂移

---

## ✅ 品質檢查清單

- [$(if ($passRate -ge $PassRateThreshold) { 'x' } else { ' ' })] 通過率 ≥${PassRateThreshold}% ($passRate%)
- [ ] 產品程式碼完整性維持 (0 行為改變)
- [ ] 可再現性驗證 (≥3 獨立運行)
- [ ] 已知限制文檔化
- [ ] 根本原因識別
- [ ] 基礎設施程式碼審查

---

## 📁 產出檔案

- **測試日誌**: $testLogFile
- **測試結果 (TRX)**: $testResultsFile
- **本報告**: $reportFile

---

## 💡 後續步驟

$(if ($passRate -ge $PassRateThreshold) {
    @"
### ✅ 通過標準 - 已準備好進行 CI/CD 集成

1. **驗證重現性**: 再運行 ≥2 次以確認通過率一致性
2. **檢查已知限制**: 評估是否有需要進一步處理的限制
3. **進行程式碼審查**: 確認任何測試基礎設施變更符合標準
4. **提交至版本控制**: 確認所有變更已適當提交

### 檢查清單:
- [ ] 3 次獨立運行中通過率 ≥${PassRateThreshold}%
- [ ] 無新的產品程式碼行為改變
- [ ] 已知限制已記錄
- [ ] 測試基礎設施已審查
- [ ] 已提交至版本控制 (git)

"@
} else {
    @"
### ⚠️ 未符合標準 - 需要進一步診斷

1. **分析失敗**: 使用 ITQA 決策框架對每個失敗進行分類
   - 詳見: \`.agents/skills/integration-test-quality/references/decision-framework.md\`

2. **實施修復**: 按優先順序應用測試層修復
   - Infrastructure (15-30 分鐘)
   - Data (20-45 分鐘)
   - Logic (30-60 分鐘)
   - Product Defect (10-20 分鐘)

3. **重新運行**: 驗證修復後通過率改善

4. **升級**: 如果無法在測試層解決，請向架構團隊升級

### 檢查清單:
- [ ] 所有失敗已分類至根本原因
- [ ] 測試層修復已實施
- [ ] 通過率改善到 ≥${PassRateThreshold}%
- [ ] 產品程式碼完整性維持
- [ ] 已知限制已文檔化

"@
})

---

## 📚 參考資源

- **ITQA 主要技能文檔**: \`.agents/skills/integration-test-quality/SKILL.md\`
- **決策框架**: \`.agents/skills/integration-test-quality/references/decision-framework.md\`
- **品質檢查清單**: \`.agents/skills/integration-test-quality/references/quality-checklist.md\`
- **測試模式**: \`.agents/skills/integration-test-quality/references/test-patterns.md\`

---

*報告由 ITQA (Integration Test Quality Assessor) 自動生成*  
*OnlineService_SG Skill 版本: 1.0*
"@

Set-Content -Path $reportFile -Value $reportContent -Encoding UTF8

Write-Host "✅ 報告已生成:" -ForegroundColor Green
Write-Host "  $reportFile" -ForegroundColor Cyan
Write-Host ""

# ============================================================================
# SUMMARY
# ============================================================================

Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Yellow
Write-Host "📋 評估摘要" -ForegroundColor Yellow
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Yellow
Write-Host ""

Write-Host "📊 結果概覽:" -ForegroundColor Green
Write-Host "  測試總數: $total | 通過: $passed | 失敗: $failed | 略過: $skipped"
Write-Host "  通過率: $statusEmoji ${passRate}% (要求: ${PassRateThreshold}%)"
Write-Host ""

Write-Host "📁 輸出檔案:" -ForegroundColor Green
Write-Host "  • 報告: $(Split-Path $reportFile -Leaf)" -ForegroundColor Cyan
Write-Host "  • 日誌: $(Split-Path $testLogFile -Leaf)" -ForegroundColor Cyan
Write-Host ""

if ($passRate -ge $PassRateThreshold) {
    Write-Host "✅ 評估完成: 符合品質標準" -ForegroundColor Green
} else {
    Write-Host "⚠️ 評估完成: 需要進一步修復 ($([math]::Ceiling($PassRateThreshold - $passRate))% 改善需求)" -ForegroundColor Red
}

Write-Host ""
Write-Host "💡 建議:" -ForegroundColor Yellow
Write-Host "  • 查看完整報告: $reportFile" -ForegroundColor Cyan
Write-Host "  • 參考 ITQA 技能: .agents/skills/integration-test-quality/" -ForegroundColor Cyan
Write-Host ""

exit $(if ($passRate -ge $PassRateThreshold) { 0 } else { 1 })
