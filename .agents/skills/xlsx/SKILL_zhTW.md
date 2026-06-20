---
name: xlsx
description: "完整的試算表建立、編輯與分析工具，支援公式、格式化、資料分析與視覺化。當 Claude 需要處理試算表（.xlsx、.xlsm、.csv、.tsv 等）時使用，包含：(1) 建立含公式與格式的新試算表、(2) 讀取或分析資料、(3) 在保留公式的前提下修改現有試算表、(4) 試算表中的資料分析與視覺化，或 (5) 重新計算公式"
license: 專有授權。完整條款請見 LICENSE.txt
---

# 輸出規範

## 所有 Excel 檔案

### 零公式錯誤
- 每個 Excel 模型交付時**必須**確保零公式錯誤（#REF!、#DIV/0!、#VALUE!、#N/A、#NAME?）

### 保留現有範本（更新範本時）
- 修改檔案時，研究並**精確**符合現有格式、樣式與慣例
- 絕不在有既定格式的檔案上強加標準化格式
- 現有範本的慣例**永遠**優先於這些指南

## 財務模型

### 色彩編碼標準
除非使用者或現有範本另有指定

#### 業界標準色彩慣例
- **藍色文字（RGB：0,0,255）**：硬編碼輸入值，以及使用者會因情境調整的數字
- **黑色文字（RGB：0,0,0）**：**所有**公式與計算結果
- **綠色文字（RGB：0,128,0）**：從同一活頁簿中其他工作表取用的連結
- **紅色文字（RGB：255,0,0）**：連結至其他檔案的外部連結
- **黃色背景（RGB：255,255,0）**：需要注意的關鍵假設，或需要更新的儲存格

### 數字格式標準

#### 必要格式規則
- **年份**：格式化為文字字串（例如「2024」而非「2,024」）
- **貨幣**：使用 $#,##0 格式；在標題中**一律**標明單位（「Revenue ($mm)」）
- **零值**：使用數字格式讓所有零值顯示為「-」，包括百分比（例如「$#,##0;($#,##0);-」）
- **百分比**：預設使用 0.0% 格式（一位小數）
- **倍數**：估值倍數（EV/EBITDA、P/E）格式化為 0.0x
- **負數**：使用括號表示 (123)，而非負號 -123

### 公式建構規則

#### 假設值的放置
- 將**所有**假設值（成長率、利潤率、倍數等）放在獨立的假設儲存格中
- 公式中使用儲存格參照而非硬編碼值
- 範例：使用 =B5*(1+$B$6) 而非 =B5*1.05

#### 公式錯誤預防
- 確認所有儲存格參照正確
- 檢查範圍中的偏移錯誤
- 確保所有預測期間的公式一致
- 使用邊緣案例測試（零值、負數）
- 確認沒有非預期的循環參照

#### 硬編碼值的文件規範
- 在旁邊的儲存格加上備註或說明（若位於表格末端）。格式：「來源：[系統/文件]，[日期]，[具體參照]，[URL（如適用）]」
- 範例：
  - 「來源：Company 10-K，FY2024，第 45 頁，Revenue Note，[SEC EDGAR URL]」
  - 「來源：Company 10-Q，Q2 2025，Exhibit 99.1，[SEC EDGAR URL]」
  - 「來源：Bloomberg Terminal，8/15/2025，AAPL US Equity」
  - 「來源：FactSet，8/20/2025，Consensus Estimates Screen」

# XLSX 建立、編輯與分析

## 概覽

使用者可能會要求你建立、編輯或分析 .xlsx 檔案的內容。不同的任務有不同的可用工具和工作流程。

## 重要需求

**公式重新計算需要 LibreOffice**：可假設已安裝 LibreOffice，用於執行 `recalc.py` 腳本重新計算公式值。該腳本首次執行時會自動設定 LibreOffice。

## 資料庫資源（內部）

本技能旁邊提供了額外的試算表參考資料和範例：

- `spreadsheet.md`：使用環境工具處理試算表的內部指南
- `artifact_tool_spreadsheets_api.md`：內部 API 參考
- `artifact_tool_spreadsheet_formulas.md`：內部公式支援參考
- `examples/`：建立/編輯/樣式化活頁簿的範例腳本

注意：這些文件所參照的部分內部工具屬於專有工具，不應暴露在使用者提供的程式碼中。

## 相容性限制（必須遵守）

- **不要使用動態陣列函式**（例如 `FILTER`、`XLOOKUP`、`SORT`、`SEQUENCE`、`LET`、`UNIQUE`）。這些函式在編輯/重算工具鏈中往往無法可靠處理，可能破壞後續使用。
- **避免使用 Excel 資料表**：不要使用 `=TABLE(...)`。
- 優先使用非揮發性公式；除非絕對必要，否則避免使用 `INDIRECT` 和 `OFFSET`。

## 資料來源引用（表內）

- 新增硬編碼輸入值（尤其是財務假設）時，在表格中附上純文字 URL 及足夠的追溯來源資訊（系統/文件＋日期＋具體參照）。

## 僅限環境使用的工具（不得公開）

- 此資料庫包含內部參考文件，可能有用於試算表渲染/重算的環境工具。
- **不要**在使用者提供的程式碼中包含專有/內部工具的使用方式；請使用標準函式庫如 `openpyxl`/`pandas` 以及提供的 `recalc.py` 工作流程。

## 讀取與分析資料

### 使用 pandas 進行資料分析
資料分析、視覺化及基本操作請使用 **pandas**，它提供強大的資料處理能力：

```python
import pandas as pd

# 讀取 Excel
df = pd.read_excel('file.xlsx')  # 預設：第一個工作表
all_sheets = pd.read_excel('file.xlsx', sheet_name=None)  # 所有工作表（字典）

# 分析
df.head()      # 預覽資料
df.info()      # 欄位資訊
df.describe()  # 統計摘要

# 寫入 Excel
df.to_excel('output.xlsx', index=False)
```

## Excel 檔案工作流程

## 關鍵原則：使用公式，不要硬編碼值

**永遠使用 Excel 公式，而非在 Python 中計算值後硬編碼。** 這確保試算表保持動態且可更新。

### ❌ 錯誤 — 硬編碼計算值
```python
# 錯誤：在 Python 中計算後硬編碼結果
total = df['Sales'].sum()
sheet['B10'] = total  # 硬編碼 5000

# 錯誤：在 Python 中計算成長率
growth = (df.iloc[-1]['Revenue'] - df.iloc[0]['Revenue']) / df.iloc[0]['Revenue']
sheet['C5'] = growth  # 硬編碼 0.15

# 錯誤：Python 計算平均值
avg = sum(values) / len(values)
sheet['D20'] = avg  # 硬編碼 42.5
```

### ✅ 正確 — 使用 Excel 公式
```python
# 正確：讓 Excel 計算加總
sheet['B10'] = '=SUM(B2:B9)'

# 正確：成長率用 Excel 公式
sheet['C5'] = '=(C4-C2)/C2'

# 正確：使用 Excel 函式計算平均
sheet['D20'] = '=AVERAGE(D2:D19)'
```

這適用於所有計算——加總、百分比、比率、差值等。試算表應在來源資料變更時能自動重新計算。

## 一般工作流程
1. **選擇工具**：資料用 pandas，公式/格式化用 openpyxl
2. **建立/載入**：建立新活頁簿或載入現有檔案
3. **修改**：新增/編輯資料、公式和格式
4. **儲存**：寫入檔案
5. **重新計算公式（使用公式時為必要步驟）**：使用 recalc.py 腳本
   ```bash
   python recalc.py output.xlsx
   ```
6. **驗證並修正錯誤**：
   - 腳本以 JSON 格式回傳錯誤詳情
   - 若 `status` 為 `errors_found`，查看 `error_summary` 了解具體錯誤類型和位置
   - 修正錯誤後再次重算
   - 常見錯誤：
     - `#REF!`：無效的儲存格參照
     - `#DIV/0!`：除以零
     - `#VALUE!`：公式中的資料型別錯誤
     - `#NAME?`：無法識別的公式名稱

### 建立新 Excel 檔案

```python
# 使用 openpyxl 處理公式和格式
from openpyxl import Workbook
from openpyxl.styles import Font, PatternFill, Alignment

wb = Workbook()
sheet = wb.active

# 新增資料
sheet['A1'] = 'Hello'
sheet['B1'] = 'World'
sheet.append(['Row', 'of', 'data'])

# 新增公式
sheet['B2'] = '=SUM(A1:A10)'

# 格式化
sheet['A1'].font = Font(bold=True, color='FF0000')
sheet['A1'].fill = PatternFill('solid', start_color='FFFF00')
sheet['A1'].alignment = Alignment(horizontal='center')

# 欄寬
sheet.column_dimensions['A'].width = 20

wb.save('output.xlsx')
```

### 編輯現有 Excel 檔案

```python
# 使用 openpyxl 保留公式和格式
from openpyxl import load_workbook

# 載入現有檔案
wb = load_workbook('existing.xlsx')
sheet = wb.active  # 或 wb['SheetName'] 指定特定工作表

# 處理多個工作表
for sheet_name in wb.sheetnames:
    sheet = wb[sheet_name]
    print(f"工作表：{sheet_name}")

# 修改儲存格
sheet['A1'] = '新值'
sheet.insert_rows(2)  # 在第 2 行插入列
sheet.delete_cols(3)  # 刪除第 3 欄

# 新增工作表
new_sheet = wb.create_sheet('NewSheet')
new_sheet['A1'] = '資料'

wb.save('modified.xlsx')
```

## 重新計算公式

openpyxl 建立或修改的 Excel 檔案包含字串形式的公式，但沒有計算後的值。使用提供的 `recalc.py` 腳本重新計算公式：

```bash
python recalc.py <excel_file> [timeout_seconds]
```

範例：
```bash
python recalc.py output.xlsx 30
```

腳本功能：
- 首次執行時自動設定 LibreOffice 巨集
- 重新計算所有工作表中的所有公式
- 掃描所有儲存格的 Excel 錯誤（#REF!、#DIV/0! 等）
- 以 JSON 格式回傳包含錯誤位置和數量的詳細資訊
- 同時支援 Linux 和 macOS

## 公式驗證檢查清單

確保公式正確運作的快速檢查：

### 基本驗證
- [ ] **測試 2-3 個範例參照**：建立完整模型前，確認這些參照會取用正確的值
- [ ] **欄對應**：確認 Excel 欄位對應正確（例如第 64 欄 = BL，而非 BK）
- [ ] **列偏移**：記住 Excel 列從 1 開始（DataFrame 第 5 列 = Excel 第 6 列）

### 常見陷阱
- [ ] **NaN 處理**：使用 `pd.notna()` 檢查空值
- [ ] **遠右欄位**：FY 資料通常在第 50+ 欄
- [ ] **多重比對**：搜尋所有符合項，不只是第一個
- [ ] **除以零**：在公式中使用 `/` 前先檢查分母（#DIV/0!）
- [ ] **錯誤參照**：確認所有儲存格參照指向正確的儲存格（#REF!）
- [ ] **跨表參照**：使用正確格式（Sheet1!A1）跨工作表連結

### 公式測試策略
- [ ] **從小開始**：先在 2-3 個儲存格測試公式，再廣泛套用
- [ ] **驗證相依性**：確認公式中參照的所有儲存格都存在
- [ ] **測試邊緣案例**：包含零值、負數和極大值

### 解讀 recalc.py 輸出
腳本以 JSON 格式回傳錯誤詳情：
```json
{
  "status": "success",           // 或 "errors_found"
  "total_errors": 0,              // 錯誤總數
  "total_formulas": 42,           // 檔案中的公式數量
  "error_summary": {              // 僅在有錯誤時出現
    "#REF!": {
      "count": 2,
      "locations": ["Sheet1!B5", "Sheet1!C10"]
    }
  }
}
```

## 最佳實踐

### 函式庫選擇
- **pandas**：最適合資料分析、批次操作和簡單資料匯出
- **openpyxl**：最適合複雜格式化、公式和 Excel 特有功能

### 使用 openpyxl
- 儲存格索引從 1 開始（row=1, column=1 指的是儲存格 A1）
- 使用 `data_only=True` 讀取計算後的值：`load_workbook('file.xlsx', data_only=True)`
- **警告**：若以 `data_only=True` 開啟後儲存，公式會被值取代，且**永久遺失**
- 大型檔案：讀取用 `read_only=True`，寫入用 `write_only=True`
- 公式會被保留但不會被評估——使用 recalc.py 更新值
