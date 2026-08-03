# Skills 與 Agents 衝突檢查結論

**檢查日期**：2026-08-03
**檢查範圍**：`.agents/skills/`、`.github/agents/`、`.github/prompts/`、`.github/instructions/` 與 Team Mode 協作規範

## 結論

`speckit.*` 視為上游專案規範；在本 repository 中，若由 `ba` Agent 進入流程，應以 Team Mode 的 BA、Phase Gate、Commit Gate 與專責 Agent 委派流程為準。

Team Mode 與 Native SpecKit Mode 已明確分流，不應將上游 `speckit.*` 的原生 handoff、直接提問或全任務實作流程套用到 Team Mode。相關分流定義見 `Docs/governance/TEAM_COORDINATION_GUIDE.md:14-26`。

因此，不建議為了本 repository 的 Team Mode 行為直接修改上游 `speckit.*` Agent；應補強 Team workflow 的優先順序與覆寫規則。

## 已通過檢查

已執行嚴格一致性檢測：

```bash
rtk proxy python3 .agents/skills/consistency-check/scripts/consistency-check.py --strict
```

結果：未發現跨檔案重複、Skill 翻譯缺漏、重複載入或治理文件載入循環。

## 需要補充的規則

### 1. 明確規定 Team Mode 的規範優先順序

目前 Team Guide 已定義 Team Mode 不直接呼叫 `/speckit.*`，但尚未集中說明上游規則與 Team 規則衝突時的優先順序。

建議在 `Docs/governance/TEAM_COORDINATION_GUIDE.md` 增加唯一權威說明：

1. `AGENTS.md` 的全域強制規則
2. `TEAM_COORDINATION_GUIDE.md` 的 Team Mode 流程
3. 目前 Team Agent 的角色與邊界
4. `speckit.*` 上游 workflow 的產物格式與一般流程
5. 上游 frontmatter handoff、直接使用者互動、測試選配與全任務迴圈不得覆寫 Team 規則

各 Team Agent 僅需保留一句交叉引用，避免重複維護同一套優先順序。

### 2. 統一需求狀態標記與轉換規則

目前同時出現三種未決狀態：

- Team BA：`[PENDING-USER-DECISION]`，見 `.github/agents/ba.agent.md:55`
- Team Spec Engineer：`[UNKNOWN]`，見 `.github/agents/spec-engineer.agent.md:36`
- 上游 SpecKit：`[NEEDS CLARIFICATION]`，見 `.github/agents/speckit.specify.agent.md:124`

建議在 Team Guide 定義：

- 上游 `[NEEDS CLARIFICATION]` 進入 Team Mode 後，一律轉成 `[PENDING-USER-DECISION]`。
- 未經使用者確認的需求不得以合理猜測取代，符合 `.github/agents/ba.agent.md:55`。
- `[UNKNOWN]` 若要保留，必須明確定義為「既有系統行為尚未查證」，不可代表可直接採用的需求決策。

### 3. 明確覆寫上游的測試選配規則

`AGENTS.md:24` 規定規格未明確定義時預設採 TDD，但上游 `speckit.tasks.agent.md:143` 與 `.specify/templates/tasks-template.md:12` 將測試任務列為選配。

Team Mode 應明定：

- 每個 Team Task 必須有測試類型與可驗證 DoD，符合 `.github/agents/task-manager.agent.md:30-40`。
- 工程師必須依架構師測試策略同步撰寫並執行測試，符合 `.github/agents/software-engineer.agent.md:51-54`。
- 上游「Tests are OPTIONAL」只適用 Native SpecKit Mode，不適用 Team Mode。
- 若確實不需測試，必須由 BA 記錄明確例外與理由，不得默默省略。

### 4. 明確禁止 Team Agent 執行上游互動指示

`spec-engineer` 已要求遇到人為決策時回報 BA，見 `.github/agents/spec-engineer.agent.md:21`；但它同時要求完整套用上游 workflow，見 `.github/agents/spec-engineer.agent.md:15-19`。

建議補充一句：

> Team Mode 載入上游 workflow 時，只套用其輸入、產物、驗證與 hook 規則；上游文件中的直接詢問使用者、等待使用者回覆、frontmatter handoff 與模式切換指示均不執行，統一回報 BA。

### 5. 記錄 `vscode/askQuestions` 的平台前置條件

Team Gate 要求使用 `vscode/askQuestions`，見 `AGENTS.md:16` 與 `Docs/governance/TEAM_COORDINATION_GUIDE.md:31-43`。目前 Codex CLI 執行環境未暴露此工具；若 Team Mode 僅支援 VS Code，應在 Team Guide 明確標示：

- 工具不可用時視為 workflow blocker。
- 不得退回普通文字提問作為替代。
- BA 應回報阻塞，等待切換到具備該工具的平台。

### 6. 補強 Commit Agent 的分支安全檢查

全域 Git 規則禁止在受保護分支直接 commit，見 `.github/instructions/git-workflow.instructions.md:14`；但 `commit-executor` 的固定流程只檢查檔案與 staged diff，見 `.github/agents/commit-executor.agent.md:25-32`。

建議在 commit 前加入目前分支檢查；若分支為 `main`、`master`、`production`、`release` 或 `prod`，立即停止並回報 BA。

## 非 Team Mode 的獨立風險

以下問題與上游 `speckit.*` 無關，但仍建議後續處理：

- `.agents/skills/hush/SKILL.md:206` 仍示範直接執行 `git commit`，可能繞過 Team Commit Gate。
- `.agents/skills/doc-coauthoring/SKILL.md:188`、`:208`、`:368` 指定使用 `str_replace`／`create_file`，不符合目前 Codex 可用的編輯工具模型。

## 不需視為衝突的項目

- Native SpecKit Mode 使用原生 `/speckit.*` handoff 與全任務流程，屬於另一種明確模式。
- Team Mode 中工程師只處理單一 `T###`，不執行上游 `speckit.implement` 的全任務迴圈；此限制已寫於 `.github/agents/software-engineer.agent.md:15-18` 與 `.github/agents/fullstack-engineer.agent.md:12-16`。
- `consistency-check --strict` 通過表示結構性 SSOT／載入問題沒有被機械檢測出來；上述項目屬於語意優先順序與執行邊界，仍需文件補充。

## 建議處理順序

1. 先在 Team Guide 補上規範優先順序與上游規則覆寫條款。
2. 統一需求狀態標記，明確禁止未決需求被猜測取代。
3. 明定 Team Mode 的 TDD／測試任務政策。
4. 補上 `vscode/askQuestions` 的平台阻塞規則與 commit 分支檢查。
5. 最後整理獨立 Skills 的 commit 與編輯工具說明。

## 執行記錄（2026-08-03，多輪修正）

### 已完成修正

- `Docs/governance/TEAM_COORDINATION_GUIDE.md`
	- 集中定義 Team Mode 的規範優先順序：`AGENTS.md`、Team Guide、Team Agent 角色邊界、上游 `speckit.*` workflow。
	- 明確禁止上游的直接使用者互動、frontmatter handoff、模式切換、合理猜測、未經確認的預設值、測試選配與全任務迴圈覆寫 Team Mode 規則。
	- 統一 `[PENDING-USER-DECISION]`、`[UNKNOWN]` 與 `[NEEDS CLARIFICATION]` 的 Team Mode 轉換與語意。
	- 明定每個 Team Task 的測試類型、可驗證 DoD、測試例外記錄，以及 `vscode/askQuestions` 不可用時的 workflow blocker 行為。
- `.github/agents/spec-engineer.agent.md`
	- 明確限定 Team Mode 只套用上游 workflow 的輸入、產物、驗證與 hook 規則，不執行上游互動、等待回覆或模式切換指示。
	- 區分尚未查證的既有行為 `[UNKNOWN]` 與需要使用者決策的 `[PENDING-USER-DECISION]`。
- `.github/agents/task-manager.agent.md`、`.github/agents/system-architect.agent.md`
	- 加入以 `TEAM_COORDINATION_GUIDE.md` 為準的非載入型交叉引用，避免使用「依檔案辦理」造成未來工具誤判為讀取指令。
- `.github/agents/commit-executor.agent.md`
	- 在 staging 前增加受保護分支檢查；位於 `main`、`master`、`production`、`release` 或 `prod` 時立即停止並回報 BA。
- `.agents/skills/hush/SKILL.md`、`.agents/skills/hush/SKILL_zhTW.md`
	- 移除直接 `git commit` 範例，改由 Team Mode 的 Commit Gate 與 `commit-executor` 負責提交。
- `.agents/skills/doc-coauthoring/SKILL.md`、`.agents/skills/doc-coauthoring/SKILL_zhTW.md`
	- 既有檔案編輯統一使用 `apply_patch`。
	- 新 artifact 與 workspace file 改以平台提供的建立能力描述，不再綁定 `create_file` 工具名稱。

### 驗證結果

- 多輪執行 `rtk proxy python3 .agents/skills/consistency-check/scripts/consistency-check.py --strict`，最終通過；未發現跨檔案重複、Skill 翻譯缺漏、重複載入或治理文件載入循環。
- `git diff --check` 最終通過。
- 精確搜尋確認兩份 `doc-coauthoring` Skill 已無 `create_file` 殘留。
- Team Agent 的交叉引用採「以 `TEAM_COORDINATION_GUIDE.md` 為準」表述，不建立明確載入邊，因此不形成遞迴讀取。

### 最終狀態

主要 Team Mode 衝突與本輪確認的三項殘留風險均已補強；上游 `speckit.*` 的 Native SpecKit Mode 行為未被改動。此次未執行 commit，因目前工作分支為受保護的 `main`。
