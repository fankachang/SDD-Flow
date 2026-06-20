---
name: commit-message-helper
description: 協助依照 Conventional Commits 規範撰寫 Git commit 訊息。當使用者要求提交變更、撰寫 commit 訊息或提及 git commit 時，使用此技能。
---

# Commit 訊息輔助工具

撰寫 commit 訊息時，遵循以下規則：

## 格式

<type>(<scope>): <subject>

<body>

<footer>

## 類型

- feat：新功能
- fix：錯誤修復
- docs：僅文件變更
- style：不影響程式碼語意的變更（例如格式調整）
- refactor：既未修復錯誤也未新增功能的程式碼重構
- perf：提升效能的程式碼變更
- test：新增缺失的測試或修正現有測試
- chore：建置流程或輔助工具的變更

## 撰寫指南

1. 標題行不超過 50 個字元
2. 使用祈使語氣（例如「新增功能」而非「已新增功能」）
3. 標題行結尾不加句號
4. 標題與本文之間以空行分隔
5. 本文說明「做了什麼」及「為什麼」，而非「怎麼做」

## 附加規則

- Commit 訊息**必須以繁體中文撰寫**，以確保清晰易讀並符合專案語言規範。

## 範例

正確示範：
feat(auth): 新增 OAuth2 登入支援

實作 OAuth2 驗證流程，讓使用者可透過
Google 或 GitHub 帳號登入。

Closes #123

錯誤示範：
updated stuff
