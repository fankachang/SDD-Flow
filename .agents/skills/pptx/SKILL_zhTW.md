---
name: pptx
description: "簡報建立、編輯與分析。當 Claude 需要處理簡報（.pptx 檔案）時使用，包含：(1) 建立新簡報、(2) 修改或編輯內容、(3) 處理版面配置、(4) 新增注釋或講者備忘稿，或任何其他簡報任務"
license: 專有授權。完整條款請見 LICENSE.txt
---

# PPTX 建立、編輯與分析

## 概覽

使用者可能會要求你建立、編輯或分析 .pptx 檔案的內容。.pptx 檔案本質上是一個包含 XML 檔案和其他資源的 ZIP 壓縮包，你可以讀取或編輯它。不同的任務有不同的可用工具和工作流程。

## 讀取與分析內容

### 文字擷取
若只需要讀取簡報的文字內容，應將文件轉換為 Markdown：

```bash
# 將文件轉換為 Markdown
python -m markitdown path-to-file.pptx
```

### 原始 XML 存取
以下情況需要原始 XML 存取：注釋、講者備忘稿、投影片版面、動畫、設計元素和複雜格式。這些功能需要解包簡報並讀取其原始 XML 內容。

#### 解包檔案
`python ooxml/scripts/unpack.py <office_file> <output_dir>`

**注意**：unpack.py 腳本位於相對於專案根目錄的 `skills/pptx/ooxml/scripts/unpack.py`。若腳本不在此路徑，使用 `find . -name "unpack.py"` 定位。

#### 主要檔案結構
* `ppt/presentation.xml` — 主要簡報中繼資料和投影片參照
* `ppt/slides/slide{N}.xml` — 個別投影片內容（slide1.xml、slide2.xml 等）
* `ppt/notesSlides/notesSlide{N}.xml` — 每張投影片的講者備忘稿
* `ppt/comments/modernComment_*.xml` — 特定投影片的注釋
* `ppt/slideLayouts/` — 投影片的版面配置範本
* `ppt/slideMasters/` — 母片範本
* `ppt/theme/` — 佈景主題和樣式資訊
* `ppt/media/` — 圖片和其他媒體檔案

#### 字型與顏色擷取
**當給定要仿效的設計範例時**：始終先使用以下方法分析簡報的字型和顏色：
1. **讀取佈景主題檔案**：查看 `ppt/theme/theme1.xml` 的顏色（`<a:clrScheme>`）和字型（`<a:fontScheme>`）
2. **取樣投影片內容**：查看 `ppt/slides/slide1.xml` 的實際字型用法（`<a:rPr>`）和顏色
3. **搜尋模式**：使用 grep 在所有 XML 檔案中找尋顏色（`<a:solidFill>`、`<a:srgbClr>`）和字型參照

## 從頭建立新 PowerPoint 簡報（**不使用範本**）

從頭建立新 PowerPoint 簡報時，使用 **html2pptx** 工作流程，將 HTML 投影片轉換為具有精確定位的 PowerPoint。

### 設計原則

**重要**：建立任何簡報前，先分析內容並選擇適當的設計元素：
1. **考量主題內容**：這份簡報是關於什麼的？它暗示什麼樣的基調、產業或氛圍？
2. **檢查品牌識別**：若使用者提到公司/組織，考量其品牌顏色和識別
3. **配色符合內容**：選擇反映主題的顏色
4. **說明設計理念**：在撰寫程式碼前說明你的設計選擇

**需求**：
- ✅ 撰寫程式碼前說明內容驅動的設計理念
- ✅ 只使用網頁安全字型：Arial、Helvetica、Times New Roman、Georgia、Courier New、Verdana、Tahoma、Trebuchet MS、Impact
- ✅ 透過大小、粗細和顏色建立清晰的視覺層次
- ✅ 確保可讀性：強烈對比、適當大小的文字、整齊對齊
- ✅ 保持一致：在所有投影片中重複相同的模式、間距和視覺語言

#### 配色方案選擇

**創意地選擇顏色**：
- **超越預設**：哪些顏色真正符合這個特定主題？避免自動選擇。
- **從多個角度考慮**：主題、產業、氛圍、能量層次、目標受眾、品牌識別（若有提及）
- **大膽嘗試**：試試出人意料的組合——醫療保健簡報不一定要用綠色，財務不一定要用深藍
- **建立調色板**：選擇 3-5 個搭配的顏色（主色＋輔助色調＋強調色）
- **確保對比度**：文字必須在背景上清晰可讀

**配色方案範例**（用來激發創意——選擇一個、調整它，或建立自己的）：

1. **經典藍**：深海軍藍 (#1C2833)、板岩灰 (#2E4053)、銀色 (#AAB7B8)、米白 (#F4F6F6)
2. **藍綠與珊瑚**：藍綠 (#5EA8A7)、深藍綠 (#277884)、珊瑚 (#FE4447)、白色 (#FFFFFF)
3. **大膽紅**：紅 (#C0392B)、亮紅 (#E74C3C)、橙 (#F39C12)、黃 (#F1C40F)、綠 (#2ECC71)
4. **暖玫瑰**：茱萸粉 (#A49393)、嫩粉 (#EED6D3)、玫瑰 (#E8B4B8)、奶油 (#FAF7F2)
5. **勃艮第奢華**：勃艮第 (#5D1D2E)、深紅 (#951233)、鐵鏽 (#C15937)、金 (#997929)
6. **深紫與翠綠**：紫 (#B165FB)、深藍 (#181B24)、翠綠 (#40695B)、白色 (#FFFFFF)
7. **奶油與森林綠**：奶油 (#FFE1C7)、森林綠 (#40695B)、白色 (#FCFCFC)
8. **粉與紫**：粉 (#F8275B)、珊瑚 (#FF574A)、玫瑰 (#FF737D)、紫 (#3D2F68)
9. **萊姆與梅紅**：萊姆 (#C5DE82)、梅紅 (#7C3A5F)、珊瑚 (#FD8C6E)、藍灰 (#98ACB5)
10. **黑與金**：金 (#BF9A4A)、黑 (#000000)、奶油 (#F4F6F6)
11. **鼠尾草與赭紅**：鼠尾草 (#87A96B)、赭紅 (#E07A5F)、奶油 (#F4F1DE)、炭灰 (#2C2C2C)
12. **炭灰與紅**：炭灰 (#292929)、紅 (#E33737)、淺灰 (#CCCBCB)
13. **活力橙**：橙 (#F96D00)、淺灰 (#F2F2F2)、炭灰 (#222831)
14. **森林綠**：黑 (#191A19)、綠 (#4E9F3D)、深綠 (#1E5128)、白色 (#FFFFFF)
15. **復古彩虹**：紫 (#722880)、粉 (#D72D51)、橙 (#EB5C18)、琥珀 (#F08800)、金 (#DEB600)
16. **復古大地**：芥末黃 (#E3B448)、鼠尾草 (#CBD18F)、森林綠 (#3A6B35)、奶油 (#F4F1DE)
17. **海岸玫瑰**：老玫瑰 (#AD7670)、河狸 (#B49886)、蛋殼 (#F3ECDC)、灰綠 (#BFD5BE)
18. **橙與藍綠**：淺橙 (#FC993E)、灰藍綠 (#667C6F)、白色 (#FCFCFC)

#### 視覺細節選項

**幾何圖案**：
- 對角線段落分隔線取代水平線
- 不對稱欄寬（30/70、40/60、25/75）
- 旋轉 90° 或 270° 的文字標題
- 圓形/六角形圖片框架
- 角落的三角形強調形狀
- 重疊形狀增加層次感

**邊框與框架處理**：
- 只在單側的粗色邊框（10-20pt）
- 對比色的雙線邊框
- 取代完整框架的角括號
- L 型邊框（上+左 或 下+右）
- 標題下方的底線強調（3-5pt 粗）

**字型處理**：
- 極端的尺寸對比（72pt 標題 vs. 11pt 正文）
- 全大寫標題搭配寬字距
- 超大顯示字型的編號段落
- 資料/統計/技術內容使用等寬字型（Courier New）
- 密集資訊使用壓縮字型（Arial Narrow）
- 強調用的描邊文字

**圖表與資料樣式**：
- 單色圖表搭配關鍵資料的強調色
- 水平長條圖取代垂直
- 點圖取代長條圖
- 最少或無格線
- 直接在元素上的資料標籤（無圖例）
- 關鍵指標使用超大數字

**版面配置創新**：
- 全出血圖片搭配文字疊加
- 側邊欄（20-30% 寬）用於導航/脈絡
- 模組化網格系統（3×3、4×4 方塊）
- Z 型或 F 型內容流
- 彩色形狀上的浮動文字框
- 雜誌風格的多欄版面

**背景處理**：
- 占據投影片 40-60% 的純色色塊
- 填充漸層（只用垂直或對角線）
- 分割背景（兩種顏色，對角線或垂直分割）
- 從邊到邊的色帶
- 負空間作為設計元素

### 版面配置提示
**建立含圖表或表格的投影片時：**
- **雙欄版面（建議）**：使用橫跨全寬的標題，下方分兩欄——一欄放文字/條列，另一欄放主要內容。使用 flexbox 搭配不等欄寬（例如 40%/60% 分割）以最佳化各類型內容的空間。
- **全投影片版面**：讓主要內容（圖表/表格）占據整張投影片以獲得最大衝擊力和可讀性
- **絕不垂直堆疊**：不要將圖表/表格放在文字下方的單欄中——這會導致可讀性差和版面問題

### 工作流程
1. **必要——閱讀整份檔案**：從頭到尾完整閱讀 [`html2pptx.md`](html2pptx.md)。**讀取此檔案時絕不設定任何範圍限制。** 在開始建立簡報前，閱讀完整的檔案內容以了解詳細語法、重要格式規則和最佳實踐。
2. 為每張投影片建立 HTML 檔案，設定適當尺寸（例如 16:9 為 720pt × 405pt）
   - 所有文字內容使用 `<p>`、`<h1>`-`<h6>`、`<ul>`、`<ol>`
   - 圖表/表格要添加的區域使用 `class="placeholder"`（以灰色背景渲染以提高可見性）
   - **重要**：先使用 Sharp 將漸層和圖示柵格化為 PNG 圖片，再在 HTML 中參照
   - **版面**：含圖表/表格/圖片的投影片，使用全投影片版面或雙欄版面以提高可讀性
3. 使用 [`html2pptx.js`](scripts/html2pptx.js) 函式庫建立並執行 JavaScript 檔案，將 HTML 投影片轉換為 PowerPoint 並儲存簡報
   - 使用 `html2pptx()` 函式處理每個 HTML 檔案
   - 使用 PptxGenJS API 在占位符區域加入圖表和表格
   - 使用 `pptx.writeFile()` 儲存簡報
4. **視覺驗證**：生成縮圖並檢查版面問題
   - 建立縮圖網格：`python scripts/thumbnail.py output.pptx workspace/thumbnails --cols 4`
   - 仔細檢查縮圖圖片，確認：
     - **文字被截斷**：文字被標題列、形狀或投影片邊緣截斷
     - **文字重疊**：文字與其他文字或形狀重疊
     - **定位問題**：內容太靠近投影片邊界或其他元素
     - **對比度問題**：文字和背景之間對比度不足
   - 若發現問題，調整 HTML 的邊距/間距/顏色並重新生成簡報
   - 重複直到所有投影片在視覺上正確

## 編輯現有 PowerPoint 簡報

編輯現有 PowerPoint 簡報中的投影片時，需要處理原始的 Office Open XML（OOXML）格式。這包括解包 .pptx 檔案、編輯 XML 內容，然後重新打包。

### 工作流程
1. **必要——閱讀整份檔案**：從頭到尾完整閱讀 [`ooxml.md`](ooxml.md)（約 500 行）。**讀取此檔案時絕不設定任何範圍限制。** 在進行任何簡報編輯前，閱讀完整的檔案內容以了解 OOXML 結構和編輯工作流程的詳細指引。
2. 解包簡報：`python ooxml/scripts/unpack.py <office_file> <output_dir>`
3. 編輯 XML 檔案（主要是 `ppt/slides/slide{N}.xml` 和相關檔案）
4. **重要**：每次編輯後立即驗證，在繼續前修正任何驗證錯誤：`python ooxml/scripts/validate.py <dir> --original <file>`
5. 打包最終簡報：`python ooxml/scripts/pack.py <input_directory> <office_file>`

## 使用範本建立新 PowerPoint 簡報

當需要建立遵循現有範本設計的簡報時，在替換占位符內容之前，需要先複製和重新排列範本投影片。

### 工作流程
1. **擷取範本文字並建立視覺縮圖網格**：
   * 擷取文字：`python -m markitdown template.pptx > template-content.md`
   * 讀取 `template-content.md`：閱讀整份檔案以了解範本簡報的內容。**讀取此檔案時絕不設定任何範圍限制。**
   * 建立縮圖網格：`python scripts/thumbnail.py template.pptx`
   * 詳見[建立縮圖網格](#建立縮圖網格)章節

2. **分析範本並將清單儲存至檔案**：
   * **視覺分析**：審閱縮圖網格以了解投影片版面、設計模式和視覺結構
   * 在 `template-inventory.md` 建立並儲存範本清單，包含：
     ```markdown
     # 範本清單分析
     **投影片總數：[數量]**
     **重要：投影片從 0 開始索引（第一張 = 0，最後一張 = 數量-1）**

     ## [類別名稱]
     - 投影片 0：[版面代碼（若有）] — 說明/用途
     - 投影片 1：[版面代碼] — 說明/用途
     - 投影片 2：[版面代碼] — 說明/用途
     [... 必須列出每張投影片及其索引 ...]
     ```
   * **使用縮圖網格**：參考視覺縮圖以識別：
     - 版面模式（標題投影片、內容版面、章節分隔）
     - 圖片占位符的位置和數量
     - 投影片群組間的設計一致性
     - 視覺層次和結構
   * 下一步需要此清單檔案以選擇合適的範本

3. **根據範本清單建立簡報大綱**：
   * 從步驟 2 審閱可用範本。
   * 為第一張投影片選擇片頭或標題範本。通常是最前面的範本之一。
   * 為其他投影片選擇安全的純文字版面。
   * **重要：使版面結構符合實際內容**：
     - 單欄版面：用於統一的敘述或單一主題
     - 雙欄版面：只在恰好有 2 個不同項目/概念時使用
     - 三欄版面：只在恰好有 3 個不同項目/概念時使用
     - 圖片＋文字版面：只在有實際圖片要插入時使用
     - 引言版面：只用於實際引用某人的話（附署名），絕不用於強調
     - 絕不使用占位符多於內容的版面
     - 若有 2 個項目，不要強迫放入三欄版面
     - 若有 4 個以上的項目，考慮拆分成多張投影片或使用列表格式
   * 選擇前先計算實際的內容項目數量
   * 確認所選版面的每個占位符都會填入有意義的內容
   * 為每個內容區段選擇**最佳**版面。
   * 儲存 `outline.md`，包含內容**和**利用可用設計的範本對應
   * 範本對應範例：
      ```
      # 要使用的範本投影片（0 基索引）
      # 警告：確認索引在範圍內！73 張投影片的範本索引為 0-72
      # 對應：大綱中的投影片編號 -> 範本投影片索引
      template_mapping = [
          0,   # 使用投影片 0（標題/封面）
          34,  # 使用投影片 34（B1：標題和內文）
          34,  # 再次使用投影片 34（第二個 B1 的複本）
          50,  # 使用投影片 50（E1：引言）
          54,  # 使用投影片 54（F2：結尾＋文字）
      ]
      ```

4. **使用 `rearrange.py` 複製、重新排序和刪除投影片**：
   * 使用 `scripts/rearrange.py` 腳本以所需順序建立新簡報：
     ```bash
     python scripts/rearrange.py template.pptx working.pptx 0,34,34,50,52
     ```
   * 該腳本自動處理重複投影片、刪除未使用投影片和重新排序
   * 投影片索引從 0 開始（第一張是 0，第二張是 1，依此類推）
   * 同一個投影片索引可出現多次以複製該投影片

5. **使用 `inventory.py` 腳本擷取所有文字**：
   * **執行清單擷取**：
     ```bash
     python scripts/inventory.py working.pptx text-inventory.json
     ```
   * **讀取 text-inventory.json**：閱讀整份 text-inventory.json 以了解所有形狀及其屬性。**讀取此檔案時絕不設定任何範圍限制。**

   * 清單 JSON 結構：
      ```json
        {
          "slide-0": {
            "shape-0": {
              "placeholder_type": "TITLE",  // 或非占位符時為 null
              "left": 1.5,                  // 位置（英吋）
              "top": 2.0,
              "width": 7.5,
              "height": 1.2,
              "paragraphs": [
                {
                  "text": "段落文字",
                  // 可選屬性（只在非預設值時包含）：
                  "bullet": true,           // 明確偵測到的條列
                  "level": 0,               // 只在 bullet 為 true 時包含
                  "alignment": "CENTER",    // CENTER、RIGHT（非 LEFT）
                  "space_before": 10.0,     // 段落前間距（pt）
                  "space_after": 6.0,       // 段落後間距（pt）
                  "line_spacing": 22.4,     // 行距（pt）
                  "font_name": "Arial",     // 來自第一個 run
                  "font_size": 14.0,        // pt 單位
                  "bold": true,
                  "italic": false,
                  "underline": false,
                  "color": "FF0000"         // RGB 顏色
                }
              ]
            }
          }
        }
      ```

   * 主要功能：
     - **投影片**：命名為「slide-0」、「slide-1」等
     - **形狀**：依視覺位置排序（從上到下、從左到右），命名為「shape-0」、「shape-1」等
     - **占位符類型**：TITLE、CENTER_TITLE、SUBTITLE、BODY、OBJECT 或 null
     - **預設字型大小**：從版面占位符擷取的 `default_font_size`（若有）
     - **投影片編號已篩除**：SLIDE_NUMBER 占位符類型的形狀自動從清單中排除
     - **條列**：當 `bullet: true` 時，`level` 始終包含（即使為 0）

6. **生成替換文字並將資料儲存至 JSON 檔案**
   根據前一步驟的文字清單：
   - **重要**：先確認清單中存在哪些形狀——只參照實際存在的形狀
   - **驗證**：replace.py 腳本會驗證替換 JSON 中的所有形狀存在於清單中
     - 若參照不存在的形狀，會收到顯示可用形狀的錯誤
     - 若參照不存在的投影片，會收到指示該投影片不存在的錯誤
     - 所有驗證錯誤在腳本退出前一次顯示
   - **重要**：replace.py 腳本在內部使用 inventory.py 識別所有文字形狀
   - **自動清除**：除非在替換 JSON 中為它們提供「paragraphs」，否則清單中的所有文字形狀都會被清除
   - 將「paragraphs」欄位加入需要內容的形狀（不是「replacement_paragraphs」）
   - 替換 JSON 中沒有「paragraphs」的形狀會自動清除其文字
   - 有條列的段落會自動靠左對齊。`"bullet": true` 時不要設定 `alignment` 屬性
   - 為占位符文字生成適當的替換內容
   - 使用形狀大小決定適當的內容長度
   - **重要**：包含原始清單中的段落屬性——不只提供文字
   - **重要**：`bullet: true` 時，文字中**不要**包含條列符號（•、-、*）——它們會自動添加
   - **必要格式規則**：
     - 標題通常應有 `"bold": true`
     - 列表項目應有 `"bullet": true, "level": 0`（bullet 為 true 時 level 是必要的）
     - 保留任何對齊屬性（例如置中文字用 `"alignment": "CENTER"`）
     - 與預設值不同時包含字型屬性（例如 `"font_size": 14.0`、`"font_name": "Lora"`）
     - 顏色：使用 `"color": "FF0000"` 表示 RGB，或 `"theme_color": "DARK_1"` 表示佈景主題顏色
     - 替換腳本期望**格式正確的段落**，而非只是文字字串
     - **重疊形狀**：優先使用 default_font_size 較大或 placeholder_type 更適合的形狀
   - 將含替換值的更新清單儲存至 `replacement-text.json`
   - **警告**：不同範本版面有不同的形狀數量——建立替換值前始終檢查實際清單

   段落欄位範例（展示正確格式）：
   ```json
   "paragraphs": [
     {
       "text": "新簡報標題文字",
       "alignment": "CENTER",
       "bold": true
     },
     {
       "text": "章節標題",
       "bold": true
     },
     {
       "text": "不含條列符號的第一個條列點",
       "bullet": true,
       "level": 0
     },
     {
       "text": "紅色文字",
       "color": "FF0000"
     },
     {
       "text": "佈景主題顏色文字",
       "theme_color": "DARK_1"
     },
     {
       "text": "不含特殊格式的一般段落文字"
     }
   ]
   ```

   **未列在替換 JSON 中的形狀會自動清除**：
   ```json
   {
     "slide-0": {
       "shape-0": {
         "paragraphs": [...] // 此形狀取得新文字
       }
       // 清單中的 shape-1 和 shape-2 會自動清除
     }
   }
   ```

   **簡報的常見格式模式**：
   - 標題投影片：粗體文字，有時置中
   - 投影片中的章節標題：粗體文字
   - 條列清單：每個項目需要 `"bullet": true, "level": 0`
   - 正文：通常不需要特殊屬性
   - 引言：可能有特殊對齊或字型屬性

7. **使用 `replace.py` 腳本套用替換**
   ```bash
   python scripts/replace.py working.pptx replacement-text.json output.pptx
   ```

   腳本功能：
   - 首先使用 inventory.py 中的函式擷取所有文字形狀的清單
   - 驗證替換 JSON 中的所有形狀存在於清單中
   - 清除清單中識別的所有形狀的文字
   - 只將新文字套用到替換 JSON 中有定義「paragraphs」的形狀
   - 透過套用 JSON 中的段落屬性保留格式
   - 自動處理條列、對齊、字型屬性和顏色
   - 儲存更新後的簡報

   驗證錯誤範例：
   ```
   ERROR: 替換 JSON 中的無效形狀：
     - 「slide-0」上找不到形狀「shape-99」。可用形狀：shape-0、shape-1、shape-4
     - 清單中找不到投影片「slide-999」
   ```

   ```
   ERROR: 替換文字使以下形狀的溢出情況更嚴重：
     - slide-0/shape-2：溢出加劇 1.25"（原本 0.00"，現在 1.25"）
   ```

## 建立縮圖網格

要建立 PowerPoint 投影片的視覺縮圖網格以快速分析和參考：

```bash
python scripts/thumbnail.py template.pptx [output_prefix]
```

**功能**：
- 建立：`thumbnails.jpg`（或大型簡報的 `thumbnails-1.jpg`、`thumbnails-2.jpg` 等）
- 預設：5 欄，每個網格最多 30 張投影片（5×6）
- 自訂前綴：`python scripts/thumbnail.py template.pptx my-grid`
  - 注意：若要輸出到特定目錄，輸出前綴應包含路徑（例如 `workspace/my-grid`）
- 調整欄數：`--cols 4`（範圍：3-6，影響每個網格的投影片數）
- 網格限制：3 欄 = 12 張/網格，4 欄 = 20，5 欄 = 30，6 欄 = 42
- 投影片從零開始索引（投影片 0、投影片 1 等）

**使用場景**：
- 範本分析：快速了解投影片版面和設計模式
- 內容審閱：整份簡報的視覺概覽
- 導航參考：依視覺外觀找到特定投影片
- 品質檢查：確認所有投影片格式正確

**範例**：
```bash
# 基本用法
python scripts/thumbnail.py presentation.pptx

# 組合選項：自訂名稱、欄數
python scripts/thumbnail.py template.pptx analysis --cols 4
```

## 將投影片轉換為圖片

要視覺分析 PowerPoint 投影片，使用兩步驟流程將其轉換為圖片：

1. **將 PPTX 轉換為 PDF**：
   ```bash
   soffice --headless --convert-to pdf template.pptx
   ```

2. **將 PDF 頁面轉換為 JPEG 圖片**：
   ```bash
   pdftoppm -jpeg -r 150 template.pdf slide
   ```
   這會建立 `slide-1.jpg`、`slide-2.jpg` 等檔案。

選項：
- `-r 150`：設定解析度為 150 DPI（調整以平衡品質/大小）
- `-jpeg`：輸出 JPEG 格式（若偏好 PNG 使用 `-png`）
- `-f N`：要轉換的第一頁（例如 `-f 2` 從第 2 頁開始）
- `-l N`：要轉換的最後一頁（例如 `-l 5` 在第 5 頁停止）
- `slide`：輸出檔案的前綴

特定範圍的範例：
```bash
pdftoppm -jpeg -r 150 -f 2 -l 5 template.pdf slide  # 只轉換第 2-5 頁
```

## 程式碼風格指南
**重要**：為 PPTX 操作生成程式碼時：
- 撰寫簡潔的程式碼
- 避免冗長的變數名稱和多餘的操作
- 避免不必要的 print 陳述式

## 相依套件

所需的相依套件（應已安裝）：

- **markitdown**：`pip install "markitdown[pptx]"`（用於從簡報中擷取文字）
- **pptxgenjs**：`npm install -g pptxgenjs`（透過 html2pptx 建立簡報）
- **playwright**：`npm install -g playwright`（用於 html2pptx 中的 HTML 渲染）
- **react-icons**：`npm install -g react-icons react react-dom`（用於圖示）
- **sharp**：`npm install -g sharp`（用於 SVG 柵格化和圖片處理）
- **LibreOffice**：`sudo apt-get install libreoffice`（用於 PDF 轉換）
- **Poppler**：`sudo apt-get install poppler-utils`（用於 pdftoppm 將 PDF 轉換為圖片）
- **defusedxml**：`pip install defusedxml`（用於安全的 XML 解析）
