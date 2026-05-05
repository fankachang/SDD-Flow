<!-- SPECKIT START -->
For additional context about technologies to be used, project structure,
shell commands, and other important information, read the current plan
<!-- SPECKIT END -->

## 全域強制規則（所有 agent 均適用）

### AGENTS.md 自動載入
**BLOCKING REQUIREMENT**: 每次對話開始時，必須檢查工作區根目錄是否存在 `AGENTS.md`。若存在，**必須立即以 `read_file` 讀取完整內容**，並將其中所有規則視為與本檔案同等效力的強制規範，不得略過。

### UTF-8 終端機設定
**BLOCKING REQUIREMENT**: 每次開啟 PowerShell 終端機執行任何指令之前，必須先執行以下三行 UTF-8 設定，不得省略：

```ps1
chcp 65001 > $null
$OutputEncoding = [Console]::OutputEncoding = [Console]::InputEncoding = [System.Text.Encoding]::UTF8
$PSDefaultParameterValues['*:Encoding'] = 'utf8'
```

### 決策前強制詢問
**BLOCKING REQUIREMENT**: 面對以下任何情況，必須**立即停止執行**並呼叫 #askQuestions 並且供 **≥3 個具體方案**供使用者選擇，絕對禁止自行決定後繼續：
- 任何技術選型、框架、工具、版本選擇
- 需求範圍模糊或有多個可行路徑
- Phase 推進前使用者意圖未明確確認
- 任何影響後續流程的重大決策點

**備註**：每次使用 `vscode_askQuestions` （#askQuestions ） 時，**必須至少提供一個允許使用者自訂回答的選項**（設定 `allowFreeformInput: true`），不得限制使用者只能選擇預設選項。
