---
name: docx
description: "全方位的文件建立、編輯與分析工具，支援追蹤修訂、註解、格式保留及文字擷取。當 Claude 需要處理專業文件（.docx 檔案）時使用，包括：(1) 建立新文件、(2) 修改或編輯內容、(3) 處理追蹤修訂、(4) 新增註解，或其他任何文件相關任務。"
license: 專有授權。完整條款請見 LICENSE.txt
---

# DOCX 文件的建立、編輯與分析

## 概覽

使用者可能要求你建立、編輯或分析 .docx 檔案的內容。.docx 檔案本質上是一個包含 XML 檔案和其他資源的 ZIP 壓縮檔，可供讀取或編輯。針對不同任務，有不同的工具和工作流程可供使用。

## 工作流程決策樹

### 讀取／分析內容
使用下方「文字擷取」或「原始 XML 存取」章節

### 建立新文件
使用「建立新 Word 文件」工作流程

### 編輯現有文件
- **自己的文件 + 簡單的修改**
  使用「基本 OOXML 編輯」工作流程

- **他人的文件**
  使用**「紅線標記工作流程」**（建議預設）

- **法律、學術、商業或政府文件**
  使用**「紅線標記工作流程」**（必須）

## 讀取與分析內容

### 文字擷取
若只需要讀取文件的文字內容，應使用 pandoc 將文件轉換為 Markdown。Pandoc 能出色地保留文件結構，並可顯示追蹤修訂：

```bash
# 將文件轉換為含追蹤修訂的 Markdown
pandoc --track-changes=all path-to-file.docx -o output.md
# 選項：--track-changes=accept/reject/all
```

### 原始 XML 存取
以下情況需要原始 XML 存取：註解、複雜格式、文件結構、嵌入媒體以及中繼資料。對於這些功能，需要解壓縮文件並讀取其原始 XML 內容。

#### 解壓縮檔案
`python ooxml/scripts/unpack.py <office_file> <output_directory>`

#### 關鍵檔案結構
* `word/document.xml` — 主要文件內容
* `word/comments.xml` — document.xml 中參照的註解
* `word/media/` — 嵌入的圖片和媒體檔案
* 追蹤修訂使用 `<w:ins>`（插入）和 `<w:del>`（刪除）標籤

## 建立新 Word 文件

從頭建立新 Word 文件時，使用 **docx-js**，它允許你使用 JavaScript/TypeScript 建立 Word 文件。

### 工作流程
1. **必要步驟——讀取完整檔案**：完整閱讀 [`docx-js.md`](docx-js.md)（約 500 行），從頭到尾不遺漏。**絕不設定任何讀取範圍限制。** 在開始建立文件之前，先完整閱讀檔案內容，取得詳細語法、關鍵格式規則和最佳實踐。
2. 使用 Document、Paragraph、TextRun 元件建立 JavaScript/TypeScript 檔案（可假設所有依賴已安裝，若未安裝請參閱下方依賴章節）
3. 使用 Packer.toBuffer() 匯出為 .docx

## 編輯現有 Word 文件

編輯現有 Word 文件時，使用 **Document 函式庫**（一個用於 OOXML 操作的 Python 函式庫）。此函式庫會自動處理基礎設施設定，並提供文件操作方法。對於複雜情境，可透過函式庫直接存取底層 DOM。

### 工作流程
1. **必要步驟——讀取完整檔案**：完整閱讀 [`ooxml.md`](ooxml.md)（約 600 行），從頭到尾不遺漏。**絕不設定任何讀取範圍限制。** 完整閱讀檔案內容以取得 Document 函式庫 API 和直接編輯文件檔案的 XML 模式。
2. 解壓縮文件：`python ooxml/scripts/unpack.py <office_file> <output_directory>`
3. 使用 Document 函式庫建立並執行 Python 腳本（詳見 ooxml.md 的「Document Library」章節）
4. 打包最終文件：`python ooxml/scripts/pack.py <input_directory> <office_file>`

Document 函式庫同時提供常見操作的高階方法，以及複雜情境下的直接 DOM 存取。

## 文件審閱的紅線標記工作流程

此工作流程讓你在用 OOXML 實作前，先以 Markdown 規劃完整的追蹤修訂。**關鍵**：對於完整的追蹤修訂，必須系統性地實作所有修改。

**批次策略**：將相關修改分組，每批 3-10 個修改。這讓除錯更易於管理，同時維持效率。每批測試完再進行下一批。

**原則：最小化、精確的編輯**
實作追蹤修訂時，只標記真正有更動的文字。重複未更動的文字會使編輯更難審閱，且顯得不專業。將替換拆分為：[未更動文字] + [刪除] + [插入] + [未更動文字]。從原始 `<w:r>` 元素中提取並重用，以保留未更動文字的原始 RSID。

範例——將句子中的「30 days」改為「60 days」：
```python
# 錯誤做法——替換整個句子
'<w:del><w:r><w:delText>The term is 30 days.</w:delText></w:r></w:del><w:ins><w:r><w:t>The term is 60 days.</w:t></w:r></w:ins>'

# 正確做法——只標記有更動的部分，保留未更動文字的原始 <w:r>
'<w:r w:rsidR="00AB12CD"><w:t>The term is </w:t></w:r><w:del><w:r><w:delText>30</w:delText></w:r></w:del><w:ins><w:r><w:t>60</w:t></w:r></w:ins><w:r w:rsidR="00AB12CD"><w:t> days.</w:t></w:r>'
```

### 追蹤修訂工作流程

1. **取得 Markdown 表示**：將文件轉換為保留追蹤修訂的 Markdown：
   ```bash
   pandoc --track-changes=all path-to-file.docx -o current.md
   ```

2. **識別並分組修改**：審閱文件，識別所有需要的修改，並將其整理成邏輯批次：

   **定位方法**（在 XML 中尋找修改位置）：
   - 章節／標題編號（例如「Section 3.2」、「Article IV」）
   - 段落識別符（若有編號）
   - 帶有獨特周邊文字的 Grep 模式
   - 文件結構（例如「第一段」、「簽名區塊」）
   - **不要使用 Markdown 行號**——它們無法對應到 XML 結構

   **批次組織**（每批分組 3-10 個相關修改）：
   - 按章節：「批次 1：第 2 節修訂」、「批次 2：第 5 節更新」
   - 按類型：「批次 1：日期修正」、「批次 2：當事人名稱更動」
   - 按複雜度：從簡單的文字替換開始，再處理複雜的結構性修改
   - 按順序：「批次 1：第 1-3 頁」、「批次 2：第 4-6 頁」

3. **閱讀文件並解壓縮**：
   - **必要步驟——讀取完整檔案**：完整閱讀 [`ooxml.md`](ooxml.md)（約 600 行），從頭到尾不遺漏。**絕不設定任何讀取範圍限制。** 特別注意「Document Library」和「Tracked Change Patterns」章節。
   - **解壓縮文件**：`python ooxml/scripts/unpack.py <file.docx> <dir>`
   - **記錄建議的 RSID**：解壓縮腳本會建議一個用於追蹤修訂的 RSID。將此 RSID 複製備用於步驟 4b。

4. **分批實作修改**：將修改邏輯性地分組（按章節、按類型或按位置鄰近性），並在單一腳本中一起實作。這種做法：
   - 讓除錯更容易（批次較小 = 更容易隔離錯誤）
   - 允許增量進展
   - 維持效率（每批 3-10 個修改效果最佳）

   **建議的批次分組：**
   - 按文件章節（例如「第 3 節修改」、「定義條款」、「終止條款」）
   - 按修改類型（例如「日期更動」、「當事人名稱更新」、「法律術語替換」）
   - 按鄰近性（例如「第 1-3 頁的修改」、「文件前半段的修改」）

   對於每批相關修改：

   **a. 將文字對應至 XML**：在 `word/document.xml` 中 Grep 文字，確認文字如何分布在 `<w:r>` 元素之間。

   **b. 建立並執行腳本**：使用 `get_node` 找到節點，實作修改，然後 `doc.save()`。詳見 ooxml.md 的「Document Library」章節取得模式。

   **注意**：每次撰寫腳本前，立即 Grep `word/document.xml` 以取得當前行號並確認文字內容。每次執行腳本後行號都會改變。

5. **打包文件**：所有批次完成後，將解壓縮目錄轉換回 .docx：
   ```bash
   python ooxml/scripts/pack.py unpacked reviewed-document.docx
   ```

6. **最終驗證**：對完整文件進行全面檢查：
   - 將最終文件轉換為 Markdown：
     ```bash
     pandoc --track-changes=all reviewed-document.docx -o verification.md
     ```
   - 確認所有修改均已正確套用：
     ```bash
     grep "original phrase" verification.md  # 不應找到
     grep "replacement phrase" verification.md  # 應能找到
     ```
   - 確認沒有引入非預期的修改


## 將文件轉換為圖片

要視覺化分析 Word 文件，可透過兩個步驟將其轉換為圖片：

1. **將 DOCX 轉換為 PDF**：
   ```bash
   soffice --headless --convert-to pdf document.docx
   ```

2. **將 PDF 頁面轉換為 JPEG 圖片**：
   ```bash
   pdftoppm -jpeg -r 150 document.pdf page
   ```
   這會產生 `page-1.jpg`、`page-2.jpg` 等檔案。

選項：
- `-r 150`：設定解析度為 150 DPI（可依品質／大小需求調整）
- `-jpeg`：輸出 JPEG 格式（若偏好 PNG 則使用 `-png`）
- `-f N`：要轉換的起始頁（例如 `-f 2` 從第 2 頁開始）
- `-l N`：要轉換的結束頁（例如 `-l 5` 在第 5 頁停止）
- `page`：輸出檔案的前綴名稱

指定範圍的範例：
```bash
pdftoppm -jpeg -r 150 -f 2 -l 5 document.pdf page  # 只轉換第 2-5 頁
```

## 程式碼風格指南
**重要**：為 DOCX 操作生成程式碼時：
- 撰寫簡潔的程式碼
- 避免冗長的變數名稱和多餘的操作
- 避免不必要的 print 陳述式

## 依賴套件

所需依賴（若未安裝請先安裝）：

- **pandoc**：`sudo apt-get install pandoc`（用於文字擷取）
- **docx**：`npm install -g docx`（用於建立新文件）
- **LibreOffice**：`sudo apt-get install libreoffice`（用於 PDF 轉換）
- **Poppler**：`sudo apt-get install poppler-utils`（用於 pdftoppm 將 PDF 轉換為圖片）
- **defusedxml**：`pip install defusedxml`（用於安全的 XML 解析）
