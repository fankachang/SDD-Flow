---
name: rtk-token-killer
description: 'RTK (Rust Token Killer) CLI proxy that auto-saves 60-90% tokens. Supports Claude Code CLI, VS Code Copilot, and GitHub Copilot CLI. Use for: RTK install, hook setup, verification, and savings stats.'
argument-hint: 'install | verify | setup-hooks | gain'
---

# RTK - Rust Token Killer

Token optimization CLI proxy that automatically intercepts shell commands through supported agent hooks, saving 60-90% token usage on command output.

## When to Use

- Verify if RTK is correctly installed (or auto-installed)
- View token savings statistics
- Set up Hook auto-proxy (Claude Code CLI / VS Code Copilot / GitHub Copilot CLI)

> ⚠️ **Environment Notes**:
> - **Claude Code CLI**: Full support. Hook matcher is `"Bash"`, use `rtk hook claude`.
> - **VS Code Copilot**: Use the PascalCase `PreToolUse` event and `rtk hook copilot`.
> - **GitHub Copilot CLI**: Use the camelCase `preToolUse` event and `rtk hook copilot`. RTK uses deny-with-suggestion when the CLI cannot rewrite a command transparently.

## Supported Platforms

The project hook (`.github/hooks/rtk_settings.json`) dispatches by OS key. Three platform groups are covered:

| Platform | Hook key | Wrapper | `rtk` binary |
|---|---|---|---|
| **macOS** | `osx` | `scripts/rtk-hook-wrapper.sh` (bash) | `rtk` on PATH |
| **Linux / Windows + WSL** | `linux` | `scripts/rtk-hook-wrapper.sh` (bash) | `rtk` on PATH (Linux build) |
| **Windows (native)** | `windows` | `scripts/rtk-hook-wrapper.ps1` (PowerShell) | `rtk` on PATH, local `scripts/rtk.exe` fallback |

> - **WSL** runs the Linux path — install the Linux `rtk` inside WSL, not the Windows `.exe`.
> - Shell scripts are LF-only (enforced by `.gitattributes`); this prevents `/bin/bash^M: bad interpreter` when the repo is checked out on Windows and run in WSL/Linux.
> - The global toggle uses a git-ignored sentinel file (`scripts/.rtk-disabled`), which is platform-neutral: WSL and Windows-native checkouts of the same repo share the same on/off state.

## Auto-Verify and Install

Execute the corresponding script, which will automatically detect if already installed; if not installed, it will automatically download and install:

**macOS / Linux**
```bash
bash .agents/skills/rtk-token-killer/scripts/install-check.sh
```

**Windows (PowerShell)**
```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force
.\.agents\skills\rtk-token-killer\scripts\install-check.ps1
```

> ℹ️ **Windows Notes**: Windows environment already includes rtk.exe executable in `.agents/skills/rtk-token-killer/scripts/` directory; the above script will automatically use this executable.

Script behavior:
| Situation | Action |
|---|---|
| Installed and working | Show version, verify `rtk gain` available |
| Wrong version installed (Rust Type Kit) | Warning and prompt to remove and reinstall |
| Not installed (macOS + Homebrew) | `brew install rtk` |
| Not installed (macOS/Linux, no brew) | `curl \| sh` official script |
| Not installed (Windows) | Download latest zip from GitHub Releases, automatically add to user PATH |

## Bypassing RTK (Per-Command)

The fastest way to get unfiltered output for a single command:

```bash
rtk proxy <cmd>          # Run any command without RTK filtering
rtk proxy npm test       # Example: full test output
rtk proxy docker logs app --tail 200
```

Use this in agent instructions whenever full output is required (e.g., debugger, test-review).

## Global Toggle (Reliable — Sentinel File)

The active hook (`.github/hooks/rtk_settings.json`) runs `rtk-hook-wrapper.sh` (macOS/Linux) or `rtk-hook-wrapper.ps1` (Windows), which checks for a sentinel file before applying RTK. This does **not** depend on environment-variable propagation, so it works reliably and takes effect immediately.

**macOS / Linux / WSL**
```bash
bash .agents/skills/rtk-token-killer/rtk-toggle.sh disable  # turn RTK off (full output)
bash .agents/skills/rtk-token-killer/rtk-toggle.sh enable   # turn RTK on
bash .agents/skills/rtk-token-killer/rtk-toggle.sh status   # check current state
```

**Windows (native PowerShell)**
```powershell
.\agents\skills\rtk-token-killer\rtk-toggle.ps1 -Action disable
.\agents\skills\rtk-token-killer\rtk-toggle.ps1 -Action enable
.\agents\skills\rtk-token-killer\rtk-toggle.ps1 -Action status
```

> The toggle creates/removes `scripts/.rtk-disabled` (git-ignored, local only).
> `COPILOT_RTK_ENABLED=false` is also honored as a fallback if the hook process inherits it, but the sentinel file is the recommended, reliable switch.

## SDD Phase Integration

RTK behavior recommendation by SDD phase:

| Phase | RTK | Notes |
|-------|-----|-------|
| Phase 1–3 (Spec / Design / Tasks) | ✅ Keep enabled | Mostly document ops; minimal shell |
| Phase 4 — routine commands | ✅ Keep enabled | `git`, `npm build`, `pnpm install`, etc. |
| Phase 4 — debugging (`debugger` agent) | ⚠️ Use `rtk proxy` | Full logs required for root-cause |
| Phase 4 — build failures | ⚠️ Use `rtk proxy` | Full compiler/linker errors needed |
| Phase 5 — test runs | ✅ Use `rtk test` | Compressed pass/fail summary |
| Phase 5 — failure analysis | ⚠️ Use `rtk proxy` | Full stack trace for exact diagnosis |

## Installation and Verification (Manual)

**macOS / Linux**
```bash
rtk --version         # Confirm version, should show: rtk X.Y.Z
rtk gain              # Confirm command works (not "command not found")
which rtk             # Confirm correct binary path
```

**Windows (PowerShell)**
```powershell
# Use local rtk.exe
.\.agents\skills\rtk-token-killer\scripts\rtk.exe --version         # Confirm version, should show: rtk X.Y.Z
.\.agents\skills\rtk-token-killer\scripts\rtk.exe gain              # Confirm command works
Get-Command rtk                                                      # Confirm command available (alias configured)
```

⚠️ **Name Conflict**: If `rtk gain` fails, you may have installed `reachingforthejack/rtk` (Rust Type Kit) instead of this tool.

## Setting Up Hooks

| Environment | Config File | matcher |
|---|---|---|
| Claude Code CLI | User-level hook installed by `rtk init -g` | `Bash` |
| VS Code Copilot | [settings-vscode.json](./settings-vscode.json) | `PreToolUse` |
| GitHub Copilot CLI | [settings-vscode.json](./settings-vscode.json) | `preToolUse` |

**macOS / Linux**
```bash
# Claude Code
rtk init -g
# VS Code Copilot + GitHub Copilot CLI (project-level)
cp .agents/skills/rtk-token-killer/settings-vscode.json .github/hooks/rtk_settings.json
```

**Windows (PowerShell)**
```powershell
# Claude Code
rtk init -g
# VS Code Copilot + GitHub Copilot CLI (project-level)
Copy-Item .agents\skills\rtk-token-killer\settings-vscode.json .github\hooks\rtk_settings.json
```

Hook effect examples:
```
git status  →  rtk git status  (the hook rewrites the tool input; the client may still request approval)
```

For `copilot -p`, repository hooks load only when the folder is trusted or prompt-mode repository hooks are explicitly enabled. Never enable repository hooks for untrusted code.

## Token Accounting Boundary

RTK measures shell-output compression only. It does not measure provider prompt-cache reads or writes. Keep RTK savings, input tokens, output tokens, and cache tokens as separate metrics; see [Docs/guides/Token與Prompt-Cache使用指南.md](../../../Docs/guides/Token與Prompt-Cache使用指南.md) for the cross-surface measurement flow.

## Meta Commands (Use rtk directly)

```bash
rtk gain              # Show token savings statistics
rtk gain --history    # Show command usage history and savings
rtk discover          # Analyze Claude Code history to find unintercepted opportunities
```

> For per-command bypass, see "Bypassing RTK (Per-Command)" above.

## 詳細說明

參閱 [RTK.md](./RTK.md) 取得 RTK 的拦截範圍（Scope）與輸出使用原則（Output Policy）。
