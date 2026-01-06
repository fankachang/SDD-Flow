# PowerShell UTF-8 環境設定

## 📝 技能說明

在 Windows 環境下使用 PowerShell 執行包含中文的指令或腳本時，若未正確設定編碼，將會出現亂碼問題。本技能文件說明如何在 PowerShell 中正確設定 UTF-8 編碼，確保中文字元正常顯示與處理。

## 🎯 學習目標

完成本技能後，你將能夠：
- ✅ 理解 PowerShell 編碼設定的重要性
- ✅ 在 PowerShell 中正確設定 UTF-8 編碼
- ✅ 選擇適合的 PowerShell 版本（PowerShell 7 vs Windows PowerShell）
- ✅ 驗證編碼設定是否生效

## 📋 前置需求

- Windows 作業系統
- PowerShell 5.1+ 或 PowerShell 7+（推薦）

## 🚀 快速開始

### 步驟 1：開啟 PowerShell

- **推薦**：PowerShell 7 (`pwsh.exe`) - UTF-8 支援更完整
- **替代**：Windows PowerShell (`powershell.exe`) - 需要額外設定

### 步驟 2：執行 UTF-8 設定指令

在 PowerShell 開始執行任何中文相關指令前，先執行以下設定：

```powershell
chcp 65001 > $null
$OutputEncoding = [Console]::OutputEncoding = [Console]::InputEncoding = [System.Text.Encoding]::UTF8
$PSDefaultParameterValues['*:Encoding'] = 'utf8'
```

#### 指令說明

| 指令 | 用途 |
|------|------|
| `chcp 65001 > $null` | 切換控制台代碼頁至 UTF-8 (65001)，`> $null` 隱藏輸出訊息 |
| `$OutputEncoding = ...` | 設定 PowerShell 輸出、主控台輸出與輸入編碼為 UTF-8 |
| `$PSDefaultParameterValues['*:Encoding'] = 'utf8'` | 設定所有 Cmdlet 的預設編碼參數為 UTF-8 |

### 步驟 3：驗證設定

執行以下指令確認編碼設定正確：

```powershell
# 測試輸出中文
Write-Output "測試中文輸出：你好，世界！"

# 檢查當前編碼設定
[Console]::OutputEncoding.EncodingName
# 應該顯示：Unicode (UTF-8)
```

## 💡 最佳實踐

### 多指令鏈結

PowerShell 使用分號 (`;`) 來分隔多個指令，而非 Bash 的 `&&`：

```powershell
# ✅ 正確
chcp 65001 > $null; $OutputEncoding = [System.Text.Encoding]::UTF8; Write-Output "測試"

# ❌ 錯誤（這是 Bash 語法）
chcp 65001 && $OutputEncoding = [System.Text.Encoding]::UTF8
```

### Profile 自動設定

若經常使用 PowerShell，可將 UTF-8 設定加入 PowerShell Profile，每次啟動時自動載入：

```powershell
# 編輯 Profile（若不存在會自動建立）
notepad $PROFILE

# 在 Profile 中加入以下內容：
chcp 65001 > $null
$OutputEncoding = [Console]::OutputEncoding = [Console]::InputEncoding = [System.Text.Encoding]::UTF8
$PSDefaultParameterValues['*:Encoding'] = 'utf8'
```

### VS Code 整合終端機設定

在 VS Code 的 `settings.json` 中可預設使用 PowerShell 7：

```json
{
  "terminal.integrated.defaultProfile.windows": "PowerShell",
  "terminal.integrated.profiles.windows": {
    "PowerShell": {
      "source": "PowerShell",
      "icon": "terminal-powershell",
      "args": [
        "-NoExit",
        "-Command",
        "chcp 65001 > $null; $OutputEncoding = [Console]::OutputEncoding = [Console]::InputEncoding = [System.Text.Encoding]::UTF8; $PSDefaultParameterValues['*:Encoding'] = 'utf8'"
      ]
    }
  }
}
```

## ⚠️ 常見問題

### Q1: 為什麼執行後還是有亂碼？

**A:** 可能原因：
1. 使用的是 Windows PowerShell 5.1（建議升級至 PowerShell 7）
2. 檔案本身編碼不是 UTF-8（請檢查檔案編碼）
3. 終端機字型不支援中文（建議使用 Cascadia Code、Consolas 等）

### Q2: 每次都要手動執行設定指令嗎？

**A:** 不用，可以：
- 將設定加入 PowerShell Profile（見上方「Profile 自動設定」）
- 在 VS Code 中設定預設終端機啟動參數
- 建立啟動腳本 (`.ps1`) 並在執行其他指令前先執行

### Q3: PowerShell 7 在哪裡下載？

**A:** 前往 [PowerShell GitHub Releases](https://github.com/PowerShell/PowerShell/releases) 下載最新版本，或使用 winget 安裝：

```powershell
winget install Microsoft.PowerShell
```

## 🔗 相關資源

- [PowerShell 官方文件](https://learn.microsoft.com/zh-tw/powershell/)
- [about_Character_Encoding](https://learn.microsoft.com/zh-tw/powershell/module/microsoft.powershell.core/about/about_character_encoding)
- [PowerShell 7 新功能](https://learn.microsoft.com/zh-tw/powershell/scripting/whats-new/what-s-new-in-powershell-7)

## ✅ 檢查清單

使用此檢查清單確認你已掌握本技能：

- [ ] 我知道如何在 PowerShell 中設定 UTF-8 編碼
- [ ] 我已驗證設定後中文顯示正常
- [ ] 我了解 PowerShell 7 與 Windows PowerShell 的差異
- [ ] 我知道如何使用分號 (`;`) 串接多個 PowerShell 指令
- [ ] （選用）我已將 UTF-8 設定加入 PowerShell Profile

---

**技能等級**：基礎  
**預估時間**：5-10 分鐘  
**最後更新**：2026-01-06
