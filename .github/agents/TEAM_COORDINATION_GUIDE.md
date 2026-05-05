---
title: SDD 開發團隊協調指南
description: 完整的 SDD 開發流程中各 Agent 的角色、職責與協作方式
---

# 🏢 SDD 開發團隊協調指南

此指南定義了完整的 SDD（Software Design Document）開發流程中，15 個 Agents 的角色、職責與協作模式。

## 📋 快速索引

| 角色 | 職責 | 主要調用時機 |
|------|------|-----------|
| **ba** | 需求接收、流程協調 | 每個 Phase 開始前 |
| **web-researcher** | 技術文檔查詢 | 任何 Agent 遇到技術不確定 |
| **spec-engineer** | 規格化（speckit.specify/clarify） | Phase 1 |
| **system-architect** | 技術設計（speckit.plan/analyze） | Phase 2、Phase 3 end |
| **sdd-expert** | SDD 文件撰寫、架構指導 | Phase 2（支援 system-architect） |
| **frontend-designer** | 前端 UI 設計審查 | Phase 2、Phase 4 UI Task 前 |
| **db-expert** | 數據庫設計審查（read-only） | Phase 2、Phase 4 DB Task |
| **sql-optimizer** | SQL 查詢最佳化 | Phase 2、Phase 4（支援 db-expert 或工程師） |
| **task-manager** | 任務拆解（speckit.tasks） | Phase 3 start |
| **software-engineer** | 簡單 Task 實作（speckit.implement） | Phase 4 簡單 Task |
| **fullstack-engineer** | 複雜 Task 實作（speckit.implement） | Phase 4 複雜 Task |
| **linq-expert** | LINQ 查詢最佳化 | Phase 4（支援工程師） |
| **critic** | 靜態代碼審查 + 安全審計 | Phase 4 每個 TASK 完成後 |
| **vuln-verifier** | 漏洞驗證（PoC 代碼） | critic 發現漏洞後 |
| **test-review** | Spec 一致性 + 測試驗證 | Phase 5 |
| **debugger** | 根本原因診斷 | Bug 修復或生產問題 |
| **migration-engineer** | 框架/庫版本升級 | 版本升級維護流程 |
| **tool-expert** | 工具選型、工具鏈協調 | Phase 0、工具故障診斷 |
| **commit-executor** | Git commit 執行 | 每個 Phase 完成後 |

---

## 🎯 完整 SDD 開發流程

### Phase 0：需求接收 & 技術決策

**主要角色**：BA（協調）

```
BA 接收需求
  → 若需技術查詢 → runSubagent("web-researcher", ...)
  → 若需工具決策 → runSubagent("tool-expert", ...)
  → 產出 requirements.md
  → 確認無誤後推進 Phase 1
```

### Phase 1：規格化

**主要角色**：spec-engineer（執行）

```
BA: runSubagent("spec-engineer", requirements.md, model: "GPT-5.4")
  ├─ spec-engineer 內部：
  │  ├─ 讀取 speckit.specify.agent.md
  │  ├─ 執行規格化流程 → 產出 spec.md
  │  ├─ 技術查詢 → 自行使用搜尋工具（fetch_webpage 等）
  │  ├─ 若需決策 → 回報 BA
  │  └─ spec 確認後向 BA 回報
  
若 BA 判斷需深入技術調查：
  └─ BA: runSubagent("web-researcher", 技術查詢, model: "GPT-4o")
  └─ 將查詢結果傳遞給 spec-engineer
  
BA: runSubagent("commit-executor", "Phase 1 Spec 完成", model: "GPT-4o")

完成標誌：spec.md 確認、所有決策項已確認或排除
```

### Phase 2：技術設計

**主要角色**：system-architect（執行）、frontend-designer/db-expert/sdd-expert（支援）

```
BA: runSubagent("system-architect", "執行技術設計", model: "GPT-5.4")
  ├─ system-architect 內部：
  │  ├─ 讀取 speckit.plan.agent.md
  │  ├─ 執行技術設計 → 產出 plan.md
  │  ├─ 技術查詢 → 自行使用搜尋工具（fetch_webpage 等）
  │  └─ plan 確認後向 BA 回報

plan.md 產出後，BA 視需要邀請支援審查：
  ├─ 如有 DB 設計 → BA: runSubagent("db-expert", "plan.md DB 部分", model: "GPT-5.4")
  │  ├─ db-expert 內部：
  │  │  ├─ 審查 schema、constraints、indexes
  │  │  └─ 回報審查結果
  │  └─ BA 判斷是否需退回 system-architect 調整 plan.md
  ├─ 如有前端 UI 決策 → BA: runSubagent("frontend-designer", "plan.md UI 部分", model: "GPT-5.4")
  │  ├─ frontend-designer 內部：
  │  │  ├─ 分析 UI/UX 需求
  │  │  ├─ 定義美感方向、設計原則
  │  │  └─ 回報設計建議
  │  └─ BA 判斷是否需退回 system-architect 調整 plan.md
  ├─ 如需 SDD 文件支援 → BA: runSubagent("sdd-expert", "plan.md", model: "GPT-5.4")
  │  └─ sdd-expert 提供 SDD 章節內容、Mermaid 圖表
  ├─ 如涉及複雜 SQL → BA: runSubagent("sql-optimizer", ..., model: "GPT-5.4")
  └─ BA: runSubagent("commit-executor", "Phase 2 Plan 完成", model: "GPT-4o")

完成標誌：plan.md 確認、所有子系統設計決策已明確
```

### Phase 3：任務拆解 + 一致性分析

**主要角色**：task-manager（執行）、system-architect（驗證）

```
BA: runSubagent("task-manager", "plan.md + 執行任務拆解", model: "GPT-5.4")
  ├─ task-manager 內部：
  │  ├─ 讀取 speckit.tasks.agent.md
  │  ├─ 執行任務拆解 → 產出 tasks.md
  │  └─ tasks 確認後向 BA 回報
  
BA: runSubagent("system-architect", "spec/plan/tasks + 執行一致性分析", model: "GPT-5.4")
  ├─ system-architect 內部：
  │  ├─ 讀取 speckit.analyze.agent.md
  │  ├─ 驗證 spec ↔ plan ↔ tasks 一致性
  │  ├─ ✅ 通過 → 向 BA 回報通過
  │  └─ ❌ 未通過 → 向 BA 回報問題及退回對象
  
  若 analyze 未通過：
  ├─ BA 決定退回對象（task-manager 或 system-architect）
  └─ 重新執行對應 Phase
  
  若 analyze 通過：
  └─ BA: runSubagent("commit-executor", "Phase 3 Tasks + 一致性檢查完成", model: "GPT-4o")

完成標誌：tasks.md 確認、speckit.analyze 通過
```

### Phase 4：實作 + 品質控制

**主要角色**：software-engineer/fullstack-engineer（實作）、critic（審查）

```
對 tasks.md 中的每個 TASK，執行以下流程：

【步驟 1：前置支援審查（按需，由 BA 根據 TASK 分類標記判斷）】
  ├─ 如涉及前端 UI → BA: runSubagent("frontend-designer", "TASK-XXX UI 設計", model: "GPT-5.4")
  ├─ 如涉及 DB 變更 → BA: runSubagent("db-expert", "TASK-XXX DB 審查", model: "GPT-5.4")
  ├─ 如涉及複雜 LINQ/SQL → BA: runSubagent("linq-expert" 或 "sql-optimizer", ...)
  └─ 將審查結果作為工程師的實作參考

【步驟 2：選擇工程師】
  ├─ 簡單 Task（單模塊、低風險）
  │  └─ BA: runSubagent("software-engineer", "TASK-XXX + 前置審查結果", model: "Claude Sonnet 4.6")
  └─ 複雜 Task（跨模塊、設計決策、高風險）
     └─ BA: runSubagent("fullstack-engineer", "TASK-XXX + 前置審查結果", model: "Claude Sonnet 4.6")

【步驟 3：實作】
  工程師內部：
  ├─ 讀取 speckit.implement.agent.md
  ├─ BA 提供的前置審查結果作為實作參考
  ├─ 技術查詢 → 自行使用搜尋工具（fetch_webpage 等）
  ├─ 依 Task DoD 完成實作 + 測試
  └─ 完成後向 BA 回報

【步驟 4：靜態代碼審查】
  BA: runSubagent("critic", "TASK-XXX 代碼", model: "GPT-5.4")
  ├─ critic 內部：
  │  ├─ 檢查代碼品質、安全性、效能、錯誤處理
  │  ├─ 🔴 Critical/🟠 Major 問題 → 向 BA 報告
  │  ├─ 🔐 發現安全漏洞 → 向 BA 報告
  │  ├─ ✅ 通過 → 向 BA 回報通過
  │  └─ ❌ 有問題 → 向 BA 回報問題
  
  BA 根據 Critic 結果決定後續行動：
  ├─ 🔐 安全漏洞 → BA: runSubagent("vuln-verifier", "critic 漏洞報告", model: "GPT-5.4")
  │     ├─ vuln-verifier 內部：寫 PoC 代碼驗證
  │     └─ 回報驗證結果
  
  若 critic 通過：
  └─ BA: runSubagent("commit-executor", "TASK-XXX 完成", model: "GPT-4o")
  
  若 critic 有問題：
  ├─ BA 決定退回對象（工程師修復）
  └─ 工程師修復後回到步驟 3

【迴圈結束】所有 TASK 完成

完成標誌：所有 TASK 完成實作 + critic 審查通過
```

### Phase 5：最終審查驗證

**主要角色**：test-review（執行）

```
BA: runSubagent("test-review", "所有 TASK + spec/plan/tasks", model: "GPT-5.4")
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
  ├─ BA: runSubagent("commit-executor", "chore: Phase 5 審查通過", model: "GPT-4o")
  └─ 向使用者回報特性已交付
  
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
BA: runSubagent("debugger", "Bug 描述、錯誤日誌", model: "GPT-5.4")
  ├─ debugger 內部：
  │  ├─ 收集錯誤信息、觸發條件、頻率、最近改動
  │  ├─ 建立假設並驗證
  │  └─ 產出根本原因分析報告
  
根據根本原因決定修復方案：
├─ 簡單 hotfix → BA: runSubagent("software-engineer", "BUG-XXX", model: "Claude Sonnet 4.6")
└─ 複雜 hotfix → BA: runSubagent("fullstack-engineer", "BUG-XXX", model: "Claude Sonnet 4.6")

修復完成後：
├─ BA: runSubagent("critic", "修復代碼", model: "GPT-5.4")
└─ BA: runSubagent("commit-executor", "fix: [Bug ID] 修復", model: "GPT-4o")
```

### 版本升級

```
BA: runSubagent("migration-engineer", "升級信息：X.Y → A.B", model: "GPT-5.4")
  ├─ migration-engineer 內部：
  │  ├─ 讀取官方升級指南
  │  ├─ 逐步升級，每步驟驗證
  │  └─ 完成後回報

升級完成後：
├─ BA: runSubagent("test-review", "升級後的測試驗證", model: "GPT-5.4")
└─ BA: runSubagent("commit-executor", "chore(deps): 升級 [庫] X.Y → A.B", model: "GPT-4o")
```

### 技術查詢（整個流程）

任何 Agent 遇到技術不確定（API 行為、庫用法、版本差異等）：
```
runSubagent("web-researcher", "查詢問題：[具體問題]", model: "GPT-4o")
```

### 複雜工具協調

需要複雜的工具集成或工具決策：
```
runSubagent("tool-expert", "工具決策/診斷", model: "GPT-5.4")
```

---

## 📊 協作矩陣

| Phase | 主執行 | 支援審查 | 決策審批 | 
|-------|--------|---------|---------|
| 0 | BA | web-researcher, tool-expert | BA + 使用者 |
| 1 | spec-engineer | web-researcher | BA + 使用者 |
| 2 | system-architect | frontend-designer, db-expert, sdd-expert, sql-optimizer | BA + 使用者 |
| 3 | task-manager | system-architect (analyze) | BA |
| 4 | software/fullstack-engineer | frontend-designer, db-expert, linq-expert, sql-optimizer, critic, vuln-verifier | BA |
| 5 | test-review | - | BA + 使用者 |

---

## ⚙️ Agent 調用模式

### 強制模式（必須調用）
- Phase 1 → **必須** 呼叫 spec-engineer
- Phase 2 → **必須** 呼叫 system-architect
- Phase 3 → **必須** 呼叫 task-manager + system-architect（analyze）
- Phase 4 → **必須** 呼叫 software/fullstack-engineer + critic
- Phase 5 → **必須** 呼叫 test-review

### 條件模式（按需調用）
- **frontend-designer**：只在涉及前端 UI/UX 時
- **db-expert**：只在涉及 DB 變更時
- **vuln-verifier**：只在 critic 發現安全漏洞時
- **web-researcher**：任何 Agent 遇到技術不確定時
- **debugger**：發現 bug 時
- **migration-engineer**：版本升級時
- **tool-expert**：工具決策或故障時

---

## 💡 反面案例（禁止）

❌ **BA 自行執行規格化/設計/實作** → 必須呼叫對應 Agent  
❌ **跳過 critic 審查直接 commit** → 必須先通過 critic  
❌ **跳過 Phase 5 test-review** → 必須在 Phase 5 驗證一致性  
❌ **軟體工程師自行決定 commit** → 必須由 commit-executor 執行  
❌ **忽視 Agent 的 ❌ 或退回信號** → 必須處理完所有問題再推進

---

## 📞 快速聯繫

- **流程問題**：BA（ba.agent.md）
- **規格問題**：spec-engineer（spec-engineer.agent.md）
- **設計問題**：system-architect（system-architect.agent.md）
- **實作問題**：software/fullstack-engineer
- **代碼品質**：critic（critic.agent.md）
- **測試/最終審查**：test-review（test-review.agent.md）
- **Bug 診斷**：debugger（debugger.agent.md）
- **技術查詢**：web-researcher（web-researcher.agent.md）
