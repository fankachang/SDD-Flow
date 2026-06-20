---
name: hush
description: >
  本機、對 AI agent 安全的 per-worktree 密鑰管理工具（macOS 限定）。
  將 .env 的值完全移出 worktree，以 age 加密儲存於 repo 外，僅在 hush run
  啟動的子行程中注入明文。防止 AI agent 透過 cat/grep 讀取 secret，防止
  secret 誤 commit。當使用者詢問如何安全管理開發用密鑰、如何讓 .env 不被
  AI agent 讀取、如何在多個 worktree 間管理不同環境變數時使用。
  觸發詞：hush、密鑰管理、secret 管理、.env 安全、agent-safe secrets。
license: MIT
source: https://github.com/allen-hsu/hush
platform: macOS only
---

# hush — 本機 Agent-Safe 密鑰管理

> 平台限制：**僅限 macOS**（依賴 macOS Keychain 與 `hdiutil` RAM disk）

`.env` 檔案在 AI coding agent 進入 repo 的那一刻就成為風險：agent 習慣 `cat .env`、`grep -r KEY`，一個不小心 secret 就進了模型 context 或被誤 commit。hush 讓 secret 根本不存在 worktree 裡。

## Agent 使用前置檢查（必讀）

**每次協助使用者使用 hush 前，依序確認：**

### Step 1：確認平台

```bash
uname -s   # 必須輸出 Darwin（macOS）
```

非 macOS 則告知不支援，停止。

### Step 2：檢查 hush 是否已安裝

```bash
which hush 2>/dev/null && hush version || echo "NOT_INSTALLED"
```

**已安裝** → 直接進入使用流程。

**未安裝** → 執行 Step 3。

### Step 3：引導安裝（未安裝時）

提示使用者選擇安裝方式：

```bash
# 方式 A（推薦）：Go 本機編譯，不會被 Gatekeeper 隔離
# 需先安裝 Go：https://go.dev/dl/
go install github.com/allen-hsu/hush@latest

# 方式 B：Homebrew
brew install allen-hsu/tap/hush
```

安裝後執行 shell hook 設定：

```bash
hush install     # 冪等地將 eval "$(hush hook)" 加入 ~/.zshrc
source ~/.zshrc  # 或重開終端機
```

確認安裝成功：

```bash
hush version
```

### Step 4：確認專案是否已初始化

```bash
# 在專案目錄下
ls .hush.toml 2>/dev/null && echo "已初始化" || echo "尚未初始化"
```

**尚未初始化** → 詢問使用者是否要執行 `hush init` 開始設定。

## 核心概念

| 元件 | 位置 | 說明 |
|------|------|------|
| 宣告 | `.hush.toml`（commit 進 repo） | 宣告哪些 key、如何選 profile，**永不含值** |
| Store | `~/.config/hush/store.age`（repo 外） | 所有值，age 加密，namespace：project → profile → key |
| 主金鑰 | macOS Keychain | 首次使用自動產生，磁碟上無明文金鑰檔 |

`hush run` 解析 profile → 解密 store → 注入子行程 env → `exec`。明文只存在那個子行程的記憶體。

## 安裝

```bash
# 推薦：本機編譯，不會被 Gatekeeper 隔離
go install github.com/allen-hsu/hush@latest
hush install     # 加入 eval "$(hush hook)" 到 ~/.zshrc

# 或用 Homebrew
brew install allen-hsu/tap/hush
hush install
```

重開 shell（或 `source ~/.zshrc`）後生效。

## 快速開始

```bash
cd my-project
hush init                    # 建立 .hush.toml（會 commit；只宣告 key 名稱）
hush import .env --shred     # 匯入現有 .env 並銷毀明文
hush ls                      # 列出宣告的 key + 由哪個 profile 解析（不顯示值）
hush run -- npm run dev      # 解密、注入 env 到子行程、exec
```

## .hush.toml 設定

```toml
# .hush.toml — 會 commit，不含值
profile = "branch"           # branch | cwd | fixed:<name>
extends = "base"             # 當前 profile 沒有的 key，往此 profile 找
keys    = ["DATABASE_URL", "STRIPE_KEY"]
shims   = ["npm", "pnpm"]    # 輸入裸命令時自動包 hush run（opt-in）

# Per-project agent 策略（選填）
# disable_get = true         # 完全禁用 hush get，值只能透過 hush run 使用
# deny_agent_run = true      # 偵測到 agent 時連 hush run 也拒絕
# agent_profile = "sandbox"  # agent 改用此 profile（放測試憑證）
```

## 指令參考

| 指令 | 說明 |
|------|------|
| `hush run -- <cmd>` | 解析 profile、注入 env 到子行程、exec。能用、不能看 |
| `hush set <KEY>` | 設定單一值（互動輸入，不顯示、不進 history） |
| `hush unset <KEY>` | 從當前 profile 移除一個 key |
| `hush ls [--json]` | 列出宣告的 key + 由哪個 profile 解析，**永不顯示值** |
| `hush get [KEY]` | 印出某個值（限 TTY；agent 自動拒絕） |
| `hush edit` | 在 `$EDITOR` 編輯 profile（RAM disk 支撐，限 TTY） |
| `hush import [path]` | 匯入現有 .env（`--shred` 匯入後銷毀來源） |
| `hush fork [--from p]` | 複製一個 profile 到當前 profile |
| `hush cp <from> <to>` | 複製 profile 的值到另一個 profile |
| `hush init` | 建立 .hush.toml 範本 |
| `hush install` | 把 shell hook 加進 ~/.zshrc |
| `hush scrub` | 列出清掉 hush 變數/shim 的 shell 指令（啟動 agent 前用） |

`--json` 適用於 `ls`、`get`、`set`、`unset`、`import`、`fork`、`cp`。

## Per-worktree 工作流

```bash
git worktree add ../feature-x -b feature-x
cd ../feature-x
hush fork                   # 從 base profile 複製到此 branch 的 profile
hush set DATABASE_URL        # 只設定差異的值
```

## Agent 行為模式

hush 自動偵測 agent 情境（`CLAUDECODE`、`CODEX_SANDBOX`、`HUSH_AGENT` 環境變數，或無 TTY）：

- **互動 shell（人類）**：shim 自動包命令，`hush get` 可用，顯示 banner
- **Agent 模式**：shim 不裝，`hush get` 被拒，只能 `hush run`

Agent 在此工具設計下的正確用法：
```bash
# ✅ 正確：用 hush run 執行需要 secret 的命令
hush run -- pytest
hush run -- node app.js

# ❌ 禁止：agent 直接 cat/grep 讀取 secret（值根本不在 worktree）
cat .env          # 只看得到 key 名稱
grep -r API_KEY . # 找不到值
```

## 安全模型

**hush 能擋住**：
- cat/grep worktree 讀出 secret 值
- 誤 commit 值（repo 只有 key 名稱）
- secret 洩進持久 shell（agent 繼承不到）
- edit 把明文寫到持久化儲存（RAM disk）

**hush 無法擋住**：同一 uid 下刻意執行 `hush run -- env` 的程式。

## 與現有程式碼整合

程式碼**不需要任何修改**，hush 在 OS 行程層注入 env：

```javascript
// JS — 不變
const url = process.env.DATABASE_URL;
```

```python
# Python — 不變
url = os.environ["DATABASE_URL"]
```

只有啟動方式改變：
```bash
node app.js     →  hush run -- node app.js
npm run dev     →  hush run -- npm run dev  （或設 shims 自動包）
```

## 從 .env 遷移

```bash
hush init
hush import .env --shred   # 匯入並安全銷毀 .env
echo ".env" >> .gitignore  # 確保不再 commit
git add .hush.toml && git commit -m "chore: migrate secrets to hush"
```
