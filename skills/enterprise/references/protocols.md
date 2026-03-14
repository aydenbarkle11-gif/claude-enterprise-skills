# Enterprise Protocols

## Approach Pivot Protocol

If the user changes their mind mid-pipeline (after PLAN or CONTRACT is written):

1. **Acknowledge**: "Understood — pivoting approach."
2. **Assess impact**: which artifacts are invalidated?
   - Changing intent → invalidates TDD, PLAN, CONTRACT (restart from BRAINSTORM)
   - Changing approach → invalidates PLAN, CONTRACT (restart from PLAN)
   - Changing scope → amend CONTRACT only (add/remove postconditions)
3. **Save current state**: `MEMORY: save — [slug] PIVOTED from [old] to [new], invalidated: [list]`
4. **Archive** invalidated artifacts: rename with `-v1` suffix, don't delete
5. **Restart** from the first invalidated stage

Never silently ignore a pivot. The user said something changed — trace the impact.

---

## Architectural Escalation Protocol

When a circuit breaker fires (3 failures on same check in FORGE, or 3 fix attempts in DEBUG):

1. **STOP all implementation work** — do not attempt fix #4
2. **Diagnose the pattern**:
   - Same test keeps failing → design assumption is wrong
   - Different tests keep failing → architecture doesn't support this feature
   - Build keeps failing → dependency or integration problem
3. **Present to user** with options:
   ```
   ARCHITECTURAL ESCALATION
   ════════════════════════
   Circuit breaker triggered: [which check, how many times]
   Pattern: [what keeps failing and why]

   Options:
   A. Redesign: go back to BRAINSTORM with the new constraint
   B. Simplify: reduce scope to avoid the architectural limitation
   C. Accept risk: document the limitation and ship with known gap
   D. Seek help: pause and escalate to [human/team]

   Recommendation: [A/B/C/D] because [reason]
   ```
4. **Wait for user decision** — do not proceed autonomously after an escalation

---

## Non-Standard Task Types

| Task Type | Pipeline Modification |
|-----------|----------------------|
| **CSS/styling only** | Skip FORGE M6 (tenant isolation), M7 (concurrency). Focus on build verification. |
| **Documentation only** | Skip BUILD TDD, skip FORGE mechanical checks. Quality gate: accuracy, completeness, clarity. |
| **Configuration change** | Micro tier. Skip BRAINSTORM. Contract = "setting X changes from Y to Z". |
| **Data migration/backfill** | Add DRY RUN: `BEGIN; [migration]; ROLLBACK;` first. Include rollback SQL in contract. |
| **Performance optimization** | Add BASELINE: measure before AND after. Contract PCs include performance numbers. |
| **Dependency upgrade** | Focus on VERIFY. Contract PCs: "all existing tests pass", "build succeeds", "no new deprecation warnings". |

---

## Greenfield Bootstrap

When the codebase has NO existing tests:

1. **Acknowledge**: "Greenfield test setup. Creating test infrastructure first."
2. **Create test config** if missing: `jest.config.js` or equivalent
3. **Create first test**: `test('infrastructure works', () => { expect(1+1).toBe(2); });`
4. **Run it**: verify test runner executes successfully
5. **Then proceed** with normal TDD sequence

---

## Completion Audit Report Template

```
═══════════════════════════════════════════════════════════
                    ENTERPRISE AUDIT REPORT
═══════════════════════════════════════════════════════════

## Task
[1-2 sentence description]

## Tier & Mode
[tier] | [mode] | Branch: [name]

## Artifacts
├── Profile:  project-profile.md
├── TDD:      docs/designs/YYYY-MM-DD-<slug>-tdd.md
├── Plan:     docs/plans/YYYY-MM-DD-<slug>-plan.md
├── Contract: docs/contracts/YYYY-MM-DD-<slug>-contract.md
├── Review:   docs/reviews/YYYY-MM-DD-<slug>-review.md
└── Solution: docs/solutions/YYYY-MM-DD-<slug>.md

## Plain Language Summary
[2-3 sentences]

## Contract Compliance
  PC-1: [text] .............. VERIFIED — [test name]
  Result: [N]/[N] postconditions met

## TDD Compliance
  RED→GREEN cycles: [N]
  Tests written before code: YES/NO
  All tests passing: [N] passed, 0 failed

## Forge Review
  Mechanical checks: [N]/7 passed
  Contract probes: [N]/[N] passed
  Bugs recycled: [N]

## Security
  Tenant isolation | Parameterized queries | Auth middleware

## Files Changed
  [git diff --stat]
═══════════════════════════════════════════════════════════
```
