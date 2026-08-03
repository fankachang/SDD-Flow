---
name: adaptive-learning-loop
description: Capture verified, reusable lessons after tool failures, incorrect assumptions, validation surprises, repeated user corrections, or missing workflow guidance, then append them to a separate learning log with redaction and deduplication. Use during coding, debugging, review, governance, and documentation work when a difficulty reveals a prevention rule that can help future sessions.
---

# Adaptive Learning Loop

Use this skill to turn a resolved difficulty into a small, auditable lesson without mutating the core instructions during execution. The bundled script performs the mechanical append so the agent can record a lesson consistently and safely.

## Core Rule

Append learning records to the separate log; never automatically edit `SKILL.md`, `AGENTS.md`, instruction files, or other governance files. Core guidance is promoted only after repeated evidence and an explicit maintenance change.

## Context Budget

- Treat `references/lessons.md` as the append-only audit archive and source of truth. Do not read it wholesale during ordinary tasks.
- Read `references/active-rules.md` when this Skill is relevant; it is a compact working index, not a replacement for the full evidence.
- For a specific issue, search the archive by scope, tag, or symptom keywords and load only matching records.
- Keep the index short with one prevention rule per line. Refresh it only for recurring or broadly useful lessons; do not add every one-off record.

## Runtime Compatibility

The append script uses only the Python standard library and explicit UTF-8 file I/O. It is intended to run on macOS, Linux, Windows PowerShell, and WSL; adapt the interpreter and path syntax to the shell that is actually executing the command.

| Environment | Interpreter | Path form | Boundary |
|---|---|---|---|
| macOS / Linux | `python3` | `/path/to/...` | Use POSIX paths and quote paths containing spaces. |
| Windows PowerShell | `py -3` or `python` | `C:\path\to\...` | Use PowerShell quoting and initialize UTF-8 before passing non-ASCII values. |
| WSL | `python3` | `/home/...` or `/mnt/c/...` | Run the command inside WSL and do not pass a `C:\...` path to the Linux interpreter. |

Use the `RunPowerShell` Skill for the canonical PowerShell UTF-8 initialization. Do not mix a PowerShell command with a WSL path, or a WSL command with a Windows path. The `--key=value` form is preferred when another command wrapper may reparse quoted arguments.

## When to Record a Lesson

Record a lesson when at least one of these occurs:

- A tool or command fails because its contract, arguments, or execution mode was misunderstood.
- A local hypothesis is disproved by a focused validation check.
- A user correction exposes a missing routing rule, technology assumption, or scope boundary.
- A validation step finds a defect that a prior scan or review missed.
- The same avoidable recovery pattern is likely to recur in another repository or session.

Do not record harmless transient output, an unresolved guess with no useful next action, or a one-off project fact that cannot generalize.

## Workflow

1. **Stabilize the task.** Preserve the original error or unexpected result. Make the smallest repair and run a focused check that could disprove the repair.
2. **Separate fact from inference.** State the observed symptom, the evidence-backed cause, the correction, and the check that confirmed it. Mark unresolved items as candidates rather than facts.
3. **Abstract the lesson.** Remove user names, absolute paths, credentials, project identifiers, and technology-specific details that are not essential to the prevention rule.
4. **Append once.** Run `scripts/append_lesson.py` with the required fields. It defaults to `references/lessons.md`; pass `--target` to use a repository or external memory file instead.
5. **Verify the append.** Confirm the script reports `APPENDED` or `DUPLICATE`, then check that the record is present and contains no secret or raw error dump.
6. **Refresh the index.** If the lesson recurs across independent sessions or is broadly useful, add one concise prevention rule to `references/active-rules.md`; otherwise leave the index unchanged.
7. **Promote cautiously.** When substantially identical lessons recur in at least two independent sessions, propose a small update to the canonical instruction or skill. Do not make that promotion automatically.

## Append Command

Use one of these shell-specific forms with concise, single-line values. Replace `SKILL_DIR` with the actual Skill directory.

POSIX shells (macOS/Linux) and WSL:

```text
SKILL_DIR="/path/to/adaptive-learning-loop"
python3 "$SKILL_DIR/scripts/append_lesson.py" --target="$SKILL_DIR/references/lessons.md" --summary="Short prevention-oriented title" --symptom="What was observed" --cause="What evidence showed" --correction="What fixed or prevented it" --evidence="The focused check and its result" --scope="Where the lesson applies" --tag=workflow --tag=validation
```

Windows PowerShell:

```powershell
$SkillDir = "C:\path\to\adaptive-learning-loop"
py -3 "$SkillDir\scripts\append_lesson.py" --target="$SkillDir\references\lessons.md" --summary="Short prevention-oriented title" --symptom="What was observed" --cause="What evidence showed" --correction="What fixed or prevented it" --evidence="The focused check and its result" --scope="Where the lesson applies" --tag=workflow --tag=validation
```

Use `--status candidate` when the problem is not resolved but the observation is worth tracking. The script rejects empty fields, control characters, likely secret values, and duplicate records. It creates the target log when needed and never rewrites existing records.

## Record Quality

- Prefer one prevention rule per record.
- Keep each field factual and short; put detailed raw output in the task's normal diagnostic artifact, not in the learning log.
- Write the correction as an action that another agent can perform.
- Include the validation command, observation, or user confirmation that supports the record.
- Use tags for retrieval, not for embedding a long explanation.

## Safety Boundaries

- Never append secrets, access tokens, private keys, personal data, full stack traces, or unredacted environment values.
- Never treat a failed validation caused by a missing dependency as evidence that the Skill itself is defective; record the environment blocker separately when it is repeatable.
- Never weaken a check just to produce a successful lesson record.
- Keep the learning log append-only. Correct a bad record through a follow-up record or an explicit maintenance edit.

See `references/active-rules.md` for compact working rules and `references/lessons.md` for the audit history. Load the archive only for targeted retrieval or maintenance; use the script's `--help` output for the complete interface.
