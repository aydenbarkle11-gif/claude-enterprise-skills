# JSON State Files

Models are less likely to inappropriately modify JSON files than Markdown files. The enterprise pipeline uses three JSON state files as machine-readable state, parallel to the human-readable Markdown artifacts. Markdown is for humans. JSON is for machines.

**State directory:** `.claude/enterprise-state/`

## 1. Pipeline State (`<slug>.json`)

Created at TRIAGE, updated at every stage transition. Single source of truth for pipeline progress.

```json
{
  "slug": "example-feature",
  "created": "2026-03-14T10:00:00Z",
  "tier": "medium",
  "mode": "subagent",
  "branch": "feat/example-feature",
  "stages": {
    "discover":  { "status": "complete", "artifact": "project-profile.md", "completed_at": "..." },
    "brainstorm": { "status": "complete", "artifact": "docs/designs/...-tdd.md", "completed_at": "..." },
    "plan":      { "status": "in_progress", "started_at": "..." },
    "contract":  { "status": "pending" },
    "build":     { "status": "pending" },
    "review":    { "status": "pending" },
    "forge":     { "status": "pending" },
    "verify":    { "status": "pending" },
    "compound":  { "status": "pending" }
  },
  "circuit_breakers": {
    "forge_iterations": 0,
    "forge_max": 5,
    "forge_per_check_failures": {},
    "debug_fix_attempts": 0,
    "debug_max": 3
  }
}
```

**Update rules:**
- At stage START: set `"status": "in_progress"`, add `"started_at"`
- At stage COMPLETE: set `"status": "complete"`, add `"completed_at"` and `"artifact"` path
- At stage FAIL: set `"status": "failed"`, add `"failed_at"` and `"failure_reason"`
- Circuit breaker counts: updated by forge/debug skills, persist across sessions

**Stage transition command:**
```bash
node -e "
  const fs = require('fs');
  const f = '.claude/enterprise-state/<slug>.json';
  const s = JSON.parse(fs.readFileSync(f));
  s.stages.<completed_stage>.status = 'complete';
  s.stages.<completed_stage>.completed_at = new Date().toISOString();
  s.stages.<completed_stage>.artifact = '<artifact_path>';
  s.stages.<next_stage>.status = 'in_progress';
  s.stages.<next_stage>.started_at = new Date().toISOString();
  fs.writeFileSync(f, JSON.stringify(s, null, 2));
"
```

## 2. Postcondition Registry (`<slug>-postconditions.json`)

Created by `enterprise-contract` alongside the Markdown contract. Updated by `enterprise-build` as tests go RED → GREEN. Tamper-resistant checklist — must run tests and verify before flipping `"passes"` to `true`.

```json
{
  "contract": "docs/contracts/...-contract.md",
  "locked_at": "2026-03-14T10:40:00Z",
  "postconditions": [
    { "id": "PC-A1", "text": "...", "test_file": "...", "test_name": "...", "passes": false, "last_verified": null }
  ],
  "invariants": [
    { "id": "INV-1", "text": "All queries scoped to $TENANT_FIELD", "passes": false, "last_verified": null }
  ]
}
```

**Update rules:**
- `enterprise-contract` creates this file when the contract is LOCKED
- `enterprise-build` sets `"passes": true` ONLY after test runner output confirms pass
- `enterprise-forge` adds new entries when bugs are recycled as new PCs
- Never delete entries — only add or update `"passes"` status

## 3. Verification Log (`<slug>-verification.json`)

Append-only audit trail. Prevents "verification amnesia" where a model retries verification without fixing the issue.

```json
{
  "verifications": [
    {
      "type": "verify",
      "timestamp": "...",
      "checks": {
        "test_suite": { "result": "PASS", "passed": 47, "failed": 0 },
        "postcondition_trace": { "result": "PASS", "mapped": 12, "total": 12 },
        "regression": { "result": "PASS", "new_failures": 0 },
        "build": { "result": "SKIP" },
        "diff_classification": { "result": "PASS", "drift_files": [] },
        "imports": { "result": "PASS" },
        "debug_artifacts": { "result": "PASS" }
      },
      "overall": "PASS"
    }
  ]
}
```

**Update rules:**
- `enterprise-verify` appends after running all 7 checks
- `enterprise-harness` appends after running all 10 checks
- Never overwrite — always append
