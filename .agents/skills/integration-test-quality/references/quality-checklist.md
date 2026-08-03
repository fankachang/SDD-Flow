# Quality Checklist: Integration Test Assessment

Use this checklist after baseline collection and again before handing the suite to CI or release validation.

## 1. Scope and Prerequisites

- [ ] The integration boundary is named: API, database, message broker, filesystem, browser, service, or another external boundary.
- [ ] The supported test command, runner, configuration profile, and dependency versions are documented.
- [ ] Required services, network access, credentials, certificates, feature flags, locale, clock, and filesystem permissions are explicit.
- [ ] Secrets are injected through the supported mechanism and are not written to logs, reports, fixtures, or source code.
- [ ] Test data ownership is clear: provisioned by the suite, supplied by an environment, or controlled by another team.
- [ ] A structured result format is available, or the report explicitly says that metrics require manual completion.

## 2. Baseline Metrics

- [ ] A complete baseline run was captured with raw output and structured results when available.
- [ ] Total, passed, failed, skipped, pending, blocked, duration, exit code, revision, and environment are recorded.
- [ ] The pass-rate definition is stated. Unless the project defines another rule, use `passed / total`; disclose excluded states separately.
- [ ] The configured threshold is recorded. If no project threshold exists, mark 95% as provisional rather than as a project requirement.
- [ ] A non-zero exit code, missing result file, or unparsed summary is not reported as a clean pass.

## 3. Failure Diagnosis

For every failure or tightly related failure group:

- [ ] The test's intended behavior and integration boundary are stated.
- [ ] The original error, assertion mismatch, logs, timing, inputs, and environment are preserved.
- [ ] The test was run in isolation and compared with the complete-suite result when ordering may matter.
- [ ] Serial and configured parallel runs were compared when shared state or timing is plausible.
- [ ] The failure is classified as environment, setup/fixture, data/dependency, concurrency/timing, product defect, or unknown.
- [ ] The classification is supported by at least one observation, not only by an exception name.
- [ ] One cheap discriminating check is recorded for the leading hypothesis.

## 4. Test-Layer Correction

- [ ] Test setup is deterministic and owns every resource it creates.
- [ ] Teardown runs on failure and removes temporary state without deleting unrelated data.
- [ ] Assertions remain at the intended integration boundary and are not replaced by unit-level mocks.
- [ ] Data selection is deterministic or capability-based and validates its preconditions.
- [ ] External dependency substitutes, if used, are at the same boundary and their coverage limits are explicit.
- [ ] Time-based behavior waits on an observable condition with a bounded timeout.
- [ ] Retries are absent unless they cover a named transient boundary; retry counts and outcomes remain visible.
- [ ] No broad exception handler, unconditional skip, relaxed assertion, or alternate success path hides a failure.

## 5. Product Impact

- [ ] Product changes are listed separately from test and environment changes.
- [ ] Any product change is tied to a requirement, defect, schema, or contract and reviewed by its owner.
- [ ] No test-only branch, secret, fixture, or dependency leaked into production behavior.
- [ ] Temporary workarounds state lost coverage, impact, owner, removal condition, and expiry.
- [ ] A product defect remains observable through an active assertion or a linked, explicit defect test.

## 6. Reproducibility and Isolation

- [ ] The focused correction passes in the smallest relevant test scope.
- [ ] The complete suite passes under the supported configuration, or every remaining failure is reported.
- [ ] High-risk or flaky behavior was run at least three independent times.
- [ ] The same tests pass, fail, skip, or block consistently within the stated tolerance.
- [ ] Tests do not depend on execution order, a developer machine, wall-clock time, or leftover external state.
- [ ] Parallel execution behavior is known and documented.
- [ ] Resource cleanup is verified after the process exits.

## 7. Known Limitations

For every skipped, pending, blocked, flaky, or temporarily bypassed test, record:

```text
Test or group:
State:
Category:
Reason and evidence:
Impact on coverage:
Current mitigation:
Owner:
Next action:
Expiry or review date:
```

- [ ] No limitation is hidden by a generic suppression or ignored failure.
- [ ] Blocked tests are distinguished from intentional skips and from passing tests.
- [ ] A missing environment capability has a documented setup path or an explicit escalation.

## 8. Assessment Report

The final report includes:

- [ ] Status: READY, ESCALATION REQUIRED, BLOCKED, or INCONCLUSIVE.
- [ ] Command, runner, profile, revision, dependency state, and parallelism.
- [ ] Baseline metrics and the pass-rate calculation.
- [ ] Root-cause breakdown with evidence and actions.
- [ ] Reproduction matrix and validation runs.
- [ ] Product impact and separate test-infrastructure changes.
- [ ] Known limitations with owners and next actions.
- [ ] Remaining risk and recommendation for CI or release use.

## Final Gate

Mark the suite **READY** only when the configured threshold is met, results are parseable, failures are resolved or explicitly escalated, the integration assertion remains meaningful, and the required reproducibility checks pass. Use **INCONCLUSIVE** when metrics or evidence cannot be established; do not convert missing evidence into a pass.
