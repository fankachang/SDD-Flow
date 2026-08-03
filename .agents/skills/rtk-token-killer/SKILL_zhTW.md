---
name: rtk-token-killer
description: 'RTK（Rust Token Killer）CLI 代理，自動節省 60-90% token。支援 Claude Code CLI、VS Code Copilot 與 GitHub Copilot CLI。適用於：安裝 RTK、設定 Hooks、驗證、查看節省統計。'
argument-hint: 'install | verify | setup-hooks | gain'
---

# RTK - Rust Token Killer

Token 最佳化 CLI 代理，透過支援的 agent hooks 自動攔截 shell 指令，節省 60-90% 的命令輸出 token 用量。

## 使用時機

- 驗證 RTK 是否正確安裝（或自動安裝）
- 查看 token 節省統計
- 設定 Hook 自動代理（Claude Code CLI / VS Code Copilot / GitHub Copilot CLI）

> ⚠️ **環境說明**：
> - **Claude Code CLI**：完整支援。Hook matcher 為 `"Bash"`，使用 `rtk hook claude`。
> - **VS Code Copilot**：使用 PascalCase `PreToolUse` 事件與 `rtk hook copilot`。
> - **GitHub Copilot CLI**：使用 camelCase `preToolUse` 事件與 `rtk hook copilot`。CLI 無法透明改寫時，RTK 會採 deny-with-suggestion 讓 agent 重試。

## 支援平台

專案 Hook（`.github/hooks/rtk_settings.json`）依 OS key 分派，涵蓋三個平台群組：

| 平台 | Hook key | Wrapper | `rtk` 來源 |
|---|---|---|---|
| **macOS** | `osx` | `scripts/rtk-hook-wrapper.sh`（bash）| PATH 上的 `rtk` |
| **Linux / Windows + WSL** | `linux` | `scripts/rtk-hook-wrapper.sh`（bash）| PATH 上的 `rtk`（Linux 版）|
| **Windows 原生** | `windows` | `scripts/rtk-hook-wrapper.ps1`（PowerShell）| 優先使用 PATH 上的 `rtk`，否則 fallback 至本地 `scripts/rtk.exe` |

> - **WSL** 走 Linux 路徑 — 需在 WSL 內安裝 Linux 版 `rtk`，而非 Windows `.exe`。
> - Shell 腳本一律 LF 換行（由 `.gitattributes` 強制），避免在 Windows 簽出後於 WSL/Linux 執行時出現 `/bin/bash^M: bad interpreter`。
> - 全域開關使用 git-ignored 的 sentinel 檔案（`scripts/.rtk-disabled`），跨平台中立：同一 repo 的 WSL 與 Windows 原生簽出共用同一開關狀態。

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

> ℹ️ **Windows 說明**：Windows 環境已包含 rtk.exe 執行檔於 `.agents/skills/rtk-token-killer/scripts/` 目錄下，上述腳本會自動使用此執行檔。

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
rtk --version         # 確認版本，應顯示：rtk X.Y.Z
rtk gain              # 確認指令正常（非「command not found」）
which rtk             # 確認正確的二進位檔路徑
```

**Windows (PowerShell)**
```powershell
# 使用本地 rtk.exe
.\.agents\skills\rtk-token-killer\scripts\rtk.exe --version         # 確認版本，應顯示：rtk X.Y.Z
.\.agents\skills\rtk-token-killer\scripts\rtk.exe gain              # 確認指令正常
Get-Command rtk                                                      # 確認命令可用（已設定別名）
```

⚠️ **名稱衝突**：若 `rtk gain` 失敗，可能安裝的是 `reachingforthejack/rtk`（Rust Type Kit）而非本工具。

## 設定 Hooks

| 環境 | 設定檔 | matcher |
|---|---|---|
| Claude Code CLI | 由 `rtk init -g` 安裝的使用者層級 hook | `Bash` |
| VS Code Copilot | [settings-vscode.json](./settings-vscode.json) | `PreToolUse` |
| GitHub Copilot CLI | [settings-vscode.json](./settings-vscode.json) | `preToolUse` |

**macOS / Linux**
```bash
# Claude Code
rtk init -g
# VS Code Copilot + GitHub Copilot CLI（專案層級）
cp .agents/skills/rtk-token-killer/settings-vscode.json .github/hooks/rtk_settings.json
```

**Windows (PowerShell)**
```powershell
# Claude Code
rtk init -g
# VS Code Copilot + GitHub Copilot CLI（專案層級）
Copy-Item .agents\skills\rtk-token-killer\settings-vscode.json .github\hooks\rtk_settings.json
```

Hook 效果範例：
```
git status  →  rtk git status  （Hook 改寫工具輸入；介面仍可能要求使用者核准）
```

使用 `copilot -p` 時，只有在資料夾已受信任或明確啟用 prompt-mode repository hooks 時才會載入專案 hook。不要對不受信任的程式碼啟用 repository hooks。

## Token 計量邊界

RTK 只計算 shell 輸出壓縮，不會計算模型供應商的 Prompt Cache 讀取或寫入。RTK 節省量、input tokens、output tokens 與 cache tokens 必須分開統計；跨介面的量測流程詳見 [Docs/guides/Token與Prompt-Cache使用指南.md](../../../Docs/guides/Token與Prompt-Cache使用指南.md)。

## Meta 指令（直接使用 rtk）

```bash
rtk gain              # 顯示 token 節省統計
rtk gain --history    # 顯示指令使用歷史與節省量
rtk discover          # 分析 Claude Code 歷史，找出未被攔截的機會
rtk proxy <cmd>       # 不經過過濾直接執行原始指令（單次繞過 RTK）
```

## 單次繞過 RTK（最常用）

需要完整輸出時，對任何命令加上 `rtk proxy` 前綴：

```bash
rtk proxy <cmd>              # 取得完整、未壓縮的輸出
rtk proxy npm test           # 完整測試輸出
rtk proxy docker logs app --tail 200
```

**debugger agent**、**test-review agent** 在診斷時應一律使用此方式。

## 全域開關（可靠 — sentinel 檔案機制）

目前的 hook（`.github/hooks/rtk_settings.json`）執行 `rtk-hook-wrapper.sh`（macOS/Linux）或 `rtk-hook-wrapper.ps1`（Windows），會檢查 sentinel 檔案決定是否套用 RTK。此機制**不依賴環境變數傳遞**，可靠且立即生效。

**macOS / Linux / WSL**：
```bash
bash .agents/skills/rtk-token-killer/rtk-toggle.sh disable  # 停用（完整輸出）
bash .agents/skills/rtk-token-killer/rtk-toggle.sh enable   # 啟用
bash .agents/skills/rtk-token-killer/rtk-toggle.sh status   # 查看狀態
```

**Windows 原生**：
```powershell
.\agents\skills\rtk-token-killer\rtk-toggle.ps1 -Action disable
.\agents\skills\rtk-token-killer\rtk-toggle.ps1 -Action enable
.\agents\skills\rtk-token-killer\rtk-toggle.ps1 -Action status
```

> toggle 會建立/移除 `scripts/.rtk-disabled`（已加入 .gitignore，僅本機生效）。
> `COPILOT_RTK_ENABLED=false` 仍作為 fallback，但 sentinel 檔案是建議的可靠開關。

## SDD Phase 對應指引

| Phase | RTK 狀態 | 說明 |
|-------|---------|------|
| Phase 1–3（規格/設計/任務）| ✅ 正常使用 | 文件操作為主，shell 極少 |
| Phase 4 例行命令 | ✅ 正常使用 | `git`、build、install 等 |
| Phase 4 + debugger | ⚠️ `rtk proxy` | 需要完整 log 找根因 |
| Phase 4 建置失敗 | ⚠️ `rtk proxy` | 需要完整編譯器錯誤 |
| Phase 5 測試執行 | ✅ `rtk test` | 壓縮通過/失敗摘要 |
| Phase 5 失敗分析 | ⚠️ `rtk proxy` | 需要完整 stack trace |
