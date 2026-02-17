# SDD Flow 專案範本

* 專案起始範本
* 此專案為 Will 保哥 - [規格驅動開發實戰：AI 時代的軟體開發新典範](https://sdd.gh.miniasp.com/) 課後彙整資料

## 先決條件

- 作業系統：Linux / macOS / Windows
- Python 3.11+
- Git
- 建議安裝 `uv`（提供 `uvx` 執行工具）以方便安裝與執行 Spec Kit

## 安裝 `uv`（包含 `uvx`）

本專案的安裝、環境與工具設定（包含 `uv` / `uvx`、`specify` CLI、PowerShell 與常用開發工具）已移至專門文件，請參考：

- [Docs/SpecKit工具與環境.md](Docs/SpecKit工具與環境.md)（包含安裝步驟、Scoop / nvm / uv 設定範例與常用指令範例）

## 快速更新 Spec Kit 範本檔案的方法

* Linux（Bash）
* 
  ```bash
  # 1. 刪除 .specify 資料夾
  rm -rf .specify
  # 2. 重建範本 (以 GitHub Copilot 為例)
  specify init --here --script sh --ai copilot --no-git --force
  # 3. 復原原本的憲法
  git restore .specify/memory/constitution.md
  ```

* Windows（PowerShell）

  ```ps1
  # 1. 刪除 .specify 資料夾
  Remove-Item -Path .specify -Recurse -Force -ErrorAction SilentlyContinue
  # 2. 重建範本 (以 GitHub Copilot 為例)
  specify init --here --script ps --ai copilot --no-git --force
  # 3. 復原原本的憲法
  git restore .specify/memory/constitution.md
  ```

## 一次性安裝所有 AI 工具 + PowerShell

* Linux（Bash）

  ```bash
  specify init --here --no-git --force --script sh --ignore-agent-tools --ai claude
  specify init --here --no-git --force --script sh --ignore-agent-tools --ai gemini
  specify init --here --no-git --force --script sh --ignore-agent-tools --ai copilot
  specify init --here --no-git --force --script sh --ignore-agent-tools --ai cursor-agent
  specify init --here --no-git --force --script sh --ignore-agent-tools --ai qwen
  specify init --here --no-git --force --script sh --ignore-agent-tools --ai opencode
  specify init --here --no-git --force --script sh --ignore-agent-tools --ai codex
  specify init --here --no-git --force --script sh --ignore-agent-tools --ai windsurf
  specify init --here --no-git --force --script sh --ignore-agent-tools --ai kilocode
  specify init --here --no-git --force --script sh --ignore-agent-tools --ai auggie
  specify init --here --no-git --force --script sh --ignore-agent-tools --ai codebuddy
  specify init --here --no-git --force --script sh --ignore-agent-tools --ai amp
  specify init --here --no-git --force --script sh --ignore-agent-tools --ai shai
  specify init --here --no-git --force --script sh --ignore-agent-tools --ai q
  ```

* Windows（PowerShell）

  ```ps1
  specify init --here --no-git --force --script ps --ignore-agent-tools --ai claude
  specify init --here --no-git --force --script ps --ignore-agent-tools --ai gemini
  specify init --here --no-git --force --script ps --ignore-agent-tools --ai copilot
  specify init --here --no-git --force --script ps --ignore-agent-tools --ai cursor-agent
  specify init --here --no-git --force --script ps --ignore-agent-tools --ai qwen
  specify init --here --no-git --force --script ps --ignore-agent-tools --ai opencode
  specify init --here --no-git --force --script ps --ignore-agent-tools --ai codex
  specify init --here --no-git --force --script ps --ignore-agent-tools --ai windsurf
  specify init --here --no-git --force --script ps --ignore-agent-tools --ai kilocode
  specify init --here --no-git --force --script ps --ignore-agent-tools --ai auggie
  specify init --here --no-git --force --script ps --ignore-agent-tools --ai codebuddy
  specify init --here --no-git --force --script ps --ignore-agent-tools --ai amp
  specify init --here --no-git --force --script ps --ignore-agent-tools --ai shai
  specify init --here --no-git --force --script ps --ignore-agent-tools --ai q
  ```
## 指令說明

* 核心指令

  | Command | Description |
  | ------- | ----------- |
  | /speckit.constitution	| 制定或更新專案管理原則和開發指南| 
  | /speckit.specify	| 明確你想建構什麼（需求和使用者故事）| 
  | /speckit.plan	| 使用您選擇的技術堆疊建立技術實施計劃。| 
  | /speckit.tasks	| 產生可執行的任務清單以供實施| 
  | /speckit.implement	| 依照計劃執行所有任務以建置該功能。| 

* 可選用指令

  | Command | Description |
  | ------- | ----------- |
  | `/speckit.clarify`   | 釐清規格中未明確的區塊（建議於 `/speckit.plan` 前執行；前身為 `/quizme`）             |
  | `/speckit.analyze`   | 跨產物一致性與覆蓋度分析（於 `/speckit.tasks` 後、`/speckit.implement` 前執行）                |
  | `/speckit.checklist` | 產生自訂品質檢查清單，驗證需求的完整性、清晰度與一致性（類似「英文的單元測試」） |

## Skills（參考 / 查找方式）

本專案的 Skill 以資料夾形式放在 `.github/skills/`；每個 Skill 的入口文件固定為 `SKILL.md`。

- 直接開啟：`.github/skills/<skill-id>/SKILL.md`
- VS Code 全域搜尋：在搜尋框輸入 `path:.github/skills SKILL.md`，或搜尋 skill-id（例如 `python-venv-check`）
- 由目錄瀏覽：查看 `.github/skills/` 以取得目前可用的 skills 清單

## 目前提供的 Skills 與用途

| Skill | 用途說明 |
|---|---|
| brand-guidelines | 應用官方品牌色彩與排版，將產出套用 Anthropic 視覺風格與設計規範。 |
| algorithmic-art | 使用 p5.js 與種子隨機性創作互動式演算法藝術與產生式視覺稿件範例。 |
| commit-message-helper | 幫助產生符合 Conventional Commits 規範的 Git 提交訊息建議。 |
| copilot-sdk | 建置可程式化的 GitHub Copilot SDK 代理應用（工具串接、串流回應、Session 管理、MCP 整合等）。 |
| doc-coauthoring | 支援協作式文件撰寫流程（提案、技術規格、決策紀錄等），包含檢視與版本化建議。 |
| canvas-design | 依設計哲學輸出高品質靜態視覺稿（PNG、PDF），適用於海報與展示稿。 |
| frontend-design | 建構高品質前端介面與元件，提供樣式、版面與 UX 建議（React / Tailwind 等）。 |
| internal-comms | 撰寫企業內部溝通文件範本（狀態更新、通告、事故報告、FAQ 等）。 |
| docx | 產生與編輯 .docx 文件，保留格式、批註與修訂記錄，支援專業文件處理。 |
| pdf | 處理 PDF 檔案（抽取文字/表格、合併/拆分、填表單與格式化輸出）。 |
| pptx | 建立與修改 PowerPoint 簡報（版面設計、講者備註與樣版套用）。 |
| mcp-builder | 建立 Model Context Protocol (MCP) 伺服器範本與整合指引，用於 LLM 與外部服務整合。 |
| RunPowerShell | 提供 PowerShell UTF-8 編碼設定與啟動建議，避免中文亂碼問題。 |
| skill-creator | 協助設計與建立新的 skill，包含提示設計、結構建議與整合步驟。 |
| slack-gif-creator | 為 Slack 最佳化的動畫 GIF 製作規範與工具支援（尺寸、幀率、最佳實務）。 |
| theme-factory | 提供主題工廠功能，為文件或產物套用預設色彩與字型主題。 |
| web-artifacts-builder | 建構複雜、多元的前端產物（React + Tailwind + shadcn/ui），適用於大型介面產出。 |
| webapp-testing | 使用 Playwright 執行本地 Web 應用測試、截圖與偵錯支援。 |
| container-image-hygiene | 容器映像（Docker image）清理與最佳實務，包含建構、標記、掃描與體積控管建議。 |
| python-venv-check | 在執行 Python 開發或測試前，先檢查專案根目錄是否已有 `.venv`；若存在則直接使用，不存在才詢問要建立虛擬環境或改用系統預設環境。 |
| xlsx | 產生與處理 Excel 檔案，包含格式、公式、表格操作與視覺化。 |

## 參考資料

* [Spec Kit [zhTW]](https://github.com/doggy8088/spec-kit/)
* [Learn-Git-in-30-days](https://github.com/doggy8088/Learn-Git-in-30-days)
* [最佳 GitHub Copilot 設定](https://github.com/doggy8088/github-copilot-configs)
* [Docker — 從入門到實踐](https://github.com/doggy8088/docker_practice)
* [Gemini CLI](https://github.com/doggy8088/gemini-cli)