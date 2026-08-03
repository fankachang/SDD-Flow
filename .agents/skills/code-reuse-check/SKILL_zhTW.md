---
name: code-reuse-check
description: Search for existing implementations before adding any new reusable code (function, method, class, or module), reuse or extend instead of duplicating, and place shared code in the project's designated shared location. When existing duplicates are found, report them only; converge solely on explicit user request — never refactor beyond the task scope.
---

# 程式碼重用檢查

## 使用時機

- 新增任何可重用程式碼(函式、方法、類別、模組)之前
- 發現多個檔案存在同用途的重複實作時(**僅回報**;收斂需使用者明確要求)

## 流程

### 1. 先查重再新增

撰寫新的可重用程式碼前,先以 grep 搜尋既有實作:

- 名稱與可能的同義詞(如 `FormatDate|DateFormat|ToDateString`)
- 特徵邏輯(正則模式、magic string、API endpoint、常數)

若已有同用途實作 → 重用或擴充,禁止複製到其他檔案;若存在多份重複,引用其中最合適的一份即可,**不得順手改動其他副本**。

### 2. 判定共用位置

判定順序:

1. **已記錄值**:查 `.github/copilot-instructions.md` 的「專案技術棧與環境」區段是否已記錄共用程式碼位置 → 直接採用。
2. **從既有專案結構偵測慣例**:

   | 專案類型 | 常見慣例 |
   |---|---|
   | C# / .NET | `Common/` 或 `Shared/` 類庫、`src/<App>.Common/` |
   | 前端(JS/TS) | `src/utils/`、`src/lib/`、`src/shared/` |
   | Python | 共用套件如 `<pkg>/utils/`、`common/` |
   | Monorepo | 供其他 package 引用的獨立共用 package/library |

3. **仍不明確** → 以 askQuestions 詢問使用者(列出偵測到的候選並保留自訂輸入),確認後將路徑以 `- **共用程式碼位置**：<path>` 寫入 `.github/copilot-instructions.md` 的「專案技術棧與環境」區段(無此列則新增),供後續 session 繼承。

### 3. 收斂既有重複(僅限使用者明確要求)

**前提**:非需求驅動的重構不被允許(棕地專案尤其如此)。任務中發現重複時僅回報位置與影響範圍,待使用者明確同意後才執行:

1. grep 找出重複實作的所有副本
2. 於共用位置保留或建立 canonical 版本
3. 所有呼叫端改引用 canonical 版本
4. 刪除其餘副本
5. 編譯與測試驗證
