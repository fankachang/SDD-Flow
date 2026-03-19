
## Upgrade/Update Project Spec Kit Files

To upgrade or update the Spec Kit files for both Gemini and Copilot, run the following commands:

```powershell
specify init --here --no-git --force --script sh --ignore-agent-tools --ai gemini
```

```powershell
specify init --here --no-git --force --script sh --ignore-agent-tools --ai copilot
```

**注意**: 升級可能會覆蓋 .specify/memory/constitution.md，建議備份或使用 git restore。更多信息請參見 [github/spec-kit/docs/upgrade.md](https://github.com/github/spec-kit/docs/upgrade.md).
