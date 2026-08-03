# Compact Working Index

> Retrieval hints only. Full evidence remains in `lessons.md`; verify before treating a rule as a canonical instruction.

- `routing`: After generic changes, scan core callers, routes, examples, and configuration.
- `argv`: When a wrapper may reparse quotes, use `--key=value` or verify preserved argv.
- `shell-support`: Document each supported shell and reject shell/path mismatches.
- `shell-validation`: Validate with shell-native syntax and argument arrays.
- `patching`: After context mismatch, split patches by file and validate each slice.
- `git-state`: Before deletion, inspect staged and unstaged diffs; stage only the approved final state.
- `git-ignore`: `git check-ignore --quiet` handles one path; loop for multiple paths or use non-quiet output.
