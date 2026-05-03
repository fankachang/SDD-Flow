# Base Rules

* **Response Language:** `zh-TW`
* All specifications, plans, and user-facing documentation MUST be written in Traditional Chinese (zh-TW). Only the constitution MUST be in English.
* When drafting the constitution, the context MUST be translated into `constitution_zhTW.md` and placed in the same directory (file names are case-sensitive).
* Git logs and code annotations MUST be written in Traditional Chinese (zh-TW).

## Development Guidelines

* When the frontend calls a backend API or function, ensure the API/function actually exists on the backend. Do not arbitrarily name or assume APIs/functions.
* Avoid over-design and over-engineering.
* During development, the frontend UI should account for layout height. Input fields, components, and their placement should be consistent across the interface.

## Virtual Environment

* Check whether a virtual environment (e.g., `.venv`) exists in the current folder. If it does, do not create a new virtual environment.

## Skills

Skills in this project are stored as folders under `.agents/skills/`. Each skill has a fixed entry file named `SKILL.md`.

* **How to reference / find skills**
  * Open directly: `.agents/skills/<skill-id>/SKILL.md`
  * VS Code global search: search for `path:.agents/skills SKILL.md`, or search by skill-id (e.g. `python-venv-check`)
  * Browse the directory: open `.agents/skills/` to see the list of available skills

* **Included skills (folder name = skill-id)**
  * `RunPowerShell`: `.agents/skills/RunPowerShell/SKILL.md`
  * `algorithmic-art`: `.agents/skills/algorithmic-art/SKILL.md`
  * `brand-guidelines`: `.agents/skills/brand-guidelines/SKILL.md`
  * `canvas-design`: `.agents/skills/canvas-design/SKILL.md`
  * `commit-message-helper`: `.agents/skills/commit-message-helper/SKILL.md`
  * `copilot-sdk`: `.agents/skills/copilot-sdk/SKILL.md`
  * `container-image-hygiene`: `.agents/skills/container-image-hygiene/SKILL.md`
  * `doc-coauthoring`: `.agents/skills/doc-coauthoring/SKILL.md`
  * `docx`: `.agents/skills/docx/SKILL.md`
  * `frontend-design`: `.agents/skills/frontend-design/SKILL.md`
  * `internal-comms`: `.agents/skills/internal-comms/SKILL.md`
  * `mcp-builder`: `.agents/skills/mcp-builder/SKILL.md`
  * `pdf`: `.agents/skills/pdf/SKILL.md`
  * `pptx`: `.agents/skills/pptx/SKILL.md`
  * `python-venv-check`: `.agents/skills/python-venv-check/SKILL.md`
  * `rtk-token-killer`: `.agents/skills/rtk-token-killer/SKILL.md`
  * `skill-creator`: `.agents/skills/skill-creator/SKILL.md`
  * `slack-gif-creator`: `.agents/skills/slack-gif-creator/SKILL.md`
  * `theme-factory`: `.agents/skills/theme-factory/SKILL.md`
  * `web-artifacts-builder`: `.agents/skills/web-artifacts-builder/SKILL.md`
  * `webapp-testing`: `.agents/skills/webapp-testing/SKILL.md`
  * `xlsx`: `.agents/skills/xlsx/SKILL.md`

## Agent

* If you have questions, use #askQuestions and provide your proposed solutions for the user to choose from.
* If the specification is not clearly defined, default to using TDD for planning and development.

## Dev Team Agents（工程團隊）

以下 12 個專業 agent 定義於 `.github/agents/`，遵循 P7/P9/P10 方法論與三條紅線紀律：

| Agent | 職責 | 適用時機 |
|-------|------|----------|
| `planner` | Tech Lead，P9 方法論，將模糊需求拆解為可並行 Task Prompts | 任務涉及 3+ 個檔案或 2+ 個模組 |
| `fullstack-engineer` | 資深全端工程師，P7 方法論，設計→實作→自我審查→交付 | 單一功能或跨模組實作 |
| `refactor-specialist` | 大規模安全重構，原子 commit，完整呼叫點驗證 | 跨 10+ 個檔案的重命名、搬移、模組抽取 |
| `migration-engineer` | 框架/函式庫主版本升級，逐步驗證 | Next.js、Vue、Tailwind 等主版本升級 |
| `frontend-designer` | 前端設計師，拒絕 AI 風格爛 UI，有主見的美學方向 | 新頁面、UI 重設計、視覺升級 |
| `critic` | 程式碼審查與安全稽核，每個發現附檔名+行號 | commit 前、部署前、合併前 |
| `vuln-verifier` | 漏洞驗證，寫真實 PoC 證明漏洞存在或誤報 | critic 標記安全問題後 |
| `debugger` | 除錯工程師，讀日誌→建立假設→驗證→修復，絕不猜測 | Bug 回報、服務中斷、測試失敗 |
| `db-expert` | 資料庫專家，審查 schema、migration、查詢的安全性 | Schema 變更、migration、查詢最佳化 |
| `onboarder` | 首次探索程式庫，建立架構心智模型，唯讀 | 加入新專案、評估開源 repo |
| `tool-expert` | 工具專家，選對工具、串接複雜流程、排除工具失敗 | MCP 工具失敗、複雜工具串接 |
| `web-researcher` | 技術文件研究員，查詢官方文件、API 規格、錯誤碼 | 不確定 API 用法、錯誤碼查詢 |

另有 9 個 SpecKit 流程 agent（`.github/agents/speckit.*.agent.md`）：`speckit.specify`、`speckit.plan`、`speckit.tasks`、`speckit.implement`、`speckit.clarify`、`speckit.analyze`、`speckit.checklist`、`speckit.constitution`、`speckit.taskstoissues`。

### 使用規則

* 任務涉及 3+ 個檔案 → 先派 `planner` 分解，再由其他 agent 執行
* 所有部署前 → 必跑 `critic` 審查
* `critic` 發現安全問題 → 派 `vuln-verifier` 寫 PoC 確認
* Bug 根因不明 → 先派 `debugger`，不要讓 `fullstack-engineer` 猜測

## Instructions（行為規則）

以下規則定義於 `.github/instructions/`，GitHub Copilot 會依 `applyTo` 自動套用：

| 檔案 | 適用範圍 | 規則內容 |
|------|----------|----------|
| `code-safety.instructions.md` | `**/*.{js,jsx,ts,tsx,py}` | 禁止 debugger、console.log、hardcoded secrets；禁止修改 linter 設定；大檔案讀取限制 |
| `frontend-quality.instructions.md` | `**/*.{tsx,jsx,vue,css,scss,html,svelte,astro}` | 禁止通用 AI 風格 UI；CTA 需具體；視覺層次要求 |
| `git-workflow.instructions.md` | `**` | 禁止 force push 受保護分支；禁止直接 commit 到 main；禁止 --no-verify |

## RTK Hook（Token 最佳化）

GitHub Copilot 的 RTK hook 設定於 `.github/settings.json`（matcher: `run_in_terminal`）。
RTK 相關說明請參閱 `.agents/skills/rtk-token-killer/SKILL.md`。

## VS Code Tasks

`.vscode/tasks.json` 定義以下可手動觸發的任務：
* `Format: Prettier + TypeCheck` — 格式化並執行 tsc 型別檢查
* `Test: Run Related Tests (vitest)` — 執行 vitest
* `Lint: Check console.log` — 掃描修改過的檔案中的 console.log
* `Security: Check for Secrets` — 掃描 staged 檔案中的 debugger / secrets
