---
name: db-migration
description: "審查與執行安全的數據庫 Schema 變更、 Migration 腳本及查詢效能評估。"
argument-hint: "[migration 檔案、schema 路徑或模型異動說明]"
agent: db-expert
tools: ['read', 'search', 'execute', 'web']
---

# 資料庫 Migration 與 Schema 安全審查

對資料庫結構變更、Migration 腳本或數據存取層異動進行完整安全性與效能評估。

## 審查流程

1. **Schema 與安全性審查 (DB Expert)**：
   - **資料遺失風險**：檢查是否有未經防護的 `DROP COLUMN`、`DROP TABLE` 或縮小欄位型別。
   - **鎖定風險**：評估大型表 `ALTER TABLE` 的 Lock 時間，驗證是否需 `CONCURRENTLY` 或線上 DDL。
   - **向後相容性**：確認既有應用程式版本在 migration 執行期間是否依然可運作。
   - **預設值與回滾**：檢查新增 `NOT NULL` 欄位是否附帶默認值或補全腳本；確認回滾（Rollback）路徑可行。

2. **SQL 效能最佳化 (SQL Optimizer)**：
   - 檢查新新增之 `WHERE`、`JOIN`、`ORDER BY` 欄位是否缺乏適當索引。
   - 識別全表掃描、N+1 查詢及鎖競爭問題。

3. **產出審查報告**：
   - 提供 Migration 風險評估（無/低/中/高）、鎖定時間預估、向下相容性結論與修復建議。
