---
name: project-init
description: "偵測開發環境、設定 git hooks/RTK，並與使用者確認後寫入 copilot-instructions.md 的專案技術棧與環境區段，同時移除僅供樣板 repo 使用的說明段落。"
argument-hint: "[可選：已知的技術棧描述，跳過部分偵測]"
---

# 專案初始化

## 執行步驟

1. 判斷作業系統，執行對應的初始化腳本（不得省略，腳本負責偵測與決定性設定）：
   - macOS/Linux/WSL：`bash .github/scripts/project-init/project-init.sh`
   - Windows PowerShell：`.github/scripts/project-init/project-init.ps1`

   腳本會自動設定 `git config core.hooksPath .githooks`、檢查/安裝 RTK，列出候選語言/建置工具（可能誤判，例如誤抓工具或 skill 自身的 manifest 檔案），並回報其他初始化狀態（Python .venv 存在性、SpecKit 憲章是否仍為 placeholder）。

2. 讀取腳本輸出的候選清單，用 `vscode/askQuestions` 一次列出所有候選項目讓使用者確認或修正，保留自訂輸入選項。不得跳過確認直接採用腳本輸出。若腳本回報「Python .venv: 不存在」且確認為 Python 專案，在同一次詢問中一併詢問是否依 `python-venv-check` skill 建立 `.venv`。

3. 確認後，用編輯工具將結果寫入 `.github/copilot-instructions.md` 的「專案技術棧與環境」區段：移除 `<!-- 尚未初始化... -->` 註解行，並取代所有 `[待偵測]` 佔位符為確認後的內容。

4. 移除 `.github/copilot-instructions.md` 中僅供本樣板 repo 自身使用、對下游專案已無意義的段落：「專案定位」（說明本檔案是樣板、會被複製到下游專案）與「`.specify/` 目錄結構」（說明範本檔案不可修改）。這兩段是樣板作者留給尚未初始化的 repo 看的提示，一旦執行過初始化即應移除。

5. 簡短回報：偵測到什麼、使用者確認/修正了什麼、已移除哪些樣板專屬段落、已寫入檔案的最終內容。若腳本回報憲章仍為 placeholder，在回報結尾提醒使用者後續執行 `/speckit.constitution` 初始化憲章（不得自動執行）。
