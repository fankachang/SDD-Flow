---
applyTo: "**/*.{js,jsx,ts,tsx,py}"
---

# 程式碼安全規則（來源：commit-quality + check-console + config-protection hooks）

## 禁止提交的內容

- **絕對禁止**在任何 JS/TS/Python 檔案中留下 `debugger` 陳述式
- **絕對禁止**在生產路徑的程式碼中留下 `console.log`（測試檔 `*.test.*`、`*.spec.*`、`*.config.*`、`scripts/`、`__tests__/` 除外）
- **絕對禁止** hardcode 任何 secret、token 或 API key，包括：
  - OpenAI key：`sk-[a-zA-Z0-9]{20,}`
  - GitHub token：`ghp_`、`gho_` 開頭
  - AWS key：`AKIA[A-Z0-9]{16}`
  - Google key：`AIza[a-zA-Z0-9_-]{35}`

## 禁止修改的設定檔

不得修改以下 linter/formatter 設定檔（應修正原始碼，而非放寬規則）：
- `.eslintrc`、`eslint.config.js`、`eslint.config.mjs`
- `.prettierrc`、`prettier.config.js`
- `biome.json`、`biome.jsonc`
- `.ruff.toml`、`ruff.toml`
- `.stylelintrc`

## 禁止讀取大型檔案

- 讀取超過 500 KB 的檔案時，必須使用 offset/limit 或 Grep 先定位目標位置
- 超過 2 MB 的檔案**禁止**整個讀取，必須改用搜尋工具
