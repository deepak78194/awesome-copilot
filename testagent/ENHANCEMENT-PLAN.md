# Enhancement Plan — Closing the Collaboration Gap

> **Purpose:** Document three layered enhancements that bring within-run collaborative intelligence to the Wave Conductor, Guardian Loop, and Assembly Line patterns — without requiring the long-term persistence overhead of the Evolution Engine.
>
> **Compatibility:** GitHub Copilot Chat in VS Code · GitHub Copilot CLI · GitHub Copilot Coding Agent
>
> **Author note:** These enhancements are inspired by the Evolution Engine's self-learning contract but scoped to a single run. The goal is per-task collaboration, not cross-session memory.

---

## Why Enhancement is Needed

### The Fundamental Constraint

In Copilot (CLI and VS Code), every subagent is **completely isolated**. A subagent receives a prompt, performs work, and returns a report. It cannot call another subagent. It cannot read another agent's context. The only bridges that exist are:

1. **Orchestrator-mediated** — the orchestrator extracts information from one agent's report and injects it into the next agent's prompt
2. **File-mediated** — agents read and write shared files on disk that survive across subagent invocations

Everything in this enhancement plan works within these two constraints. No new tools, no new infrastructure, no changes to how Copilot works.

---

### What's Missing Today

Each current pattern has specific gaps:

| Gap | Wave Conductor | Guardian Loop | Assembly Line |
|---|:---:|:---:|:---:|
| Parallel coders are invisible to each other | ✗ Critical | — | — |
| Plan is immutable even when reality contradicts it | ✗ | ✗ | ✗ |
| Each agent starts cold — no accumulated run context | ✗ | ✗ | ✗ |
| Reviewer findings are discarded after each wave/phase | ✗ | ✗ | ✗ |
| Coder A's architectural decisions are invisible to Coder B | ✗ Critical | ✗ | ✗ |

**The core problem in one sentence:** Every subagent in the current patterns starts as if it's the first agent to ever touch the project within this run. It cannot see what prior agents discovered, decided, or warned about.

**Real-world consequence:** Coder B in Wave 2 may choose `async/await` while Coder A in Wave 1 chose promise chaining. The reviewer catches it — but only after the work is done. Or Coder B uses `camelCase` for DB columns that Coder A already established as `snake_case`. The reviewer catches it. The task fails. A retry is launched — with the same cold context.

---

## The Three Enhancements

The enhancements are designed to be **layered** — each builds on the previous, and each can be adopted independently.

```
Enhancement 1: Progressive Context Enrichment   ← No files, orchestrator-only, lowest cost
Enhancement 2: Session Decision Board           ← File-mediated, within-run collaboration
Enhancement 3: Adaptive Plan Gate              ← Plan becomes a living document
```

---

## Enhancement 1 — Progressive Context Enrichment

### What It Is

After every subagent returns, the orchestrator extracts 3–5 structured bullet points — **key facts discovered or decided** — and appends them to a growing `SHARED_CONTEXT` block held in its own working memory. Every subsequent subagent receives this block prepended to its prompt.

This is **zero-cost** to implement: no new files, no new agents, no new tools. It is a behaviour change in the orchestrator prompt only.

### How It Works

```
Run start: SHARED_CONTEXT = []

After Explorer returns:
  → Orchestrator extracts: architecture facts, tech stack, existing patterns, risks
  → Appends to SHARED_CONTEXT

After Planner returns:
  → Orchestrator extracts: plan approach, phase rationale, key constraints
  → Appends to SHARED_CONTEXT

After each Coder returns:
  → Orchestrator extracts: decisions made, patterns chosen, files created, issues encountered
  → Appends to SHARED_CONTEXT

After each Reviewer returns:
  → Orchestrator extracts: what passed, what failed, what to watch out for in later tasks
  → Appends to SHARED_CONTEXT

Every subsequent subagent receives SHARED_CONTEXT at the top of its prompt.
```

### SHARED_CONTEXT Format

```markdown
## SHARED CONTEXT (accumulated during this run — read before doing any work)

### From Explorer
- Tech stack: Node.js 20, Express 4.x, PostgreSQL 15, Jest
- Auth pattern: JWT middleware already exists in `src/auth/middleware.ts` — do NOT replace it
- DB column naming: snake_case throughout (e.g., `user_id`, `created_at`) — never camelCase
- Test setup: integration tests use a real DB via Docker Compose — unit tests mock the DB

### From Planner
- Chose repository pattern for all DB access — every new DAO must extend `BaseRepository`
- Wave ordering rationale: schema migrations must complete before any service layer work

### From Wave 1 / Coder A (Task: user-auth-service)
- Used bcrypt@5 for password hashing (argon2 was missing from package.json — do not add it)
- Error handling: all service methods throw typed errors extending `AppError` from `src/errors.ts`
- Decision: chose dependency injection via constructor, not service locator

### From Wave 1 / Coder B (Task: email-service)
- Email provider: SendGrid SDK used (not Nodemailer) — already in package.json
- Template pattern: all email templates stored in `src/templates/*.html`

### From Wave 1 Reviewer
- WARNING: Rate limiting not yet implemented on auth endpoints — flagged for Wave 2
- WARNING: `email-service` tests mock the SendGrid client but production code uses the real client — ensure Wave 2 integration tests account for this
```

### Extraction Protocol for Orchestrator

After each subagent returns, the orchestrator MUST:

1. **Read** the subagent's full report
2. **Extract** only facts that could affect future agents: decisions made, patterns chosen, constraints discovered, risks flagged
3. **Tag** each entry with its source: `[Explorer]`, `[Planner]`, `[Wave N / Coder — task-name]`, `[Wave N / Reviewer]`
4. **Append** extracted items to SHARED_CONTEXT
5. **Inject** the full current SHARED_CONTEXT at the top of every subsequent subagent prompt

### What NOT to Include in SHARED_CONTEXT

- Implementation details (specific code snippets, line numbers) — too verbose
- Things only relevant to one task — omit if no future agent would care
- Status updates ("task 3 is done") — the todo list handles that
- Opinions or guesses — only facts that an agent actually reported

### Impact Per Pattern

| Pattern | Impact |
|---|---|
| **Wave Conductor** | Parallel coders in Wave 2 see all Wave 1 decisions. Critical gap closed. |
| **Guardian Loop** | Each new sentinel-coder gets context from all prior completed tasks — no cold starts on retries. |
| **Assembly Line** | Each station-coder inherits the full picture from all prior stations. |

### Implementation Effort

- Modify: `conductor.agent.md`, `guardian.agent.md`, `foreman.agent.md`
- Change: Add `SHARED_CONTEXT` extraction step after each `runSubagent` call
- Change: Add `SHARED_CONTEXT` injection to every subsequent subagent prompt template
- No changes to subagent files (planner, coder, reviewer, explorer)

---

## Enhancement 2 — Session Decision Board

### What It Is

A single append-only file `.session/board.md` created at the start of each run. Coders and reviewers write tagged entries to the board. The orchestrator reads the board at key decision points to extract risks and decisions before advancing.

Unlike SHARED_CONTEXT (which lives only in the orchestrator's working memory), the board is **on disk** — visible to humans mid-run, inspectable for debugging, and accessible to any agent that can read files.

### Board File Location

```
.session/
└── board.md     ← Created fresh at run start, deleted or archived at run end
```

The `.session/` folder is temporary — it should be gitignored or cleaned up after each run.

### Board Entry Format

```markdown
# Session Board

<!-- Entries are appended as the run progresses. Do not edit manually. -->

## [FINDING] Explorer · 2026-03-24
No existing auth system found. Must build from scratch. JWT library not in package.json — needs to be added.

## [DECISION] Task-2 · Coder · auth-service
Chose bcrypt@5 over argon2 — argon2 was not in dependencies. All password operations must use bcrypt.
Files affected: `src/auth/service.ts`, `src/auth/hash.ts`

## [DECISION] Task-2 · Coder · auth-service
Repository pattern selected for all DB access. Every new DAO extends `BaseRepository` from `src/db/base.ts`.

## [RISK] Task-3 · Coder · email-service
Rate limiting on /auth/login endpoint not implemented. Marked as known gap — must be addressed before production.

## [BLOCKER] Task-4 · Reviewer · email-service
Email service mocks SendGrid in tests but uses real client in production. Task-5 integration tests must account for this or they will fail in CI.

## [CONSTRAINT] Task-5 · Reviewer · user-profile
DB schema for `users` table uses snake_case. Any new columns added must follow this convention. camelCase columns will break the ORM mapping.
```

### Entry Tags and Their Meaning

| Tag | Written by | Meaning | Who reads it |
|---|---|---|---|
| `[FINDING]` | Explorer, Coder | Discovered fact about the codebase | All subsequent agents |
| `[DECISION]` | Coder | Architectural or technical choice made that future coders must respect | All subsequent coders |
| `[RISK]` | Coder, Reviewer | Known gap or fragile area that later tasks should be aware of | Orchestrator before next wave/phase, subsequent reviewers |
| `[BLOCKER]` | Reviewer | Something that WILL cause failure in a future task if not addressed | Orchestrator reads immediately, injects into next coder prompt |
| `[CONSTRAINT]` | Reviewer | A hard rule discovered during validation that all future coders must follow | All subsequent coders |

### Orchestrator Board-Reading Protocol

The orchestrator reads `.session/board.md` at three points:

1. **Before the planner** — inject all `[FINDING]` entries into the planner prompt so the plan is informed by discovery
2. **After each wave/phase reviewer returns** — scan for `[BLOCKER]` entries; if any exist for upcoming tasks, inject them as hard constraints into those tasks' coder prompts
3. **Before each coder prompt** — inject all `[DECISION]` and `[CONSTRAINT]` entries relevant to the files that coder will touch

### Subagent Writing Protocol

Coders and reviewers are instructed to **append** entries to `.session/board.md` before returning their report. The instruction in their prompt:

```
BOARD PROTOCOL (required):
Before returning your report, append any of the following to `.session/board.md`:
- [FINDING] if you discovered something about the codebase that future agents must know
- [DECISION] if you made an architectural or technical choice that future coders must respect
- [RISK] if you encountered a fragile area or known gap
- [BLOCKER] if something will definitely cause a future task to fail without intervention
- [CONSTRAINT] if validation revealed a hard rule that all future coders must follow

Format each entry as:
## [TAG] TaskName · Role · Brief title
One to three sentences. Be specific. Name files and patterns explicitly.

If you have nothing to add, do not append anything.
```

### Impact Per Pattern

| Pattern | Impact |
|---|---|
| **Wave Conductor** | Parallel coders write to the board independently. After the wave, the orchestrator reads all `[DECISION]` entries and injects them into Wave N+1 coders. Parallel coders now effectively collaborate through the board. |
| **Guardian Loop** | Each sentinel-coder's decisions become constraints for the next task's coder. Reviewers can write `[BLOCKER]` entries that the guardian reads before delegating the next task's work. |
| **Assembly Line** | Board entries persist across phases. Phase 3 coder sees exactly what Phase 1 and Phase 2 decided — no cold start. The board complements `.pipeline/plan.md` with live discoveries not in the original plan. |

### Board vs SHARED_CONTEXT — When to Use Which

| | SHARED_CONTEXT | Session Board |
|---|---|---|
| Lives in | Orchestrator working memory | File on disk (`.session/board.md`) |
| Visible to humans mid-run | No | Yes |
| Can be read by subagents | No — orchestrator injects it | Yes — agents append directly |
| Survives a session restart | No | Yes (until manually deleted) |
| Best for | Summarised context in prompts | Raw agent-to-agent communication |

**Use both together.** The orchestrator extracts from the board into SHARED_CONTEXT. The board is the raw source; SHARED_CONTEXT is the curated digest.

### Implementation Effort

- Modify: `conductor.agent.md`, `guardian.agent.md`, `foreman.agent.md`
- Modify: all coder and reviewer subagent files (add board-writing protocol)
- Add: `.gitignore` entry for `.session/`
- New behaviour: orchestrator reads board at 3 checkpoints per run

---

## Enhancement 3 — Adaptive Plan Gate

### What It Is

After each wave/phase reviewer returns, the orchestrator makes a structured judgment: **did reality match the plan?** If the reviewer's report contains significant surprises — things the plan did not anticipate — the orchestrator launches a targeted micro-replan before continuing.

Today, all three patterns treat the plan as immutable once created. Real projects always produce surprises. This gap means agents execute increasingly stale instructions as the run progresses.

### The Problem it Solves

```
Current behaviour:
  Planner creates plan → Execute Wave 1 → Reviewer finds DB schema is completely different → Execute Wave 2 with the SAME old plan
  → Wave 2 coders fail because their task descriptions reference wrong schema → retries → more failures

With Adaptive Plan Gate:
  Planner creates plan → Execute Wave 1 → Reviewer finds DB schema is completely different
  → Orchestrator detects SIGNIFICANT_CHANGE → Micro-Planner: amend remaining waves to reflect actual schema
  → Execute Wave 2 with updated tasks → coders succeed first time
```

### Surprise Detection — What Counts as "Significant"

The orchestrator applies this decision rule to each reviewer report:

```
SIGNIFICANT_CHANGE = true if ANY of the following:
  - Reviewer found a [BLOCKER] on the session board for an upcoming task
  - A file that multiple upcoming tasks depend on does not exist as planned
  - A technology choice in the plan was invalidated (wrong version, missing dep, different API)
  - An assumption about existing code was wrong (e.g., "feature X exists" — it does not)
  - A new mandatory constraint was discovered that affects 2+ remaining tasks

SIGNIFICANT_CHANGE = false if:
  - Only style or naming issues were found
  - A single isolated task failed (handle with retry, not replan)
  - The reviewer flagged a risk but no downstream tasks are affected
```

### Micro-Replan Protocol

When `SIGNIFICANT_CHANGE = true`, the orchestrator launches a targeted planner subagent **before the next wave/phase begins**:

```
> MICRO-REPLAN REQUEST
>
> Original objective: [original user request]
>
> Original plan for remaining tasks:
> [list of remaining tasks from current plan]
>
> What was discovered in Wave/Phase N that the plan did not anticipate:
> [specific surprises from reviewer report + board entries]
>
> What has already been completed (do not re-plan completed work):
> [list of completed tasks]
>
> Your job: Amend ONLY the remaining tasks. Do not change completed tasks.
> Return:
> - Updated task list for remaining waves/phases
> - What you changed and why
> - Any tasks that should be added
> - Any tasks that should be removed or merged
>
> Output the amended plan in the same format as the original.
```

The orchestrator replaces the remaining portion of the plan with the micro-replan output and continues.

### Safeguards

- **Micro-replan is scoped** — it can only modify remaining tasks, never retroactively change completed ones
- **Maximum one micro-replan per wave/phase** — the orchestrator does not replan again if the same wave triggers another surprise; it retries instead
- **User escalation if micro-replan creates a new wave/phase** — adding completely new work (not amending existing tasks) requires user confirmation
- **The decision is logged to the session board** as a `[DECISION]` entry: "Plan amended after Wave N due to: [reason]"

### Impact Per Pattern

| Pattern | Impact |
|---|---|
| **Wave Conductor** | After each wave review, the orchestrator checks for SIGNIFICANT_CHANGE. If true, triggers micro-replan before next wave. Plans survive reality. |
| **Guardian Loop** | After every 3 tasks validate, the orchestrator checks accumulated board entries for SIGNIFICANT_CHANGE. If true, micro-replan runs against remaining tasks. |
| **Assembly Line** | After each phase review, orchestrator checks for SIGNIFICANT_CHANGE. If true, `station-planner` is called with a targeted amendment prompt. The amended plan is written back to `.pipeline/plan.md`. |

### Implementation Effort

- Modify: `conductor.agent.md`, `guardian.agent.md`, `foreman.agent.md`
- Add: SIGNIFICANT_CHANGE detection logic to orchestrator (post-reviewer step)
- Add: micro-replan prompt template to orchestrator
- No changes to subagent files

---

## Combined Architecture — All Three Enhancements Together

```
Run start
│
├── [E2] Create .session/board.md
│
├── Explorer
│   ├── Writes [FINDING] entries to board
│   └── Returns report
│   │
│   ├── [E1] Orchestrator extracts → SHARED_CONTEXT += explorer findings
│   └── [E2] Orchestrator reads board → extracts all [FINDING] entries
│
├── Planner (receives: objective + SHARED_CONTEXT + board [FINDING] entries)
│   └── Returns plan
│   │
│   └── [E1] Orchestrator extracts → SHARED_CONTEXT += plan decisions
│
├── Wave/Phase 1
│   ├── Coder(s) (receives: task + SHARED_CONTEXT + relevant [DECISION]/[CONSTRAINT] from board)
│   │   ├── Writes [FINDING]/[DECISION]/[RISK] entries to board
│   │   └── Returns report
│   │   └── [E1] Orchestrator extracts → SHARED_CONTEXT += coder decisions
│   │
│   └── Reviewer (receives: task + SHARED_CONTEXT)
│       ├── Writes [BLOCKER]/[CONSTRAINT]/[RISK] entries to board
│       └── Returns verdict
│       │
│       ├── [E1] Orchestrator extracts → SHARED_CONTEXT += reviewer findings
│       ├── [E2] Orchestrator reads board → checks for [BLOCKER] entries
│       └── [E3] Orchestrator checks SIGNIFICANT_CHANGE
│           ├── false → proceed to Wave/Phase 2
│           └── true → Micro-Planner(remaining tasks + discoveries) → update plan → proceed
│
├── Wave/Phase 2+ (repeat with richer SHARED_CONTEXT and updated plan)
│
├── Final Integration Review
│   └── [E2] Reads board for full run history of [DECISION]/[CONSTRAINT] entries
│
└── Report + [E2] Archive or delete .session/board.md
```

---

## Enhancement Compatibility Matrix

All three enhancements are **fully compatible** with GitHub Copilot in VS Code, CLI, and as coding agents. Here is why:

| Requirement | E1: Progressive Context | E2: Session Board | E3: Adaptive Plan Gate |
|---|---|---|---|
| New Copilot tools needed | None | None (file I/O) | None |
| New agent types needed | None | None | None |
| Works offline / no network | Yes | Yes | Yes |
| Works in CLI mode | Yes | Yes | Yes |
| Works in VS Code agent mode | Yes | Yes | Yes |
| Requires user interaction | No | No | Only if micro-replan adds new scope |
| Risk of infinite loops | No | No | No (one replan max per wave) |

---

## Implementation Roadmap

### Phase A — Quick Win (Enhancement 1 only)

Touch only the three orchestrator files. All subagent files unchanged.

| File | Change |
|---|---|
| `wave-conductor/conductor.agent.md` | Add SHARED_CONTEXT extraction + injection to all `runSubagent` calls |
| `guardian-loop/guardian.agent.md` | Add SHARED_CONTEXT extraction + injection to all `runSubagent` calls |
| `assembly-line/foreman.agent.md` | Add SHARED_CONTEXT extraction + injection to all `runSubagent` calls |

Estimated effort: **Low** — 3 file edits, orchestrator-only.

---

### Phase B — Full Collaboration (E1 + E2)

Add the Session Decision Board to all patterns.

| File | Change |
|---|---|
| `wave-conductor/conductor.agent.md` | Add board creation, board-reading checkpoints |
| `guardian-loop/guardian.agent.md` | Add board creation, board-reading checkpoints |
| `assembly-line/foreman.agent.md` | Add board creation, board-reading checkpoints |
| `wave-conductor/wave-coder.agent.md` | Add board-writing protocol |
| `wave-conductor/wave-reviewer.agent.md` | Add board-writing protocol |
| `guardian-loop/sentinel-coder.agent.md` | Add board-writing protocol |
| `guardian-loop/sentinel-reviewer.agent.md` | Add board-writing protocol |
| `assembly-line/station-coder.agent.md` | Add board-writing protocol |
| `assembly-line/station-reviewer.agent.md` | Add board-writing protocol |
| `.gitignore` (root) | Add `.session/` to ignored paths |

Estimated effort: **Medium** — 10 file edits, all well-defined.

---

### Phase C — Adaptive Intelligence (E1 + E2 + E3)

Add Adaptive Plan Gate on top of Phase B.

| File | Change |
|---|---|
| `wave-conductor/conductor.agent.md` | Add SIGNIFICANT_CHANGE detection + micro-replan protocol |
| `guardian-loop/guardian.agent.md` | Add SIGNIFICANT_CHANGE detection + micro-replan protocol (every 3 tasks) |
| `assembly-line/foreman.agent.md` | Add SIGNIFICANT_CHANGE detection + micro-replan protocol + `.pipeline/plan.md` amendment |

Estimated effort: **Medium-High** — 3 file edits, but the SIGNIFICANT_CHANGE logic is the most cognitively complex part.

---

## What This Does NOT Provide

These enhancements close the within-run collaboration gap. They do **not** provide:

| Capability | Covered? | For this, use |
|---|---|---|
| Knowledge that persists across multiple runs | No | Evolution Engine |
| Versioned architectural decisions | No | Evolution Engine |
| Lessons from past mistakes applied to future runs | No | Evolution Engine |
| Pattern governance (active/deprecated/blocked) | No | Evolution Engine |

The three enhancements and the Evolution Engine are **complementary, not competing**. You can apply all three enhancements to the Evolution Engine as well — the within-run board and SHARED_CONTEXT work alongside the long-term `.nucleus/` knowledge stores.

---

## Summary

| Enhancement | Effort | What it closes |
|---|---|---|
| E1: Progressive Context Enrichment | Low — orchestrator only | Cold-start problem; agents no longer work in ignorance of prior decisions |
| E2: Session Decision Board | Medium — coders + reviewers + orchestrators | Parallel coder conflicts; human-visible mid-run state; agent-native communication |
| E3: Adaptive Plan Gate | Medium-High — orchestrator only | Stale plan problem; plans survive unexpected reality |

**Together, E1 + E2 + E3 give all three patterns roughly 75% of Evolution Engine's within-run intelligence — with zero long-term persistence overhead, full CLI/VS Code compatibility, and no new agents or tools.**

The remaining 25% (cross-run memory, versioned lessons, pattern governance) is exactly what the Evolution Engine exists to provide. The two approaches are designed to be used at different scales of a project's lifecycle.
