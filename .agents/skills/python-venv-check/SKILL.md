---
name: python-venv-check
description: Check and reuse the project-root .venv before Python project development, dependency-sensitive execution, testing, or package installation. If it is absent, ask whether to create it or use system Python. Do not trigger for repository utility scripts whose governing skill or documentation explicitly says they use only the Python standard library and require no venv or installation.
---

# Python Virtual Environment Check Flow (.venv Priority)

Use this skill to standardize dependency-sensitive Python project execution, avoid repeatedly creating virtual environments, and follow the "use existing first, then ask" principle.

## Applicable Scenarios

- Before Python project development, tests, package installation, or commands that depend on project/third-party packages
- Project may already have an existing `.venv`
- Need to confirm with the user before creating a new environment; if `.venv` already exists, use it directly

## Exemption: Self-Contained Repository Utilities

Do not trigger this skill when the utility's governing skill or documentation explicitly states that it:

- uses only the Python standard library; and
- requires no venv or package installation.

Run that utility with the documented system Python command without checking `.venv` or asking an environment question. If the interpreter itself is unavailable, report that missing prerequisite; creating a venv cannot supply Python.

## Core Principles

1. First classify the command: apply the self-contained utility exemption when its governing documentation explicitly allows it
2. Otherwise, check whether `.venv` exists in the project root
3. If `.venv` exists: use that environment directly, don't create a new virtual environment
4. If `.venv` doesn't exist: use the VS Code `vscode/askQuestions` tool first, with `allowFreeformInput: true`
   - Whether to create a new virtual environment
   - Or use the system default Python environment
5. Don't proactively create a new virtual environment without explicit user choice

## Standard Flow

### Step 0: Check for the Documented Exemption

If the utility meets the self-contained repository utility exemption, run it as documented and stop this flow.

### Step 1: Check if `.venv` Exists

Check the `.venv` directory based on the current project root.

### Step 2: If `.venv` Exists

- Treat as the primary Python execution environment
- All subsequent Python commands and package installations should use this environment
- No longer ask whether to create a new environment (unless user actively requests)

### Step 3: If `.venv` Doesn't Exist

Present a two-choice question to the user:

- Create a new virtual environment (e.g., `.venv`)
- Use the system default Python environment

Example question:

"Currently no `.venv` found in the project root. Would you like me to create a new virtual environment now, or use the system default Python environment?"

## Implementation Notes

- Use project root as the sole decision basis, avoid repeatedly creating environments in subdirectories
- If `.venv` already exists, don't overwrite or rebuild
- Record user choice and maintain consistency within the same workflow
- If user changes their choice later, switch environment strategy accordingly

## Completion Criteria

- Exempt repository utilities ran directly without a redundant `.venv` check; or
- `.venv` existence check completed and an existing environment or explicit user choice was adopted
- All subsequent dependency-sensitive operations use a consistent Python environment
