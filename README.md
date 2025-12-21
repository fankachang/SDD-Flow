# SDD Flow 專案範本

* 專案起始範本

## 快速更新 Spec Kit 範本檔案的方法

* Linux（Bash）
* 
  ```bash
  # 1. 刪除 .specify 資料夾
  rm -rf .specify
  # 2. 重建範本 (以 GitHub Copilot 為例)
  specify init --here --script sh --ai copilot --no-git --force
  # 3. 復原原本的憲法
  git restore .specify/memory/constitution.md
  ```

* Windows（Power Shell）

  ```ps1
  # 1. 刪除 .specify 資料夾
  Remove-Item -Path .specify -Recurse
  # 2. 重建範本 (以 GitHub Copilot 為例)
  specify init --here --script ps --ai copilot --no-git --force
  # 3. 復原原本的憲法
  git restore .specify/memory/constitution.md
  ```

## 一次性安裝所有 AI 工具 + PowerShell

* Linux（Bash）

  ```bash
  specify init --here --no-git --force --script sh --ignore-agent-tools --ai claude
  specify init --here --no-git --force --script sh --ignore-agent-tools --ai gemini
  specify init --here --no-git --force --script sh --ignore-agent-tools --ai copilot
  specify init --here --no-git --force --script sh --ignore-agent-tools --ai cursor-agent
  specify init --here --no-git --force --script sh --ignore-agent-tools --ai qwen
  specify init --here --no-git --force --script sh --ignore-agent-tools --ai opencode
  specify init --here --no-git --force --script sh --ignore-agent-tools --ai codex
  specify init --here --no-git --force --script sh --ignore-agent-tools --ai windsurf
  specify init --here --no-git --force --script sh --ignore-agent-tools --ai kilocode
  specify init --here --no-git --force --script sh --ignore-agent-tools --ai auggie
  specify init --here --no-git --force --script sh --ignore-agent-tools --ai codebuddy
  specify init --here --no-git --force --script sh --ignore-agent-tools --ai amp
  specify init --here --no-git --force --script sh --ignore-agent-tools --ai shai
  specify init --here --no-git --force --script sh --ignore-agent-tools --ai q
  ```

* Windows（PowerShell）

  ```ps1
  specify init --here --no-git --force --script ps --ignore-agent-tools --ai claude
  specify init --here --no-git --force --script ps --ignore-agent-tools --ai gemini
  specify init --here --no-git --force --script ps --ignore-agent-tools --ai copilot
  specify init --here --no-git --force --script ps --ignore-agent-tools --ai cursor-agent
  specify init --here --no-git --force --script ps --ignore-agent-tools --ai qwen
  specify init --here --no-git --force --script ps --ignore-agent-tools --ai opencode
  specify init --here --no-git --force --script ps --ignore-agent-tools --ai codex
  specify init --here --no-git --force --script ps --ignore-agent-tools --ai windsurf
  specify init --here --no-git --force --script ps --ignore-agent-tools --ai kilocode
  specify init --here --no-git --force --script ps --ignore-agent-tools --ai auggie
  specify init --here --no-git --force --script ps --ignore-agent-tools --ai codebuddy
  specify init --here --no-git --force --script ps --ignore-agent-tools --ai amp
  specify init --here --no-git --force --script ps --ignore-agent-tools --ai shai
  specify init --here --no-git --force --script ps --ignore-agent-tools --ai q
  ```
