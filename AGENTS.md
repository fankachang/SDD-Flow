# 基本規則

* **回應語言**: `zh-TW`
* 所有規格、計畫和面向使用者的文件**必須**以正體中文 (zh-TW) 撰寫。僅憲章**必須**以英文撰寫。
* 草擬憲章時，內容**必須**翻譯為 `constitution_zhTW.md` 並放在同一目錄中（檔案名稱區分大小寫）。
* Git 日誌和程式碼註釋**必須**以正體中文 (zh-TW) 撰寫。

## 開發指南

* 當呼叫 API 或函式時，必須確保該 API/函式確實存在於後端。不要任意命名或假設 API/函式。
* 避免過度設計和過度工程化。
* 開發期間，前端 UI 應考慮版面配置高度。輸入欄位、元件及其放置應在整個介面中保持一致。

## 虛擬環境

* 若當前專案為 Python 相關，執行前先確認當前資料夾是否已有虛擬環境（例如 `.venv`）。若存在，直接使用，不得重新建立。

## 技能

本專案的技能儲存在 `.agents/skills/` 資料夾下的子資料夾中。每個技能都有一個名為 `SKILL.md` 的固定進入點檔案。

* **如何參考/尋找技能**
  * 直接開啟：`.agents/skills/<skill-id>/SKILL.md`
  * VS Code 全域搜尋：搜尋 `path:.agents/skills SKILL.md` 或依技能 ID 搜尋（例如 `python-venv-check`）
  * 瀏覽目錄：開啟 `.agents/skills/` 查看可用技能清單

**已包含技能（資料夾名稱 = skill-id）**
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
  * `integration-test-quality`: `.agents/skills/integration-test-quality/SKILL.md` ⭐ **NEW（新增）**
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
*  遇到決策問題必須以 `vscode_askQuestions`（ #askQuestions ） 提供至少三個方案讓使用者選擇，並於最後也追加一個輸入選項讓使用者可自行撰寫其他方案。
* 如果規格未明確定義，預設使用 TDD 進行規劃和開發。

# 輸出規範

* 除非要求完整版，先給精簡版（要點式）
* 不寫廢話開場，直接輸出結果
* 長任務先列清單確認，逐項執行
* 對話接近上限時主動提示開新對話
* 開發撰寫程式碼禁止猜測，可以假設但需要調查取得證據