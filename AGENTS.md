# 基本規則

* **回應語言：** `zh-TW`
* 所有規格、計畫與使用者可見文件必須以繁體中文（zh-TW）撰寫。憲章（constitution）本文例外，須以英文撰寫。
* 起草憲章時，內容必須同步翻譯為 `constitution_zhTW.md` 並放置於同一目錄（檔名區分大小寫）。
* Git 提交訊息與程式碼注釋必須以繁體中文（zh-TW）撰寫。

## 開發準則

* 前端呼叫後端 API 或函式時，須確認該 API／函式確實存在於後端，不得任意命名或假設。
* 避免過度設計與過度工程化。
* 開發前端 UI 時須考量版面高度，輸入欄位、元件及其位置應在整個介面中保持一致。

## 虛擬環境

* 執行前先確認當前資料夾是否已有虛擬環境（例如 `.venv`）。若存在，直接使用，不得重新建立。

## 技能

技能存放於 `.agents/skills/` 底下的子資料夾，每個技能有固定的入口檔 `SKILL.md`。

**如何參照／尋找技能**

* 直接開啟：`.agents/skills/<skill-id>/SKILL.md`
* VS Code 全域搜尋：搜尋 `path:.agents/skills SKILL.md`，或依 skill-id 搜尋（例如 `python-venv-check`）
* 瀏覽目錄：開啟 `.agents/skills/` 查看可用技能清單

**已包含技能（資料夾名稱 = skill-id）**
* `RunPowerShell`: `.agents/skills/RunPowerShell/SKILL.md`
* `algorithmic-art`: `.agents/skills/algorithmic-art/SKILL.md`
* `brand-guidelines`: `.agents/skills/brand-guidelines/SKILL.md`
* `canvas-design`: `.agents/skills/canvas-design/SKILL.md`
* `commit-message-helper`: `.agents/skills/commit-message-helper/SKILL.md`
* `container-image-hygiene`: `.agents/skills/container-image-hygiene/SKILL.md`
* `copilot-sdk`: `.agents/skills/copilot-sdk/SKILL.md`
* `doc-coauthoring`: `.agents/skills/doc-coauthoring/SKILL.md`
* `docx`: `.agents/skills/docx/SKILL.md`
* `frontend-design`: `.agents/skills/frontend-design/SKILL.md`
* `internal-comms`: `.agents/skills/internal-comms/SKILL.md`
* `karpathy-guidelines`: `.agents/skills/karpathy-guidelines/SKILL.md`
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

## 代理人

* 若有疑問，使用 #askQuestions 並提出你的建議方案供使用者選擇。
* 若規格未明確定義，預設使用 TDD 進行規劃與開發。

### 工程團隊代理人

以下 12 個專業代理人定義於 `.github/agents/`，遵循 P7/P9/P10 方法論與三條紅線紀律：

| 代理人 | 職責 | 適用時機 |
|--------|------|----------|
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

另有 9 個 SpecKit 流程代理人（`.github/agents/speckit.*.agent.md`）：`speckit.specify`、`speckit.plan`、`speckit.tasks`、`speckit.implement`、`speckit.clarify`、`speckit.analyze`、`speckit.checklist`、`speckit.constitution`、`speckit.taskstoissues`。

### 代理人使用規則

* 任務涉及 3+ 個檔案 → 先派 `planner` 分解，再由其他代理人執行
* 所有部署前 → 必跑 `critic` 審查
* `critic` 發現安全問題 → 派 `vuln-verifier` 寫 PoC 確認
* Bug 根因不明 → 先派 `debugger`，不要讓 `fullstack-engineer` 猜測

## 指令規則

以下規則定義於 `.github/instructions/`，GitHub Copilot 會依 `applyTo` 自動套用：

| 檔案 | 適用範圍 | 規則內容 |
|------|----------|----------|
| `code-safety.instructions.md` | `**/*.{js,jsx,ts,tsx,py}` | 禁止 debugger、console.log、hardcoded secrets；禁止修改 linter 設定；大檔案讀取限制 |
| `frontend-quality.instructions.md` | `**/*.{tsx,jsx,vue,css,scss,html,svelte,astro}` | 禁止通用 AI 風格 UI；CTA 需具體；視覺層次要求 |
| `git-workflow.instructions.md` | `**` | 禁止 force push 受保護分支；禁止直接 commit 到 main；禁止 --no-verify |

## RTK Hook（Token 最佳化）

GitHub Copilot 的 RTK hook 設定於 `.github/settings.json`（matcher: `run_in_terminal`）。
RTK 相關說明請參閱 `.agents/skills/rtk-token-killer/SKILL.md`。

## VS Code 工作任務

`.vscode/tasks.json` 定義以下可手動觸發的任務：

| 任務 | 說明 |
|------|------|
| `Format: Prettier + TypeCheck` | 格式化並執行 tsc 型別檢查 |
| `Test: Run Related Tests (vitest)` | 執行 vitest |
| `Lint: Check console.log` | 掃描修改過的檔案中的 console.log |
| `Security: Check for Secrets` | 掃描 staged 檔案中的 debugger / secrets |

# 輸出規範

* 除非要求完整版，先給精簡版（要點式）
* 不寫廢話開場，直接輸出結果
* 長任務先列清單確認，逐項執行
* 對話接近上限時主動提示開新對話