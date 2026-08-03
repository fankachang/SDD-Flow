#!/bin/bash
# RTK Token Killer - 全域啟用/關閉開關（sentinel 檔案機制）
#
# 用法：
#   bash .agents/skills/rtk-token-killer/rtk-toggle.sh disable  # 關閉 RTK
#   bash .agents/skills/rtk-token-killer/rtk-toggle.sh enable   # 啟用 RTK
#   bash .agents/skills/rtk-token-killer/rtk-toggle.sh status   # 查看狀態
#
# 原理：在 scripts/ 目錄建立/移除 .rtk-disabled 檔案。
# rtk-hook-wrapper.sh 會檢查此檔案是否存在，決定是否套用 RTK。
# 此機制不依賴環境變數傳遞，比 export COPILOT_RTK_ENABLED 更可靠，且立即生效。

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SENTINEL="${SCRIPT_DIR}/scripts/.rtk-disabled"

case "${1:-status}" in
  disable)
    touch "$SENTINEL"
    echo "❌ RTK 已關閉（終端機命令將取得完整、未壓縮輸出）"
    echo "   立即生效，無需重啟 shell。sentinel: $SENTINEL"
    ;;
  enable)
    rm -f "$SENTINEL"
    echo "✅ RTK 已啟用（終端機命令自動節省 token）"
    echo "   立即生效，無需重啟 shell。"
    ;;
  status)
    if [[ -f "$SENTINEL" ]]; then
      echo "❌ RTK 目前為關閉狀態"
    else
      echo "✅ RTK 目前為啟用狀態（預設）"
    fi
    ;;
  *)
    echo "用法："
    echo "  bash .agents/skills/rtk-token-killer/rtk-toggle.sh disable  # 關閉 RTK"
    echo "  bash .agents/skills/rtk-token-killer/rtk-toggle.sh enable   # 啟用 RTK"
    echo "  bash .agents/skills/rtk-token-killer/rtk-toggle.sh status   # 查看狀態"
    exit 1
    ;;
esac
