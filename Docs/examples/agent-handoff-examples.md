# Agent Hand-off 完整範例

本文件只示範 [handoff Skill](../../.agents/skills/handoff/SKILL_zhTW.md) 的 canonical Contract，不另行定義格式或規則。下列路徑與命令屬於虛構情境中的交接資料，不表示目前 repository 實際存在相同產品檔案或驗證結果。

## 範例 A：部分驗證尚未完成的程式實作任務

# Agent Hand-off

## 1. 任務概述

- **任務／功能名稱**：登入鎖定功能
- **使用者目標**：依既有 Spec 與 Plan 完成登入失敗鎖定邏輯，並交由下一角色完成測試驗證。
- **目前狀態**：`completed-unverified`
- **目前 SDD Phase**：Phase 4
- **建議接手角色**：`test-review`；若測試發現實作缺陷則轉交 `software-engineer`
- **交接範圍**：登入服務模組實作完成後的測試與審查續接

## 2. 使用者已確認的需求

- `[使用者已確認]` 登入鎖定行為以 `specs/001-login-lockout/spec.md` 為準。
- `[使用者已確認]` 本次不得擴張到密碼重設或多因素驗證。

## 3. 重要限制與治理規則

- `[Repository 已查證]` 技術設計以 `specs/001-login-lockout/plan.md` 為準。
- `[Repository 已查證]` 任務狀態與 DoD 以 `specs/001-login-lockout/tasks.md` 為準。
- **Canonical 參考**：`AGENTS.md`

## 4. 已完成工作

- [x] Specification 與 Plan 已完成。
- [x] 已修改 `src/auth/login-service` 模組，實作 Spec 定義的登入鎖定行為。
- [x] 已實際執行 Build，exit code 為 0。

## 5. 尚未完成工作

- [ ] 依 `plan.md` 與既有測試設定確認正式 test command。
- [ ] 執行登入成功、連續失敗、鎖定期間與鎖定解除測試。
- [ ] 測試失敗時，將可重現證據與對應 Spec 條目交回 `software-engineer`。

## 6. 重要決策

| 決策 | 理由 | 來源／依據 | 是否已確認 |
|---|---|---|---|
| 狀態使用 `completed-unverified` | 預定程式修改已完成，但必要 Tests 尚未執行 | handoff Contract 的狀態定義 | 是 |
| 不在交接中重述鎖定規則 | Spec 是需求 SSOT | `specs/001-login-lockout/spec.md` | 是 |

## 7. 變更與相關檔案

### 已修改

- `src/auth/login-service`：加入登入失敗計數與鎖定判斷。

### 尚未修改但可能相關

- `tests/auth/login-service-tests`：下一角色應先確認現有 coverage，再決定是否需要補測試。

## 8. 驗證狀態

| 驗證項目 | 命令／方法 | 結果 | 實際證據／備註 |
|---|---|---|---|
| Build | `./scripts/build` | 通過 | `[工具已查證]` repository-local build script，exit code 0 |
| Tests | `未確認` | 未執行 | 尚未從 repository 設定確認正式 test command |
| Lint／Format | `不適用` | 不適用 | 本情境未定義獨立 lint／format gate |
| Governance check | `不適用` | 不適用 | 未修改治理檔 |

## 9. 已知問題與風險

- **問題／風險**：登入鎖定行為尚未經測試驗證。
  - **影響**：邊界條件或既有登入流程可能回歸。
  - **證據**：Tests 狀態為 `未執行`。
  - **建議處理方式**：先依 repository 設定確認正式 test command，再執行 Plan 要求的測試範圍。

## 10. 阻塞與待使用者決策

無。

## 11. 下一步

1. 依序閱讀 Spec、Plan、Tasks 與 `src/auth/login-service` 模組。
2. 從 solution、測試專案或 CI 設定查證正式 test command。
3. 實際執行測試並記錄命令、exit code、通過／失敗數；若全部通過，再依治理流程進入審查，不得直接把 Hand-off 狀態改為 `completed`。

## 12. 續接工作所需最小 Context

下一個 Agent 應依序優先讀取：

1. `specs/001-login-lockout/spec.md`
2. `specs/001-login-lockout/plan.md`
3. `specs/001-login-lockout/tasks.md`
4. `src/auth/login-service`
5. `tests/auth/login-service-tests`

不應主動載入：

- 不相關的 History
- 完整聊天紀錄
- 未被精確引用的 guides／research／examples
- 完整 Build log；Build 已通過，除非後續結果衝突才需回查

## 13. 未確認事項與假設

- **未確認／假設**：既有測試專案是否已涵蓋所有登入鎖定邊界條件。
- **類型**：`[假設／未確認]`
- **依據**：Tests 尚未執行，也尚未完成測試檔盤點。
- **驗證方式**：檢視測試清單並執行 repository 查證後的 test command。

## 14. 交接中繼資料

- **產生／更新時間**：`2026-07-17T10:00:00+08:00`（範例值）
- **來源 Agent／工具**：`software-engineer`（範例角色）
- **工作分支**：`未提供`
- **Commit／基準 SHA**：`未提供`
- **Working tree 狀態**：`src/auth/login-service` 已修改；其餘狀態 `未確認`
- **敏感資訊處理**：無

---

## 範例 B：缺少外部資料而阻塞的棕地遷移分析

# Agent Hand-off

## 1. 任務概述

- **任務／功能名稱**：棕地系統資料遷移盤點
- **使用者目標**：盤點舊系統結構與資料模型，產出可驗證的遷移映射基礎。
- **目前狀態**：`blocked`
- **目前 SDD Phase**：不適用（獨立維護／分析工作）
- **建議接手角色**：`migration-engineer`
- **交接範圍**：續接尚未確認的資料欄位與 API 映射

## 2. 使用者已確認的需求

- `[使用者已確認]` 先完成現況盤點，不得在資料映射未確認前實作轉換程式。
- `[使用者已確認]` 必須保留舊系統可觀察行為，不以欄位名稱相似度直接推定語意。

## 3. 重要限制與治理規則

- `[Repository 已查證]` 現況盤點記錄於 `migration/system-inventory.md` 與 `migration/data-model-inventory.md`。
- 缺少 production-like schema 與舊系統 API 文件時，不得把推測寫成已確認映射。
- **Canonical 參考**：`AGENTS.md`

## 4. 已完成工作

- [x] 完成 repository 目錄、主要模組與執行邊界盤點。
- [x] 完成可從原始碼查證的資料表、entity 與欄位清單。
- [x] 標記來源碼中無法判定語意的欄位與外部 API 依賴。

## 5. 尚未完成工作

- [ ] 比對 production-like schema 與目前資料模型盤點。
- [ ] 查證舊系統 API request／response 欄位語意。
- [ ] 確認未決欄位的來源、轉換規則與錯誤處理。
- [ ] 產出經證據支持的資料映射表與增量遷移切片。

## 6. 重要決策

| 決策 | 理由 | 來源／依據 | 是否已確認 |
|---|---|---|---|
| 暫停資料映射結論 | 缺少 production-like schema 與舊 API 文件，繼續會把推測當事實 | 使用者限制與盤點缺口 | 是 |
| 狀態使用 `blocked` | 缺少外部資訊，現有 repository 無法自行補足 | handoff Contract 的狀態定義 | 是 |

## 7. 變更與相關檔案

### 已新增

- `migration/system-inventory.md`：Repository 結構、模組與外部邊界盤點。
- `migration/data-model-inventory.md`：可從原始碼查證的資料模型與未決欄位。

### 尚未修改但可能相關

- `migration/data-mapping.md`：取得必要資料後才可建立，不得先填推測映射。

## 8. 驗證狀態

| 驗證項目 | 命令／方法 | 結果 | 實際證據／備註 |
|---|---|---|---|
| Build | `不適用` | 不適用 | 本交接範圍只有唯讀分析 |
| Tests | `不適用` | 不適用 | 尚未實作遷移程式 |
| Repository inventory | 原始碼搜尋與逐檔盤點 | 通過 | `[工具已查證]` 已記錄可查證的模組與資料模型；未宣稱涵蓋外部 schema |
| Governance check | `未執行` | 未執行 | 此虛構情境未提供治理檢查結果 |

## 9. 已知問題與風險

- **問題／風險**：無法確認部分欄位與舊 API payload 的真實語意。
  - **影響**：直接實作可能造成資料遺失、錯誤轉換或相容性破壞。
  - **證據**：`migration/data-model-inventory.md` 的未決欄位清單。
  - **建議處理方式**：取得 production-like schema dump 與對應版本的舊系統 API 文件後逐項對帳。

## 10. 阻塞與待使用者決策

- [ ] 請提供 production-like schema 或經遮蔽且結構等價的 schema dump。
  - **可選方案**：唯讀 schema export、經遮蔽的 DDL、可供查詢的受控環境。
  - **影響**：決定是否能查證欄位型別、constraint、default 與關聯。
  - **不決定時的預設處理**：維持 `blocked`，不建立資料映射結論。
- [ ] 請提供與目前舊系統版本一致的 API 文件或可重現 request／response 樣本。
  - **可選方案**：正式 API 文件、經遮蔽的流量樣本、可重現的測試環境。
  - **影響**：決定是否能確認外部欄位語意與錯誤行為。
  - **不決定時的預設處理**：保留未決項，不實作轉換。

## 11. 下一步

1. 取得並確認 schema／API 資料的版本、來源與遮蔽範圍。
2. 將新證據逐項對照 `migration/data-model-inventory.md` 的未決清單，保留來源引用。
3. 只有所有關鍵映射都有可查證依據後，才建立 `migration/data-mapping.md` 與增量遷移計畫。

## 12. 續接工作所需最小 Context

下一個 Agent 應依序優先讀取：

1. `migration/system-inventory.md`
2. `migration/data-model-inventory.md`
3. 使用者新提供的 schema 或 API artifact（目前 `未提供`）
4. `AGENTS.md`

不應主動載入：

- 不相關的 History
- 完整聊天紀錄
- 未被精確引用的 guides／research／examples
- 與未決欄位無關的完整 application log

## 13. 未確認事項與假設

- **未確認／假設**：Repository 內的 entity 定義與 production-like schema 完全一致。
- **類型**：`[假設／未確認]`
- **依據**：目前只有原始碼，沒有可比對的 schema。
- **驗證方式**：取得相同版本的 schema dump，逐項比較型別、constraint、default 與關聯。

## 14. 交接中繼資料

- **產生／更新時間**：`2026-07-17T10:30:00+08:00`（範例值）
- **來源 Agent／工具**：`migration-engineer`（範例角色）
- **工作分支**：`未提供`
- **Commit／基準 SHA**：`未提供`
- **Working tree 狀態**：新增兩份盤點文件；其餘狀態 `未確認`
- **敏感資訊處理**：已遮蔽環境識別資訊；未記錄原值
