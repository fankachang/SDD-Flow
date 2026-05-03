---
description: "從中斷的 SDD 流程指定 Stage 續跑。提供 feature 名稱與要續跑的 Stage 編號（0–8），SDD_Leader 將跳過已完成的階段直接從指定點繼續，並維持完整的 commit gate 互動。"
---

# SDD 流程續跑（Resume）

> **使用時機**：你已跑過部份 SDD 流程，中途因故中斷，想從特定 Stage 繼續執行。

## 使用方式

在 VS Code 聊天視窗輸入：

```
@SDD_Leader /sdd-resume <feature-name> <stage>
```

例如：

```
@SDD_Leader /sdd-resume macos-sound2txt 6
```

---

## 代理人指令

請 SDD_Leader 代理人依以下步驟執行 Resume 流程：

### Step 1：確認目前狀態

1. 解析參數：`$feature_name`、`$resume_stage`（整數 0–8）
2. 讀取 `AGENTS.md`
3. 執行 `git rev-parse --abbrev-ref HEAD` 確認分支安全性
4. 讀取以下已存在的產出（跳過不存在的）：
   - `specs/<feature-name>/spec.md`
   - `specs/<feature-name>/plan.md`
   - `specs/<feature-name>/tasks.md`
5. 向使用者回報「目前偵測到的產出狀態」：
   ```
   spec.md   ── [存在 / 不存在]  FR 數：X
   plan.md   ── [存在 / 不存在]  Phase 數：Y
   tasks.md  ── [存在 / 不存在]  任務總數：Z
   ```

### Step 2：確認 Resume 起始點

用 `vscode_askQuestions` 詢問使用者：

- **問題**：確認要從哪個 Stage 開始續跑？

| Stage | 階段名稱 |
|-------|---------|
| 0 | 前置檢查 |
| 1 | Specify（產生 spec.md）|
| 2 | Clarify（澄清規格）|
| 3 | Plan（產生 plan.md）|
| 4 | Tasks（產生 tasks.md）|
| 5 | Analyze（一致性審查）|
| 6 | Implement（執行實作）|
| 7 | Verify（品質安全驗證）|
| 8 | 交付 |

- 選項：[Stage $resume_stage（使用參數值）] / [重新選擇 Stage] / [自行輸入（freeform）]

### Step 3：執行 SDD 流程（從指定 Stage 開始）

從使用者確認的 Stage 繼續，完整執行 SDD_Leader 的剩餘所有階段，包含每階段的 commit gate 與互動確認。

**注意事項**：
- 跳過已確認完成的早期 Stage，不重複產出已存在的文件
- 若偵測到中間產出（如 spec.md 存在但 plan.md 不存在），自動建議從最早缺失的階段開始
- 每個 Stage 的 commit gate 和互動規則與正常 SDD 流程完全相同
