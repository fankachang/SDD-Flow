#!/usr/bin/env python3
import json
import re
import subprocess
import sys


PROTECTED_BRANCHES = {"main", "master", "production", "release", "prod"}
USE_CAMEL_CASE = False


def write_allow() -> None:
    if USE_CAMEL_CASE:
        print(json.dumps({"permissionDecision": "allow"}, ensure_ascii=False, separators=(",", ":")))
        return
    print(json.dumps({
        "hookSpecificOutput": {
            "hookEventName": "PreToolUse",
            "permissionDecision": "allow",
        }
    }, ensure_ascii=False, separators=(",", ":")))


def write_deny(reason: str) -> None:
    if USE_CAMEL_CASE:
        print(json.dumps({
            "permissionDecision": "deny",
            "permissionDecisionReason": reason,
        }, ensure_ascii=False, separators=(",", ":")))
        return
    print(json.dumps({
        "hookSpecificOutput": {
            "hookEventName": "PreToolUse",
            "permissionDecision": "deny",
            "permissionDecisionReason": reason,
        },
    }, ensure_ascii=False, separators=(",", ":")))


def write_ask(reason: str) -> None:
    if USE_CAMEL_CASE:
        print(json.dumps({
            "permissionDecision": "ask",
            "permissionDecisionReason": reason,
        }, ensure_ascii=False, separators=(",", ":")))
        return
    print(json.dumps({
        "hookSpecificOutput": {
            "hookEventName": "PreToolUse",
            "permissionDecision": "ask",
            "permissionDecisionReason": reason,
        }
    }, ensure_ascii=False, separators=(",", ":")))


def current_branch() -> str:
    try:
        result = subprocess.run(
            ["git", "branch", "--show-current"],
            check=True,
            capture_output=True,
            text=True,
        )
        return result.stdout.strip()
    except Exception:
        return ""


stdin_content = sys.stdin.read()
if not stdin_content:
    write_allow()
    raise SystemExit(0)

try:
    data = json.loads(stdin_content)
except json.JSONDecodeError:
    write_allow()
    raise SystemExit(0)

USE_CAMEL_CASE = "toolName" in data or "toolArgs" in data
tool_input = data.get("tool_input") or data.get("toolArgs") or data.get("input") or {}
command = tool_input.get("command", "")
if not command:
    write_allow()
    raise SystemExit(0)

# Check if current branch is protected for commit guard
branch = current_branch()
is_on_protected_branch = branch in PROTECTED_BRANCHES

denied_rules = [
    (r"\bgit\s+push\b[^\n]*(?:--force|-f)\b", "絕對禁止：git push --force / -f 可能損壞受保護分支歷史。請使用 PR 流程合併。"),
    (r"\bgit\b[^\n]*\s--no-verify\b", "絕對禁止：--no-verify 會跳過 git hooks 安全檢查，不得使用。"),
    (r"\bgit\s+push\s+\S+\s+(main|master|production|release|prod)\b", "絕對禁止：不得直接推送到受保護分支（main/master/production/release/prod）。請建立 feature branch 並透過 PR 合併。"),
]

for pattern, reason in denied_rules:
    if re.search(pattern, command):
        write_deny(reason)
        raise SystemExit(0)

# Check git commit on protected branch
if is_on_protected_branch and re.search(r"\bgit\s+commit\b", command):
    write_deny(f"絕對禁止：不得直接在受保護分支 '{branch}' 上執行 git commit。請先建立 feature branch：git checkout -b feature/your-feature-name")
    raise SystemExit(0)

ask_rules = [
    (r"\bgit\s+reset\s+--hard\b", "git reset --hard 是不可逆操作，將丟失工作目錄所有未提交變更。確認要繼續嗎？", False),
    (r"\brm\s+(-rf|-fr|-r\s+-f|-f\s+-r)\b", "rm -rf 是破壞性指令，需明確使用者授權（AGENTS.md 規定）。確認要繼續嗎？", False),
    (r"\bgit\s+(merge|rebase|cherry-pick)\b", "此 git 操作在受保護分支（main/master/production/release/prod）上執行前須確認。請確認目前分支為 feature branch。", True),
]

for pattern, reason, protected_only in ask_rules:
    if re.search(pattern, command):
        if protected_only and current_branch() not in PROTECTED_BRANCHES:
            continue
        write_ask(f"[Git Guard] {reason}")
        raise SystemExit(0)

write_allow()
