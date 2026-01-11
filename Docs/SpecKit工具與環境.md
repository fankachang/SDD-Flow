# 安裝工具與環境設置

## 先以 PowerShell 5 安裝以下套件

* 安裝 Scoop 套件管理器
  
  ```ps1
  Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
  Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression
  ```

* 安裝工具

  ```ps1
  #  pwsh、git、uv 與 nvm
  scoop install pwsh git uv nvm
  
  # 安裝搜尋文字檔案的利器 ripgrep
  scoop install ripgrep

  # 安裝 Windows Terminal
  scoop bucket add extras
  scoop install extras/windows-terminal

  # 更新 uv 的路徑
  uv tool update-shell

  # 重新啟動檔案總管，讓環境變數生效
  Stop-Process -Name explorer -Force; Start-Process explorer
  ```  

## Windows Terminal 下安裝

```ps1
# 透過 nvm 安裝 Node.js LTS 版本
nvm install lts
nvm use lts

# 安裝 Spec Kit 的 Specify CLI 命令列工具
uv tool install specify-cli --from git+https://github.com/github/spec-kit.git

# 安裝 Copilot CLI (請自由選擇)
npm install -g @github/copilot

# 安裝 Claude Code (請自由選擇)
npm install -g @anthropic-ai/claude-code

# 安裝 Gemini CLI (請自由選擇)
npm install -g @google/gemini-cli

# 檢查 Spec Kit 需要的工具支援
specify check
```

## 指令說明

* 核心指令

  | Command | Description |
  | ------- | ----------- |
  | /speckit.constitution	| 制定或更新專案管理原則和開髮指南| 
  | /speckit.specify	| 明確你想建構什麼（需求和使用者故事）| 
  | /speckit.plan	| 使用您選擇的技術堆疊建立技術實施計劃。| 
  | /speckit.tasks	| 產生可執行的任務清單以供實施| 
  | /speckit.implement	| 依照計劃執行所有任務以建置該功能。| 

* 可選用指令

  | Command | Description |
  | ------- | ----------- |
  | `/speckit.clarify`   | 釐清規格中未明確的區塊（建議於 `/speckit.plan` 前執行；前身為 `/quizme`）             |
  | `/speckit.analyze`   | 跨產物一致性與覆蓋度分析（於 `/speckit.tasks` 後、`/speckit.implement` 前執行）                |
  | `/speckit.checklist` | 產生自訂品質檢查清單，驗證需求的完整性、清晰度與一致性（類似「英文的單元測試」） |