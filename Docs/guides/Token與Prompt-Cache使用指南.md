# Token 與 Prompt Cache 使用指南

## 目的

本指南說明此樣板在不同 AI 開發介面中的 Token 量測方式。RTK、模型 Context 與 Prompt Cache 是三個不同層次，必須分開記錄：

| 層次 | 代表指標 | 用途 |
| --- | --- | --- |
| Shell 輸出壓縮 | RTK saved tokens | 減少測試、建置、Git 與 log 輸出進入模型 context 的體積 |
| 模型輸入／輸出 | input tokens、output tokens | 觀察 instructions、tools、messages 與回應的總消耗 |
| Prompt Cache | cache read、cache creation | 觀察模型供應商重用穩定前綴的程度 |

RTK 統計不能用來推論 Prompt Cache 是否命中；同樣地，Cache 命中也不會縮小模型的 context window 佔用。

## 使用情境

| 介面 | 建議觀測方式 | 注意事項 |
| --- | --- | --- |
| VS Code Copilot Chat／Agent | Agent Debug Logs 的 Summary 與 Cache Explorer | 適合逐回合找出第一個前綴差異點 |
| GitHub Copilot CLI 互動模式 | `/usage`、`/context`、`/env` | `/usage` 看 Token，`/context` 看來源，`/env` 確認載入的 instructions、hooks 與 tools |
| `copilot -p` 非互動模式 | OpenTelemetry（OTel） | Repository hooks 只應在受信任的專案啟用 |
| Codex CLI | `codex exec --json` 的 usage event | Cache 欄位為 `usage.cached_input_tokens` |
| OpenAI Responses API | Response usage | Cache 欄位為 `usage.input_tokens_details.cached_tokens` |
| OpenAI Chat Completions API | Completion usage | Cache 欄位為 `usage.prompt_tokens_details.cached_tokens` |

不同模型供應商的 Cache 門檻、保留時間與計費方式不同，不應在共用計算器中寫死單一供應商的規則。

## VS Code Copilot

需要診斷時，在使用者層級暫時啟用：

```json
{
  "github.copilot.chat.agentDebugLog.fileLogging.enabled": true
}
```

接著從 Chat view 的 `...` 選單開啟 **Show Agent Debug Logs**，進入工作階段 Summary，再選擇 **Cache Explorer**。主要觀察：

- Cache hit percentage。
- reused input tokens／total input tokens。
- Prompt signature 的第一個 divergence point。
- system instructions、tool definitions 或 messages 中最早發生變動的位置。

Debug logs 會保存在本機，且可能包含 prompt、程式碼與工具輸出；完成診斷後應關閉 file logging，避免長期保存敏感內容。

若需要機器可讀資料，可在使用者設定啟用 OTel file exporter，但預設不要開啟 content capture：

```json
{
  "github.copilot.chat.otel.enabled": true,
  "github.copilot.chat.otel.exporterType": "file",
  "github.copilot.chat.otel.outfile": "/tmp/copilot-otel.jsonl",
  "github.copilot.chat.otel.captureContent": false
}
```

## GitHub Copilot CLI

互動工作階段優先使用內建指令：

```text
/usage
/context
/env
```

需要跨工作階段或自動化分析時，使用 OTel file exporter。

macOS／Linux：

```bash
COPILOT_OTEL_FILE_EXPORTER_PATH=/tmp/copilot-otel.jsonl copilot
```

Windows PowerShell：

```powershell
$env:COPILOT_OTEL_FILE_EXPORTER_PATH = "$env:TEMP\copilot-otel.jsonl"
copilot
```

分析 `chat` 或 `invoke_agent` span 的下列 attributes：

```text
gen_ai.usage.input_tokens
gen_ai.usage.output_tokens
gen_ai.usage.cache_read.input_tokens
gen_ai.usage.cache_creation.input_tokens
```

使用 `copilot -p` 時，Repository hooks 可能因資料夾信任狀態而不載入。只有在已審查且受信任的專案，才設定 `GITHUB_COPILOT_PROMPT_MODE_REPO_HOOKS=true`；不要用此設定繞過不受信任程式碼的保護。

## 統一計算方式

每個介面、provider、model、agent 與 toolset 分開彙總：

```text
cache_read_rate = sum(cache_read_input_tokens) / sum(input_tokens)
cache_creation_rate = sum(cache_creation_input_tokens) / sum(input_tokens)
uncached_input_tokens = sum(input_tokens) - sum(cache_read_input_tokens)
```

RTK 另用 `rtk gain` 的 saved tokens 計算，不併入 Cache 命中率。

第一個請求通常負責建立 Cache，因此評估時至少分開記錄：

1. 第一回合。
2. 同工作階段第二回合以後。
3. 新工作階段但相同 model／agent／tools 的請求。

## Cache A/B 驗證

1. 固定介面、provider、model、reasoning effort、agent、tools、MCP servers 與 workspace。
2. 先執行一個具有穩定 instructions 與工具定義的任務。
3. 在同一工作階段執行第二回合，只改變最後的短動態需求。
4. 比較第二回合的 cache read rate 與第一個 divergence point。
5. 再刻意切換 agent 或 toolset，確認工具能辨識 Cache miss。

若第二回合仍無命中，優先檢查：

- SessionStart hook 是否加入動態內容。
- instructions 或 custom agent 是否在工作階段中途變更。
- tools／MCP schemas 的順序或內容是否不同。
- model、reasoning effort 或 context tier 是否切換。
- 測量工具是否讀取了正確介面的欄位。

## 本專案的穩定前綴策略

- 根目錄 `AGENTS.md` 交由 VS Code 與 Copilot CLI 原生載入，不再由 SessionStart hook 重複注入。
- `.github/copilot-instructions.md` 只保留 Copilot 特有且全工作階段需要的規則。
- 路徑特定規則放在 `.github/instructions/*.instructions.md`，只在符合條件時載入。
- 專門流程放在 skills，需要時才載入完整內容。
- RTK 只攔截 shell 工具輸出；檔案讀取、MCP 與其他原生工具不計入 RTK savings。

## 官方參考

- [VS Code：Diagnose prompt caching with the Cache Explorer](https://code.visualstudio.com/docs/agents/agent-troubleshooting/cache-explorer)
- [VS Code：Monitor agent usage with OpenTelemetry](https://code.visualstudio.com/docs/agents/guides/monitoring-agents)
- [VS Code：Agent hooks](https://code.visualstudio.com/docs/agent-customization/hooks)
- [GitHub：Copilot CLI command reference](https://docs.github.com/en/copilot/reference/copilot-cli-reference/cli-command-reference)
- [GitHub：Copilot hooks reference](https://docs.github.com/en/copilot/reference/hooks-reference)
- [GitHub：Data available in Copilot usage metrics](https://docs.github.com/en/copilot/reference/copilot-usage-metrics/copilot-usage-metrics)
- [OpenAI：Prompt caching](https://developers.openai.com/api/docs/guides/prompt-caching)
