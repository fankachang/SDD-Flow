---
name: hush
description: >
  Local, agent-safe per-worktree secrets manager (macOS). Encrypts .env with age
  outside the repo; injects plaintext only in `hush run` subprocesses so AI agents
  can't read secrets via cat/grep. Trigger: hush, secrets management, .env security.
license: MIT
source: https://github.com/allen-hsu/hush
platform: macOS only
---

# hush — Local Agent-Safe Secrets Management

> Platform restriction: **macOS only** (depends on macOS Keychain and `hdiutil` RAM disk)

The `.env` file becomes a risk the moment an AI coding agent enters the repo: agents habitually `cat .env`, `grep -r KEY`, and a careless secret ends up in the model context or gets accidentally committed. hush ensures secrets simply don't exist in the worktree.

## Agent Usage Pre-Check (Must Read)

**Before assisting users with hush, confirm in order:**

### Step 1: Confirm Platform

```bash
uname -s   # Must output Darwin (macOS)
```

If not macOS, inform user it's unsupported and stop.

### Step 2: Check if hush is Installed

```bash
which hush 2>/dev/null && hush version || echo "NOT_INSTALLED"
```

**Installed** → Proceed directly to usage flow.

**Not Installed** → Execute Step 3.

### Step 3: Guide Installation (When Not Installed)

Prompt user to choose installation method:

```bash
# Method A (Recommended): Go local compilation, not quarantined by Gatekeeper
# Requires Go installed first: https://go.dev/dl/
go install github.com/allen-hsu/hush@latest

# Method B: Homebrew
brew install allen-hsu/tap/hush
```

After installation, run shell hook setup:

```bash
hush install     # Idempotently adds eval "$(hush hook)" to ~/.zshrc
source ~/.zshrc  # Or restart terminal
```

Confirm installation success:

```bash
hush version
```

### Step 4: Confirm if Project is Already Initialized

```bash
# In project directory
ls .hush.toml 2>/dev/null && echo "Initialized" || echo "Not Initialized"
```

**Not Initialized** → Ask user if they want to run `hush init` to begin setup.

## Core Concepts

| Component | Location | Description |
|-----------|----------|-------------|
| Declaration | `.hush.toml` (committed to repo) | Declares which keys, how to select profile, **never contains values** |
| Store | `~/.config/hush/store.age` (outside repo) | All values, age-encrypted, namespace: project → profile → key |
| Master Key | macOS Keychain | Auto-generated on first use, no plaintext key file on disk |

`hush run` parses profile → decrypts store → injects into subprocess env → `exec`. Plaintext exists only in that subprocess's memory.

## Installation

```bash
# Recommended: Local compilation, not quarantined by Gatekeeper
go install github.com/allen-hsu/hush@latest
hush install     # Adds eval "$(hush hook)" to ~/.zshrc

# Or use Homebrew
brew install allen-hsu/tap/hush
hush install
```

Take effect after restarting shell (or `source ~/.zshrc`).

## Quick Start

```bash
cd my-project
hush init                    # Create .hush.toml (will commit; only declares key names)
hush import .env --shred     # Import existing .env and shred plaintext
hush ls                      # List declared keys + resolved by which profile (no values shown)
hush run -- npm run dev      # Decrypt, inject env to subprocess, exec
```

## .hush.toml Configuration

```toml
# .hush.toml — Will commit, no values
profile = "branch"           # branch | cwd | fixed:<name>
extends = "base"             # Keys not in current profile, look in this profile
keys    = ["DATABASE_URL", "STRIPE_KEY"]
shims   = ["npm", "pnpm"]    # Auto-wrap hush run when entering bare commands (opt-in)

# Per-project agent strategy (optional)
# disable_get = true         # Completely disable hush get, values only via hush run
# deny_agent_run = true      # Also reject hush run when agent detected
# agent_profile = "sandbox"  # Agent uses this profile instead (test credentials)
```

## Command Reference

| Command | Description |
|---------|-------------|
| `hush run -- <cmd>` | Parse profile, inject env to subprocess, exec. Usable, not readable |
| `hush set <KEY>` | Set single value (interactive input, not shown, not in history) |
| `hush unset <KEY>` | Remove a key from current profile |
| `hush ls [--json]` | List declared keys + resolved by which profile, **never shows values** |
| `hush get [KEY]` | Print a value (TTY only; agent automatically rejects) |
| `hush edit` | Edit profile in `$EDITOR` (RAM disk backed, TTY only) |
| `hush import [path]` | Import existing .env (`--shred` shreds source after import) |
| `hush fork [--from p]` | Copy a profile to current profile |
| `hush cp <from> <to>` | Copy profile values to another profile |
| `hush init` | Create .hush.toml template |
| `hush install` | Add shell hook to ~/.zshrc |
| `hush scrub` | List shell commands that clear hush vars/shims (use before starting agent) |

`--json` applies to `ls`, `get`, `set`, `unset`, `import`, `fork`, `cp`.

## Per-Worktree Workflow

```bash
git worktree add ../feature-x -b feature-x
cd ../feature-x
hush fork                   # Copy from base profile to this branch's profile
hush set DATABASE_URL        # Set only the differing values
```

## Agent Behavior Patterns

hush automatically detects agent context (`CLAUDECODE`, `CODEX_SANDBOX`, `HUSH_AGENT` env vars, or no TTY):

- **Interactive shell (human)**: shims auto-wrap commands, `hush get` works, shows banner
- **Agent mode**: shims not installed, `hush get` rejected, only `hush run` allowed

Correct usage of this tool design by agents:
```bash
# ✅ Correct: Use hush run to execute commands needing secrets
hush run -- pytest
hush run -- node app.js

# ❌ Forbidden: Agent directly cat/grep to read secrets (values not in worktree)
cat .env          # Only sees key names
grep -r API_KEY . # Can't find values
```

## Security Model

**hush can block**:
- cat/grep worktree to read out secret values
- Accidental commit of values (repo only has key names)
- Secrets leaking into persistent shell (agent can't inherit)
- edit writing plaintext to persistent storage (RAM disk)

**hush cannot block**: A program deliberately executing `hush run -- env` under the same uid.

## Integration with Existing Code

Code **requires no modifications**, hush injects env at OS process level:

```javascript
// JS — Unchanged
const url = process.env.DATABASE_URL;
```

```python
# Python — Unchanged
url = os.environ["DATABASE_URL"]
```

Only startup method changes:
```bash
node app.js     →  hush run -- node app.js
npm run dev     →  hush run -- npm run dev  (or set shims to auto-wrap)
```

## 從 .env 遷移

```bash
hush init
hush import .env --shred   # 匯入並安全銷毀 .env
echo ".env" >> .gitignore  # 確保不再 commit
git add .hush.toml && git commit -m "chore: migrate secrets to hush"
```
