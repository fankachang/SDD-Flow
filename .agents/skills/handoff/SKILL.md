---
name: handoff
description: >-
  Create or update a provider-, model-, runtime-, and technology-agnostic Markdown handoff that preserves the minimum verified state needed to continue work safely without the full conversation. Use when the user requests a handoff or resume summary; before switching agents, CLIs, providers, or sessions; near a context limit; when blocked or stopping with unfinished work; after partial completion; or at an important SDD phase boundary that another role may continue.
---

# Agent Hand-off

Create a compact, evidence-based continuation artifact. Preserve decisions, state, results, blockers, paths, and concrete next steps; do not preserve the conversation transcript.

This `SKILL.md` / `SKILL_zhTW.md` translation pair is the canonical Hand-off Contract. Keep complete contract rules here only. Agents, prompts, governance documents, and examples may provide a one-line cross-reference but must not copy this contract.

## Contract rules

- Make Markdown the required, human-readable artifact and the source of truth for the handoff.
- Keep the handoff subordinate to formal artifacts. Reference `spec.md`, `plan.md`, `tasks.md`, constitutions, ADRs, issues, and governance documents by path or URL plus a short state-specific summary; never replace or reproduce them.
- Preserve only the minimum context needed to resume safely. Exclude transcripts, large code blocks, full diffs, full logs, and background already available from a canonical artifact. Point to a durable log or artifact when one exists.
- Remain provider-, model-, runtime-, and technology-agnostic. Recommend an abstract role such as `business-analyst`, `software-engineer`, `debugger`, `test-review`, or `migration-engineer`; never prescribe a provider, model, endpoint, runtime, model size, or quantization.
- Redact secrets, credentials, tokens, personal data, private endpoints, and other sensitive values. Record that redaction occurred when it affects continuation.
- Do not invent content to fill the structure. Use exactly `未提供`, `未確認`, `未執行`, or `不適用` when information is absent, uncertain, not run, or irrelevant in Traditional Chinese artifacts.
- Keep paths repository-relative when possible. Preserve URLs only when they are durable and safe to share.

## Evidence and verification

Classify claims when their origin is not already obvious from a cited source:

| Label | Meaning |
|---|---|
| `[使用者已確認]` | The user explicitly confirmed the statement. |
| `[Repository 已查證]` | A repository artifact or source file supports the statement; cite its path. |
| `[工具已查證]` | Actual tool output supports the statement; record the command or method and concise result. |
| `[推論]` | The agent derived a recommendation from cited facts; do not present it as confirmed. |
| `[假設／未確認]` | Work depends on an unverified assumption; include how to verify it. |

Record validation as passed only when the handoff author actually inspected the command result or a durable CI/log artifact. Include the command or method, result, and the diagnostic part of any failure. Treat another agent's unsupported claim as `未確認`; never convert "should work" into a pass. Use `未執行` when a required check did not run.

## Task status vocabulary

Use exactly one status:

| Status | Definition |
|---|---|
| `not-started` | No task work has begun. |
| `in-progress` | Work is active, and no more specific terminal or partial status applies. |
| `blocked` | Work cannot continue without external information, access, environment changes, or a user decision. |
| `partially-completed` | Some deliverables are complete, but known implementation or analysis work remains. |
| `completed-unverified` | The intended work appears complete, but required validation has not run or could not finish. |
| `completed` | The intended work is complete and every required validation actually passed. |
| `cancelled` | The user or governing process explicitly stopped the task. |

Do not use `completed-unverified` when known implementation work remains; use `partially-completed`. Do not use `completed` merely because files exist, checkboxes are marked, or another agent says the work passed. Keep SDD phase and task checkbox vocabulary unchanged; this status describes the handoff scope only.

## Creation threshold

Create or update a handoff at a meaningful continuation boundary: a requested transfer or resume summary, an agent/CLI/provider/session switch, a long-session stop, an approaching context limit, a blocker, partial completion requiring another role, an unfinished stop, or an important SDD phase boundary likely to change owners. Do not create one after each small operation.

## File selection and update policy

Use this deterministic order:

1. Update the existing handoff for the same task when its path is known.
2. For a Spec Kit feature, use `<feature-directory>/handoff.md` beside that feature's formal artifacts.
3. For non-feature work with a formal work directory, use `<work-directory>/handoff.md`.
4. Otherwise, follow an existing repository-wide handoff/resume location documented by repository governance.
5. For a local, session-only handoff with no formal location or repository convention, use `tmp/handoff.md`; treat it as ephemeral when `tmp/` is ignored.
6. If multiple task identities or versioned locations remain plausible, obtain the user decision through the repository's required decision mechanism before writing.

Prefer one `handoff.md` per task and update it in place. Use Git history for versioned history. Use a repository History policy only when it explicitly applies or the user requests a historical snapshot. Do not invent a new handoff directory or create timestamped duplicates by default.

## Workflow

1. Confirm the handoff scope, task identity, intended continuation, and whether an existing handoff must be updated.
2. Locate the governing Spec, Plan, Tasks, ADR, Constitution, issue, or other formal artifacts without copying their contents.
3. Inspect actual repository state: current branch, baseline commit when available, working-tree status, and changed paths. Use `不適用` outside Git.
4. Collect only build, test, lint, formatting, review, and governance results whose outputs or durable artifacts are available.
5. Separate completed, pending, blocked, cancelled, and unverified work; select one task status from the canonical vocabulary.
6. Record confirmed decisions with rationale and source. Mark recommendations, inferences, and assumptions explicitly.
7. Select the smallest ordered file set the next agent must read. Respect repository context-exclusion and visibility rules.
8. Resolve the destination using the file-selection policy and create or update the Markdown handoff.
9. Create a machine-readable sidecar only under the conditions below.
10. Run the lightweight validator below when the artifact is local, then check non-mechanical concerns such as stale claims, sensitive data, duplicated SDD content, and invalid paths. Run repository-required governance or formatting checks when applicable.
11. Report the handoff path and its status without claiming that unverified product work is complete.

## Lightweight validator

After creating or updating one local Hand-off Markdown file, run:

```bash
python3 .agents/skills/handoff/scripts/validate_handoff.py <handoff.md>
```

The script uses only the Python standard library and requires no virtual environment or package installation. It checks the single-document title, required numbered sections, section order, status vocabulary, validation-table results, and mechanically detectable contradictions for `completed`, `completed-unverified`, `blocked`, and `not-started`.

It does not verify factual truth, referenced paths, command execution, evidence quality, or whether optional prose is complete. Review those concerns manually. Fix every reported issue before handoff.

Exit codes:

- `0`: Format and status are internally consistent.
- `1`: One or more format or status-consistency issues were found.
- `2`: CLI usage or file reading failed.

## Canonical Markdown structure

Keep sections 1, 4, 5, 8, 10, 11, 12, and 14. Sections 2, 3, 6, 7, 9, and 13 may be omitted only when genuinely inapplicable; otherwise retain them and use the explicit missing-value markers. Omit inapplicable file-category subsections under section 7. Keep the numbering of retained sections stable.

Use the repository's required document language. When governance requires Traditional Chinese, use this structure:

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

## Optional machine-readable sidecar

Do not create a sidecar by default. Add JSON or YAML only when the user explicitly requests it or the repository already has a documented consumer, schema, and validation path. Keep Markdown authoritative; treat the sidecar as a regenerable projection that points back to the Markdown path and contains only compact machine state. Never duplicate narrative, SDD content, logs, provider/model settings, or secrets. If the two disagree, correct or regenerate the sidecar from Markdown before handoff.

## Examples

Read [Docs/examples/agent-handoff-examples.md](../../../Docs/examples/agent-handoff-examples.md) only when an end-to-end example is needed. It contains a technology-neutral `completed-unverified` implementation handoff and a `blocked` brownfield migration analysis handoff; it is illustrative, not a second contract.
