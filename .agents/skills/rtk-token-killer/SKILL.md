---
name: rtk-token-killer
description: '設定並使用 RTK（Rust Token Killer）作為 CLI 代理，自動節省 60-90% 的 token 用量。支援 Claude Code CLI 及 VS Code + GitHub Copilot，可在 macOS、Linux、Windows (PowerShell) 使用。適用於：初次安裝 RTK、設定 Hooks（Claude Code 用 Bash matcher、VS Code 用 run_in_terminal matcher）、驗證安裝、查看 token 節省統計。'
argument-hint: 'install | verify | setup-hooks | gain'
---

# RTK - Rust Token Killer

Token 最佳化 CLI 代理，透過 Claude Code Hook 自動攔截指令，節省 60-90% 的 token 用量。

## 使用時機

- 驗證 RTK 是否正確安裝（或自動安裝）
- 查看 token 節省統計
- 設定 Hook 自動代理（Claude Code CLI / VS Code Copilot）

> ⚠️ **環境說明**：
> - **Claude Code CLI**：完整支援。Hook matcher 為 `"Bash"`，使用 `rtk hook claude`。
> - **VS Code + GitHub Copilot**：完整支援。Hook matcher 為 `run_in_terminal`，使用 `rtk hook claude`。已驗證 `rtk hook claude` 能正確解析 VS Code stdin JSON 格式並改寫指令。

## 自動驗證與安裝

執行對應腳本，會自動偵測是否已安裝，若未安裝則自動下載安裝：

**macOS / Linux**
```bash
bash .agents/skills/rtk-token-killer/scripts/install-check.sh
```

**Windows (PowerShell)**
```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force
.\.agents\skills\rtk-token-killer\scripts\install-check.ps1
```

腳本行為：
| 情況 | 動作 |
|---|---|
| 已安裝且正常 | 顯示版本，驗證 `rtk gain` 可用 |
| 安裝錯誤版本（Rust Type Kit）| 警告並提示移除重裝 |
| 未安裝（macOS + Homebrew）| `brew install rtk` |
| 未安裝（macOS/Linux，無 brew）| `curl \| sh` 官方腳本 |
| 未安裝（Windows）| 從 GitHub Releases 下載最新 zip，自動加入使用者 PATH |

## 安裝與驗證（手動）

**macOS / Linux**
```bash
rtk --version         # 確認版本，應顯示: rtk X.Y.Z
rtk gain              # 確認指令正常（非「command not found」）
which rtk             # 確認正確的二進位檔路徑
```

**Windows (PowerShell)**
```powershell
rtk --version         # 確認版本，應顯示: rtk X.Y.Z
rtk gain              # 確認指令正常
Get-Command rtk       # 確認正確的二進位檔路徑
```

⚠️ **名稱衝突**：若 `rtk gain` 失敗，可能安裝的是 `reachingforthejack/rtk`（Rust Type Kit）而非本工具。

## 設定 Hooks

| 環境 | 設定檔 | matcher |
|---|---|---|
| Claude Code CLI | [settings-claude.json](./settings-claude.json) | `Bash` |
| VS Code Copilot | [settings-vscode.json](./settings-vscode.json) | `run_in_terminal` |

**macOS / Linux**
```bash
# Claude Code
cp .agents/skills/rtk-token-killer/settings-claude.json .github/settings.json
# VS Code
cp .agents/skills/rtk-token-killer/settings-vscode.json .github/settings.json
```

**Windows (PowerShell)**
```powershell
# Claude Code
Copy-Item .agents\skills\rtk-token-killer\settings-claude.json .github\settings.json
# VS Code
Copy-Item .agents\skills\rtk-token-killer\settings-vscode.json .github\settings.json
```

Hook 效果範例：
```
git status  →  rtk git status  （透明代理，0 額外 token 開銷）
```

## Meta 指令（直接使用 rtk）

```bash
rtk gain              # 顯示 token 節省統計
rtk gain --history    # 顯示指令使用歷史與節省量
rtk discover          # 分析 Claude Code 歷史，找出未被攔截的機會
rtk proxy <cmd>       # 不經過過濾直接執行原始指令（供偵錯用）
```

## 詳細說明

參閱 [RTK.md](./RTK.md) 取得完整指令參考。
