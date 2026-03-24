# Guardian Loop — Zero-Trust Delegation

> **Metaphor:** A security checkpoint where every piece of work passes through an independent guard before proceeding.

## Pattern Summary

The orchestrator does **zero** implementation work. Every task is handled by a **work agent + validation agent** pair. The validation agent reads actual files, never trusts the coder's claims. Failed tasks get a fresh work agent with original prompt + failure report.

```
Explorer → Planner → [Coder → Reviewer] → [Coder → Reviewer] → ... → Integration Check → Done
```

## Agents

| File                                                     | Role                | Can Modify Files?                            |
| -------------------------------------------------------- | ------------------- | -------------------------------------------- |
| [guardian.agent.md](guardian.agent.md)                   | Orchestrator / Lead | No — only `runSubagent` + `manage_todo_list` |
| [sentinel-planner.agent.md](sentinel-planner.agent.md)   | Planner             | No                                           |
| [sentinel-coder.agent.md](sentinel-coder.agent.md)       | Coder / Implementer | Yes                                          |
| [sentinel-reviewer.agent.md](sentinel-reviewer.agent.md) | Tester / Reviewer   | No — reads and verifies                      |
| [sentinel-explorer.agent.md](sentinel-explorer.agent.md) | Explorer            | No — read-only                               |

## When to Use

- Specification adherence is critical (user chose specific tech for a reason)
- You've had agents falsely report completion before
- Each step has clear, verifiable acceptance criteria
- Quality over speed is the priority
- Context window management matters (delegating preserves orchestrator clarity)

## Key Characteristics

- Every task verified by independent validator
- Spec compliance is checked, not assumed
- Fresh subagent on retry — avoids poisoned context
- Final integration validation after all tasks pass
- Orchestrator permitted only 2 tools: `runSubagent` and `manage_todo_list`

## Trade-offs

| Strength                                      | Weakness                                     |
| --------------------------------------------- | -------------------------------------------- |
| Catches false self-reported completion        | 2x agent cost — every task runs twice        |
| Spec compliance verified at every step        | Slower than patterns without dual validation |
| Retries use fresh context                     | Requires tightly written acceptance criteria |
| Orchestrator stays clean across massive tasks | No built-in parallelism within a task        |
