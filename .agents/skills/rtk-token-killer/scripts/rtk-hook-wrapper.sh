#!/bin/bash
# RTK Hook Wrapper
# Intercepts VS Code Copilot and GitHub Copilot CLI shell hooks and conditionally applies RTK.
#
# Global OFF switch (two ways, checked in order):
#   1. Sentinel file (most reliable — no env propagation needed):
#        bash .agents/skills/rtk-token-killer/rtk-toggle.sh disable|enable|status
#   2. Environment variable (works only if the hook process inherits it):
#        export COPILOT_RTK_ENABLED=false
#
# Per-command bypass (no global switch needed): call `rtk proxy <cmd>` directly.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SENTINEL="${SCRIPT_DIR}/.rtk-disabled"

if [[ -f "$SENTINEL" || "${COPILOT_RTK_ENABLED:-true}" == "false" ]]; then
  # Empty hook output keeps the original tool call unchanged.
  exit 0
else
  exec rtk hook copilot
fi
