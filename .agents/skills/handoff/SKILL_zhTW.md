---
name: handoff
description: >-
  建立或更新不綁定 Provider、模型、Runtime 與技術棧的 Markdown 交接文件，保存無需完整對話即可安全續接的最小已驗證狀態。適用於使用者要求交接或恢復摘要、即將更換 Agent／CLI／Provider／Session、Context 接近上限、工作阻塞或未完成即將停止、部分完成需轉交，以及重要 SDD Phase 邊界可能由不同角色接手時。
---

# Agent 交接

建立精簡、以證據為基礎的續接 artifact。只保留決策、狀態、結果、阻塞、路徑與具體下一步，不保存對話逐字稿。

此 `SKILL.md`／`SKILL_zhTW.md` 翻譯對是 Hand-off Contract 的 canonical source。完整 Contract 規則只保留於此；Agent、Prompt、治理文件與範例只能用一句話交叉引用，不得複製本 Contract。

## Contract 規則

- Markdown 是必要的人類可讀 artifact，也是交接內容的 source of truth。
- Hand-off 必須從屬於正式 artifacts。對 `spec.md`、`plan.md`、`tasks.md`、constitution、ADR、issue 與治理文件，只記錄路徑或 URL 加上與目前狀態直接相關的精簡摘要，不得取代或複製內容。
- 只保留安全續接所需的最小 Context。排除聊天逐字稿、大段程式碼、完整 diff、完整 log，以及 canonical artifact 已有的背景；若有可持久存取的 log 或 artifact，改為引用。
- 保持 Provider、模型、Runtime 與技術棧無關。只能建議 `business-analyst`、`software-engineer`、`debugger`、`test-review`、`migration-engineer` 等抽象角色；不得指定 Provider、模型、endpoint、Runtime、模型大小或量化格式。
- 遮蔽秘密、憑證、token、個人資料、私有 endpoint 與其他敏感值；若遮蔽會影響續接，記錄已遮蔽的資料類型，不記錄原值。
- 不得為了填滿格式而捏造內容。資訊缺失、不確定、未執行或不相關時，只能分別使用 `未提供`、`未確認`、`未執行`、`不適用`。
- 路徑盡量使用 repository 相對路徑；URL 只保留可持久存取且可安全分享者。

## 證據與驗證

來源無法直接從引用判斷時，使用以下標籤分類敘述：

| 標籤 | 意義 |
|---|---|
| `[使用者已確認]` | 使用者已明確確認。 |
| `[Repository 已查證]` | Repository artifact 或原始檔支持此敘述；必須引用路徑。 |
| `[工具已查證]` | 實際工具輸出支持此敘述；必須記錄命令或方法及精簡結果。 |
| `[推論]` | Agent 依已引用事實提出的推導或建議；不得寫成已確認。 |
| `[假設／未確認]` | 工作依賴尚未驗證的假設；必須附驗證方式。 |

只有交接撰寫者實際檢視過命令結果或可持久存取的 CI／log artifact，才能將驗證記為通過。記錄命令或方法、結果，以及失敗時足以診斷的錯誤摘要。沒有可查證輸出的其他 Agent 自述一律視為 `未確認`；「應該可用」不得轉寫為通過。必要檢查沒有執行時，填寫 `未執行`。

## 任務狀態詞彙

只能選擇一個狀態：

| 狀態 | 定義 |
|---|---|
| `not-started` | 尚未開始任何任務工作。 |
| `in-progress` | 工作正在進行，且沒有更精確的終止或部分完成狀態可用。 |
| `blocked` | 缺少外部資訊、權限、環境變更或使用者決策，無法繼續。 |
| `partially-completed` | 部分產出已完成，但仍有明確的實作或分析工作。 |
| `completed-unverified` | 預定工作看似已完成，但必要驗證尚未執行或無法完成。 |
| `completed` | 預定工作已完成，且所有必要驗證都實際通過。 |
| `cancelled` | 使用者或治理流程已明確停止任務。 |

已知仍有實作工作時不得使用 `completed-unverified`，應使用 `partially-completed`。不得僅因檔案存在、checkbox 已勾選或其他 Agent 自述通過而使用 `completed`。既有 SDD Phase 與 task checkbox 詞彙維持不變；此狀態只描述本次交接範圍。

## 產生門檻

只在有意義的續接邊界建立或更新 Hand-off：使用者要求交接或恢復摘要、更換 Agent／CLI／Provider／Session、長 Session 即將結束、Context 接近上限、任務阻塞、部分完成需由其他角色接手、Agent 即將停止但任務未完成，或重要 SDD Phase 完成且下一 Phase 可能更換負責者。不要在每個微小操作後建立 Hand-off。

## 檔案選擇與更新策略

依下列確定順序選擇：

1. 已知同一任務的既有 Hand-off 路徑時，直接更新該檔案。
2. Spec Kit feature 已存在時，使用 `<feature-directory>/handoff.md`，與該 feature 的正式 artifacts 並列。
3. 非 feature 工作已有正式工作目錄時，使用 `<work-directory>/handoff.md`。
4. 否則，遵循 repository 治理文件已定義的共用 handoff／resume 位置。
5. 單純本地跨 Session、沒有正式位置或 repository 慣例時，使用 `tmp/handoff.md`；若 `tmp/` 被忽略，將其視為暫存 artifact。
6. 若仍有多個任務身份或版本化位置同樣合理，寫入前依 repository 強制的決策機制請使用者決定。

同一任務優先只保留一份 `handoff.md` 並原地更新。需要版本歷史時使用 Git history；只有 repository 的 History 政策明確適用或使用者要求歷史快照時，才使用該政策。預設不得自創 Hand-off 目錄或不斷產生時間戳重複檔案。

## 操作流程

1. 確認交接範圍、任務身份、續接目的，以及是否應更新既有 Hand-off。
2. 找出正式 Spec、Plan、Tasks、ADR、Constitution、issue 或其他治理 artifacts，只引用而不複製。
3. 檢查實際 repository 狀態：目前分支、可取得時的基準 commit、working tree 狀態與異動路徑；非 Git 工作填寫 `不適用`。
4. 只收集可取得實際輸出或可持久 artifact 的 build、test、lint、format、review 與 governance 結果。
5. 區分已完成、未完成、阻塞、取消與未驗證工作，並從 canonical 詞彙選擇一個任務狀態。
6. 記錄已確認決策、理由與來源；明確標示建議、推論及假設。
7. 選出下一個 Agent 真正需要依序讀取的最小檔案集，並遵守 repository 的 Context 排除及可見性規則。
8. 依檔案選擇策略決定位置，建立或更新 Hand-off Markdown。
9. 只有符合下方條件時，才建立機器可讀 sidecar。
10. Artifact 位於本機時，先執行下方輕量 validator，再人工檢查過期敘述、敏感資料、重複 SDD 內容與無效路徑等無法機械判斷的事項；適用時執行 repository 要求的治理或格式檢查。
11. 回報 Hand-off artifact 路徑與狀態，不得宣稱尚未驗證的產品工作已完成。

## 輕量 Validator

建立或更新單一 Hand-off Markdown 後，執行：

```bash
python3 .agents/skills/handoff/scripts/validate_handoff.py <handoff.md>
```

此腳本只使用 Python 標準函式庫，不需要虛擬環境或安裝套件。它檢查單一文件標題、必要編號章節、章節順序、狀態詞彙、驗證表結果，以及 `completed`、`completed-unverified`、`blocked`、`not-started` 可機械判斷的矛盾。

它不驗證內容真偽、引用路徑、命令是否實際執行、證據品質或可選敘述是否完整；這些事項仍須人工審查。交接前必須修正所有回報問題。

Exit codes：

- `0`：格式與狀態內部一致。
- `1`：發現一個以上格式或狀態一致性問題。
- `2`：CLI 使用方式錯誤或檔案讀取失敗。

## Canonical Markdown 結構

必須保留第 1、4、5、8、10、11、12、14 節。第 2、3、6、7、9、13 節只有在確實不適用時才可省略；否則保留並使用明確的缺失值。第 7 節中不適用的檔案類別子節可省略。保留各節原本編號，不因省略而重新編號。

依 repository 要求的文件語言輸出；治理規則要求正體中文時，使用以下結構：

```markdown
# Agent Hand-off

## 1. 任務概述

- **任務／功能名稱**：
- **使用者目標**：
- **目前狀態**：`not-started`／`in-progress`／`blocked`／`partially-completed`／`completed-unverified`／`completed`／`cancelled`
- **目前 SDD Phase**：
- **建議接手角色**：
- **交接範圍**：

## 2. 使用者已確認的需求

- ...

## 3. 重要限制與治理規則

- ...
- **Canonical 參考**：`path` 或 URL

## 4. 已完成工作

- [x] ...

## 5. 尚未完成工作

- [ ] ...

## 6. 重要決策

| 決策 | 理由 | 來源／依據 | 是否已確認 |
|---|---|---|---|
| ... | ... | 使用者指示、`path`、命令或方法 | 是／否 |

## 7. 變更與相關檔案

### 已修改

- `path`：修改摘要

### 已新增

- `path`：用途

### 已刪除

- `path`：刪除理由與可恢復性

### 尚未修改但可能相關

- `path`：關聯原因

## 8. 驗證狀態

| 驗證項目 | 命令／方法 | 結果 | 實際證據／備註 |
|---|---|---|---|
| Build | `...` | 通過／失敗／未執行／不適用 | exit code、計數或精簡錯誤 |
| Tests | `...` | 通過／失敗／未執行／不適用 | exit code、通過／失敗數或原因 |
| Lint／Format | `...` | 通過／失敗／未執行／不適用 | ... |
| Governance check | `...` | 通過／失敗／未執行／不適用 | ... |

## 9. 已知問題與風險

- **問題／風險**：
  - **影響**：
  - **證據**：
  - **建議處理方式**：

## 10. 阻塞與待使用者決策

- [ ] 待決策事項
  - **可選方案**：
  - **影響**：
  - **不決定時的預設處理**：

若沒有，填寫「無」。

## 11. 下一步

1. ...
2. ...
3. ...

## 12. 續接工作所需最小 Context

下一個 Agent 應依序優先讀取：

1. `path/to/canonical-artifact`
2. `path/to/modified-file`
3. `path/to/governance-file`

不應主動載入：

- 不相關的 History
- 完整聊天紀錄
- 未被精確引用的 guides／research／examples
- 完整 build／test log（除非正在診斷且已提供精確路徑）

## 13. 未確認事項與假設

- **未確認／假設**：
- **類型**：`[推論]`／`[假設／未確認]`
- **依據**：
- **驗證方式**：

## 14. 交接中繼資料

- **產生／更新時間**：ISO 8601 含時區；無法取得時填 `未提供`
- **來源 Agent／工具**：若可取得；否則填 `未提供`
- **工作分支**：
- **Commit／基準 SHA**：
- **Working tree 狀態**：
- **敏感資訊處理**：無／已遮蔽（說明類型，不記錄值）
```

## 可選的機器可讀 Sidecar

預設不得建立 sidecar。只有使用者明確要求，或 repository 已有文件化 consumer、schema 與驗證路徑時，才加入 JSON 或 YAML。Markdown 維持 authoritative；sidecar 只能是可重新產生的投影，必須指回 Markdown 路徑，且只保存精簡的機器狀態。不得重複敘事內容、SDD 內容、log、Provider／模型設定或秘密。兩者不一致時，必須依 Markdown 修正或重新產生 sidecar 後再交接。

## 範例

只有需要端到端範例時，才讀取 [Docs/examples/agent-handoff-examples.md](../../../Docs/examples/agent-handoff-examples.md)。該檔案包含技術棧無關的 `completed-unverified` 程式實作交接，以及 `blocked` 的棕地遷移分析交接；它只供示範，不是第二份 Contract。
