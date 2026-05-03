---
applyTo: "**"
---

# Git 工作流程安全規則（來源：branch-protection + commit-quality hooks）

## 受保護分支

受保護分支包括：`main`、`master`、`production`、`release`、`prod`

## 禁止操作

- **絕對禁止** `git push --force` 或 `git push -f` 到任何受保護分支
- **絕對禁止**直接在受保護分支上執行 `git commit`（必須先建立 feature branch）
- **絕對禁止**使用 `--no-verify` 跳過 git hooks
- **絕對禁止** `rm -rf` 等不可逆的破壞性指令（需明確使用者授權）

## 建議流程

```bash
# 正確做法：從受保護分支建立 feature branch
git checkout -b feature/your-feature-name
# ... 開發 ...
git commit -m "feat: ..."
# 再透過 PR 合併回 main
```

## 在受保護分支上的警告操作

以下操作在受保護分支上執行前，必須確認是否為預期行為：
- `git merge`
- `git rebase`
- `git reset`
- `git cherry-pick`
