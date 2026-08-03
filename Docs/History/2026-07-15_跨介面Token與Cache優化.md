# 2026-07-15 跨介面 Token 與 Cache 優化

## 背景

原 RTK 設定只針對舊版 VS Code `run_in_terminal` payload，並呼叫 `rtk hook claude`；同時另有 SessionStart hook 嘗試再次注入根目錄 `AGENTS.md`。這兩項設計無法可靠涵蓋目前的 VS Code Copilot 與 GitHub Copilot CLI，也容易讓 RTK savings 與 Prompt Cache 指標混淆。

## 本次調整

- RTK project hook 改為 VS Code `PreToolUse` 與 Copilot CLI `preToolUse` 雙格式。
- 兩個介面統一呼叫 `rtk hook copilot`，並保留專案 sentinel 停用機制。
- 移除過時的 `.github/settings.json`。
- 移除重複的 `agents-loader` hook 與平台腳本，改用兩個介面的原生 `AGENTS.md` 載入。
- Git 與 Windows UTF-8 guards 同步改為雙事件格式，並支援 Copilot CLI 的 camelCase payload。
- UTF-8 guard 不再於 macOS／Linux 執行空的 allow hook，減少不必要的 hook 呼叫。
- 同步更新 `rtk-token-killer` 的英文／zh-TW 文件、設定範本、wrapper 與安裝提示。
- 新增 [Token 與 Prompt Cache 使用指南](../guides/Token與Prompt-Cache使用指南.md)，定義各介面的觀測欄位與 A/B 驗證方式。

## 設計邊界

- RTK 只處理 shell 輸出壓縮，不代表模型端 Prompt Cache 命中。
- Cache 指標依介面與 provider 分開統計，不跨 model 或 agent 混算。
- VS Code debug logging 與 OTel 採使用者按需啟用，不在樣板的 `.vscode/settings.json` 預設開啟，以避免長期保存可能含敏感資訊的診斷資料。
- `copilot -p` 的 repository hooks 只在受信任的專案明確啟用。

## 驗證範圍

- 所有 `.github/hooks/*.json` 與 RTK 設定範本可解析為 JSON。
- RTK 雙事件設定與 `rtk init --copilot --dry-run` 的介面格式一致，且 VS Code payload 可產生改寫結果。
- Git guard 可分別處理 VS Code snake_case 與 Copilot CLI camelCase payload。
- sentinel 啟用／停用時分別產生改寫與空 hook 結果。
- PowerShell 7.6.3 下的 wrapper、Git guard 與 UTF-8 guard 已完成實際 smoke test。
- 英文與 zh-TW skill 成對，且治理一致性檢測無 BLOCK-level 問題。
- 專案不再引用已移除的 `agents-loader` 或 `.github/settings.json` 作為現行設定。

## 驗證限制

- PowerShell wrapper 已使用 macOS 原生 RTK 驗證 enabled／disabled 路徑；專案內附的 Windows PE `rtk.exe` 仍需在 Windows 實機補一次 smoke test。
- 未呼叫需消耗 Copilot 額度的線上模型；Cache 命中率需依使用指南，在實際 VS Code 或 Copilot CLI 工作階段執行 A/B 量測。
