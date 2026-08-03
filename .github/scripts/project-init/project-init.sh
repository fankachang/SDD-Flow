#!/bin/bash
# 專案初始化工具（macOS / Linux / WSL）。
# 建議透過 AI 代理程式執行 `/project-init` 呼叫本腳本；也可直接手動執行。
# 偵測開發環境、設定 git hooks 與 RTK，並列出候選語言/建置工具供 AI 助理與使用者確認。
# 對應版本：project-init.ps1（Windows pwsh）、project-init.bat（cmd 薄殼層）
#
# 本腳本只做「偵測」與「決定性設定」（git hooks、RTK 安裝檢查），
# 不會自動寫入 .github/copilot-instructions.md — 候選建置工具清單須由 AI 助理
# 與使用者確認後，再用編輯工具寫入「專案技術棧與環境」區段。

set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../../.." && pwd -P)"
cd "$ROOT_DIR"

echo "=== 專案初始化偵測結果 ==="
echo "作業系統: $(uname -s)"
echo "Shell: ${SHELL:-未知}"

if git rev-parse --git-dir > /dev/null 2>&1; then
    git config core.hooksPath .githooks
    echo "Git hooks path: 已設定為 .githooks"
else
    echo "Git hooks path: 略過（非 git repository）"
fi

if command -v rtk > /dev/null 2>&1; then
    echo "RTK: 已安裝（$(rtk --version 2>/dev/null || echo 版本未知)）via $(command -v rtk)"
else
    echo "RTK: 未安裝，嘗試執行 install-check.sh"
    if [[ -f .agents/skills/rtk-token-killer/scripts/install-check.sh ]]; then
        bash .agents/skills/rtk-token-killer/scripts/install-check.sh || echo "RTK 安裝檢查未完成，請手動查看 rtk-token-killer skill"
    fi
fi

echo ""
echo "候選語言/建置工具（僅供參考，可能誤判，需與使用者確認後才可寫入 copilot-instructions.md）:"

# 排除建置產物與範本自身基礎設施目錄（非下游專案的實際程式碼）。
EXCLUDE_DIRS='node_modules|/\.git/|/bin/|/obj/|/dist/|/build/|/\.venv/|/vendor/|^\./\.agents/|^\./\.github/|^\./\.specify/|^\./\.vscode/|^\./Docs/'
found_any=false

check() {
    local label="$1" pattern="$2"
    local matches
    matches=$(find . -maxdepth 4 -iname "$pattern" 2>/dev/null | grep -Ev "$EXCLUDE_DIRS" | head -5 || true)
    if [[ -n "$matches" ]]; then
        echo "  - ${label}（發現: $(echo "$matches" | tr '\n' ' ')）"
        found_any=true
    fi
}

check "Node.js" "package.json"
check "Python (pyproject)" "pyproject.toml"
check "Python (requirements)" "requirements.txt"
check ".NET (專案)" "*.csproj"
check ".NET (方案)" "*.sln"
check "Rust" "Cargo.toml"
check "Go" "go.mod"
check "Java (Maven)" "pom.xml"
check "Java (Gradle)" "build.gradle*"
check "Ruby" "Gemfile"
check "PHP" "composer.json"

if [[ "$found_any" == false ]]; then
    echo "  (未偵測到常見語言 manifest 檔案)"
fi

echo ""
echo "其他初始化狀態:"

# Python 虛擬環境（僅在偵測到 Python manifest 時回報）
if find . -maxdepth 4 \( -iname "pyproject.toml" -o -iname "requirements.txt" \) 2>/dev/null | grep -Ev "$EXCLUDE_DIRS" | grep -q .; then
    if [[ -d .venv ]]; then
        echo "  - Python .venv: 已存在（依 python-venv-check skill 直接使用，不得重建）"
    else
        echo "  - Python .venv: 不存在（Python 專案建議建立，見 python-venv-check skill）"
    fi
fi

# SpecKit 憲章是否仍為 placeholder
if [[ -f .specify/memory/constitution.md ]]; then
    if grep -q '\[PROJECT_NAME\]' .specify/memory/constitution.md; then
        echo "  - SpecKit 憲章: 仍為 placeholder，請執行 /speckit.constitution 初始化"
    else
        echo "  - SpecKit 憲章: 已初始化"
    fi
fi

echo ""
echo "=== 偵測完成 ==="
echo "若非透過 /project-init 呼叫：請將以上結果交給 AI 助理，由其與你確認候選項目後，寫入 .github/copilot-instructions.md 的「專案技術棧與環境」區段。"
