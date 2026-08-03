# Test Patterns: Technology-Neutral Integration Fixtures

These patterns describe responsibilities and invariants, not a particular language, framework, runner, or infrastructure provider. Translate the pseudocode into the project's native test APIs and keep the integration boundary visible.

## Contents

- [Pattern 1: Environment Adapter](#pattern-1-environment-adapter)
- [Pattern 2: Deterministic Fixture](#pattern-2-deterministic-fixture)
- [Pattern 3: Context and Dependency Harness](#pattern-3-context-and-dependency-harness)
- [Pattern 4: Observable Synchronization](#pattern-4-observable-synchronization)
- [Pattern 5: Capability Guard](#pattern-5-capability-guard)
- [Pattern 6: Evidence-Preserving Workaround](#pattern-6-evidence-preserving-workaround)
- [Pattern 7: Flakiness Isolation](#pattern-7-flakiness-isolation)
- [Pattern Selection](#pattern-selection)

## Pattern 1: Environment Adapter

**Use when:** the production environment supplies a capability that the supported test environment cannot provide directly, such as a path resolver, clock, identity, network endpoint, or service process.

**Goal:** preserve the production path and make the test substitution explicit, narrow, and behaviorally equivalent.

```text
interface ResourceResolver:
    resolve(resourceName) -> Resource

productionResolver:
    resolve(resourceName):
        return nativeProductionResolution(resourceName)

testResolver:
    resolve(resourceName):
        return deterministicTestResolution(resourceName)

application:
    resolver = injectedResolverOrProductionDefault()
    resource = resolver.resolve(resourceName)
```

**Checks**

- The adapter is injected at a boundary rather than selected by a hidden test flag.
- The test verifies the same observable behavior after resolution.
- The production default is unchanged.
- Differences and unsupported capabilities are documented.

**Avoid:** catching every failure and silently switching to an unrelated resource or data source.

## Pattern 2: Deterministic Fixture

**Use when:** the test depends on records, files, messages, identities, or resources that may differ across environments.

**Goal:** own the minimum state needed by the test and remove it reliably.

```text
fixture = createFixture()
try:
    arrange(fixture)
    result = executeSystemBoundary(fixture.input)
    assertBehavior(result, fixture.expected)
finally:
    disposeFixture(fixture)
```

**Checks**

- Inputs are explicit and stable; no hidden dependency on a developer account, current time, or leftover state.
- Resource names are unique for the test or run.
- Cleanup is idempotent and runs after assertion failures.
- The fixture does not mutate shared data unless ownership and cleanup are explicit.
- The assertion checks the intended behavior rather than only resource creation.

**Variation:** when a shared environment is intentional, use capability discovery with a narrow predicate, validate the selected data, and report an actionable precondition failure when no valid data exists.

## Pattern 3: Context and Dependency Harness

**Use when:** the system boundary requires request metadata, identity, tenant, locale, clock, queue, storage, or a third-party service.

**Goal:** construct the smallest realistic context and clean it up between tests.

```text
context = harness.createContext(
    identity = testIdentity,
    tenant = isolatedTenant,
    clock = fixedClock,
    dependencies = configuredTestDependencies)
try:
    response = callBoundary(context, request)
    assertContract(response)
finally:
    harness.disposeContext(context)
```

**Checks**

- Every value required by the boundary is visible in setup.
- Test doubles are used only for dependencies outside the behavior being verified.
- A substitute has the same contract shape and failure semantics needed by the test.
- Context and global state are restored after the test.
- The test is not merely a unit test with integration labels.

## Pattern 4: Observable Synchronization

**Use when:** a write is followed by asynchronous processing, eventual consistency, a message, a job, or a remote state transition.

**Goal:** wait for an observable condition with a bounded deadline instead of sleeping for an arbitrary duration.

```text
deadline = now() + configuredTimeout
repeat:
    observed = readObservableState(key)
    if conditionIsSatisfied(observed):
        break
    if now() >= deadline:
        fail("Condition was not observed before the contract timeout")
    wait(configuredPollingInterval)
assertExpectedState(observed)
```

**Checks**

- The condition represents the contract the user cares about.
- Timeout and polling values are tied to a documented service expectation.
- Reads do not mutate state or create duplicate work.
- Timeout failures include the final observed state and correlation information.

**Avoid:** replacing a fixed sleep with an unbounded loop or retrying a product operation that is not idempotent.

## Pattern 5: Capability Guard

**Use when:** a test genuinely requires an unavailable capability, such as a licensed integration, private network, device, provider, or optional service.

**Goal:** distinguish blocked coverage from a passing test and make the missing prerequisite actionable.

```text
capability = inspectPrerequisite()
if not capability.available:
    markBlocked(
        reason = capability.reason,
        owner = capability.owner,
        nextAction = capability.setupInstructions)
else:
    runIntegrationAssertion()
```

**Checks**

- The guard runs before mutating the system under test.
- The result is reported as blocked or skipped according to the project's result model, not passed.
- The reason is specific and safe to log.
- The suite has a route to provision or enable the capability.
- Adjacent tests cover behavior that does not require the unavailable capability.

**Avoid:** using a guard for a flaky test, an unknown failure, or a missing fixture that the suite owns.

## Pattern 6: Evidence-Preserving Workaround

**Use when:** a non-target layer is known to be broken and a temporary bypass is required to keep a meaningful behavior test active.

**Goal:** preserve the signal while making lost coverage and removal work impossible to overlook.

```text
knownIssue = recordIssue(
    layer = "dependency adapter",
    impact = "mapping validation is not exercised",
    owner = "team",
    expiry = "date or release")

rawObservation = useTemporaryBoundaryObservation()
assertTargetBehavior(rawObservation)
attachKnownIssueToTest(knownIssue)
```

**Checks**

- The failing layer is proven and outside the behavior claimed by the test.
- The workaround keeps the target assertion meaningful.
- The report states exactly which coverage is lost.
- An owner and removal condition exist.
- A separate test or defect remains for the bypassed layer.

**Avoid:** using a fallback to turn a product contract violation into a pass or keeping a temporary workaround without an expiry review.

## Pattern 7: Flakiness Isolation

**Use when:** a test passes and fails across runs, order, machines, or parallelism modes.

**Goal:** identify the variable before changing the test.

```text
matrix = [
    isolatedCleanProcess,
    fullSuiteSerial,
    fullSuiteParallel,
    repeatedWithSameInputs]

for condition in matrix:
    result = runTest(condition)
    record(condition, result, logs, timing, resourceState)

compareResultsBy(
    order, parallelism, processLifetime, environment, data, timing)
```

**Checks**

- Inputs, revision, dependency versions, and environment are recorded for each run.
- The test is repeated enough to establish a pattern, not just one lucky pass.
- Shared resources, generated names, cleanup, and clock assumptions are inspected.
- A retry is not added until the transient boundary is named and bounded.

## Pattern Selection

Choose based on the first controlling boundary:

| Observation | Start with |
|---|---|
| Capability missing before the test reaches the product | Environment Adapter or Capability Guard |
| Test depends on records or resources not created by itself | Deterministic Fixture |
| Required request, identity, tenant, clock, or dependency context is absent | Context and Dependency Harness |
| Failure appears after asynchronous work or remote propagation | Observable Synchronization |
| A known non-target layer blocks meaningful behavior coverage | Evidence-Preserving Workaround |
| Result varies by order, parallelism, or process lifetime | Flakiness Isolation |

After applying a pattern, run the smallest focused test that can disprove the current hypothesis before expanding the change.
