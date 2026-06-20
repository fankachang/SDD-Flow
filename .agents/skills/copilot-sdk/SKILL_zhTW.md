---
name: copilot-sdk
description: 使用 GitHub Copilot SDK 建構代理式應用程式。適用於在應用程式中嵌入 AI 代理、建立自訂工具、實作串流回應、管理工作階段、連接 MCP 伺服器或建立自訂代理人。觸發詞：Copilot SDK、GitHub SDK、代理式應用程式、嵌入 Copilot、可程式化代理人、MCP 伺服器、自訂代理人。
---

# GitHub Copilot SDK

使用 TypeScript、Python、Go 或 .NET，在任何應用程式中嵌入 Copilot 的代理式工作流程。

## 概覽

Copilot SDK 將 Copilot CLI 背後的同一個代理執行環境，以程式化 API 的形式開放出來。定義代理行為；Copilot 負責處理規劃、工具呼叫、檔案編輯等一切。

## 前置條件

1. **GitHub Copilot CLI** 已安裝並完成驗證（`copilot --version`）
2. **執行環境**：Node.js 18+ | Python 3.8+ | Go 1.21+ | .NET 8.0+

## 安裝

| 語言 | 指令 |
|----------|---------|
| TypeScript | `npm install @github/copilot-sdk tsx` |
| Python | `pip install github-copilot-sdk` |
| Go | `go get github.com/github/copilot-sdk/go` |
| .NET | `dotnet add package GitHub.Copilot.SDK` |

## 快速入門（TypeScript）

```typescript
import { CopilotClient } from "@github/copilot-sdk";

const client = new CopilotClient();
const session = await client.createSession({ model: "gpt-4.1" });
const response = await session.sendAndWait({ prompt: "What is 2 + 2?" });
console.log(response?.data.content);

await client.stop();
process.exit(0);
```

執行：`npx tsx index.ts`

其他語言：[Python](references/python.md) | [Go](references/go.md) | [.NET](references/dotnet.md)

## 串流回應

啟用 `streaming: true` 並訂閱事件以即時接收輸出：

```typescript
import { CopilotClient, SessionEvent } from "@github/copilot-sdk";

const client = new CopilotClient();
const session = await client.createSession({ model: "gpt-4.1", streaming: true });

session.on((event: SessionEvent) => {
    if (event.type === "assistant.message_delta") process.stdout.write(event.data.deltaContent);
    if (event.type === "session.idle") console.log();
});

await session.sendAndWait({ prompt: "Tell me a short joke" });
await client.stop();
```

其他語言：[Python](references/python.md#streaming-responses) | [Go](references/go.md#streaming-responses) | [.NET](references/dotnet.md#streaming-responses)

## 自訂工具

定義 Copilot 在推理過程中可呼叫的工具——指定說明、參數結構和處理函式：

```typescript
import { CopilotClient, defineTool } from "@github/copilot-sdk";

const getWeather = defineTool("get_weather", {
    description: "Get the current weather for a city",
    parameters: {
        type: "object",
        properties: { city: { type: "string", description: "The city name" } },
        required: ["city"],
    },
    handler: async ({ city }) => ({
        city, temperature: `${Math.floor(Math.random() * 30) + 50}°F`, condition: "sunny"
    }),
});

const client = new CopilotClient();
const session = await client.createSession({ model: "gpt-4.1", tools: [getWeather] });
await session.sendAndWait({ prompt: "What's the weather in Seattle?" });
await client.stop();
```

工具呼叫流程：Copilot 傳送參數 → SDK 執行處理函式 → 結果回傳至 Copilot → 整合進回應。

其他語言：[Python（Pydantic）](references/python.md#custom-tools) | [Go（struct）](references/go.md#custom-tools) | [.NET（Microsoft.Extensions.AI）](references/dotnet.md#custom-tools)

## MCP 伺服器整合

連接 MCP 伺服器以取得預建工具（例如 GitHub MCP 伺服器，提供倉庫／Issue／PR 存取）：

```typescript
const session = await client.createSession({
    model: "gpt-4.1",
    mcpServers: {
        github: { type: "http", url: "https://api.githubcopilot.com/mcp/" },
    },
});
```

其他語言：[Python](references/python.md#mcp-server-integration) | [Go](references/go.md#mcp-server-integration) | [.NET](references/dotnet.md#mcp-server-integration)

## 自訂代理人

定義專門的 AI 角色：

```typescript
const session = await client.createSession({
    model: "gpt-4.1",
    customAgents: [{
        name: "pr-reviewer",
        displayName: "PR Reviewer",
        description: "Reviews pull requests for best practices",
        prompt: "You are an expert code reviewer. Focus on security, performance, and maintainability.",
    }],
});
```

## 系統訊息

覆寫預設系統提示以自訂行為：

```typescript
const session = await client.createSession({
    model: "gpt-4.1",
    systemMessage: { content: "You are a helpful assistant. Always be concise." },
});
```

## 外部 CLI 伺服器

以伺服器模式單獨執行 CLI，再讓 SDK 連接至它：

```bash
copilot --server --port 4321
```

```typescript
const client = new CopilotClient({ cliUrl: "localhost:4321" });
const session = await client.createSession({ model: "gpt-4.1" });
```

提供 `cliUrl` 時，SDK 會連接至現有伺服器，而不會啟動新的 CLI 程序。

其他語言：[Python](references/python.md#external-cli-server) | [Go](references/go.md#external-cli-server) | [.NET](references/dotnet.md#external-cli-server)

## 事件類型

| 事件 | 說明 |
|-------|-------------|
| `user.message` | 使用者輸入已新增 |
| `assistant.message` | 模型完整回應 |
| `assistant.message_delta` | 串流回應片段 |
| `assistant.reasoning` | 模型推理過程（依模型而定） |
| `assistant.reasoning_delta` | 串流推理片段 |
| `tool.execution_start` | 工具呼叫已開始 |
| `tool.execution_complete` | 工具執行已完成 |
| `session.idle` | 無進行中的處理 |
| `session.error` | 發生錯誤 |

## 客戶端設定

| 選項 | 說明 | 預設值 |
|--------|-------------|---------|
| `cliPath` | Copilot CLI 可執行檔的路徑 | 系統 PATH |
| `cliUrl` | 連接至現有伺服器（例如「localhost:4321」） | 無 |
| `port` | 伺服器通訊埠 | 隨機 |
| `useStdio` | 使用 stdio 傳輸取代 TCP | true |
| `logLevel` | 記錄詳細程度 | "info" |
| `autoStart` | 自動啟動伺服器 | true |
| `autoRestart` | 崩潰時自動重啟 | true |
| `cwd` | CLI 程序的工作目錄 | 繼承 |

## 工作階段設定

| 選項 | 說明 |
|--------|-------------|
| `model` | 使用的 LLM（"gpt-4.1"、"claude-sonnet-4.5" 等） |
| `sessionId` | 自訂工作階段識別碼 |
| `tools` | 自訂工具定義 |
| `mcpServers` | MCP 伺服器連接 |
| `customAgents` | 自訂代理人角色 |
| `systemMessage` | 覆寫預設系統提示 |
| `streaming` | 啟用增量回應片段 |
| `availableTools` | 允許使用的工具白名單 |
| `excludedTools` | 停用的工具黑名單 |

## 最佳實踐

1. **始終清理資源** — 使用 `try-finally` 或 `defer` 確保 `client.stop()` 被呼叫
2. **設定逾時** — 對長時間操作使用帶有逾時的 `sendAndWait`
3. **處理事件** — 訂閱錯誤事件以實現強健的錯誤處理
4. **使用串流** — 啟用串流以在長回應時提供更好的使用者體驗
5. **持久化工作階段** — 使用自訂工作階段 ID 進行多輪對話
6. **定義清晰的工具** — 撰寫描述性的工具名稱和說明

## 架構

```
你的應用程式 → SDK 客戶端 → (JSON-RPC) → Copilot CLI（伺服器模式）→ GitHub（模型、驗證）
```

SDK 透過 stdio 或 TCP 的 JSON-RPC 自動管理 CLI 程序的生命週期。

## 常見模式與進階用法

關於工作階段持久化、錯誤處理、優雅關閉、多輪對話、檔案附件、中止操作和模型查詢，請見 [patterns.md](references/patterns.md)。

## 語言專屬指南

- **[TypeScript 指南](references/typescript.md)** — 完整範例：串流、自訂工具、互動式 CLI、MCP、代理人、系統訊息、外部伺服器
- **[Python 指南](references/python.md)** — 含 asyncio、Pydantic、SessionEventType 的完整範例
- **[Go 指南](references/go.md)** — 含 struct、goroutine、DefineTool 的完整範例
- **[.NET 指南](references/dotnet.md)** — 含 Microsoft.Extensions.AI、async/await 的完整範例

## 資源

- [GitHub Copilot SDK](https://github.com/github/copilot-sdk)
- [入門教學](https://github.com/github/copilot-sdk/blob/main/docs/tutorials/first-app.md)
- [GitHub MCP 伺服器](https://github.com/github/github-mcp-server)
- [食譜](https://github.com/github/copilot-sdk/tree/main/cookbook) | [範例](https://github.com/github/copilot-sdk/tree/main/samples)

## 狀態

此 SDK 目前處於**技術預覽**階段，可能存在破壞性變更。
