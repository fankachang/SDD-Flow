---
name: adaptive-learning-loop
description: 在工具失敗、假設錯誤、驗證結果出乎預期、使用者重複修正或工作流程指引缺漏後，擷取已驗證且可重用的教訓，透過遮罩與去重追加到獨立學習記錄。適用於編碼、除錯、審查、治理與文件工作中，當困難揭示可防止未來重犯的規則時使用。
---

# 自適應學習迴圈

使用本技能將已解決的困難轉換為小型、可稽核的教訓，不在執行期間改寫核心指引。內含腳本負責機械性的追加，讓 agent 能以一致且安全的格式記錄教訓。

## 核心規則

將學習記錄追加到獨立檔案；不得自動編輯 `SKILL.md`、`AGENTS.md`、instruction 檔案或其他治理檔案。只有在有重複證據且進行明確維護變更時，才將教訓提升為核心指引。

## 執行環境相容性

追加腳本只使用 Python 標準函式庫與明確的 UTF-8 檔案 I/O，設計上可在 macOS、Linux、Windows PowerShell 與 WSL 執行；請依實際執行命令的 shell 調整解譯器與路徑語法。

| 環境 | 解譯器 | 路徑形式 | 邊界 |
|---|---|---|---|
| macOS / Linux | `python3` | `/path/to/...` | 使用 POSIX 路徑；路徑含空白時加引號。 |
| Windows PowerShell | `py -3` 或 `python` | `C:\path\to\...` | 使用 PowerShell 引號；傳入非 ASCII 值前先初始化 UTF-8。 |
| WSL | `python3` | `/home/...` 或 `/mnt/c/...` | 在 WSL 內執行；不要把 `C:\...` 路徑傳給 Linux 解譯器。 |

PowerShell 的標準 UTF-8 初始化請使用 `RunPowerShell` Skill。不要混用 PowerShell 命令與 WSL 路徑，或 WSL 命令與 Windows 路徑。若外部命令包裝器可能重新解析引號，優先使用 `--key=value` 形式。

## 何時記錄教訓

符合以下任一情況時記錄：

- 工具或命令因誤解其契約、參數或執行模式而失敗。
- 局部假設被可聚焦的驗證檢查推翻。
- 使用者修正揭示路由規則、技術假設或範圍邊界缺漏。
- 驗證步驟發現先前搜尋或審查漏掉的問題。
- 相同的可避免復原模式很可能在其他 repository 或工作階段重現。

不要記錄無害的暫時輸出、沒有有用後續行動的未解決猜測，或無法泛化的一次性專案事實。

## 工作流程

1. **穩定任務。** 保留原始錯誤或非預期結果，做最小修正，並執行能推翻修正的聚焦檢查。
2. **區分事實與推論。** 說明觀察到的症狀、證據支持的原因、修正方式，以及確認結果的檢查。未解決項目標記為候選，不當作事實。
3. **抽象教訓。** 移除使用者名稱、絕對路徑、憑證、專案識別資訊，以及不影響防錯規則的技術細節。
4. **追加一次。** 使用必要欄位執行 `scripts/append_lesson.py`。腳本預設寫入 `references/lessons.md`；若要使用 repository 或外部記憶檔案，傳入 `--target`。
5. **確認追加。** 確認腳本回報 `APPENDED` 或 `DUPLICATE`，再檢查記錄存在且不含秘密或原始錯誤傾印。
6. **謹慎提升。** 當實質相同的教訓在至少兩個獨立工作階段重現時，提出小幅更新 canonical 指引或 Skill；不得自動執行提升。

## 追加命令

依 shell 選擇以下形式，並使用簡短的單行值。請將 `SKILL_DIR` 替換成實際 Skill 目錄。

POSIX shell（macOS/Linux）與 WSL：

```text
SKILL_DIR="/path/to/adaptive-learning-loop"
python3 "$SKILL_DIR/scripts/append_lesson.py" --target="$SKILL_DIR/references/lessons.md" --summary="簡短且面向預防的標題" --symptom="觀察到的現象" --cause="證據顯示的原因" --correction="修正或預防方式" --evidence="聚焦檢查及其結果" --scope="教訓適用範圍" --tag=workflow --tag=validation
```

Windows PowerShell：

```powershell
$SkillDir = "C:\path\to\adaptive-learning-loop"
py -3 "$SkillDir\scripts\append_lesson.py" --target="$SkillDir\references\lessons.md" --summary="簡短且面向預防的標題" --symptom="觀察到的現象" --cause="證據顯示的原因" --correction="修正或預防方式" --evidence="聚焦檢查及其結果" --scope="教訓適用範圍" --tag=workflow --tag=validation
```

問題尚未解決但值得追蹤時使用 `--status candidate`。腳本會拒絕空欄位、控制字元、疑似秘密值與重複記錄；必要時建立目標記錄檔，且不會重寫既有記錄。

## 記錄品質

- 每筆記錄優先只寫一條預防規則。
- 每個欄位保持客觀且簡短；詳細原始輸出應留在正常診斷產物，不要放進學習記錄。
- 將修正寫成其他 agent 可以執行的動作。
- 包含支持記錄的驗證命令、觀察結果或使用者確認。
- 使用標籤便於檢索，不要用標籤塞入長篇說明。

## 安全邊界

- 絕不追加秘密、存取 token、私鑰、個人資料、完整 stack trace 或未遮罩的環境值。
- 缺少相依套件導致的驗證失敗，不代表 Skill 本身有缺陷；只有在環境阻塞可重現時，才另行記錄。
- 不得為了產生成功的教訓記錄而放寬檢查。
- 保持學習記錄只能追加。錯誤記錄以後續記錄或明確維護編輯修正。

可從 `references/lessons.md` 查看已產生的記錄與範例，完整介面請使用腳本的 `--help`。