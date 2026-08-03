---
title: SDD 開發團隊協調指南
description: 完整的 SDD 開發流程中各 Agent 的角色、職責與協作方式
---

# 🏢 SDD 開發團隊協調指南

此指南定義完整 SDD（Software Design Document）開發流程中 18 個自訂 Agents 的角色、職責與協作模式。文中的 `runSubagent(...)` 是流程偽代碼；BA 實際執行時使用當前平台提供的 `agent` 工具與允許清單。所有 `commit-executor` 範例均省略 payload 細節，實際委派必須提供 [commit-executor「必要輸入」](../../.github/agents/commit-executor.agent.md) 定義的完整資料。

本指南是 SDD 開發流程的單一真相來源；中斷恢復由 [BA](../../.github/agents/ba.agent.md) 對帳既有產出與證據後，回到本指南的 Phase 0–5 繼續執行。

## 執行模式

每個 feature 只能採用下列其中一種模式，開始後不得在同一流程中混用：

| 模式 | 進入方式 | 執行責任 |
|------|----------|----------|
| **Team Mode** | 使用者選擇 `ba` Agent 並交付需求 | BA 依本指南委派專責 Agent；各 Agent 直接套用對應 Speckit workflow，不呼叫 `/speckit.*` slash command |
| **Native SpecKit Mode** | 使用者自行依序輸入 `/speckit.*` 指令 | 各 Speckit Agent 依原生 handoff 與 command workflow 執行；BA 團隊、Phase Gate、逐 Task critic 與 commit-executor 不會自動介入 |

- 使用者呼叫 `ba` 即表示選擇 Team Mode，不需再次詢問模式。
- 使用者直接輸入 `/speckit.*` 即表示選擇 Native SpecKit Mode；除非使用者另行終止該模式並要求 BA 重新對帳，否則不得中途切換 Team Mode。
- Team Mode 中提及 `speckit.specify`、`speckit.plan` 等名稱，表示專責 Agent 讀取並套用同名 workflow 規則，不代表實際執行 slash command。
- Team Mode 的 Phase 1–3 專責 Agent 必須依序處理對應 workflow 的 Pre-Execution Checks、Outline 與 Mandatory Post-Execution Hooks；Speckit frontmatter handoff 不自動推進 Phase，控制權一律交回 BA。
- Extension hook 不視為切換模式；Team Mode 應由 BA 委派對應 agent 或工具執行，不要求使用者手動輸入 hook 的 slash command。若目前允許清單沒有對應能力，BA 必須回報阻塞，不得假裝 hook 已執行。
- Phase 4 是刻意的 task-scoped adaptation：工程師只套用 `speckit.implement` 的通用實作與驗證規則，不執行其全任務迴圈，也不逐 Task 重複 command-level hooks。若 `.specify/extensions.yml` 定義 `before_implement` 或 `after_implement`，由 BA 分別在 Phase 4 第一個 Task 前與最後一個 Task 後各協調執行一次。
- 中斷恢復時若既有產出無法判定所屬模式，或兩種模式的狀態互相衝突，BA 必須先交由使用者確認，再恢復任何 Phase。

## 🚦 全域 Gate

所有需要使用者決策的 Gate，詢問格式一律遵循 `AGENTS.md` 的「用戶選擇前強制詢問」規則。BA 依工作節點採用下列其中一種 Gate：

| Gate | 適用時機 | 使用者核准內容 |
|------|----------|---------------|
| **Phase-only** | Phase 完成但不需立即提交 | 本 Phase 產出與下一 Phase |
| **Commit-only** | 單一 `T###` 或維護工作需提交，但不推進 Phase | Git 差異與預計提交檔案 |
| **Phase + Commit** | Phase 完成且緊接著提交 | 在同一次詢問中同時核准 Phase 推進與提交 |

Gate 執行規則：

1. Phase Gate 必須列出產出摘要、關鍵檔案與下一步；Commit Gate 必須列出 `git status`、`git diff --staged`（已 stage）或 `git diff HEAD` 摘要，以及預計提交的確切檔案。
2. 同一節點同時需要 Phase Gate 與 Commit Gate 時，必須合併成一次 `vscode/askQuestions`，選項至少涵蓋「核准並提交後推進」、「退回修改或取消提交」與自訂處理，避免重複詢問與重複載入內容。
3. 只有取得對應 Gate 的明確核准後，BA 才能委派 `commit-executor` 或推進下一 Phase；委派時仍須提供完整核准 payload。
4. Phase 0–4 未通過 Phase Gate 不得推進；Phase 5 未完成最終驗收不得結案或宣告交付。

## 📋 快速索引

| 角色 | 職責 | 主要調用時機 |
|------|------|-----------|
| **ba** | 需求接收、流程協調 | 每個 Phase 開始前 |
| **web-researcher** | 技術文檔查詢 | 任何 Agent 遇到技術不確定 |
| **spec-engineer** | 規格化（speckit.specify/clarify） | Phase 1 |
| **system-architect** | 技術設計（speckit.plan/analyze）+ SDD 文件支援 | Phase 2、Phase 3 end |
| **frontend-designer** | 前端 UI 設計審查（唯讀） | Phase 2、Phase 4 UI Task 前 |
| **db-expert** | 數據庫設計審查（唯讀） | Phase 2、Phase 4 DB Task |
| **sql-optimizer** | SQL 查詢最佳化 | Phase 2、Phase 4（支援 db-expert 或工程師） |
| **task-manager** | 任務拆解（speckit.tasks） | Phase 3 start |
| **software-engineer** | 簡單 Task 實作（speckit.implement） | Phase 4 簡單 Task |
| **fullstack-engineer** | 複雜 Task 實作（speckit.implement） | Phase 4 複雜 Task |
| **linq-expert** | LINQ 查詢最佳化 | Phase 4（支援工程師） |
| **critic** | 靜態代碼審查 + 安全審計 | Phase 4 每個 Task 實作後 |
| **vuln-verifier** | 漏洞驗證（PoC 代碼） | critic 發現漏洞後 |
| **test-review** | Spec 一致性 + 測試驗證 | Phase 5 |
| **debugger** | 根本原因診斷（唯讀） | Bug 修復或生產問題 |
| **migration-engineer** | 框架/庫版本升級 | 版本升級維護流程 |
| **tool-expert** | 工具選型、工具鏈協調 | Phase 0、工具故障診斷 |
| **commit-executor** | Git commit 執行 | 需提交已核准變更時 |

---

## 🎯 完整 SDD 開發流程

### Phase 0：需求接收 & 技術決策

**主要角色**：BA（協調）

```
BA 接收需求
  → 若需技術查詢 → runSubagent("web-researcher", ...)
  → 若需工具決策 → runSubagent("tool-expert", ...)
  → 產出 requirements.md
  → 通過 Phase-only Gate 後推進 Phase 1
```

### Phase 1：規格化

**主要角色**：spec-engineer（執行）

```
BA: runSubagent("spec-engineer", requirements.md)
  ├─ spec-engineer 內部：
  │  ├─ 完整套用 speckit.specify.agent.md 的 Pre-Execution Checks、Outline 與 Mandatory Post-Execution Hooks
  │  ├─ 完整套用 speckit.clarify.agent.md 的相同 workflow 區段
  │  ├─ 執行規格化流程 → 產出 spec.md
  │  ├─ 技術查詢 → 自行使用目前可用的 web 搜尋工具
  │  ├─ 若需決策 → 回報 BA
  │  └─ spec 確認後向 BA 回報

若 BA 判斷需深入技術調查：
  └─ BA: runSubagent("web-researcher", 技術查詢)
  └─ 將查詢結果傳遞給 spec-engineer

BA: 通過 Phase + Commit Gate 後，runSubagent("commit-executor", "Phase 1 Spec 完成")
  → commit 成功後推進 Phase 2

完成標誌：spec.md 確認、所有決策項已確認或排除
```

### Phase 2：技術設計

**主要角色**：system-architect（執行）、frontend-designer/db-expert（支援）

```
BA: runSubagent("system-architect", "執行技術設計")
  ├─ system-architect 內部：
  │  ├─ 完整套用 speckit.plan.agent.md 的 Pre-Execution Checks、Outline 與 Mandatory Post-Execution Hooks
  │  ├─ 執行技術設計 → 產出 plan.md
  │  ├─ 技術查詢 → 自行使用目前可用的 web 搜尋工具
  │  └─ plan 確認後向 BA 回報

plan.md 產出後，BA 視需要邀請支援審查：
  ├─ 如有 DB 設計 → BA: runSubagent("db-expert", "plan.md DB 部分")
  │  ├─ db-expert 內部：
  │  │  ├─ 審查 schema、constraints、indexes
  │  │  └─ 回報審查結果
  │  └─ BA 判斷是否需退回 system-architect 調整 plan.md
  ├─ 如有前端 UI 決策 → BA: runSubagent("frontend-designer", "plan.md UI 部分")
  │  ├─ frontend-designer 內部：
  │  │  ├─ 分析 UI/UX 需求
  │  │  ├─ 定義美感方向、設計原則
  │  │  └─ 回報設計建議
  │  └─ BA 判斷是否需退回 system-architect 調整 plan.md
  ├─ 如涉及複雜 SQL → BA: runSubagent("sql-optimizer", ...)
  └─ BA: 通過 Phase + Commit Gate 後，runSubagent("commit-executor", "Phase 2 Plan 完成")
     → commit 成功後推進 Phase 3

完成標誌：plan.md 確認、所有子系統設計決策已明確
```

### Phase 3：任務拆解 + 一致性分析

**主要角色**：task-manager（執行）、system-architect（驗證）

```
BA: runSubagent("task-manager", "plan.md + 執行任務拆解")
  ├─ task-manager 內部：
  │  ├─ 完整套用 speckit.tasks.agent.md 的 Pre-Execution Checks、Outline 與 Mandatory Post-Execution Hooks
  │  ├─ 執行任務拆解 → 產出 tasks.md
  │  └─ tasks 確認後向 BA 回報

BA: runSubagent("system-architect", "spec/plan/tasks + 執行一致性分析")
  ├─ system-architect 內部：
  │  ├─ 完整套用 speckit.analyze.agent.md 的 Pre-Execution Checks、Outline 與 Mandatory Post-Execution Hooks
  │  ├─ 驗證 spec ↔ plan ↔ tasks 一致性
  │  ├─ ✅ 通過 → 向 BA 回報通過
  │  └─ ❌ 未通過 → 向 BA 回報問題及退回對象

  若 analyze 未通過：
  ├─ BA 決定退回對象（task-manager 或 system-architect）
  └─ 重新執行對應 Phase

  若 analyze 通過：
  └─ BA: 通過 Phase + Commit Gate 後，runSubagent("commit-executor", "Phase 3 Tasks + 一致性檢查完成")
     → commit 成功後推進 Phase 4

完成標誌：tasks.md 確認、speckit.analyze 通過
```

### Phase 4：實作 + 品質控制

**主要角色**：software-engineer/fullstack-engineer（實作）、critic（審查）

```
對 `tasks.md` 中每個未完成且相依條件已滿足的 `T###`，執行以下流程：

【步驟 1：前置支援審查（按需，由 BA 根據 T### 分類標記判斷）】
  ├─ 如涉及前端 UI → BA: runSubagent("frontend-designer", "T### UI 設計")
  ├─ 如涉及 DB 變更 → BA: runSubagent("db-expert", "T### DB 審查")
  ├─ 如涉及複雜 LINQ/SQL → BA: runSubagent("linq-expert" 或 "sql-optimizer", ...)
  │  └─ 專家產出包含標準標頭 (如 [LINQ-OPTIMIZATION] / [SQL-OPTIMIZATION])
  └─ 將審查結果作為工程師的實作參考

【步驟 2：選擇工程師】
  ├─ 簡單 Task（單模塊、低風險）
  │  └─ BA: runSubagent("software-engineer", "T### + 前置審查結果")
  └─ 複雜 Task（跨模塊、設計決策、高風險）
     └─ BA: runSubagent("fullstack-engineer", "T### + 前置審查結果")

【步驟 3：實作】
  工程師內部：
  ├─ 只讀取 speckit.implement.agent.md 的通用實作規則，不呼叫 `/speckit.implement`，也不執行其全任務迴圈
  ├─ BA 提供的前置審查結果作為實作參考
  ├─ 技術查詢 → 自行使用目前可用的 web 搜尋工具
  ├─ 依 Task DoD 完成實作 + 測試
  └─ 完成後向 BA 回報

【步驟 4：靜態代碼審查】
  BA: runSubagent("critic", "T### 程式碼")
  ├─ critic 內部：
  │  ├─ 檢查代碼品質、安全性、效能、錯誤處理
  │  ├─ 🔴 Critical/🟠 Major 問題 → 向 BA 報告
  │  ├─ 🔐 發現安全漏洞 → 向 BA 報告
  │  ├─ ✅ 通過 → 向 BA 回報通過
  │  └─ ❌ 有問題 → 向 BA 回報問題

  BA 根據 Critic 結果決定後續行動：
  ├─ 🔐 安全漏洞 → BA: runSubagent("vuln-verifier", "critic 漏洞報告")
  │     ├─ vuln-verifier 內部：寫 PoC 代碼驗證
  │     └─ 回報驗證結果

  若 critic 通過：
  ├─ 尚有後續 Task → BA 通過 Commit-only Gate 後，runSubagent("commit-executor", "T### 完成；附完整核准 payload")
  └─ 最後一個 Task → BA 通過 Phase + Commit Gate 後，runSubagent("commit-executor", "T### 完成；附完整核准 payload")
     → commit 成功後推進 Phase 5

  若 critic 有問題：
  ├─ BA 決定退回對象（工程師修復）
  └─ 工程師修復後回到步驟 3

  工程師達成 Definition of Done 與任務測試後回報 ready-for-review，不勾選任務；
  BA 將 critic-review 記為待完成 gate，審查通過後才在 tasks.md 勾選該 T###。
  必要時由 BA 將進行中、阻塞與 gate 狀態記錄於 feature 目錄下可選的 sdd-state.md。

【迴圈結束】所有 Task 完成

完成標誌：所有 Task 完成實作 + critic 審查通過
```

### Phase 5：最終審查驗證

**主要角色**：test-review（執行）

```
BA: runSubagent("test-review", "所有 Task + spec/plan/tasks")
  ├─ test-review 內部：
  │  ├─ Phase 1：Code Review（靜態審查）
  │  │  ├─ 檢查代碼是否完整對齐 Spec/Plan
  │  │  ├─ 標記不符合項
  │  │  └─ 若有問題 → 向 BA 回報
  │  ├─ Phase 2：測試驗證（動態驗證）
  │  │  ├─ 驗證測試覆蓋率
  │  │  ├─ 驗證測試類型是否符合架構設計
  │  │  └─ 若有問題 → 向 BA 回報
  │  ├─ ✅ 全部通過 → 向 BA 回報通過
  │  └─ ❌ 有問題 → 向 BA 回報問題

  若全部通過：
  ├─ BA: 通過 Phase + Commit Gate 後，runSubagent("commit-executor", "chore: Phase 5 審查通過")
  └─ commit 成功後向使用者回報特性已交付

  若有問題：
  ├─ BA 決定退回對象
  ├─ 對應角色修復
  └─ 重新進行 Phase 5 審查

完成標誌：test-review 審查通過、Phase 5 commit 完成
```

---

## 🔧 維護流程

### 緊急 Bug 修復

```
BA: runSubagent("debugger", "Bug 描述、錯誤日誌")
  ├─ debugger 內部：
  │  ├─ 收集錯誤信息、觸發條件、頻率、最近改動
  │  ├─ 建立假設並驗證
  │  └─ 產出根本原因與最小修正方向，不修改產品檔案

根據根本原因決定修復方案：
├─ 簡單 hotfix → BA: runSubagent("software-engineer", "BUG-XXX")
└─ 複雜 hotfix → BA: runSubagent("fullstack-engineer", "BUG-XXX")

修復完成後：
├─ BA: runSubagent("critic", "修復代碼")
└─ BA: 通過 Commit-only Gate 後，runSubagent("commit-executor", "fix: [Bug ID] 修復")
```

### 版本升級

```
BA: runSubagent("migration-engineer", "升級信息：X.Y → A.B")
  ├─ migration-engineer 內部：
  │  ├─ 讀取官方升級指南
  │  ├─ 逐步升級，每步驟驗證
  │  └─ 完成後回報

升級完成後：
├─ BA: runSubagent("test-review", "升級後的測試驗證")
└─ BA: 通過 Commit-only Gate 後，runSubagent("commit-executor", "chore(deps): 升級 [庫] X.Y → A.B")
```

### 技術查詢（整個流程）

任何 Agent 遇到技術不確定（API 行為、庫用法、版本差異等）：
```
runSubagent("web-researcher", "查詢問題：[具體問題]")
```

### 複雜工具協調

需要複雜的工具集成或工具決策：
```
runSubagent("tool-expert", "工具決策/診斷")
```

---

## 📊 協作矩陣

| Phase | 主執行 | 支援審查 | 決策審批 |
|-------|--------|---------|---------|
| 0 | BA | web-researcher, tool-expert | BA + 使用者 |
| 1 | spec-engineer | web-researcher | BA + 使用者 |
| 2 | system-architect | frontend-designer, db-expert, sql-optimizer | BA + 使用者 |
| 3 | task-manager | system-architect (analyze) | BA + 使用者 |
| 4 | software/fullstack-engineer | frontend-designer, db-expert, linq-expert, sql-optimizer, critic, vuln-verifier | BA + 使用者 |
| 5 | test-review | - | BA + 使用者 |

---

## 💡 反面案例（禁止）

- ❌ **BA 自行執行規格化/設計/實作** → 必須呼叫對應 Agent
- ❌ **跳過 critic 審查直接 commit** → 必須先通過 critic
- ❌ **跳過 Phase 5 test-review** → 必須在 Phase 5 驗證一致性
- ❌ **軟體工程師自行決定 commit** → 必須由 commit-executor 執行
- ❌ **未通過對應 Gate 就提交或推進 Phase** → 必須先取得使用者明確核准
- ❌ **忽視 Agent 的 ❌ 或退回信號** → 必須處理完所有問題再推進
