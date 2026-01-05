# Base Rule

* **Response Language:** `zh-TW`
* All specifications, plans, and user-facing documentation MUST be written in Traditional Chinese (zh-TW), ONLY constitution MUST in English.
* When drafting the constitution, the context MUST be translated into "constitution_zhTW.md" and placed in the same directory (please note that file names are case-sensitive).
* Git Log, Code annotations MUST be written in Traditional Chinese (zh-TW).

# PowerShell UTF-8 設定規範

當開啟 PowerShell (pwsh 或 powershell.exe) 執行指令時，務必設定 UTF-8 編碼以避免中文亂碼：

- 使用啟動參數：`pwsh -NoExit -Command "chcp 65001; $OutputEncoding = [Console]::OutputEncoding = New-Object System.Text.UTF8Encoding"` 或 `powershell.exe -NoExit -Command "chcp 65001"`
- 若執行多指令，使用 `;` 分隔命令鏈（PowerShell 語法，非 `&&`）。
- 優先使用 PowerShell 7 (pwsh.exe)，其 UTF-8 支援更佳。
- 確認輸出無亂碼後再繼續任務。

範例指令：

```ps1
pwsh -NoExit -c "chcp 65001; $OutputEncoding = [Console]::OutputEncoding = New-Object System.Text.UTF8Encoding; npm install"
```
