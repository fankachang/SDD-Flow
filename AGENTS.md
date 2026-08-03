# 專案範本規則

> 本檔案每次對話會被自動載入，請只保留**專案特有**的強制規則。
> 通用軟體工程準則交由模型內建能力；詳細開發流程規範見 `.github/instructions/`。
> 治理驗證指令：修改本檔或任何治理檔後，執行一致性檢測（指令見下方「內容分層規則」段）。

## 語言與文件

* 回應語言：`zh-TW`
* 除憲章原文 `constitution.md` 必須用英文外，所有 Spec Kit artifacts（包括規格、計畫、研究、資料模型、契約、快速入門、測試策略、檢查清單與 `tasks.md`）及面向使用者文件必須用正體中文；憲章同目錄必須提供 `constitution_zhTW.md` 中文翻譯。檔名、程式碼、識別符、指令與無通行中文譯名的專有名詞保留原文。
* Git 日誌與程式碼註解使用正體中文。
* 會被下游繼承的 AGENTS、Skills、Prompts、Agents、Spec Kit artifacts 與現行 Docs 不得寫死本樣板 repository 名稱；改用「目前專案」、「此 repository」或語意相符的通用描述。`Docs/History/` 可保留已查證的歷史名稱。

## 決策與開發

* **用戶選擇前強制詢問**：所有需要用戶決策的情境（技術選型、框架/版本選擇、需求模糊、Phase 推進、後續動作選項、檔案刪除確認等），必須用 `vscode/askQuestions`（`#tool:vscode/askQuestions`）提供選項，並**強制保留一個 `allowFreeformInput: true` 的自訂選項**讓用戶可以自由輸入。
  - **例外**：用戶明確指示「不需詢問」或處於 Autopilot 模式時，模型可自行選擇最優方案。
  - ✅ 必須用 askQuestions：「要刪除這個技能嗎？」「接下來要做什麼？」「選擇哪個框架？」
  - ❌ 禁止直接問：文字描述選項後直接結束回合等待用戶回應。
* 呼叫 API/函式前，必須確認其確實存在（禁止臆造）；改以 grep/讀檔查證存在後再呼叫。
* **新增可重用程式碼（函式、方法、類別、模組）前，必須先查重**：已有同用途實作時必須重用或擴充，禁止在其他檔案重複實作；查重方法、共用位置判定與既有重複的收斂流程見 `code-reuse-check` skill。
* **撰寫外部工具/套件文件前**（安裝指令、套件名、repo URL、配置格式、CLI 參數等），**必須**先查證官方來源（npm registry、官方 repo README、官方文件）再落筆；無法查證時須明確標示「未驗證」，禁止憑印象填寫。
* 會被下游繼承或納入版本控制的設定不得寫死使用者名稱、主目錄、磁碟機代號或機器專屬絕對路徑。必須先查證該欄位確實支援的變數或執行時解析；若不支援，改放不納入版本控制的使用者層級設定或由初始化流程產生，禁止提交不會展開的假變數。
* 規格未明確定義時，預設採 TDD。

## Python 虛擬環境

* Python 專案執行前先確認虛擬環境（`python-venv-check` skill 有完整流程）：已有 `.venv` 直接使用，不得重建。

## 技能（Skills）

* 技能位於 `.agents/skills/<skill-id>/`，進入點為 `SKILL.md`（英文），同目錄附 `SKILL_zhTW.md`（中文）。
* **系統已自動列出所有技能與描述**，此處不再重列清單。需要時搜尋 `path:.agents/skills SKILL.md`。
* 新增/編輯 `SKILL.md`（英文）時，必須同步更新 `SKILL_zhTW.md`。
* 困難經驗若已驗證且可泛化，應使用 `adaptive-learning-loop` 追加學習記錄；詳細流程與安全邊界以該 Skill 為準。
* 全域預載（無需重複讀取）：`karpathy-guidelines`（避免過度設計、精準變更、證據優於推測）、`rtk-token-killer`（終端機命令節省 token，實際運作方式見下方政策）。

### RTK Token Killer 使用政策

**重要**：Hook 自動攔截僅在 GitHub Copilot CLI 生效；**VS Code Copilot 不會自動攔截終端機指令**，AI agent 必須**主動**判斷並自行呼叫 `rtk test <cmd>` / `rtk proxy <cmd>`，不得假設已被自動處理而略過。**以下為 AI agent 的強制行為規則，無論是否套用特定角色皆適用**（使用時機、開關操作、SDD Phase 對應等完整說明見 `rtk-token-killer` skill）：

- **一般指令（無特定角色／預設對話）**：以「輸出長度是否可預期」判斷，禁止樂觀預判為短輸出：
  - 輸出長度**不可預期**的命令（全文搜尋、檢測／掃描腳本、log、diff、build、安裝）→ **一律** `rtk proxy <cmd>`
  - 僅當輸出**可預期為單行或數行**（如 `git checkout`、`git branch --show-current`、`command -v`）→ 才可直接執行
  - 測試執行 → `rtk test <cmd>`
- **debugger**：診斷命令一律使用 `rtk proxy <cmd>` 取得完整 log
- **test-review**：測試執行用 `rtk test <cmd>`；失敗逐條分析用 `rtk proxy <cmd>`
- **software-engineer / fullstack-engineer**：build 失敗時改用 `rtk proxy <cmd>` 取得完整錯誤
- **全域關閉**（需要長時間完整輸出時）：macOS/Linux 用 `.agents/skills/rtk-token-killer/rtk-toggle.sh`，Windows pwsh 用 `rtk-toggle.ps1`（完整指令與參數見 `rtk-token-killer` skill）

### 內容分層規則（防重複 / 防遞迴）

新增 SKILL 或修改 AGENTS.md 前，**必須**確認以下分層原則，避免跨文件重複描述：

| 內容類型 | 唯一正確位置（SSOT）|
|---|---|
| 工具/技能的使用說明、配置步驟、指令清單、對應表 | `SKILL.md` / `SKILL_zhTW.md` |
| AI agent 的**強制行為規則**（must/must not） | 全專案規則放 `AGENTS.md`；角色專屬規則放對應 `*.agent.md` |
| 安裝指令、環境設置 | `README.md` 或 `Docs/guides/SpecKit工具與環境.md` |
| 詳細整合流程、背景說明 | `Docs/` 下的專門指南文件 |

**單一真相來源（SSOT）原則**：每項事實只在**一個** canonical 檔案完整描述，其他檔案一律**只用一句話 + 交叉引用**，禁止複製貼上內容。

**編輯前自我檢查（避免 AI 製造重複）**：
1. 我要寫的內容屬於上表哪一類？→ 只能寫進對應的 SSOT 檔案
2. 落筆前先用 grep 搜尋這段內容（指令字串、路徑、表格列）是否已存在於其他檔案 → 若有，改為引用而非重述或複製
3. 若同一份操作說明/對應表出現在 ≥2 個檔案 → 保留 SSOT 那份，其餘刪除並改為指標

**禁止**在 AGENTS.md 中複述 SKILL.md 已有的描述，只能寫「此技能處理 X，詳見 `skill-id`」。
  - ❌ `RTK 安裝：npm i -g ...（完整 3 段步驟複貼）`
  - ✅ `RTK 自動節省 token，安裝與用法詳見 rtk-token-killer skill`
**禁止**在 AGENTS.md 中直接載入或引用另一份會再引用回 AGENTS.md 的文件（避免遞迴讀取）。

**修改治理文件前後強制檢測**：新增/修改任何治理文件後，**必須**以 `--strict` 模式執行檢測（預設模式不會攔截單行/近似重複）確認無 SSOT、成對或重複載入問題；掃描範圍與執行方式詳見 `consistency-check` skill。已設定 `core.hooksPath` 的 clone 會在 commit 時自動執行同一檢測作為最後防線，設定步驟見 `consistency-check` skill。

## 輸出規範

* 回答務必精簡；相關時不得省略技術判斷、風險、必要步驟與驗證方式。
* 省略寒暄、重複說明及重複性的結尾摘要；治理流程要求的完成報告除外。
* 引用既有程式碼、指令、路徑與錯誤訊息時，除非正在修正，應保持原文；敏感資訊必須遮蔽並明確標示。
* 資訊不足時應明確指出，不得為縮短回答而猜測。
* 長任務先列清單確認再逐項執行。

## 專案文件目錄

* 專案設定修正記錄、專案規劃文件等，存放於 `Docs/History/` 目錄。
* 命名規則：`YYYY-MM-DD_內容簡介.md`（例：`2026-07-07_專案設定修正記錄.md`）
* 規格、計畫、面向使用者文件遵循 SpecKit Flow（`.specify/` 目錄）。
* **AI context 可見性**：Agent 不得主動搜尋或讀取 `Docs/{History,examples,guides,research}/**`；僅在使用者明確要求，或可見的治理文件／skill 以精確路徑引用時按需讀取。文件分層見 `Docs/README.md`。
