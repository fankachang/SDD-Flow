# Docs 文件分層與 AI 可見性

本目錄同時保存執行期治理文件與面向人的說明資料。為避免 Agent 搜尋時把歷史背景或長篇指南加入 context，依用途分層如下：

| 目錄 | 主要用途 | Agent 預設行為 |
|---|---|---|
| `governance/` | 現行 SDD、Agent、Skill 治理與恢復規範 | 可依流程主動讀取 |
| `guides/` | 面向使用者的安裝、操作與概念指南 | 不主動搜尋；被精確引用或使用者要求時讀取 |
| `examples/` | 教學與示例 | 除非使用者要求，否則不讀取 |
| `research/` | 研究筆記與非規範性心得 | 除非使用者要求，否則不讀取 |
| `History/` | 已完成變更、舊決策與歷史規劃 | 除非追查歷史，否則不讀取 |

VS Code workspace 以 `.vscode/settings.json` 的 `search.exclude` 排除 `guides/`、`examples/`、`research/` 與 `History/`，讓它們保留在 Explorer 供人閱讀，但不進入一般文字搜尋與 grep 結果。

這是 context hygiene，不是安全控制。[GitHub 官方文件](https://docs.github.com/en/copilot/how-tos/configure-content-exclusion/exclude-content-from-copilot?tool=vscode)指出 Copilot Agent mode 目前不支援硬性 content exclusion；使用者明確提供檔案或精確路徑時，Agent 仍可能讀取。敏感資訊不得存放在這些文件中。
