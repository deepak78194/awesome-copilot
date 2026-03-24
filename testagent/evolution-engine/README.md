# Evolution Engine — Self-Learning Multi-Agent

> **Metaphor:** A biological organism that evolves — the team's DNA (lessons + memories) improves with every generation of work.

## Pattern Summary

Every subagent is bound by a **self-learning contract** — they must report lessons (mistakes) and memories (durable insights) after every task. The orchestrator governs, deduplicates, and versions this knowledge. The team gets smarter with every run.

```
Load Knowledge → Explorer → Planner → [Coder + Contract] → [Reviewer + Contract] → Govern Knowledge → Summary
                                                                                         ↓
                                                                               .nucleus/lessons/
                                                                               .nucleus/memories/
```

## Agents

| File                                                 | Role                                     | Can Modify Files?        |
| ---------------------------------------------------- | ---------------------------------------- | ------------------------ |
| [nucleus.agent.md](nucleus.agent.md)                 | Orchestrator / Lead + Knowledge Governor | Manages `.nucleus/` only |
| [genome-planner.agent.md](genome-planner.agent.md)   | Knowledge-aware Planner                  | No                       |
| [genome-coder.agent.md](genome-coder.agent.md)       | Coder with learning contract             | Yes                      |
| [genome-reviewer.agent.md](genome-reviewer.agent.md) | Reviewer + lesson compliance checker     | No                       |
| [genome-explorer.agent.md](genome-explorer.agent.md) | Knowledge-aware Explorer                 | No                       |

## When to Use

- Long-running projects spanning many sessions
- Mistakes are expensive and must not be repeated
- Architecture decisions need to be documented and versioned
- You want the agent team to improve over time
- Knowledge should transfer between different team members (agents)

## Key Characteristics

- Every subagent returns `LessonsSuggested`, `MemoriesSuggested`, `ReasoningSummary`
- Knowledge is versioned: `PatternId`, `PatternVersion`, `Status`
- Conflicting patterns are resolved — two active patterns cannot disagree
- Blocked patterns are never applied without user confirmation
- Pre-write dedup — existing artifacts are updated, not duplicated
- Supports both parallel and orchestrated execution modes

## Knowledge Stores

```
.nucleus/
├── lessons/
│   ├── LESSON-001-auth-middleware-order.md
│   ├── LESSON-002-test-isolation.md
│   └── ...
└── memories/
    ├── MEM-001-jwt-preferred-over-sessions.md
    ├── MEM-002-api-versioning-strategy.md
    └── ...
```

## Trade-offs

| Strength                                        | Weakness                                       |
| ----------------------------------------------- | ---------------------------------------------- |
| Knowledge accumulates — team gets smarter       | Memory management overhead per task            |
| Documented mistakes are not repeated            | Governance logic adds complexity               |
| Decisions are versioned and traceable           | Requires discipline to keep knowledge clean    |
| Supports both parallel and sequential execution | Initial runs have empty knowledge — cold start |
