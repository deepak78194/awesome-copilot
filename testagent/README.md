# testagent/ — Multi-Agent Orchestration Patterns

Four complete implementations of multi-agent orchestration, each using a different metaphor and architecture. Every pattern includes the same five core roles (orchestrator, planner, coder, reviewer, explorer) wired together differently.

## The Four Patterns

| Folder                                 | Metaphor            | Architecture                                | Best For                                        |
| -------------------------------------- | ------------------- | ------------------------------------------- | ----------------------------------------------- |
| [wave-conductor/](wave-conductor/)     | Orchestra           | Parallel waves with integration gates       | Large multi-domain projects needing speed       |
| [guardian-loop/](guardian-loop/)       | Security checkpoint | Zero-trust work+validation pairs            | Strict quality, spec adherence                  |
| [assembly-line/](assembly-line/)       | Factory line        | Sequential stations with file-based state   | Focused single-domain pipelines                 |
| [evolution-engine/](evolution-engine/) | Organism            | Self-learning team with versioned knowledge | Long-running projects that accumulate knowledge |

## Structure

```
testagent/
├── README.md                          ← you are here
│
├── wave-conductor/                    ← Pattern 1: Parallel Waves
│   ├── README.md
│   ├── conductor.agent.md             # Orchestrator — wave coordination
│   ├── wave-planner.agent.md          # Plans dependency-ordered waves
│   ├── wave-coder.agent.md            # Implements tasks within waves
│   ├── wave-reviewer.agent.md         # Validates each wave
│   └── wave-explorer.agent.md         # Read-only codebase analysis
│
├── guardian-loop/                     ← Pattern 2: Zero-Trust Validation
│   ├── README.md
│   ├── guardian.agent.md              # Orchestrator — pure delegation
│   ├── sentinel-planner.agent.md      # Plans with acceptance criteria
│   ├── sentinel-coder.agent.md        # Implements scoped tasks
│   ├── sentinel-reviewer.agent.md     # Independent validation
│   └── sentinel-explorer.agent.md     # Read-only investigation
│
├── assembly-line/                     ← Pattern 3: Sequential Pipeline
│   ├── README.md
│   ├── foreman.agent.md               # Orchestrator — phase routing
│   ├── station-planner.agent.md       # Creates phased plan
│   ├── station-coder.agent.md         # Implements one phase at a time
│   ├── station-reviewer.agent.md      # Quality gate between phases
│   └── station-explorer.agent.md      # Writes .pipeline/research.md
│
└── evolution-engine/                  ← Pattern 4: Self-Learning
    ├── README.md
    ├── nucleus.agent.md               # Orchestrator + knowledge governor
    ├── genome-planner.agent.md        # Knowledge-aware planning
    ├── genome-coder.agent.md          # Coder with learning contract
    ├── genome-reviewer.agent.md       # Reviews + lesson compliance
    └── genome-explorer.agent.md       # Knowledge-aware exploration
```

## Quick Comparison

|                  | Wave Conductor          | Guardian Loop                 | Assembly Line       | Evolution Engine                         |
| ---------------- | ----------------------- | ----------------------------- | ------------------- | ---------------------------------------- |
| **Parallelism**  | Up to 4 per wave        | None within task              | None                | Parallel or sequential (chosen per task) |
| **Validation**   | Wave-level review       | Per-task independent reviewer | Per-phase review    | Per-task + lesson compliance             |
| **State**        | In-memory plan          | Todo list                     | `.pipeline/` files  | `.nucleus/` lessons + memories           |
| **Retry**        | 3× per task in wave     | 3× with fresh context         | 2× per phase        | 3× with lesson injection                 |
| **Self-healing** | Wave integration checks | Dual validation catches lies  | Phase gates         | Knowledge prevents repeat mistakes       |
| **Learning**     | None                    | None                          | None                | Versioned lessons + memories             |
| **Complexity**   | High                    | Medium                        | Low                 | High                                     |
| **Speed**        | Fastest                 | Slowest (2× validation)       | Medium (sequential) | Varies by mode                           |

## How to Use

Each pattern folder is self-contained. To use a pattern:

1. Copy the folder to your project's `.github/agents/` directory
2. Invoke the orchestrator agent (conductor, guardian, foreman, or nucleus)
3. Describe your objective — the orchestrator handles the rest

The agents are designed for:

- **GitHub Copilot Chat in VS Code** — invoke the orchestrator agent by name
- **GitHub Copilot CLI** — reference the agent files with `--agent` flag
- **GitHub Copilot coding agent** — place in `.github/agents/` for autonomous execution

## Choosing a Pattern

```
Is your project long-running with recurring work?
  → Yes: evolution-engine (accumulates knowledge)
  → No:
    Is the task large with many independent subtasks?
      → Yes: wave-conductor (maximize parallelism)
      → No:
        Is spec adherence / quality critical?
          → Yes: guardian-loop (zero-trust validation)
          → No: assembly-line (simple sequential pipeline)
```

## Full Documentation

See [docs/multi-agent-orchestration-guide.md](../docs/multi-agent-orchestration-guide.md) for the complete guide including Mermaid flow diagrams, side-by-side comparisons, and combination strategies.
