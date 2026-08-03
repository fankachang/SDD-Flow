# RTK - Scope 與 Output Policy（深入參考）

> 本檔為 `SKILL.md` 的延伸，只記錄 SKILL.md 未涵蓋的兩件事：RTK 的攔截範圍與輸出使用原則。
> 安裝、驗證、開關、meta 指令請看 [SKILL.md](./SKILL.md)，不在此重複。

## Scope: What RTK covers

RTK intercepts **shell tool calls only** (`PreToolUse` in VS Code Copilot, `preToolUse` in GitHub Copilot CLI, and `Bash` in Claude Code).

| Operation | Goes through RTK? |
|---|---|
| Shell commands (`git`, `npm`, `python`, etc.) | ✅ Auto-intercepted via hook |
| Shell-based file reads (`cat`, `grep`, `head`, `tail`, `find`) | ✅ Auto-intercepted via hook |
| **Log & debug output** (`docker logs`, `pm2 logs`, `journalctl`, stack traces) | ✅ **High-value target** — RTK compresses repetitive lines & noise |
| Native tool API calls (`read_file`, `grep_search`, `file_search`) | ❌ Not intercepted (direct API, no shell) |

**Best practice**: Prefer native tools (`read_file`, `grep_search`) for file reading — they are faster and bypass shell overhead entirely. Use shell commands (and thus RTK) when native tools are insufficient, **especially for logs and debug output where RTK's compression yields the highest token savings**.

## Output Policy

- Prefer RTK for noisy shell outputs: test runs, build logs, lint output, git status/diff/log, grep/find/ls, docker logs.
- Use RTK for first-pass triage, not as the only evidence source for root-cause analysis.
- Do not rely on RTK-compressed output when debugging order-sensitive, timing-sensitive, or intermittently failing workflows.
- If RTK output lacks enough detail, immediately fall back to raw output with `rtk proxy <cmd>` for the narrowed scope.
- Preserve raw output for audit, exact diffing, or any workflow where line order is evidence.
- Keep stable long-form prompts, specs, and reusable context outside RTK rewrites to protect cache hit rate.
