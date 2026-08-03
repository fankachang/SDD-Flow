# SDD 專案範本

* 專案起始範本
* 此專案為 Will 保哥 - [規格驅動開發實戰：AI 時代的軟體開發新典範](https://sdd.gh.miniasp.com/) 課後彙整資料

## 樣板定位與憲章使用方式

此 repository 是用來初始化其他專案的 SDD 樣板，不代表單一產品專案。因此 `.specify/memory/constitution.md` 預設保留 Spec Kit placeholder 是預期狀態，不應在本樣板中寫死特定專案憲章。

若新專案是棕地專案，可先閱讀 [Docs/guides/棕地專案初始憲章.md](Docs/guides/棕地專案初始憲章.md)，再於下游專案使用 `/speckit.constitution` 將適合該專案的原則寫入 active constitution。

本樣板支援一般應用程式開發、既有系統現代化與跨技術棧遷移；涉及舊系統遷移時，建議由 `migration-engineer` 先盤點既有行為、資料模型與驗證切片，再進入實作。

## 新專案建立後的核心流程

當你使用此樣板初始化新專案後，建議按以下順序進行：

### 1. 初始化開發環境與工具鏈（一次性）
在你的 AI 代理程式中執行：
```
/project-init
```
AI 會偵測開發環境、設定 git hooks 與 RTK，列出候選語言/建置工具與你確認後，寫入 `.github/copilot-instructions.md` 的「專案技術棧與環境」區段。也可以手動執行對應平台腳本（`.github/scripts/project-init/project-init.sh` / `.ps1` / `.bat`），僅執行偵測與 git hooks/RTK 設定，不會自動寫檔。

### 2. 制定或選擇專案憲章 
在你的 AI 代理程式（Gemini CLI、Claude Code、GitHub Copilot 等）中執行：
```
/speckit.constitution
```

**針對棕地專案的建議**：使用 `Docs/guides/棕地專案初始憲章.md` 作為參考範本。

### 3. 棕地專案：先由 migration-engineer 盤點
如果是既有系統，建議先由 `migration-engineer` 使用索引圖譜盤點既有行為與資料模型。這會讓 AI 代理在規劃 `/speckit.plan` 時具備更完整的全域認知。

### 4. 選擇功能開發模式
完成上述準備後，每個 feature 選擇一種模式並全程使用，不要混用：

- **Team Mode**：在 Agent 選擇器中選擇 `ba` 並交付需求。BA 會協調專責 Agents 完成 Phase 0–5、審查與提交 Gate；流程中不需手動輸入 `/speckit.*`。
- **Native SpecKit Mode**：自行依序執行 `/speckit.specify`、`/speckit.clarify`、`/speckit.plan`、`/speckit.tasks`、`/speckit.analyze` 與 `/speckit.implement`。

兩種模式的責任邊界與恢復規則以 [SDD 開發團隊協調指南](Docs/governance/TEAM_COORDINATION_GUIDE.md) 為準。


## 先決條件

* 作業系統：Linux / macOS / Windows
* Python 3.11+
* Git
* 建議安裝 `uv`（提供 `uvx` 執行工具）以方便安裝與執行 Spec Kit
* Git hooks（治理文件一致性檢測）由「1. 初始化開發環境與工具鏈」步驟的初始化工具自動設定，無需手動執行

## 安裝 `uv`（包含 `uvx`）

本專案的安裝、環境與工具設定（包含 `uv` / `uvx`、`specify` CLI、PowerShell 與常用開發工具）已移至專門文件，請參考：

* [Docs 文件分層與 AI 可見性](Docs/README.md)
* [Docs/guides/SpecKit工具與環境.md](Docs/guides/SpecKit工具與環境.md)（包含安裝步驟、Scoop / nvm / uv 設定範例與常用指令範例）
* [Docs/guides/Token與Prompt-Cache使用指南.md](Docs/guides/Token與Prompt-Cache使用指南.md)（區分 RTK、Context Token 與 Prompt Cache，涵蓋 VS Code、Copilot CLI 與 Codex/API）

## 快速更新 Spec Kit 範本檔案的方法

* Linux（Bash）

  ```bash
  # 1. 刪除 .specify 資料夾
  rm -rf .specify
  # 2. 重建範本 (以 GitHub Copilot 為例)
  specify init --here --script sh --integration copilot --force
  # 3. 復原原本的憲法
  git restore .specify/memory/constitution.md
  ```

* Windows（PowerShell）

  ```ps1
  # 1. 刪除 .specify 資料夾
  Remove-Item -Path .specify -Recurse -Force -ErrorAction SilentlyContinue
  # 2. 重建範本 (以 GitHub Copilot 為例)
  specify init --here --script ps --integration copilot --force
  # 3. 復原原本的憲法
  git restore .specify/memory/constitution.md
  ```

## 一次性安裝所有 AI 工具 + PowerShell

* Linux（Bash）

  ```bash
  specify init --here --force --script sh --ignore-agent-tools --integration claude
  specify init --here --force --script sh --ignore-agent-tools --integration gemini
  specify init --here --force --script sh --ignore-agent-tools --integration copilot
  specify init --here --force --script sh --ignore-agent-tools --integration cursor-agent
  specify init --here --force --script sh --ignore-agent-tools --integration qwen
  specify init --here --force --script sh --ignore-agent-tools --integration opencode
  specify init --here --force --script sh --ignore-agent-tools --integration codex
  specify init --here --force --script sh --ignore-agent-tools --integration windsurf
  specify init --here --force --script sh --ignore-agent-tools --integration kilocode
  specify init --here --force --script sh --ignore-agent-tools --integration auggie
  specify init --here --force --script sh --ignore-agent-tools --integration codebuddy
  specify init --here --force --script sh --ignore-agent-tools --integration amp
  specify init --here --force --script sh --ignore-agent-tools --integration shai
  specify init --here --force --script sh --ignore-agent-tools --integration q
  ```

* Windows（PowerShell）

  ```ps1
  specify init --here --force --script ps --ignore-agent-tools --integration claude
  specify init --here --force --script ps --ignore-agent-tools --integration gemini
  specify init --here --force --script ps --ignore-agent-tools --integration copilot
  specify init --here --force --script ps --ignore-agent-tools --integration cursor-agent
  specify init --here --force --script ps --ignore-agent-tools --integration qwen
  specify init --here --force --script ps --ignore-agent-tools --integration opencode
  specify init --here --force --script ps --ignore-agent-tools --integration codex
  specify init --here --force --script ps --ignore-agent-tools --integration windsurf
  specify init --here --force --script ps --ignore-agent-tools --integration kilocode
  specify init --here --force --script ps --ignore-agent-tools --integration auggie
  specify init --here --force --script ps --ignore-agent-tools --integration codebuddy
  specify init --here --force --script ps --ignore-agent-tools --integration amp
  specify init --here --force --script ps --ignore-agent-tools --integration shai
  specify init --here --force --script ps --ignore-agent-tools --integration q
  ```
  
## 指令說明

* 核心指令

  | Command | Description |
  | ------- | ----------- |
  | /speckit.constitution | 制定或更新專案管理原則和開發指南 |
  | /speckit.specify | 明確你想建構什麼（需求和使用者故事） |
  | /speckit.plan | 使用您選擇的技術堆疊建立技術實施計劃。 |
  | /speckit.tasks | 產生可執行的任務清單以供實施 |
  | /speckit.implement | 依照計劃執行所有任務以建置該功能。 |

* 可選用指令

  | Command | Description |
  | ------- | ----------- |
  | `/speckit.clarify` | 釐清規格中未明確的區塊（建議於 `/speckit.plan` 前執行；前身為 `/quizme`） |
  | `/speckit.analyze` | 跨產物一致性與覆蓋度分析（於 `/speckit.tasks` 後、`/speckit.implement` 前執行） |
  | `/speckit.checklist` | 產生自訂品質檢查清單，驗證需求的完整性、清晰度與一致性（類似「英文的單元測試」） |

## Skills（參考 / 查找方式）

本專案的 Skill 以資料夾形式放在 `.agents/skills/`；每個 Skill 的入口文件固定為 `SKILL.md`。

* 直接開啟：`.agents/skills/<skill-id>/SKILL.md`
* VS Code 全域搜尋：在搜尋框輸入 `path:.agents/skills SKILL.md`，或搜尋 skill-id（例如 `python-venv-check`）
* 由目錄瀏覽：查看 `.agents/skills/` 以取得目前可用的 skills 清單

## 參考資料

* [Spec Kit [zhTW]](https://github.com/doggy8088/spec-kit/)
* [Learn-Git-in-30-days](https://github.com/doggy8088/Learn-Git-in-30-days)
* [最佳 GitHub Copilot 設定](https://github.com/doggy8088/github-copilot-configs)
* [Docker — 從入門到實踐](https://github.com/doggy8088/docker_practice)
* [Gemini CLI](https://github.com/doggy8088/gemini-cli)
