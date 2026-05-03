#!/usr/bin/env bash
# RTK 安裝驗證與自動安裝（macOS / Linux）
set -euo pipefail

RTK_REQUIRED_VERSION="0.38.0"

echo "=== RTK 安裝檢查 ==="

# 1. 檢查 rtk 是否存在
if command -v rtk &>/dev/null; then
    INSTALLED_VERSION=$(rtk --version | awk '{print $2}')
    echo "✅ RTK 已安裝：v${INSTALLED_VERSION}"

    # 2. 檢查是否為正確的 rtk（而非 reachingforthejack/rtk）
    if rtk gain &>/dev/null 2>&1; then
        echo "✅ RTK 功能驗證通過（rtk gain 可執行）"
    else
        echo "⚠️  警告：rtk gain 失敗。"
        echo "   可能安裝的是 reachingforthejack/rtk（Rust Type Kit）而非 Rust Token Killer。"
        echo "   請先移除舊版本，再重新安裝："
        if command -v brew &>/dev/null; then
            echo "   brew uninstall rtk && brew install rtk"
        else
            echo "   curl -fsSL https://raw.githubusercontent.com/rtk-ai/rtk/refs/heads/master/install.sh | sh"
        fi
        exit 1
    fi
    exit 0
fi

# 3. 未安裝，自動安裝
echo "❌ RTK 未安裝，開始自動安裝..."

if command -v brew &>/dev/null; then
    echo "→ 使用 Homebrew 安裝..."
    brew install rtk
elif command -v curl &>/dev/null; then
    echo "→ 使用官方安裝腳本..."
    curl -fsSL https://raw.githubusercontent.com/rtk-ai/rtk/refs/heads/master/install.sh | sh
else
    echo "❌ 無法安裝：找不到 brew 或 curl。"
    echo "   請手動從 https://github.com/rtk-ai/rtk/releases 下載二進位檔。"
    exit 1
fi

# 4. 驗證安裝結果
if command -v rtk &>/dev/null; then
    echo "✅ RTK 安裝成功：$(rtk --version)"
    echo ""
    echo "=== 下一步 ==="
    echo "設定 Hook 自動代理（在專案目錄執行）："
    echo "  Claude Code CLI : cp .agents/skills/rtk-token-killer/settings-claude.json .github/settings.json"
    echo "  VS Code Copilot : cp .agents/skills/rtk-token-killer/settings-vscode.json .github/settings.json"
else
    echo "❌ 安裝後仍無法找到 rtk，請檢查 PATH 設定。"
    exit 1
fi
