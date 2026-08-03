---
name: integration-test-quality
description: Assess integration test suites across languages, frameworks, runners, and deployment environments; diagnose failures from evidence and root cause; and recommend test-side fixes while protecting product behavior. Use when evaluating integration-test health, debugging failures, reviewing CI readiness, or defining repeatable test-quality gates.
---

# Integration Test Quality Assessor (ITQA)

Use this framework to evaluate integration-test suites, diagnose failures, and improve test reliability without hiding product defects. Keep the method independent of programming language, test framework, database, service type, and test runner.

## Scope and Operating Rules

- Inspect the repository's configured test command, fixtures, environment contract, and result format before choosing commands or patterns.
- Prefer the project's native runner and machine-readable result output. Do not assume a runner, file extension, database, hosting model, or assertion library.
- Treat a test failure as evidence. Preserve the original error, execution context, and reproducibility information before changing code.
- Try a test-layer or test-environment correction first. Change product code only when the failure demonstrates a product defect or the requested behavior includes that change.
- Never use retries, skips, broad exception handling, relaxed assertions, or alternate data paths to conceal a failure. Every exception must be explicit and justified.
- Keep technology-specific implementation details in the project's own test documentation. Use the references in this skill for reasoning patterns, not copy-paste framework setup.

## Three-Phase Assessment

### Phase 1: Establish a Baseline

1. Locate the repository's documented test command and the supported local or CI environment.
2. Run the complete integration-test scope once and save raw output plus the structured result, when available.
3. Record total, passed, failed, skipped, pending, blocked, duration, and environment details. Report skipped or pending tests separately; do not silently count them as passing.
4. Capture the baseline revision, configuration profile, dependency versions, data source, and parallelism settings.
5. Apply the project's quality threshold. If it has no threshold, use 95% as a provisional gate and mark that decision in the report.

### Phase 2: Diagnose by Evidence

1. Re-run each failure in isolation, then compare with the full-suite result when ordering or shared state may matter.
2. Preserve the first useful stack trace, logs, request or message data, fixture state, and timing information.
3. Classify the failure using [Decision Framework](references/decision-framework.md): environment, setup or fixture, data or external dependency, concurrency or timing, product defect, or unknown.
4. Select the smallest test-side correction that restores the intended integration boundary without weakening the assertion.
5. Validate the correction with a focused run before changing another slice.
6. Escalate product changes, schema or contract changes, and unresolved environmental constraints with evidence and an explicit follow-up.

### Phase 3: Validate and Report

1. Run the focused tests, the complete suite, and repeat runs sufficient to test reproducibility. Use at least three independent runs when diagnosing flakiness or shared-state risk.
2. Check isolation, cleanup, ordering independence, serial behavior, and the configured parallel mode.
3. Apply [Quality Checklist](references/quality-checklist.md), including known limitations and skipped-test review.
4. Produce the report structure below. Distinguish observed facts, hypotheses, fixes, and remaining risk.

## Failure Categories at a Glance

| Category | Typical signal | Preferred first response | Product-code risk |
|---|---|---|---|
| **Environment** | Missing runtime capability, configuration, network, filesystem, clock, or service | Make the test environment explicit; add a narrow adapter or prerequisite guard | Low when production behavior is unchanged |
| **Setup / Fixture** | State leaks between tests, incomplete cleanup, invalid arrangement, or order dependence | Isolate setup and teardown; use a deterministic fixture builder | Low |
| **Data / Dependency** | Seed data, credential, schema, service, or contract is absent or incompatible | Use deterministic fixtures or capability-based discovery; verify the dependency contract | Low to medium |
| **Concurrency / Timing** | Race, timeout, eventual consistency, or parallel-only failure | Synchronize on observable conditions; isolate shared state; remove timing assumptions | Medium |
| **Product Defect** | The system violates a documented requirement, invariant, schema, or API contract | Keep the failing assertion, fix or escalate the product defect; use only a documented temporary workaround | Medium to high |
| **Unknown** | Evidence is insufficient or contradictory | Gather one discriminating observation before patching | Unknown |

## Quality Gates

Every assessment should answer these questions:

- Is the measured pass rate at or above the configured threshold, with skipped, pending, and blocked tests disclosed?
- Can the same result be reproduced under the supported environment and parallelism settings?
- Is each failure assigned to a layer with evidence rather than an exception-name guess?
- Do test changes preserve the behavior and strength of the integration assertion?
- Are environment prerequisites, data ownership, cleanup, secrets handling, and external dependencies explicit?
- Are known limitations tracked with impact, owner, and next action rather than hidden with suppression?
- Are product changes separated from test infrastructure changes and reviewed at the correct risk level?

Use [Quality Checklist](references/quality-checklist.md) for the complete gate and report requirements.

## Reusable Patterns

Use the smallest applicable pattern from [Test Patterns](references/test-patterns.md):

1. **Environment adapter**: keep production resolution intact while providing a documented test-environment adapter.
2. **Deterministic fixture or capability discovery**: obtain valid data from controlled fixtures or verify required capabilities before execution; never guess identities or records.
3. **Context and dependency harness**: construct the request, identity, clock, queue, service, and storage boundaries the test actually requires, then clean them up.
4. **Evidence-preserving workaround**: temporarily bypass a broken non-target layer only when the intended behavior remains observable and the lost coverage is documented.
5. **Capability guard**: mark a test blocked only when a prerequisite is genuinely unavailable, with a clear reason and a separate follow-up.
6. **Flakiness isolation**: reproduce under controlled order and parallelism before adding any retry; retries may only cover a known transient boundary and must remain visible in results.

## Escalation Criteria

Escalate to the owning engineering team when:

- a product behavior, schema, or public contract must change;
- a workaround weakens the behavior being verified or would remain longer than the agreed time window;
- the required environment capability cannot be supplied or emulated faithfully at the test boundary;
- failures are nondeterministic after isolation and evidence collection;
- shared state, test doubles, or workarounds affect a material part of the suite; or
- the observed risk cannot be bounded by a focused validation.

Do not escalate solely because a local test setup is incomplete if a deterministic, documented test-layer correction resolves it without weakening the assertion.

## Assessment Report Format

Produce a concise report with this structure:

```markdown
## Integration Test Assessment: [Project or Suite]

**Status**: READY | ESCALATION REQUIRED | BLOCKED
**Environment**: [runner, profile, dependency state, and parallelism]

| Metric | Value |
|---|---|
| Total | X |
| Passed | X (Y%) |
| Failed | X |
| Skipped / Pending / Blocked | X |
| Duration | [value] |
| Repeated runs | [result] |

### Root Cause Breakdown
- **Environment**: [count, evidence, test-side action]
- **Setup / Fixture**: [count, evidence, test-side action]
- **Data / Dependency**: [count, evidence, action]
- **Concurrency / Timing**: [count, evidence, action]
- **Product Defect**: [count, evidence, owner and follow-up]
- **Unknown**: [count, next discriminating check]

### Quality Gate
- [ ] Threshold met and exclusions disclosed
- [ ] Failures categorized from evidence
- [ ] Reproducibility and isolation checked
- [ ] Product impact reviewed
- [ ] Known limitations documented with owners and next actions

### Detailed Findings
[Per-test or per-failure evidence, fix, validation result, and remaining risk]
```

## Workflow for a New Suite

1. **Discover**: read the repository's test and CI configuration; identify the integration boundary and required services.
2. **Baseline**: run the native suite once and save structured results.
3. **Diagnose**: classify failures and select one focused check per hypothesis.
4. **Repair**: change the test layer first, preserving the assertion and documenting any limitation.
5. **Validate**: run focused tests, the full suite, and repeat runs appropriate to the risk.
6. **Report**: complete the assessment format and hand off product defects or environment work with evidence.

The bundled PowerShell helper can run a project-supplied test command and create a starter report. It does not assume a particular runner or parse every result format; inspect and complete the generated report when the command uses a custom summary.
