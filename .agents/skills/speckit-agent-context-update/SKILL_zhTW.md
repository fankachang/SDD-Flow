---
name: speckit-agent-context-update
description: 更新程式碼 Agent 上下文檔案中由 Spec Kit 管理的區段
compatibility: 需要具備 .specify/ 目錄的 spec-kit 專案結構
metadata:
  author: github-spec-kit
  source: agent-context:commands/speckit.agent-context.update.md
---

# 更新程式碼 Agent 上下文

在現行程式碼 Agent 的上下文/指令檔案（例如 `CLAUDE.md`、`.github/copilot-instructions.md`、`AGENTS.md`）中，更新由 Spec Kit 管理的區段。

## 行為說明

腳本會讀取 agent-context 擴充功能的設定檔：
`.specify/extensions/agent-context/agent-context-config.yml`

以取得以下資訊：

- `context_file` — 需要管理的程式碼 Agent 上下文檔案路徑。
- `context_markers.start` / `.end` — 管理區段的起訖標記。若欄位不存在，預設使用 `<!-- SPECKIT START -->` 與 `<!-- SPECKIT END -->`。

接著腳本會建立、替換或附加管理區塊，使該區段指向最新發現的計畫路徑（`specs/<feature>/plan.md`）。

若 `context_file` 為空或找不到該檔案，指令會回報無需執行並成功結束。

## 執行方式

- **Bash**：`.specify/extensions/agent-context/scripts/bash/update-agent-context.sh [plan_path]`
- **PowerShell**：`.specify/extensions/agent-context/scripts/powershell/update-agent-context.ps1 [plan_path]`

省略 `plan_path` 時，腳本會自動偵測最近修改的 `specs/*/plan.md`。
