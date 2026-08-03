---
name: consistency-check
description: 自我檢測 AGENTS.md、skills、instructions、自訂 agents、prompts 與 Docs/governance 的 SSOT 違規及重複 context 載入。偵測重複內容、skill 翻譯未成對、自動載入文件被再次讀取、prompt-to-agent 重複載入與載入循環。修改治理文件或 skill 後及 commit 前執行。其 Python 腳本只使用標準函式庫，免 venv 且不需安裝套件。
---

# 一致性檢測（SSOT 自我檢測）

自動偵測本 repo 反覆出現的治理問題：

1. **跨檔案重複內容** — 同一段落／表格／指令被複製到 ≥2 個檔案，違反單一真相來源（SSOT）原則。
2. **skill 文件未成對** — 有 `SKILL.md` 卻缺 `SKILL_zhTW.md`（或反之）。
3. **重複 context 載入** — 入口 prompt 與其指定 agent，或同一來源文件，重複要求讀取相同文件。
4. **不安全的載入關係** — 再次讀取 `AGENTS.md` 等自動載入文件，或治理文件形成載入循環。

被檢查的規則本身定義於 **AGENTS.md →「內容分層規則（防重複 / 防遞迴）」**。本 skill 不重述規則，只檢查是否遵守。

## 使用時機

- **commit 前**：修改 `AGENTS.md`、skills、instructions、自訂 agents、prompts 或 `Docs/governance` 後。
- **新增內容後**：確認新加的內容不是從既有來源複製而來。
- **修改 prompt-to-agent 路由或強制 read/load 指令後**：避免重複載入 context。
- 定期作為治理關卡（例如審查時）。

## 執行方式

單一跨平台腳本（純 Python 標準函式庫，免 venv、免安裝）。**macOS / Linux / WSL / Windows** 指令相同：

```bash
python3 .agents/skills/consistency-check/scripts/consistency-check.py
```

Windows 原生若 `python3` 不在 PATH，改用 `python`：

```powershell
python .agents\skills\consistency-check\scripts\consistency-check.py
```

### 選項

| 旗標 | 作用 |
|---|---|
| （無）| 掃描治理 + skills（排除 `references/` 與 `vendor/`）。僅 BLOCK 級問題時離開碼 1。 |
| `--all` | 一併掃描 `references/` 子目錄。 |
| `--strict` | 把單行重複警告視為失敗（離開碼 1）。 |
| `--json` | 機器可讀輸出，供 CI 使用。 |

修改檢測器後，執行純標準函式庫回歸測試：

```bash
python3 -m unittest discover -s .agents/skills/consistency-check/tests -p 'test_*.py' -v
```

## Git Pre-Commit Hook（自動防線）

`.githooks/pre-commit` 是已版本控制的 hook，只要 commit 觸及治理檔案（`AGENTS.md`、任何 `SKILL.md`/`SKILL_zhTW.md`、`.github/instructions/`、`.github/prompts/`、`.github/agents/`、`.github/copilot-instructions.md`、`Docs/governance/`），就會自動以 `--strict` 執行此檢測；未觸及則靜默略過。

每個 clone 只需啟用一次（macOS/Linux/Windows 指令相同，因為 Git 一律透過 `sh` 執行 hook）：

```bash
git config core.hooksPath .githooks
```

停用用 `git config --unset core.hooksPath`。檢測失敗時**禁止**用 `git commit --no-verify` 略過，應修正重複內容（`--no-verify` 的禁用規則見 git-workflow instructions）。

## 輸出判讀

- **❌ 跨檔案重複區塊**：高嚴重度。連續多行被複製到不同 SSOT 群組的檔案。保留一份 canonical、其餘改為一行交叉引用。
- **⚠️ 跨檔案重複單行**：待檢視。單一共用句子／表格列／指令。可能是真的外洩，也可能是可接受的簡寫，逐案判斷。
- **❌ SKILL 成對問題**：某 skill 缺英文或中文對應檔，補齊缺少的那份。
- **❌ 重複載入指令**：移除入口 prompt 或重複章節的讀取指令，只在負責的 agent 保留一個 canonical 載入點。
- **⚠️ 共享治理文件載入**：無直接執行鏈關係的來源載入相同治理文件，確認是否真的各自需要完整 context。
- **❌ 治理文件載入循環**：中斷強制讀取鏈，將其中一邊改為不觸發載入的交叉引用。

### 載入指令掃描範圍

載入檢查涵蓋 `.github/agents/*.agent.md`、`.github/prompts/*.prompt.md`、`.github/instructions/*.md`、`Docs/governance/**/*.md` 與根目錄 agent instructions。只有明確的 read/load 命令會建立載入關係；「詳見 TEAM 指南」等資訊性連結不會觸發 finding。

`agent: ba` 等 prompt frontmatter 會建立執行關係；若 prompt 與 `ba.agent.md` 都載入同一目標，檢查會阻擋。明確再次讀取自動載入的 `AGENTS.md` 也會被阻擋。

### SSOT 群組（何謂「跨檔案」）

**同群組內**的重複屬預期，會被忽略：
- 一個 skill 的 `SKILL.md` 與 `SKILL_zhTW.md`（翻譯對）共用程式碼／指令 — 正常。
- 同一 skill 目錄內的檔案（含 `references/`）— 正常。

只有**跨不同群組**的重複才會被標記（例如 `AGENTS.md` ↔ 某 skill，或 `skillA` ↔ `skillB`）。

## 調校：ignore.txt

第三方捆綁 skill（其內部 boilerplate 非你維護）已預先列於 [ignore.txt](./ignore.txt)。每行為一個相對路徑子字串，命中的檔案會被略過。移除某行可將該 skill 重新納入檢測；新增一行可靜音已知可接受的情況。

## 修正方式

依 AGENTS.md 的 SSOT 原則：讓該事實只存在於**一個** canonical 檔案，其餘出現處一律改為「一句話 + 交叉引用」。治理文件之間禁止複製貼上內容。
