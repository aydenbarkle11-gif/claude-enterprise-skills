# Enterprise Pipeline Demo — VHS Tape
# Render with: vhs demo.tape

Output demo.gif

Set Shell "bash"
Set FontSize 14
Set Width 900
Set Height 600
Set Theme "Dracula"
Set Padding 20
Set TypingSpeed 40ms

Sleep 500ms

Type "# Enterprise Pipeline for Claude Code"
Enter
Sleep 300ms
Type "# Let's build a feature from scratch"
Enter
Sleep 1s

Type "claude"
Enter
Sleep 2s

# Simulated Claude Code session
Type "/enterprise add user authentication with JWT tokens and role-based access"
Enter
Sleep 1.5s

# Triage output
Type ""
Sleep 500ms
Set TypingSpeed 0
Type "ENTERPRISE PIPELINE — TRIAGE"
Enter
Type "═══════════════════════════════════════════════"
Enter
Type "  Tier:   MEDIUM — new auth system, 5+ files"
Enter
Type "  Path:   FULL — brainstorm → plan → contract → build → review → forge → verify"
Enter
Type "  Mode:   Solo (auto)"
Enter
Type "═══════════════════════════════════════════════"
Enter
Sleep 2s

# Discover
Type ""
Enter
Type "ENTERPRISE PIPELINE — Stage 0: DISCOVER"
Enter
Type "  ✓ Stack: Python/Django 4.2 + PostgreSQL"
Enter
Type "  ✓ Tests: pytest (143 passing)"
Enter
Type "  ✓ Auth:  none detected — greenfield"
Enter
Type "  ✓ Multi-tenancy: organization_id"
Enter
Type "  → stack-profile.json written"
Enter
Sleep 2s

# Contract
Type ""
Enter
Type "ENTERPRISE PIPELINE — Stage 3: CONTRACT"
Enter
Type "  PC-1: POST /api/auth/register creates user with hashed password"
Enter
Type "  PC-2: POST /api/auth/login returns JWT with user_id + org_id"
Enter
Type "  PC-3: @require_auth decorator rejects requests without valid JWT"
Enter
Type "  PC-4: @require_role('admin') blocks non-admin users"
Enter
Type "  PC-5: Every new endpoint scopes to organization_id"
Enter
Type "  INV-1..7: All invariants applied"
Enter
Type "  → Contract LOCKED"
Enter
Sleep 2s

# Build — TDD cycle
Type ""
Enter
Type "ENTERPRISE PIPELINE — Stage 4: BUILD (TDD)"
Enter
Sleep 500ms
Set TypingSpeed 20ms
Type "  PC-1: Write test... "
Sleep 300ms
Type "RED ✗ "
Sleep 300ms
Type "→ Write code... "
Sleep 300ms
Type "GREEN ✓"
Enter
Type "  PC-2: Write test... "
Sleep 300ms
Type "RED ✗ "
Sleep 300ms
Type "→ Write code... "
Sleep 300ms
Type "GREEN ✓"
Enter
Type "  PC-3: Write test... "
Sleep 300ms
Type "RED ✗ "
Sleep 300ms
Type "→ Write code... "
Sleep 300ms
Type "GREEN ✓"
Enter
Type "  PC-4: Write test... "
Sleep 300ms
Type "RED ✗ "
Sleep 300ms
Type "→ Write code... "
Sleep 300ms
Type "GREEN ✓"
Enter
Type "  PC-5: Write test... "
Sleep 300ms
Type "RED ✗ "
Sleep 300ms
Type "→ Write code... "
Sleep 300ms
Type "GREEN ✓"
Enter
Sleep 1s

Set TypingSpeed 0

# Review
Type ""
Enter
Type "ENTERPRISE PIPELINE — Stage 5: REVIEW"
Enter
Type "  Stage 1 — Spec Compliance:  5/5 postconditions verified  ✓"
Enter
Type "  Stage 2 — Code Quality:     8/8 checks passed            ✓"
Enter
Type "  → REVIEW PASSED"
Enter
Sleep 1.5s

# Forge
Type ""
Enter
Type "ENTERPRISE PIPELINE — Stage 6: FORGE (Adversarial)"
Enter
Type "  M1 Import Resolution .... PASS"
Enter
Type "  M2 Uncommitted Files .... PASS"
Enter
Type "  M3 Dead Exports ......... PASS"
Enter
Type "  M4 Contract Crosscheck .. PASS"
Enter
Type "  M5 Debug Artifacts ...... PASS"
Enter
Type "  M6 Tenant Isolation ..... PASS"
Enter
Type "  M7 Concurrency .......... PASS"
Enter
Type "  5 Adversarial Lenses .... PASS (0 bugs found)"
Enter
Type "  → FORGED"
Enter
Sleep 1.5s

# Verify
Type ""
Enter
Type "ENTERPRISE PIPELINE — Stage 7: VERIFY"
Enter
Type "═══════════════════════════════════════════════"
Enter
Type "  Check 1 — Test Suite:          PASS (148 passed, 0 failed)"
Enter
Type "  Check 2 — Postcondition Trace: PASS (5/5 verified)"
Enter
Type "  Check 3 — Regression Check:    PASS (no regressions)"
Enter
Type "  Check 4 — Build Verification:  PASS"
Enter
Type "  Check 5 — Final Diff:          PASS (7 files, 0 drift)"
Enter
Type "  Check 6 — Import Resolution:   PASS (all imports resolve)"
Enter
Type "  Check 7 — Debug Artifacts:     PASS (none found)"
Enter
Type "  ─────────────────────────────────────────────"
Enter
Type "  OVERALL: PASS ✓  — all checks green"
Enter
Type "═══════════════════════════════════════════════"
Enter
Sleep 2s

Type ""
Enter
Type "ENTERPRISE PIPELINE — COMPLETE"
Enter
Type "  5 postconditions verified with TDD"
Enter
Type "  148 tests passing, 0 regressions"
Enter
Type "  7 files changed, 0 scope drift"
Enter
Type "  Ready to ship."
Enter

Sleep 3s
