---
name: security-audit
description: "對指定程式碼範圍執行靜態安全審計 (critic) 與漏洞 PoC 驗證 (vuln-verifier)。"
argument-hint: "[檔案、目錄、模組或敏感功能路徑]"
agent: critic
tools: [vscode, execute, read, agent, edit, search, web, browser, todo]
---

# 專項安全審計與漏洞驗證

對指定的程式碼範圍或敏感模組進行靜態安全性檢查與漏洞驗證。

## 審查流程

1. **靜態安全掃描 (Critic Role)**：
   - 掃描 SQL 注入、XSS、CSRF、命令注入、路徑穿越、SSRF、控制不當的反序列化與 Timing Attack。
   - 檢查硬編碼憑證、密鑰、敏感 Token 及偵錯資訊洩漏。
   - 標註疑點位置 (`path/to/file:line`) 與嚴重度 (🔴 Critical / 🟠 Major / 🟡 Minor / 🔵 Suggestion)。

2. **PoC 漏洞驗證 (Vuln Verifier Role)**：
   - 若發現 🔴 Critical 或 🟠 Major 安全風險，由 BA 或模型邀請 `vuln-verifier` 撰寫最小安全的 PoC。
   - PoC 必須包含攻擊輸入與對照基準組 (baseline control)，並於安全沙盒／本機環境確認可重現性。

3. **修復建議與建議提交**：
   - 產出安全審計報告與可重現證據，提供針對根因的最小修復方向。
