<p align="center">
  <h1 align="center">Enterprise Pipeline for Claude Code</h1>
  <p align="center">
    <strong>Stop shipping code that breaks in prod.</strong><br>
    A 9-stage development pipeline that turns one-line prompts into production-grade software — with full TDD, adversarial testing, and mechanical verification.
  </p>
  <p align="center">
    <a href="#quick-start">Quick Start</a> &bull;
    <a href="#how-it-works">How It Works</a> &bull;
    <a href="#the-pipeline">The Pipeline</a> &bull;
    <a href="#installation">Installation</a> &bull;
    <a href="#hooks">Hooks</a>
  </p>
</p>

---

### The Problem

You say *"add user authentication"* and Claude writes code. Sometimes it's great. Sometimes it ships with SQL injection, missing tenant isolation, no tests, and debug `console.log` statements in production.

**Vibe coding is fast. Enterprise coding is safe. This pipeline gives you both.**

### The Solution

```
> /enterprise add user authentication with JWT and role-based access

ENTERPRISE PIPELINE — TRIAGE
═══════════════════════════════════════════════════════
  Tier:   MEDIUM — new auth system, 5+ files
  Path:   FULL — discover → contract → build → review → forge → verify
═══════════════════════════════════════════════════════

ENTERPRISE PIPELINE — Stage 0: DISCOVER
  ✓ Stack: Python/Django 4.2 + PostgreSQL
  ✓ Tests: pytest (143 passing)
  ✓ Auth:  none detected — greenfield
  ✓ Multi-tenancy: organization_id
  → stack-profile.json written

ENTERPRISE PIPELINE — Stage 3: CONTRACT
  PC-1: POST /api/auth/register creates user with hashed password
  PC-2: POST /api/auth/login returns JWT with user_id + org_id
  PC-3: @require_auth decorator rejects requests without valid JWT
  PC-4: @require_role('admin') blocks non-admin users
  PC-5: Every new endpoint scopes to organization_id
  → Contract LOCKED ✓

ENTERPRISE PIPELINE — Stage 4: BUILD (TDD)
  PC-1: Write test → RED ✗ → Write code → GREEN ✓
  PC-2: Write test → RED ✗ → Write code → GREEN ✓
  PC-3: Write test → RED ✗ → Write code → GREEN ✓
  PC-4: Write test → RED ✗ → Write code → GREEN ✓
  PC-5: Write test → RED ✗ → Write code → GREEN ✓

ENTERPRISE PIPELINE — Stage 6: FORGE (Adversarial)
  M1 Import Resolution .... PASS
  M2 Uncommitted Files .... PASS
  M3 Dead Exports ......... PASS
  M4 Contract Crosscheck .. PASS
  M5 Debug Artifacts ...... PASS
  M6 Tenant Isolation ..... PASS
  M7 Concurrency .......... PASS
  → FORGED ✓

ENTERPRISE PIPELINE — Stage 7: VERIFY
═══════════════════════════════════════════════════════
  Check 1 — Test Suite:          PASS (148 passed, 0 failed)
  Check 2 — Postcondition Trace: PASS (5/5 verified)
  Check 3 — Regression Check:    PASS (no regressions)
  Check 4 — Build Verification:  PASS
  Check 5 — Final Diff:          PASS (7 files, 0 drift)
  Check 6 — Import Resolution:   PASS (all imports resolve)
  Check 7 — Debug Artifacts:     PASS (none found)
  ─────────────────────────────────────────────────────
  OVERALL: PASS ✓
═══════════════════════════════════════════════════════

ENTERPRISE PIPELINE — COMPLETE
  5 postconditions verified with TDD
  148 tests passing, 0 regressions
  7 files changed, 0 scope drift
  Ready to ship.
```

**One command. Full TDD. Adversarial review. Mechanical verification. Zero trust.**

---

## Quick Start

```bash
# Install skills (available in all your repos)
cp -r skills/* ~/.claude/skills/

# In any project:
claude
> /enterprise-discover          # profiles your stack (once per project)
> /enterprise add payments API  # builds it with the full pipeline
```

That's it. The pipeline auto-detects your stack, test framework, auth patterns, database, and conventions.

---

## How It Works

### 1. Discover Your Stack

`/enterprise-discover` scans your codebase with parallel agents and produces structured JSON:

```
.claude/enterprise-state/
├── stack-profile.json      ← structure, commands, conventions
├── stack-traps.json        ← type mismatches, schema gotchas
└── stack-best-practices.json  ← framework-specific guidance
```

Every downstream skill reads these profiles. **No hardcoded paths. No hardcoded commands.** The pipeline works on Express, Django, Rails, Go, Rust — anything with tests and git.

### 2. Choose Your Path

| Path | When to Use | Stages |
|------|-------------|--------|
| **Quick** | Typos, config changes, 1-liners | Contract → Build → Verify |
| **Standard** | Clear fixes, 2-5 files | Contract → Build → Verify |
| **Full** | New features, refactors, 5+ files | All 9 stages |
| **Critical** | Production is broken | Contract → Build → Verify → Deploy |

The pipeline auto-selects the path based on complexity. Override with `--full`, `--quick`, etc.

### 3. Ship with Confidence

Every change goes through:
- **Mechanical contract** — testable postconditions before any code is written
- **Strict TDD** — failing test first, then code, then green. No exceptions.
- **Dual-stage review** — spec compliance, then code quality (separate concerns)
- **Adversarial forge** — 5 attack lenses + 7 mechanical checks
- **Evidence-based verification** — paste test output or don't claim done

---

## The Pipeline

```
                    ┌─────────────┐
                    │  DISCOVER   │  Profile your stack
                    └──────┬──────┘
                           │
                    ┌──────▼──────┐
                    │  BRAINSTORM │  Design the approach
                    └──────┬──────┘
                           │
                    ┌──────▼──────┐
                    │    PLAN     │  Granular implementation steps
                    └──────┬──────┘
                           │
                    ┌──────▼──────┐
                    │  CONTRACT   │  Testable postconditions
                    └──────┬──────┘
                           │
               ┌───────────▼───────────┐
               │        BUILD          │  RED → GREEN → RED → GREEN
               │   (strict TDD only)   │  No code without failing test
               └───────────┬───────────┘
                           │
                    ┌──────▼──────┐
                    │   REVIEW    │  Spec compliance → Code quality
                    └──────┬──────┘
                           │
               ┌───────────▼───────────┐
               │        FORGE          │  Adversarial testing
               │  (bugs recycle back   │  5 lenses + 7 mechanical checks
               │   to CONTRACT)        │  3-fail circuit breaker
               └───────────┬───────────┘
                           │
                    ┌──────▼──────┐
                    │   VERIFY    │  7 evidence checks
                    └──────┬──────┘
                           │
                    ┌──────▼──────┐
                    │  COMPOUND   │  Capture what you learned
                    └─────────────┘
```

### Stage Details

| Stage | Skill | What It Does |
|-------|-------|-------------|
| 0 | `/enterprise-discover` | Profiles stack, detects auth/tenancy/conventions, produces JSON |
| 1 | `/enterprise-brainstorm` | Turns ideas into Technical Design Documents |
| 2 | `/enterprise-plan` | Creates step-by-step implementation with exact file paths |
| 3 | `/enterprise-contract` | Mechanical postconditions — every one becomes a test |
| 4 | `/enterprise-build` | Strict TDD. Write test, see RED, write code, see GREEN |
| 5 | `/enterprise-review` | Stage 1: spec compliance. Stage 2: code quality. Never mixed. |
| 6 | `/enterprise-forge` | 5 adversarial lenses + M1-M7 mechanical checks |
| 7 | `/enterprise-verify` | 7 evidence checks with `verify.sh` script |
| 8 | `/enterprise-compound` | Captures institutional knowledge for the team |

### For Bug Fixes

```bash
> /enterprise-debug users report wrong totals on dashboard
```

4-phase systematic debugging: Investigate → Blast Radius Scan → Root Cause → TDD Fix. Finds the root cause, not the symptom. Scans sibling functions for the same class of bug. 3-fail circuit breaker prevents fix-forward loops.

---

## Installation

### Option A: All repos (recommended)

```bash
# Skills — available in every project
cp -r skills/* ~/.claude/skills/

# Hooks — per project (see Hooks section below)
```

### Option B: Single project

```bash
cp -r skills/* your-project/.claude/skills/
cp -r hooks/*.sh your-project/.claude/hooks/
chmod +x your-project/.claude/hooks/*.sh
# Merge hooks/settings.json into your-project/.claude/settings.json
```

### First Run

```bash
claude
> /enterprise-discover    # profiles your codebase (30 seconds)
> /enterprise             # start building
```

---

## Hooks

Optional enforcement scripts that make the pipeline mechanical. Copy to `.claude/hooks/` in any project.

| Hook | What It Does |
|------|-------------|
| `require-gate-sequence.sh` | Blocks source edits until a planning/debugging skill is invoked |
| `require-tdd-before-source-edit.sh` | Blocks source edits without recent passing tests |
| `suggest-skill.sh` | Suggests relevant skills when editing files |
| `protect-files.sh` | Blocks edits to `.env` and other sensitive files |
| `mark-test-run.sh` | Records when tests pass (feeds TDD enforcement) |
| `mark-skill-invoked.sh` | Records skill invocations (feeds gate sequence) |

A template `settings.json` wires all hooks together. Merge it into your `.claude/settings.json`.

The hooks detect test runners across stacks: Jest, Vitest, pytest, RSpec, `go test`, `cargo test`, `dotnet test`, `mix test`, and PHPUnit.

---

## Supported Stacks

The pipeline works with **any stack** that has tests and git:

| Stack | Test Framework | Status |
|-------|---------------|--------|
| Node.js / Express | Jest, Vitest, Mocha | Tested |
| Python / Django | pytest, unittest | Tested |
| Python / FastAPI | pytest | Tested |
| Ruby / Rails | RSpec, Minitest | Supported |
| Go | `go test` | Supported |
| Rust | `cargo test` | Supported |
| Java / Spring | JUnit, TestNG | Supported |
| C# / .NET | `dotnet test` | Supported |
| Elixir / Phoenix | ExUnit | Supported |
| PHP / Laravel | PHPUnit | Supported |

"Tested" = used in production. "Supported" = auto-detection works, awaiting production validation.

---

## What Makes This Different

| Feature | Vibe Coding | This Pipeline |
|---------|-------------|---------------|
| Test coverage | Maybe | Every postcondition has a test |
| Security review | Hope | Adversarial forge with 5 attack lenses |
| Tenant isolation | Forgot | Mechanical check on every query |
| Debug artifacts | Ships to prod | Caught and blocked |
| Scope creep | Always | Drift detection in every diff |
| "It works" claim | Trust me | Paste the test output or it didn't happen |

---

## Requirements

- [Claude Code CLI](https://docs.anthropic.com/en/docs/claude-code)
- Git repository
- A test framework installed for your stack

---

## License

MIT
