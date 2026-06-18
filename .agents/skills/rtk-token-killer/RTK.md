# RTK - Rust Token Killer

**Usage**: Token-optimized CLI proxy (60-90% savings on dev operations)

## Meta Commands (always use rtk directly)

```bash
rtk gain              # Show token savings analytics
rtk gain --history    # Show command usage history with savings
rtk discover          # Analyze Claude Code history for missed opportunities
rtk proxy <cmd>       # Execute raw command without filtering (for debugging)
```

## Installation Verification

```bash
rtk --version         # Should show: rtk X.Y.Z
rtk gain              # Should work (not "command not found")
which rtk             # Verify correct binary
```

⚠️ **Name collision**: If `rtk gain` fails, you may have reachingforthejack/rtk (Rust Type Kit) installed instead.

## Hook-Based Usage

All other commands are automatically rewritten by the Claude Code hook.
Example: `git status` → `rtk git status` (transparent, 0 tokens overhead)

### Scope: What RTK covers

RTK intercepts **`run_in_terminal` / `Bash` tool calls only** (shell commands).

| Operation | Goes through RTK? |
|---|---|
| Shell commands (`git`, `npm`, `python`, etc.) | ✅ Auto-intercepted via hook |
| Shell-based file reads (`cat`, `grep`, `head`, `tail`, `find`) | ✅ Auto-intercepted via hook |
| **Log & debug output** (`docker logs`, `pm2 logs`, `journalctl`, stack traces) | ✅ **High-value target** — RTK compresses repetitive lines & noise |
| Native tool API calls (`read_file`, `grep_search`, `file_search`) | ❌ Not intercepted (direct API, no shell) |

**Best practice**: Prefer native tools (`read_file`, `grep_search`) for file reading — they are faster and bypass shell overhead entirely. Use shell commands (and thus RTK) when native tools are insufficient, **especially for logs and debug output where RTK's compression yields the highest token savings**.

Refer to CLAUDE.md for full command reference.
