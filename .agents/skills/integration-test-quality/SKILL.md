---
name: integration-test-quality
description: Evaluate ASP.NET MVC integration test suites, diagnose failures by root cause, and propose test-side fixes while maintaining product code integrity. Use when assessing unit/integration test health, debugging test failures across .NET projects, or establishing repeatable test quality criteria.
---

# Integration Test Quality Assessor (ITQA)

Systematic evaluation framework for assessing integration test suites in ASP.NET MVC projects. This skill provides decision trees, quality criteria, and proven patterns for diagnosing and fixing test failures without compromising product code.

## Core Purpose

Transform ad-hoc test troubleshooting into repeatable, architecture-validated methodology. When facing test failures, ITQA provides structured root-cause analysis and fix prioritization.

## When to Use This Skill

**Primary scenarios:**
- Evaluating integration test suite health (smoke tests, characterization tests, mapping baseline tests)
- Debugging test failures in ASP.NET MVC 4.x projects
- Assessing whether tests can run in CI/CD environments (vstest.console.exe, Visual Studio Test Explorer)
- Determining if test failures require product code changes or can be fixed at test layer

**Secondary scenarios:**
- Establishing quality gates for test acceptance (pass rate thresholds, known limitation documentation)
- Creating replicable test patterns for new test suites
- Documenting architectural decisions for test infrastructure

## Quick Start: Three-Phase Assessment

### Phase 1: Baseline (15 minutes)
1. Run full test suite: `vstest.console.exe [test-assembly] /Logger:trx`
2. Capture metrics: total count, pass count, fail count, skip count
3. Calculate pass rate: `(pass + skip) / total`
4. **Gate**: ≥95% pass rate → proceed to Phase 2. <95% → proceed to diagnosis

### Phase 2: Diagnosis (30-60 minutes)
1. For each failing test, run individually to isolate root cause
2. Categorize failures: infrastructure | data | logic | product-defect
3. For each category, reference [Decision Framework](references/decision-framework.md)
4. Propose test-side fix first, validate with ≥1 run
5. Escalate to product code only if test-side impossible

### Phase 3: Validation (30 minutes)
1. Implement all proposed fixes
2. Run full suite ≥3 times independently
3. Validate reproducibility (same pass rate across runs)
4. Execute [Quality Checklist](references/quality-checklist.md)
5. Generate assessment report with root cause log

## Decision Framework at a Glance

See [Decision Framework](references/decision-framework.md) for full decision tree. Quick reference:

| Failure Category | Root Cause Pattern | Test-Side Fix | Product Code Risk |
|---|---|---|---|
| **Infrastructure** | MapPath null, HttpContext missing | Try-catch fallback, environment guard | ✅ Low (passive only) |
| **Data** | Test identity not in DB, setup tables absent | DB-driven resolver, dynamic discovery | ✅ Low (query only) |
| **Logic** | Exception in business rule, invalid state | Test context override, mock factory | ✅ Low (test layer only) |
| **Product Defect** | Type mismatch (NHibernate), schema drift | SQL fallback (temporary), flag for sprint | ⚠️ Medium (future fix) |

## Quality Checklist

All assessments must pass this checklist. See [Quality Checklist](references/quality-checklist.md) for detailed validation steps.

- [ ] **Pass Rate**: ≥95% (or clearly documented exceptions per failure category)
- [ ] **Product Code Impact**: 0 behavioral changes (try-catch only, no branching)
- [ ] **Reproducibility**: Same result across ≥3 independent test runs
- [ ] **Root Cause**: Each failure identified to layer (infrastructure/data/logic/defect)
- [ ] **Known Issues**: All limitations explicitly documented (not hidden by Ignore/Skip)
- [ ] **Maintenance Burden**: Test code changes ≤20% of touched files
- [ ] **Documentation**: Architecture decisions, fallback patterns, escalation criteria logged

## Key Patterns from OnlineService_SG Assessment

This skill was derived from successful assessment of OnlineService_SG project (153 integration tests → 151 passing, 2 known-limitations).

### Pattern 1: Try-Catch Graceful Degradation
For environment-specific APIs (e.g., `HttpContext.Current.Server.MapPath`) that fail in test runners:

```csharp
try {
    path = HttpContext.Current?.Server.MapPath(virtualPath);
}
catch {
    path = ResolvePath(virtualPath);  // Fallback to environment-agnostic method
}
```

✅ Benefit: Single code path works in production AND test environments  
✅ Benefit: No product code behavioral change (fallback is silent)  
⚠️ Limitation: Fallback must be functionally equivalent  

**When to use**: 4 or more tests failing on same environmental constraint

### Pattern 2: DB-Driven Identity Discovery
For tests requiring valid database accounts (e.g., branch profiles, user roles):

1. Query SETUP_PERSONAL_ROLE and related tables for accounts matching required criteria
2. Extract roleOuCode, accountCode dynamically
3. Replace hardcoded test identities with discovered values
4. Validate ≥1 account exists in target environment

✅ Benefit: Tests adapt to actual database contents  
✅ Benefit: Eliminates hardcoded test data (source of fragility)  
✅ Benefit: Detects missing setup data early  

**When to use**: 3+ tests failing due to "account not found", "invalid credential"

### Pattern 3: Hosted MVC Scaffold Simulation
For controller-layer tests requiring synthetic HttpContext with proper routing:

```csharp
ReadOnlyHttpContextFactory.SetupHttpContext(
    ReadOnlyIdentityFactory.CreateBranchPrincipal(roleOuCode));
var controller = new YourController { 
    ControllerContext = CreateControllerContext() 
};
```

✅ Benefit: Simulates BaseController initialization, routing, principal injection  
✅ Benefit: Isolates controller logic from hosting environment  

**When to use**: 5+ tests failing on controller instantiation or User.Identity properties

### Pattern 4: SQL Fallback for Entity Mapping Defects
When NHibernate entity materialization fails (type mismatches), use raw SQL:

```csharp
// Instead of: session.CreateCriteria(typeof(Entity)).List<Entity>()
// Use: session.CreateSQLQuery("SELECT * FROM TABLE LIMIT 1").List()
```

✅ Benefit: Test executes, mapping defect is surfaced (not hidden)  
✅ Benefit: Preserves test coverage signal while documenting product issue  
⚠️ Limitation: Reduces mapping validation strength (temporary workaround only)  

**When to use**: 1-2 tests failing on type conversion (document as known limitation)

## Escalation Criteria

**Escalate to Architecture Team If:**
- Product code behavioral changes required (not just try-catch)
- Type/mapping mismatches affect >5% of entities
- Environmental constraints cannot be satisfied in test layer
- Multiple infrastructure workarounds needed (sign of deeper architectural debt)

**Escalate to Product Engineering If:**
- NHibernate mapping defects (type mismatches, schema drift)
- Database schema changes needed
- API contract violations in product code
- Performance regressions detected during test runs

**Do NOT Escalate (Test-Side Sufficient) If:**
- Try-catch fallback can handle environmental constraint
- DB-driven resolver can discover valid test identities
- Mock/override can isolate test logic layer
- SQL fallback is acceptable temporary measure (with documentation)

## Output Format

All assessments must produce this structure:

### Executive Summary
```markdown
## Assessment: [Project Name]

**Status**: ✅ READY FOR CI/CD | ⚠️ ESCALATION REQUIRED | ❌ BLOCKER

| Metric | Value |
|--------|-------|
| Total Tests | X |
| Passing | X (Y%) |
| Failing | X (Y%) |
| Skipped | X (Y%) |
| Root Causes | [List by category] |
| Product Changes | [Count] try-catch only |
| Known Limitations | [Count] documented |

### Root Cause Breakdown
- **Infrastructure** (N tests): [Issue], [Fix Applied]
- **Data** (N tests): [Issue], [Fix Applied]
- **Logic** (N tests): [Issue], [Fix Applied]
- **Product Defect** (N tests): [Issue], [Stop-Gap Fix], [Future Action]

### Quality Gate Results
- [ ] Pass rate ≥95%
- [ ] Product code integrity maintained
- [ ] Root causes documented
- [ ] Known limitations explicit
- [ ] Reproducibility validated
```

### Detailed Report
- Per-test failure analysis (root cause, fix, validation result)
- Architecture decision log (why each pattern chosen)
- Test infrastructure code (base classes, factories, guards)
- Replication guide for future test suites
- Maintenance burden estimate

## References

- **[Decision Framework](references/decision-framework.md)**: Full decision tree for root-cause categorization and fix selection
- **[Quality Checklist](references/quality-checklist.md)**: Step-by-step validation criteria
- **[Test Patterns](references/test-patterns.md)**: Code examples for identity resolution, try-catch fallback, hosted scaffold

## Implementation Notes

For a new project assessment:

1. **Setup (5 min)**: Clone test infrastructure from OnlineService_SG if framework is ASP.NET MVC 4.x
   - Copy `ReadOnlyHttpContextFactory.cs`
   - Copy `ReadOnlyIdentityFactory.cs`
   - Copy `ReadOnlyDbEnvironmentGuard.cs`

2. **Run Baseline (5 min)**: Execute full suite once, capture pass/fail counts

3. **Diagnose (30-60 min)**: Use decision framework to categorize each failure

4. **Fix (15-45 min)**: Implement fixes per priority (infrastructure → data → logic → product defect)

5. **Validate (30 min)**: Run suite ≥3 times, confirm reproducibility

6. **Report (15 min)**: Fill out Executive Summary template, archive findings

**Expected effort**: 2-3 hours for 100-200 test suite with ≥90% baseline pass rate

---

*Last Updated: 2026-05-05 | Assessment Case Study: OnlineService_SG (153 tests, 151 passing)*
