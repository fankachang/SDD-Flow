---
name: consistency-check
description: Self-check for SSOT violations and redundant context loads across AGENTS.md, skills, instructions, custom agents, prompts, and Docs/governance. Detects duplicated content, unpaired skill translations, repeated reads of auto-loaded files, prompt-to-agent duplicate loads, and load cycles. Run after governance or skill edits and before committing them. Its Python scripts use only the standard library and require no venv or package installation.
---

# Consistency Check (SSOT Self-Check)

Automated detection for recurring governance problems in this repo:

1. **Cross-file duplicated content** — the same paragraph/table/command copied into ≥2 files, violating the single-source-of-truth (SSOT) principle.
2. **Unpaired skill docs** — a `SKILL.md` without its `SKILL_zhTW.md` sibling (or vice versa).
3. **Redundant context loads** — an entry prompt and its selected agent, or one source file, explicitly read the same document more than once.
4. **Unsafe load relationships** — an auto-loaded file such as `AGENTS.md` is read again, or governance documents form a load cycle.

The rules being enforced live in **AGENTS.md → 內容分層規則（防重複 / 防遞迴）**. This skill does not restate them; it checks compliance.

## When to Use

- **Before committing** edits to `AGENTS.md`, skills, instructions, custom agents, prompts, or `Docs/governance`.
- **After adding new content** to a governance/skill file, to confirm it was not duplicated from an existing source.
- **After changing a prompt-to-agent route or a mandatory read/load instruction**, to prevent duplicated context.
- Periodically, as a governance gate (e.g., in review).

## How to Run

Single cross-platform script (Python stdlib only — no venv, no install). Same command on **macOS / Linux / WSL / Windows**:

```bash
python3 .agents/skills/consistency-check/scripts/consistency-check.py
```

On Windows native, use `python` if `python3` is not on PATH:

```powershell
python .agents\skills\consistency-check\scripts\consistency-check.py
```

### Options

| Flag | Effect |
|---|---|
| (none) | Scan governance + skills (excludes `references/` and `vendor/`). Exit 1 only on BLOCK-level issues. |
| `--all` | Also scan `references/` subfolders. |
| `--strict` | Treat single-line duplicate warnings as failures (exit 1). |
| `--json` | Machine-readable output for CI. |

Run the standard-library regression suite after changing the checker:

```bash
python3 -m unittest discover -s .agents/skills/consistency-check/tests -p 'test_*.py' -v
```

## Git Pre-Commit Hook (Automatic Backstop)

A versioned hook at `.githooks/pre-commit` runs this check with `--strict` automatically whenever a commit touches a governance file (`AGENTS.md`, any `SKILL.md`/`SKILL_zhTW.md`, `.github/instructions/`, `.github/prompts/`, `.github/agents/`, `.github/copilot-instructions.md`, `Docs/governance/`). It skips silently for commits that don't touch those paths.

Enable it once per clone (same command on macOS/Linux/Windows, since Git always runs hooks through `sh`):

```bash
git config core.hooksPath .githooks
```

Disable with `git config --unset core.hooksPath`. Do not bypass a failing hook with `git commit --no-verify` — fix the duplication instead (see git-workflow instructions for the `--no-verify` prohibition).

## Interpreting Output

- **❌ 跨檔案重複區塊 (duplicate block)** — high severity. Consecutive lines copied across files in different SSOT groups. Keep one canonical copy; replace the others with a one-line cross-reference.
- **⚠️ 跨檔案重複單行 (duplicate line)** — review candidate. A single shared sentence/table row/command. May be a real leak or acceptable shorthand — judge case by case.
- **❌ SKILL 成對問題 (pairing)** — a skill is missing its EN or zhTW counterpart. Create the missing file.
- **❌ 重複載入指令 (redundant load)** — remove the read from the entry prompt or repeated section; keep one canonical load point in the responsible agent.
- **⚠️ 共享治理文件載入 (shared governance load)** — unrelated sources explicitly load the same governance file. Confirm that each source truly needs independent context.
- **❌ 治理文件載入循環 (load cycle)** — break the mandatory read chain and replace one edge with a non-loading cross-reference.

### Load-instruction scope

The load check scans `.github/agents/*.agent.md`, `.github/prompts/*.prompt.md`, `.github/instructions/*.md`, `Docs/governance/**/*.md`, and root agent instructions. It treats only explicit read/load commands as edges; an informational link such as "see TEAM guide" does not trigger a finding.

Prompt frontmatter such as `agent: ba` forms an execution edge. If both that prompt and `ba.agent.md` load the same target, the check blocks it. Explicitly re-reading auto-loaded `AGENTS.md` is also blocked.

### SSOT groups (what counts as "cross-file")

Duplication **within the same group** is expected and ignored:
- A skill's `SKILL.md` and `SKILL_zhTW.md` (translation pair) share code blocks/commands — fine.
- Files inside the same skill directory (including `references/`) — fine.

Only duplication **spanning different groups** is flagged (e.g., `AGENTS.md` ↔ a skill, or `skillA` ↔ `skillB`).

## Tuning: ignore.txt

Third-party bundled skills (whose internal boilerplate you don't maintain) are pre-listed in [ignore.txt](./ignore.txt). Each line is a relative-path substring; matching files are skipped. Remove a line to bring that skill back into scope; add a line to silence a known-acceptable case.

## Fixing a Finding

Follow the SSOT principle in AGENTS.md: keep the fact in exactly **one** canonical file, and replace every other occurrence with a single sentence + cross-reference. Do not copy-paste content between governance files.
