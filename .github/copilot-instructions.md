<!-- Copilot rules: See .github/instructions/ and AGENTS.md -->

# Copilot Instructions

## 專案定位

此專案是 **SDD 開發範本模板**，用於初始化其他專案，而非單一產品專案。
- 此檔案會被複製到下游專案，避免寫死本 repo 的名稱或內部結構
- 下游專案可能是棕地專案或非 SDD 專案，保持指引通用性

### `.specify/` 目錄結構

- `.specify/memory/constitution.md` — 憲章 placeholder，下游專案用 `/speckit.constitution` 更新
- `.specify/templates/` — SpecKit 原始範本檔案（spec/plan/tasks/checklist）
- **不要修改這些範本檔案**，它們會被複製到下游專案使用

## 專案技術棧與環境

<!-- 尚未初始化。執行 `/project-init` 完成偵測與使用者確認後，取代本區塊內容。 -->

- **作業系統／Shell**：[待偵測]
- **主要語言／執行環境**：[待偵測]
- **套件管理器**：[待偵測]
- **建置/編譯工具**：[待偵測]
- **RTK 安裝狀態**：[待偵測]

## 模糊任務處理

遇到模糊任務（如「優化專案」、「檢查重複」）時：
- **禁止直接全目錄掃描所有檔案**（會產生極高 token 消耗）
- 先列出 3-5 個可選的掃描範圍，等用戶確認
- 優先檢查已知的關鍵目錄：`.github/`、`.agents/`、`.specify/`、`Docs/`

## 檔案讀取策略

- 優先使用 `grep`/`glob` 定位目標檔案，避免 `cat`/`view` 全檔讀取
- 超過 500 KB 的檔案使用 `view_range` 指定範圍
- 超過 2 MB 的檔案**禁止**整個讀取（詳見 `.github/instructions/code-safety.instructions.md`）

## 檔案修改策略

- 修改檔案時，先確認並使用目前工作階段實際提供的內建編輯工具
- **禁止**在 terminal 將 `apply_patch` 當成 shell 指令執行；它不是目前 VS Code Copilot shell 環境可用的 executable
- 若沒有內建編輯工具，先查證替代工具確實存在，再以最小範圍修改

## Agent 結果不可用時

當 background agent 結果無法取得時：
- 不要重複嘗試或循環訊息
- 直接回溯工具已輸出的內容進行分析
- 若完全無法取得，請用戶確認是否重試

## RTK Token Killer Fallback 策略（VS Code Copilot）

**現況**：VS Code Copilot 目前不支援 `.github/hooks/` 自動攔截機制。

**AI 強制行為**：根據 AGENTS.md 的 RTK 使用政策，AI agent 必須主動判斷並使用適當的 RTK 模式：

| 場景 | 使用命令 | 理由 |
|------|---------|------|
| 輸出可預期為單行／數行的基本操作 | 直接執行 | 輸出已經很短，無需壓縮 |
| 輸出長度不可預期（搜尋／檢測／log／diff） | `rtk proxy <cmd>` | 需要完整輸出進行診斷 |
| 測試執行（摘要） | `rtk test <cmd>` | 只需 pass/fail 摘要 |
| Build 失敗 | `rtk proxy <cmd>` | 需要完整編譯錯誤 |

**專案配置**：`rtk` 執行檔需在 PATH 上可用（見 `rtk-token-killer` skill 的安裝步驟）；`.vscode/copilot-terminal-init.ps1` 僅負責 TMPDIR 與 UTF-8 編碼初始化，不設定別名。

## 跨平台意識

預設使用跨平台相容的指令與語法：

| 情境 | ❌ 避免 | ✅ 使用 |
|------|--------|--------|
| 刪除檔案 | `rm -rf` (Unix only) | 詢問用戶或使用 bash tool 判斷 OS |
| 檢視檔案 | `cat` (Windows 行為不同) | `view` tool |
| 路徑分隔符 | 寫死 `/` 或 `\` | 使用相對路徑或 `os.path.join` |
| 搜尋檔案 | `find` (Windows 內建衝突) | `glob` tool |
| PowerShell | 直接執行 (編碼問題) | 使用 `RunPowerShell` skill |

## 與現有文件的關係

| 文件 | 涵蓋範圍 | 適用檔案類型 |
|------|---------|-------------|
| `AGENTS.md` | 專案核心規則（語言、決策、技能、輸出規範） | 全專案 |
| `.github/instructions/code-safety.instructions.md` | 程式碼安全規則（禁止 debugger、console.log、hardcoded secrets、大檔讀取） | `**/*.{js,jsx,ts,tsx,py}` |
| `.github/instructions/frontend-quality.instructions.md` | 前端設計品質規則（禁止通用 AI 風格 UI、要求明確設計方向） | `**/*.{tsx,jsx,vue,css,scss,html,svelte,astro}` |
| `.github/instructions/git-workflow.instructions.md` | Git 工作流規則（受保護分支、禁止 force push、feature branch 流程） | `**` |

**本檔案專注於「模板專案特有」的協作模式**，與上述文件互補不重複。

<!-- SPECKIT START -->
<!-- 此區塊由 speckit.agent-context.update 管理。下游專案執行該指令後會自動填入現行 plan 的路徑。 -->
<!-- SPECKIT END -->
