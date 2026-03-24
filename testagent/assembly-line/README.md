# Assembly Line — Sequential Pipeline

> **Metaphor:** A factory assembly line where each station completes its work before passing the product to the next station.

## Pattern Summary

Work flows through sequential **stations**: Explore → Plan → Implement (phase by phase) → Review (per phase). Each station writes its output to `.pipeline/` files. No station depends on conversation context — only on files.

```
Explorer → [.pipeline/research.md] → Planner → [.pipeline/plan.md] → Coder Phase 1 → Reviewer → Coder Phase 2 → Reviewer → ... → Report
```

## Agents

| File                                                   | Role                | Can Modify Files?               |
| ------------------------------------------------------ | ------------------- | ------------------------------- |
| [foreman.agent.md](foreman.agent.md)                   | Orchestrator / Lead | No — routes work only           |
| [station-planner.agent.md](station-planner.agent.md)   | Planner             | Creates `.pipeline/plan.md`     |
| [station-coder.agent.md](station-coder.agent.md)       | Coder / Implementer | Yes                             |
| [station-reviewer.agent.md](station-reviewer.agent.md) | Tester / Reviewer   | No — reads and verifies         |
| [station-explorer.agent.md](station-explorer.agent.md) | Explorer            | Creates `.pipeline/research.md` |

## When to Use

- Focused, single-domain task (tests, migrations, refactors)
- Phases naturally depend on each other sequentially
- Reproducibility matters — file-based state survives session restarts
- Simplicity over speed is preferred
- You need inspectable, resumable intermediate state

## Key Characteristics

- All state in `.pipeline/` — inspectable by humans and agents
- Strictly sequential phases — Phase N+1 waits for Phase N
- Reviewer validates after each phase before advancing
- Simple coordination — foreman calls 4 agents in order
- Session-resumable — restart from last completed phase

## Trade-offs

| Strength                                      | Weakness                                     |
| --------------------------------------------- | -------------------------------------------- |
| Simple to understand and debug                | No parallelism — phases are strictly linear  |
| File-based state is inspectable and resumable | Failure in one phase blocks all later phases |
| Minimal orchestration overhead                | Not designed for multi-domain objectives     |
| Easy to adapt to new domains                  | No self-healing beyond per-phase retry       |
