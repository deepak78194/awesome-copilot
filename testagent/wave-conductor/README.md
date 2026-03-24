# Wave Conductor — Parallel Wave Orchestration

> **Metaphor:** An orchestra conductor coordinating instrument sections that play in waves.

## Pattern Summary

Work is decomposed into dependency-ordered **waves**. Within each wave, multiple coder agents run in parallel. Between waves, a reviewer validates the combined output before the next wave begins.

```
Explorer → Planner → [Wave 1: Coder×4] → Reviewer → [Wave 2: Coder×4] → Reviewer → ... → Summary
```

## Agents

| File                                             | Role                | Can Modify Files?            |
| ------------------------------------------------ | ------------------- | ---------------------------- |
| [conductor.agent.md](conductor.agent.md)         | Orchestrator / Lead | No — delegates only          |
| [wave-planner.agent.md](wave-planner.agent.md)   | Planner             | No                           |
| [wave-coder.agent.md](wave-coder.agent.md)       | Coder / Implementer | Yes                          |
| [wave-reviewer.agent.md](wave-reviewer.agent.md) | Tester / Reviewer   | No — reads and runs commands |
| [wave-explorer.agent.md](wave-explorer.agent.md) | Explorer            | No — read-only               |

## When to Use

- Large objectives with many independent subtasks
- Speed matters — maximize parallel execution
- Natural dependency layers exist (schema → logic → tests)
- Multiple specialties or file domains involved

## Key Characteristics

- Up to 4 concurrent agents per wave
- Wave-level integration review between phases
- Tasks sharing file targets are serialized within a wave
- Failed tasks retry up to 3 times with failure context
- Conductor never writes code

## Trade-offs

| Strength                                  | Weakness                                  |
| ----------------------------------------- | ----------------------------------------- |
| Maximum parallelism                       | Orchestration complexity                  |
| Wave gates catch integration issues early | Requires good dependency analysis upfront |
| Scales to large projects                  | Higher total agent invocations            |
