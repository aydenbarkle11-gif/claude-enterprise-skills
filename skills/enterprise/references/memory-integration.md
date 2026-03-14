# Memory Integration

Context loss is the #1 killer of multi-stage pipelines. Every stage saves state so any agent — current or future — can resume from where work stopped. JSON state files provide the machine-readable checkpoint; memory provides semantic recall across projects.

## Memory Backend Detection

At pipeline start, detect available memory backends in this order:
1. **Memora MCP** — if `memory_create` / `memory_semantic_search` tools are available
2. **Muninn MCP** — if `muninn_remember` / `muninn_recall` tools are available
3. **Filesystem fallback** — always available: write state to `docs/handovers/` files

Use whichever is available. If none of the MCPs respond, use filesystem fallback without complaint. Throughout all `enterprise-*` skills, `MEMORY: save` and `MEMORY: recall` mean "use whichever backend is available."

## Save Points (Automatic at every stage transition)

```
Stage complete → MEMORY: save
  - Task slug, tier, mode
  - Current stage (which stage just completed)
  - Artifacts produced so far (file paths)
  - Key decisions made (with rationale)
  - Next stage to execute
  - Any blockers or open questions
```

## Recovery Protocol

1. **Check JSON state** first: `cat .claude/enterprise-state/<slug>.json`
2. **Check postcondition registry**: `cat .claude/enterprise-state/<slug>-postconditions.json`
3. **Check verification log**: `cat .claude/enterprise-state/<slug>-verification.json`
4. **Check memory**: `MEMORY: recall enterprise task [slug]`
5. **Check filesystem**: contracts, plans, reviews, TDDs
6. **Check git**: `git log --oneline -5`, `git diff --stat`
7. **Resume from first incomplete stage**
8. **Save recovery checkpoint** immediately

## What Gets Saved Per Stage

| Stage | What's Saved |
|-------|-------------|
| TRIAGE | Task description, tier, mode selection, rationale |
| BRAINSTORM | Key discoveries, user decisions from EXTRACT, connection map |
| PLAN | Task breakdown, parallelization decisions, estimated scope |
| CONTRACT | Postcondition list, consumer map, blast radius findings |
| BUILD | Progress (which PCs complete), blockers, test results |
| REVIEW | Findings, pass/fail status, items requiring re-work |
| FORGE | Mechanical check results, bugs recycled, probe findings |
| VERIFY | Evidence collected, final test output |
| COMPOUND | Solution document created, tags, cross-references |

## Cross-Agent Context Sharing

In Subagent/Swarm mode, memory is the shared brain:
- Builder agents save progress after each PC
- Reviewer agents read builder's context before reviewing
- Forge agents read contract + review findings before probing
- New agents spawned mid-task inherit full context from memory

**Rule:** If you're about to lose context, save EVERYTHING first. Use `/enterprise-compound` or write a handover doc.

## Memory Save Verification

After saving to an MCP backend:
1. **Save** the state
2. **Recall** to verify persistence
3. **If recall fails**: fall back to filesystem (`docs/handovers/YYYY-MM-DD-<slug>-checkpoint.md`)
4. **Log** in audit report: `Memory saves: [N] verified, [N] fallback`
