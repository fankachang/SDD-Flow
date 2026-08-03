# Agent 與 Prompt 強化記錄

日期：2026-07-15

## 變更摘要

- 將團隊協作指南移至 `Docs/governance/`，避免一般 Markdown 被平台誤辨識為 custom agent；舊整合方案移入 `Docs/History/`。
- 將 BA 設為使用者唯一流程入口，限制可委派 agent 清單，其他內部 agent 改為不可由使用者直接呼叫並依職責縮小工具權限。
- 將工程師委派單位統一為一個 `T###`，避免包裝 agent 誤執行上游 `speckit.implement` 的全任務迴圈。
- 重構 `/sdd-resume`：由 BA 依 Markdown 產出、Git／驗證證據與可選的 `sdd-state.md` 對帳後，回到 `TEAM_COORDINATION_GUIDE.md` 的 Phase 0–5 繼續執行；恢復規則收斂於 BA agent。
- 保留上游管理的 Spec Kit agent/prompt；下游重跑時仍由上游流程判斷 shell 或 PowerShell。
- 移除會自我遞迴、硬編碼 Node 工具鏈或與自訂單一 `T###` 流程不相容的 extension hooks；一致性分析由 TEAM Phase 3 執行，extensions 僅保留官方 agent-context hooks。
- 收斂 debugger、frontend-designer、tool-expert、commit-executor 與 vuln-verifier 的寫入、安全及平台邊界。
- 將 Linus review prompt 改為唯讀、具 scope 與 finding 證據格式的 critic prompt，不再冒充真人。
- 將本次修改涉及的舊 CRLF Markdown 正規化為 repository 的文字檔換行格式。
- 將 `Docs/` 分為 Agent 可見的治理／整合文件與預設遮蔽的指南、研究、範例及歷史文件，並透過 VS Code `search.exclude` 降低無關 context。

## 驗證

- YAML/frontmatter、Markdown 連結、上游 Spec Kit 檔案完整性與 Git whitespace 檢查。
- 依 `consistency-check` skill 執行治理文件一致性檢測。
