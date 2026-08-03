# Decision Framework: Failure Categorization and Fix Prioritization

## Contents

- [Guiding questions](#guiding-questions)
- [Decision tree](#decision-tree)
- [Failure categories](#failure-categories)
- [Fix order](#fix-order)
- [Escalation](#escalation)
- [Evidence record](#evidence-record)

## Guiding Questions

Use evidence in this order:

1. What exactly failed, and what behavior was the test trying to verify?
2. Can the failure be reproduced in isolation, in a clean environment, and with the configured parallelism?
3. Which boundary failed: test setup, environment, dependency, timing, or product behavior?
4. Does the proposed fix preserve the integration boundary and the strength of the assertion?
5. What is the smallest observation that would disprove the current hypothesis?

Do not classify a failure from an exception name alone. A timeout may be a product regression, a dependency outage, a deadlock, or a test that waits on an invalid condition.

## Decision Tree

```text
START: Integration test failure
  |
  +-- Is the failure reproducible?
  |     +-- No: compare clean, isolated, serial, and parallel runs.
  |     |       Investigate shared state, ordering, timing, and resource limits.
  |     +-- Yes: continue with the original evidence.
  |
  +-- Is a required environment capability missing or misconfigured?
  |     +-- Yes: ENVIRONMENT
  |     |       Make the prerequisite explicit or add a narrow test adapter/guard.
  |     +-- No: continue.
  |
  +-- Is the test arrangement or cleanup invalid or order-dependent?
  |     +-- Yes: SETUP / FIXTURE
  |     |       Isolate state, make fixtures deterministic, and verify teardown.
  |     +-- No: continue.
  |
  +-- Is required data or an external dependency absent or incompatible?
  |     +-- Yes: DATA / DEPENDENCY
  |     |       Use controlled data or verify the dependency contract and capability.
  |     +-- No: continue.
  |
  +-- Does the failure occur only with concurrency, eventual consistency, or timing?
  |     +-- Yes: CONCURRENCY / TIMING
  |     |       Synchronize on observable state and isolate shared resources.
  |     +-- No: continue.
  |
  +-- Does the observed result violate a requirement, invariant, schema, or contract?
  |     +-- Yes: PRODUCT DEFECT
  |     |       Keep the assertion, fix or escalate the product behavior.
  |     +-- No: UNKNOWN
  |             Gather one discriminating observation before changing code.
```

## Failure Categories

### Environment

**Signals**

- A required service, port, credential scope, file, certificate, feature flag, clock, locale, or runtime capability is unavailable.
- The test fails before reaching the behavior under test.
- The same test passes in the supported environment but fails in an incomplete one.

**Discriminating checks**

- Run the prerequisite health check independently.
- Compare the effective configuration and dependency versions with the supported profile.
- Verify that the test has the required permissions without printing secrets.

**Preferred response**

- Document the prerequisite and fail early with an actionable message.
- Add a narrow adapter only when it is behaviorally equivalent and the target boundary remains covered.
- Mark the test blocked only when the capability cannot be supplied or faithfully emulated.

**Avoid**

- Catching every exception and treating the test as passed.
- Silently switching to a different service, data source, or configuration.
- Adding test-only branches to product behavior without an explicit design decision.

### Setup / Fixture

**Signals**

- The result depends on test order, a previous test, mutable global state, or incomplete cleanup.
- A fixture creates invalid state or assumes a record that it never provisions.
- A failure disappears after rerunning the whole suite or restarting the process.

**Discriminating checks**

- Run the test alone and after the suspected predecessor.
- Run it twice in a fresh process and inspect created resources after teardown.
- Execute with a randomized or reversed order if the runner supports it.

**Preferred response**

- Make setup explicit and deterministic.
- Scope temporary resources to the test and clean them in a guaranteed teardown path.
- Replace shared mutable fixtures with isolated builders or immutable inputs.

**Avoid**

- Reordering the suite solely to hide the dependency.
- Retrying before checking cleanup and shared state.
- Increasing fixture scope when a smaller scope is sufficient.

### Data / Dependency

**Signals**

- Seed data, schema, identity, queue, endpoint, or external contract is absent or incompatible.
- A dependency returns an empty, stale, malformed, or unauthorized response.
- The test assumes a specific identifier or record that is not part of its owned fixture.

**Discriminating checks**

- Verify the dependency contract and effective version.
- Query or inspect only the data required to prove the precondition; do not expose secrets or unrelated data.
- Reproduce with a controlled fixture or a documented dependency stub at the same boundary.

**Preferred response**

- Provision deterministic test data where the suite owns the dependency.
- Use capability-based discovery only when the dependency is intentionally shared and the selected data is validated.
- Fail with a clear precondition error when the dependency cannot satisfy the contract.

**Avoid**

- Hardcoding identities, timestamps, record counts, or environment-specific values without ownership.
- Replacing a real integration assertion with a unit-level mock.
- Mutating a shared environment without cleanup or ownership.

### Concurrency / Timing

**Signals**

- Failure appears only in parallel runs, under load, or near a timeout.
- The test assumes immediate visibility after a write or uses a fixed sleep.
- Logs show races, duplicate resource names, lock contention, or eventual consistency.

**Discriminating checks**

- Compare serial and parallel runs with the same inputs.
- Replace a fixed delay temporarily with polling of an observable condition and a bounded timeout.
- Give each run isolated resource names and inspect competing operations.

**Preferred response**

- Synchronize on a domain event, state transition, or other observable condition.
- Isolate resources and make operations idempotent where appropriate.
- Keep timeout values tied to a documented service contract, not to a machine-specific guess.

**Avoid**

- Increasing all timeouts or adding retries without identifying the boundary.
- Disabling parallel execution for the whole suite to mask one shared resource.
- Treating a flaky pass as evidence that the product is correct.

### Product Defect

**Signals**

- The product returns a result that contradicts a documented requirement, invariant, schema, or public contract.
- The test reaches the intended integration boundary and has valid setup and dependencies.
- The failure is reproducible with a controlled input and independent of the test runner.

**Discriminating checks**

- Re-run with a minimal controlled input and compare the observed result with the contract.
- Verify the assertion and test data against the current specification.
- Check adjacent tests or a direct boundary observation without weakening the failing assertion.

**Preferred response**

- Keep the failing test active and report the defect with evidence and impact.
- Fix the product behavior when authorized, then rerun the original test and nearby coverage.
- If a temporary workaround is unavoidable, document exactly which coverage is lost, who owns removal, and the expiry condition.

**Avoid**

- Changing the expected result to match the implementation without a specification change.
- Skipping the test or replacing the assertion with a weaker smoke check.
- Calling a product defect an environment problem merely because it is inconvenient to reproduce.

### Unknown

Use this category when evidence is insufficient or contradictory. Record the current hypothesis and choose one cheap observation that distinguishes it from the nearest alternative. Do not make a broad refactor while the controlling layer is unknown.

## Fix Order

When several failures exist, use this order unless evidence changes the priority:

1. Establish prerequisites and collect a clean baseline.
2. Remove setup, cleanup, and shared-state faults.
3. Repair deterministic data and dependency contracts.
4. Isolate concurrency and timing behavior.
5. Address product defects and contract changes.
6. Re-run the complete suite and review residual risk.

The order is a diagnostic aid, not permission to alter a lower layer when the evidence already proves a product defect.

## Escalation

Escalate when:

- product behavior, schema, or a public contract must change;
- the test boundary cannot faithfully provide a required capability;
- the failure remains nondeterministic after isolation;
- a workaround weakens the behavior being verified or has no removal owner and expiry condition; or
- shared state or test infrastructure risk affects a material part of the suite.

Include the failing test, original evidence, reproduction matrix, attempted test-side corrections, product impact, and the next owner action.

## Evidence Record

Use one entry per failure or tightly related failure group:

```text
Test or group:
Behavior under test:
Status: FAIL | BLOCKED | FLAKY | PASS AFTER FIX
Environment and revision:
Reproduction matrix: isolated / full / serial / parallel / clean process
Observed error or mismatch:
Root-cause category:
Evidence supporting the category:
Smallest discriminating check:
Test-side action:
Product-side action or escalation:
Validation result:
Known limitation, owner, and expiry:
```
