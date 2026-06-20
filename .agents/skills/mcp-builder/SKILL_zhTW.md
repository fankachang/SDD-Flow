---
name: mcp-builder
description: 建立高品質 MCP（Model Context Protocol）伺服器的指南，透過精心設計的工具讓 LLM 能與外部服務互動。適用於建構 MCP 伺服器以整合外部 API 或服務，支援 Python（FastMCP）或 Node/TypeScript（MCP SDK）。
license: 完整授權條款請見 LICENSE.txt
---

# MCP 伺服器開發指南

## 概覽

建立 MCP（Model Context Protocol）伺服器，透過精心設計的工具讓 LLM 能與外部服務互動。MCP 伺服器的品質取決於它能讓 LLM 多有效地完成真實世界的任務。

---

# 流程

## 🚀 高階工作流程

建立一個高品質的 MCP 伺服器包含四個主要階段：

### 第一階段：深入研究與規劃

#### 1.1 理解現代 MCP 設計

**API 覆蓋率 vs. 工作流程工具：**
在全面覆蓋 API 端點與提供專門工作流程工具之間取得平衡。工作流程工具對特定任務更為便利，而全面覆蓋則給予 agent 組合操作的彈性。不同客戶端的表現各異——有些從結合基本工具的程式碼執行中獲益，有些則偏好高層次的工作流程。若不確定，優先選擇全面的 API 覆蓋。

**工具命名與可探索性：**
清楚、具描述性的工具名稱有助於 agent 快速找到合適的工具。使用一致的前綴（例如 `github_create_issue`、`github_list_repos`）與行動導向的命名方式。

**上下文管理：**
簡潔的工具描述與篩選/分頁結果的能力對 agent 很有幫助。設計能回傳聚焦、相關資料的工具。部分客戶端支援程式碼執行，可幫助 agent 有效率地篩選和處理資料。

**可執行的錯誤訊息：**
錯誤訊息應提供具體建議與後續步驟，引導 agent 找到解決方案。

#### 1.2 研讀 MCP 協定文件

**瀏覽 MCP 規格文件：**

從 sitemap 開始找到相關頁面：`https://modelcontextprotocol.io/sitemap.xml`

然後加上 `.md` 後綴取得 Markdown 格式的頁面（例如 `https://modelcontextprotocol.io/specification/draft.md`）。

重點閱讀頁面：
- 規格概覽與架構
- 傳輸機制（streamable HTTP、stdio）
- 工具、資源與提示詞定義

#### 1.3 研讀框架文件

**建議的技術堆疊：**
- **語言**：TypeScript（高品質 SDK 支援，在許多執行環境中有良好相容性，例如 MCPB。加上 AI 模型擅長生成 TypeScript 程式碼，廣泛的使用率、靜態型別與優良的 linting 工具帶來更多好處）
- **傳輸**：遠端伺服器使用 Streamable HTTP，採用無狀態 JSON（較易擴展和維護，相較於有狀態 session 和串流回應）；本地伺服器使用 stdio。

**載入框架文件：**

- **MCP 最佳實踐**：[📋 查看最佳實踐](./reference/mcp_best_practices.md) — 核心指南

**TypeScript（建議）：**
- **TypeScript SDK**：使用 WebFetch 載入 `https://raw.githubusercontent.com/modelcontextprotocol/typescript-sdk/main/README.md`
- [⚡ TypeScript 指南](./reference/node_mcp_server.md) — TypeScript 模式與範例

**Python：**
- **Python SDK**：使用 WebFetch 載入 `https://raw.githubusercontent.com/modelcontextprotocol/python-sdk/main/README.md`
- [🐍 Python 指南](./reference/python_mcp_server.md) — Python 模式與範例

#### 1.4 規劃實作

**了解 API：**
查閱服務的 API 文件，找出關鍵端點、驗證需求與資料模型。視需要使用網路搜尋和 WebFetch。

**工具選擇：**
優先確保全面的 API 覆蓋。列出要實作的端點，從最常用的操作開始。

---

### 第二階段：實作

#### 2.1 設置專案結構

請參考各語言專屬指南了解專案設置：
- [⚡ TypeScript 指南](./reference/node_mcp_server.md) — 專案結構、package.json、tsconfig.json
- [🐍 Python 指南](./reference/python_mcp_server.md) — 模組組織、相依套件

#### 2.2 實作核心基礎架構

建立共用工具程式：
- 含驗證的 API 客戶端
- 錯誤處理輔助函式
- 回應格式化（JSON/Markdown）
- 分頁支援

#### 2.3 實作工具

每個工具：

**輸入 Schema：**
- 使用 Zod（TypeScript）或 Pydantic（Python）
- 包含限制條件與清楚的描述
- 在欄位描述中加入範例

**輸出 Schema：**
- 盡可能定義 `outputSchema` 以產生結構化資料
- 在工具回應中使用 `structuredContent`（TypeScript SDK 功能）
- 幫助客戶端理解和處理工具輸出

**工具描述：**
- 功能的簡潔摘要
- 參數描述
- 回傳型別 Schema

**實作：**
- I/O 操作使用 async/await
- 妥善的錯誤處理，提供可執行的訊息
- 適用時支援分頁
- 使用現代 SDK 時同時回傳文字內容和結構化資料

**標註：**
- `readOnlyHint`：true/false
- `destructiveHint`：true/false
- `idempotentHint`：true/false
- `openWorldHint`：true/false

---

### 第三階段：審查與測試

#### 3.1 程式碼品質

審查重點：
- 無重複程式碼（DRY 原則）
- 一致的錯誤處理
- 完整的型別覆蓋
- 清楚的工具描述

#### 3.2 建置與測試

**TypeScript：**
- 執行 `npm run build` 驗證編譯結果
- 使用 MCP Inspector 測試：`npx @modelcontextprotocol/inspector`

**Python：**
- 驗證語法：`python -m py_compile your_server.py`
- 使用 MCP Inspector 測試

詳細測試方式與品質檢查清單請參閱各語言專屬指南。

---

### 第四階段：建立評估

實作完 MCP 伺服器後，建立完整的評估來測試其效能。

**載入 [✅ 評估指南](./reference/evaluation.md) 取得完整評估說明。**

#### 4.1 了解評估目的

使用評估來測試 LLM 是否能有效利用你的 MCP 伺服器回答真實、複雜的問題。

#### 4.2 建立 10 個評估問題

按照評估指南中的流程建立有效的評估：

1. **工具檢視**：列出可用工具並了解其功能
2. **內容探索**：使用唯讀操作探索可用資料
3. **問題生成**：建立 10 個複雜、真實的問題
4. **答案驗證**：自行解答每個問題以驗證答案

#### 4.3 評估需求

確保每個問題符合：
- **獨立性**：不依賴其他問題
- **唯讀**：只需要非破壞性操作
- **複雜性**：需要多次工具呼叫和深入探索
- **真實性**：基於人們真正在意的實際使用場景
- **可驗證性**：單一、清楚的答案，可透過字串比對驗證
- **穩定性**：答案不會隨時間改變

#### 4.4 輸出格式

以此結構建立 XML 檔案：

```xml
<evaluation>
  <qa_pair>
    <question>Find discussions about AI model launches with animal codenames. One model needed a specific safety designation that uses the format ASL-X. What number X was being determined for the model named after a spotted wild cat?</question>
    <answer>3</answer>
  </qa_pair>
<!-- More qa_pairs... -->
</evaluation>
```

---

# 參考檔案

## 📚 文件資料庫

開發過程中視需要載入這些資源：

### 核心 MCP 文件（優先載入）
- **MCP 協定**：從 `https://modelcontextprotocol.io/sitemap.xml` 的 sitemap 開始，再用 `.md` 後綴取得特定頁面
- [📋 MCP 最佳實踐](./reference/mcp_best_practices.md) — 通用 MCP 指南，包含：
  - 伺服器與工具命名慣例
  - 回應格式指南（JSON vs Markdown）
  - 分頁最佳實踐
  - 傳輸選擇（streamable HTTP vs stdio）
  - 安全性與錯誤處理標準

### SDK 文件（第一/二階段時載入）
- **Python SDK**：從 `https://raw.githubusercontent.com/modelcontextprotocol/python-sdk/main/README.md` 取得
- **TypeScript SDK**：從 `https://raw.githubusercontent.com/modelcontextprotocol/typescript-sdk/main/README.md` 取得

### 語言專屬實作指南（第二階段時載入）
- [🐍 Python 實作指南](./reference/python_mcp_server.md) — 完整 Python/FastMCP 指南，包含：
  - 伺服器初始化模式
  - Pydantic 模型範例
  - 使用 `@mcp.tool` 的工具註冊
  - 完整可用範例
  - 品質檢查清單

- [⚡ TypeScript 實作指南](./reference/node_mcp_server.md) — 完整 TypeScript 指南，包含：
  - 專案結構
  - Zod Schema 模式
  - 使用 `server.registerTool` 的工具註冊
  - 完整可用範例
  - 品質檢查清單

### 評估指南（第四階段時載入）
- [✅ 評估指南](./reference/evaluation.md) — 完整的評估建立指南，包含：
  - 問題建立指南
  - 答案驗證策略
  - XML 格式規格
  - 範例問題與答案
  - 使用提供的腳本執行評估
