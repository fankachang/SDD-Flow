# Adaptive Learning Log

## 2026-08-03 - Validate-repaired-control-path
<!-- lesson-id: 79ce3ddd4f91e617 -->
- **Status**: verified
- **Symptom**: Generic-change-left-specific-routing
- **Cause**: First-scan-missed-adjacent-surfaces
- **Correction**: Scan-core-callers-routes-examples-and-configuration
- **Evidence**: Follow-up-scan-clean-and-strict-consistency-passed
- **Scope**: Reusable-agent-workflow
- **Tags**: validation, routing

## 2026-08-03 - Preserve-argument-boundaries
<!-- lesson-id: 8ae38e5b2812f444 -->
- **Status**: verified
- **Symptom**: Quoted-values-were-split-by-command-wrapper
- **Cause**: The-wrapper-reparsed-the-command-instead-of-preserving-argument-boundaries
- **Correction**: Use-equals-form-for-wrapper-sensitive-values-or-verify-argv-preservation
- **Evidence**: The-equals-form-appended-successfully-and-an-identical-retry-returned-DUPLICATE
- **Scope**: Wrapped-command-execution
- **Tags**: tooling, validation

## 2026-08-03 - Document-all-supported-shells
<!-- lesson-id: 5f7d5d5d6af0245b -->
- **Status**: verified
- **Symptom**: Core-script-was-portable-but-invocation-guide-assumed-one-shell
- **Cause**: Interpreter-quoting-and-path-syntax-vary-between-posix-powershell-and-wsl
- **Correction**: Provide-a-shell-matrix-and-reject-cross-shell-path-mismatches
- **Evidence**: POSIX-append-and-deduplication-passed-and-a-windows-path-was-rejected-with-guidance
- **Scope**: Cross-platform-agent-skills
- **Tags**: platform, workflow

## 2026-08-03 - Use-shell-native-validation
<!-- lesson-id: 9385b4eb2eadd49b -->
- **Status**: verified
- **Symptom**: POSIX-pipeline-was-sent-to-PowerShell
- **Cause**: The-active-terminal-shell-controls-pipeline-and-quoting-semantics
- **Correction**: Use-native-PowerShell-syntax-and-argument-arrays
- **Evidence**: Short-PowerShell-run-passed-UTF8-append-and-deduplication
- **Scope**: Cross-shell-agent-validation
- **Tags**: platform, tooling

## 2026-08-03 - Split-file-patches-after-context-mismatch
<!-- lesson-id: ecd86bdc21b47bcf -->
- **Status**: verified
- **Symptom**: Large-multi-file-patch-was-rejected-by-context-mismatch
- **Cause**: Patch-mixed-unrelated-files-and-relied-on-exact-nearby-text
- **Correction**: Use-file-scoped-patches-with-current-context-and-validate-each-slice
- **Evidence**: Smaller-patch-applied-and-focused-search-passed-after-one-local-repair
- **Scope**: Governance-file-editing
- **Tags**: workflow, validation

## 2026-08-03 - Check-index-worktree-state-before-deletion
<!-- lesson-id: 85fdee0a2ec4179a -->
- **Status**: verified
- **Symptom**: Deletion-with-pre-existing-staged-edits-produced-mixed-status
- **Cause**: Index-and-working-tree-held-different-versions
- **Correction**: Inspect-staged-and-unstaged-diffs-before-deletion-and-stage-final-state-only-with-approval
- **Evidence**: Git-status-showed-MD-for-removed-files-and-unrelated-staged-edits-were-preserved
- **Scope**: Git-governance-changes
- **Tags**: git, safety

