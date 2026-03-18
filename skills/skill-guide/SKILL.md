---
name: skill-guide
description: 'Comprehensive reference guide for creating production-grade GitHub Copilot Agent Skills. Use when asked to learn how to create a skill, understand skill folder structure, write skill frontmatter, add scripts or reference files, or prepare a skill for an organization or production repository. Covers SKILL.md anatomy, folder conventions, description best practices, bundled asset patterns, and validation workflows.'
---

# Agent Skills — Production Reference Guide

A complete reference for designing, building, and validating GitHub Copilot Agent Skills for production repositories and organizations.

---

## Table of Contents

1. [What Is a Skill?](#what-is-a-skill)
2. [Skill Anatomy](#skill-anatomy)
3. [Frontmatter Reference](#frontmatter-reference)
4. [SKILL.md Body Structure](#skillmd-body-structure)
5. [Folder Layout Patterns](#folder-layout-patterns)
6. [Writing a Great Description](#writing-a-great-description)
7. [Bundled Asset Types](#bundled-asset-types)
8. [Production Checklist](#production-checklist)
9. [Validation](#validation)
10. [Common Anti-Patterns](#common-anti-patterns)
11. [Real-World Examples](#real-world-examples)
12. [Quick-Start Templates](#quick-start-templates)

---

## What Is a Skill?

An Agent Skill is a **self-contained folder** that extends GitHub Copilot with specialized knowledge, workflows, and bundled resources. Skills follow the [Agent Skills specification](https://agentskills.io/specification) and are loaded on-demand when Copilot determines they match the user's intent.

### Why Skills Instead of Instructions?

| Feature | Instructions | Skills |
|---------|-------------|--------|
| File format | Single `.instructions.md` file | Folder with `SKILL.md` + optional assets |
| Bundled resources | ❌ | ✅ Scripts, templates, reference docs |
| Progressive loading | Loaded broadly | Loaded only when triggered by description match |
| Discovery mechanism | File glob patterns | Keyword-rich `description` field |
| Best for | Persistent coding rules | Specialized workflows, reusable toolkits |

---

## Skill Anatomy

Every skill lives in its own folder under `skills/`:

```
skills/
└── my-skill-name/           # Folder name = skill name (lowercase, hyphens)
    ├── SKILL.md             # REQUIRED — frontmatter + instructions
    ├── LICENSE.txt          # OPTIONAL — license file for the skill
    ├── scripts/             # OPTIONAL — executable automation scripts
    ├── references/          # OPTIONAL — documentation agent reads for context
    ├── assets/              # OPTIONAL — static files used as-is
    └── templates/           # OPTIONAL — starter code the agent modifies
```

The `SKILL.md` file has two parts:

```
┌─────────────────────────────────┐
│ --- YAML frontmatter ---        │  ← Discovery metadata (name + description)
│ ---                             │
├─────────────────────────────────┤
│ Markdown body                   │  ← Agent instructions, workflows, examples
└─────────────────────────────────┘
```

---

## Frontmatter Reference

All frontmatter fields are defined in YAML between `---` delimiters.

### Required Fields

```yaml
---
name: my-skill-name
description: 'What this skill does. Use when <triggers and keywords>.'
---
```

### Full Field Reference

| Field | Required | Type | Constraints | Purpose |
|-------|----------|------|-------------|---------|
| `name` | **Yes** | string | 1–64 chars; `[a-z0-9-]` only; must match folder name | Unique identifier |
| `description` | **Yes** | string | 10–1024 chars; wrapped in single quotes | Discovery signal — drives automatic skill selection |
| `license` | No | string | License name or path to bundled `LICENSE.txt` | Attribute license for bundled assets |
| `compatibility` | No | string | Max 500 chars | Environment/tool requirements |
| `metadata` | No | key-value map | Arbitrary key-value pairs | Author info, tags, versioning |
| `allowed-tools` | No | space-delimited list | Experimental | Pre-authorize specific tools |
| `context` | No | string | e.g. `fork` | Controls context window behavior |

> For the complete field specification, see [references/frontmatter-spec.md](references/frontmatter-spec.md).

### Name Rules

```
✅ codeql
✅ azure-deployment-preflight
✅ python-mcp-server-generator
❌ MySkill          (uppercase letters)
❌ my_skill         (underscores)
❌ my--skill        (consecutive hyphens)
❌ a-name-that-is-over-sixty-four-characters-long-for-this-field  (>64 chars)
```

The `name` field **must exactly match** the folder name. Validation fails otherwise.

---

## SKILL.md Body Structure

After the frontmatter, write Markdown instructions for the agent. Recommended sections:

```markdown
# Skill Title

Brief one-paragraph overview.

## When to Use This Skill

Reinforce the description with concrete trigger phrases:
- "User asks to ..."
- "When working with ... files"
- "After running ..."

## Prerequisites

- Required tool or environment (e.g., Docker, Node.js 18+)
- Required MCP server or CLI (e.g., `gh` CLI authenticated)
- Access requirements (e.g., Azure subscription)

## Step-by-Step Workflow

### Step 1: ...
### Step 2: ...
### Step 3: ...

## Common Patterns

### Pattern: [Name]
```language
code example
```

## Troubleshooting

| Problem | Solution |
|---------|----------|
| Error X | Do Y     |

## References

- [Reference file](references/detail.md) — when to read it
- [Script](scripts/run.sh) — what it does
```

### Section Priority

| Section | Importance | Notes |
|---------|-----------|-------|
| Title + overview | Critical | First thing agent reads |
| When to Use | High | Reinforces description matching |
| Prerequisites | High | Prevents tool-not-found failures |
| Step-by-Step Workflow | High | Core agent behavior |
| Common Patterns | Medium | Reusable code/commands |
| Troubleshooting | Medium | Reduces back-and-forth |
| References | Low | Point to bundled assets |

---

## Folder Layout Patterns

Choose a layout based on skill complexity. See [references/folder-structure-patterns.md](references/folder-structure-patterns.md) for full examples.

### Pattern A: Minimal (instructions only)

```
my-skill/
└── SKILL.md
```

**When to use:** Short, self-contained procedural instructions. No external resources needed.

**Examples from repo:** `git-commit`, `conventional-commit`, `playwright-generate-test`

---

### Pattern B: With Reference Files

```
my-skill/
├── SKILL.md
└── references/
    ├── overview.md        # Background knowledge
    ├── api-reference.md   # Detailed API docs
    └── troubleshooting.md # Expanded troubleshooting
```

**When to use:** The agent needs detailed documentation that is too long to inline in `SKILL.md`. References are loaded on-demand.

**Examples from repo:** `codeql`, `azure-deployment-preflight`, `dependabot`, `semantic-kernel`

**How to reference in SKILL.md:**
```markdown
> For detailed troubleshooting, see `references/troubleshooting.md`.
```
The agent will load the file when the matching search pattern is triggered.

---

### Pattern C: With Scripts

```
my-skill/
├── SKILL.md
└── scripts/
    ├── install.sh         # Setup automation
    ├── run.py             # Main workflow script
    └── validate.sh        # Verification helper
```

**When to use:** The skill automates terminal-level operations (installs, builds, data processing, API calls).

**Examples from repo:** `publish-to-pages`, `sandbox-npm-install`, `excalidraw-diagram-generator`, `datanalysis-credit-risk`

**How to reference in SKILL.md:**
```markdown
Run the install script:
```bash
bash SKILL_DIR/scripts/install.sh --workspace /path/to/project
```
```

> `SKILL_DIR` is the resolved path to the skill folder at runtime.

---

### Pattern D: With Templates

```
my-skill/
├── SKILL.md
└── templates/
    ├── starter.ts         # Scaffold the agent modifies
    ├── config.json        # Default configuration template
    └── workflow.yml       # CI/CD workflow starter
```

**When to use:** The skill scaffolds files that users customize. Templates provide working starting points.

**Examples from repo:** `excalidraw-diagram-generator` (`.excalidraw` templates), `csharp-mcp-server-generator`

---

### Pattern E: With Assets

```
my-skill/
├── SKILL.md
└── assets/
    ├── diagram.png        # Images used in output
    ├── template-doc.md    # Document template
    └── schema.json        # Data schema
```

**When to use:** The skill outputs or references static files (images, pre-built docs, schemas).

**Examples from repo:** `azure-resource-visualizer`, `make-repo-contribution`, `napkin`

---

### Pattern F: Full Production Layout

```
my-skill/
├── SKILL.md
├── LICENSE.txt
├── references/
│   ├── api-reference.md
│   ├── best-practices.md
│   └── troubleshooting.md
├── scripts/
│   ├── setup.sh
│   └── validate.py
├── templates/
│   └── starter-config.yml
└── assets/
    └── architecture-diagram.png
```

**When to use:** Enterprise-grade skills that combine documentation, automation, templates, and static resources.

---

## Writing a Great Description

The `description` field is the **primary discovery mechanism**. The agent uses it to decide whether to load the skill. Write it as: **WHAT + WHEN + KEYWORDS**.

### Formula

```
[WHAT the skill does]. Use when [TRIGGER SCENARIOS]. [ADDITIONAL KEYWORDS].
```

### Good vs. Poor Examples

```yaml
# ❌ TOO VAGUE
description: 'Web testing helpers'

# ❌ MISSING TRIGGERS
description: 'CodeQL code scanning configuration and workflow setup'

# ✅ PRODUCTION-QUALITY
description: 'Comprehensive guide for setting up and configuring CodeQL code
  scanning via GitHub Actions workflows and the CodeQL CLI. This skill should
  be used when users need help with code scanning configuration, CodeQL
  workflow files, CodeQL CLI commands, SARIF output, security analysis setup,
  or troubleshooting CodeQL analysis.'
```

### Keyword Categories to Include

| Category | Examples |
|----------|---------|
| Action verbs | create, configure, debug, deploy, analyze, generate, migrate |
| Technology names | Docker, Azure, TypeScript, pytest, Playwright |
| File/artifact types | workflow, Dockerfile, SARIF, bicep, openapi.yaml |
| User intent phrases | "set up", "troubleshoot", "scaffold", "add telemetry" |
| Error/symptom terms | "build fails", "out of memory", "auth error" |

> For the full description writing guide, see [references/description-writing-guide.md](references/description-writing-guide.md).

---

## Bundled Asset Types

### Scripts (`scripts/`)

Use for executable automation that the agent runs with a terminal tool.

| Language | Common Use |
|----------|-----------|
| Bash (`.sh`) | System setup, file manipulation, CLI automation |
| Python (`.py`) | Data processing, API calls, file conversion |
| PowerShell (`.ps1`) | Windows automation, Azure CLI sequences |
| Node.js (`.js`/`.mjs`) | Build tooling, JSON manipulation |

**Script best practices:**
- Include a shebang line (`#!/bin/bash`, `#!/usr/bin/env python3`)
- Accept arguments for flexible invocation
- Print clear success/failure messages
- Handle errors with `set -euo pipefail` (bash) or try/except (Python)
- Document arguments at the top of the file with comments

```bash
#!/bin/bash
# Usage: setup.sh --workspace <path> [--dry-run]
# Installs project dependencies in a Docker sandbox environment
set -euo pipefail

WORKSPACE="${1:-.}"
DRY_RUN=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --workspace) WORKSPACE="$2"; shift 2 ;;
    --dry-run)   DRY_RUN=true; shift ;;
    *) echo "Unknown arg: $1"; exit 1 ;;
  esac
done
```

### Reference Files (`references/`)

Use for documentation that is too long to inline in `SKILL.md`, but that the agent should load for specific sub-tasks.

**Reference file best practices:**
- Name files descriptively: `api-reference.md`, `troubleshooting.md`, `best-practices.md`
- Keep each file focused on a single topic
- Use tables, code blocks, and headings for scannable content
- Reference from `SKILL.md` with search hints:

```markdown
> For detailed CLI commands, search `references/cli-commands.md`.
> Search patterns: `database create`, `analyze`, `upload-results`
```

### Templates (`templates/`)

Use for starter files the agent copies and customizes for the user.

**Template best practices:**
- Use clear placeholder tokens: `{skill-name}`, `{language}`, `{REPO_OWNER}`
- Include inline comments explaining each placeholder
- Provide the most common configuration as defaults
- Keep templates under 200 lines where possible

### Assets (`assets/`)

Use for binary or static files the skill outputs or embeds.

**Asset best practices:**
- Keep individual assets under 5 MB (enforced by validation)
- Use widely supported formats (PNG, SVG, JSON, YAML)
- Version assets in the filename if they may change: `schema-v2.json`

---

## Production Checklist

Use this checklist before committing a skill to a production repository or organization.

### Structure

- [ ] Folder name is lowercase, uses only `[a-z0-9-]`, matches `name` field
- [ ] `SKILL.md` exists at the skill root
- [ ] No nested skill folders (each skill is exactly one folder deep)

### Frontmatter

- [ ] `name` is 1–64 characters, matches folder name exactly
- [ ] `description` is 10–1024 characters, wrapped in single quotes
- [ ] `description` explains **what** the skill does **and** **when** to trigger it
- [ ] `description` includes relevant keywords agents and users might mention
- [ ] Optional fields (`license`, `compatibility`, `metadata`) are accurate

### Body Content

- [ ] Title and overview are clear and concise
- [ ] "When to Use This Skill" section is present and specific
- [ ] Prerequisites are listed (tools, auth, environment)
- [ ] Step-by-step workflows are numbered and actionable
- [ ] All bundled assets are referenced from the body
- [ ] References use relative paths (e.g., `references/api-reference.md`)
- [ ] No sensitive data (tokens, passwords, private endpoints)

### Scripts

- [ ] Scripts include a shebang line
- [ ] Scripts accept arguments (not hardcoded paths)
- [ ] Scripts handle errors gracefully
- [ ] Scripts are referenced in `SKILL.md` with example invocations
- [ ] Scripts under 5 MB each

### Reference Files

- [ ] Each reference file covers a single topic
- [ ] References are named to match their content
- [ ] SKILL.md includes "search patterns" to help the agent find the right reference

### Organization Deployment

- [ ] Skill is placed in `.github/skills/<skill-name>/` within the target repo
- [ ] Tested in a Copilot session to confirm it triggers on expected prompts
- [ ] Reviewed for compliance with organization security policies
- [ ] `npm run skill:validate` passes (if using this repository's toolchain)

---

## Validation

### Using the Built-in Validator

```bash
# Validate all skills
npm run skill:validate

# Create a new skill interactively
npm run skill:create -- --name my-new-skill

# Build README (updates docs/README.skills.md)
npm run build
```

### Validation Rules

| Rule | What Is Checked |
|------|-----------------|
| SKILL.md exists | File is present at folder root |
| `name` format | `[a-z0-9-]`, 1–64 chars |
| `name` matches folder | Exact string match |
| `description` length | 10–1024 characters |
| Asset file size | Each bundled asset ≤ 5 MB |
| No duplicate names | Unique across all skills in repo |

### Manual Validation

```bash
# Check frontmatter can be parsed
node -e "
const fs = require('fs');
const yaml = require('js-yaml');
const content = fs.readFileSync('skills/my-skill/SKILL.md', 'utf8');
const match = content.match(/^---\n([\s\S]*?)\n---/);
const fm = yaml.load(match[1]);
console.log(fm);
"

# Check asset sizes
find skills/my-skill -type f | xargs du -sh | sort -h

# Verify folder name matches skill name
FOLDER=my-skill
NAME=$(grep '^name:' skills/$FOLDER/SKILL.md | sed 's/name: //')
[ "$FOLDER" = "$NAME" ] && echo "✅ Match" || echo "❌ Mismatch: $NAME"
```

---

## Common Anti-Patterns

| Anti-Pattern | Problem | Fix |
|---|---|---|
| Vague description | Skill never triggers | Add action verbs, user intent phrases, and error keywords |
| Hardcoded paths in scripts | Fails on other machines | Accept paths as script arguments; use `SKILL_DIR` variable |
| Entire API docs inlined | Context window overflow | Move to `references/` and point to them from `SKILL.md` |
| Missing prerequisites | Cryptic runtime errors | List all tools, auth, and environment requirements upfront |
| Uppercase or spaces in folder name | Validation failure | Use lowercase hyphens only |
| `name` field ≠ folder name | Validation failure | Keep them in sync; rename one |
| No "When to Use" section | Agent misidentifies triggers | Add concrete trigger phrases matching the description |
| Scripts without error handling | Silent failures | Use `set -euo pipefail`; validate required args |
| Assets over 5 MB | Validation failure | Compress assets; reference external URLs instead |
| Sensitive data in templates | Security risk | Use placeholder tokens; never commit real credentials |

---

## Real-World Examples

### Example 1: Minimal Skill (Bash automation)

```
git-commit/
└── SKILL.md       # 125 lines — workflow, commit types, best practices
```

Key characteristics:
- `allowed-tools: Bash` declares tool access upfront
- Description lists every trigger phrase: "commit changes", "create a git commit", "/commit"
- Workflow section has numbered steps with exact bash commands

### Example 2: Reference-Heavy Skill

```
codeql/
├── SKILL.md                       # 406 lines — core workflows
└── references/
    ├── alert-management.md
    ├── cli-commands.md
    ├── compiled-languages.md
    ├── sarif-output.md
    ├── troubleshooting.md
    └── workflow-configuration.md
```

Key characteristics:
- Main `SKILL.md` covers 80% of tasks inline
- Reference files are used for deep-dives and edge cases
- Each reference is cited with explicit search patterns so the agent knows when to load them

### Example 3: Script-Based Skill

```
publish-to-pages/
├── SKILL.md                  # Orchestrates the workflow
└── scripts/
    ├── convert-pdf.py
    ├── convert-pptx.py
    └── publish.sh
```

Key characteristics:
- `SKILL.md` describes WHAT each script does and HOW to invoke it
- Scripts accept CLI arguments — no hardcoded paths
- Error handling tells users exactly what to install if something is missing

### Example 4: Template-Driven Skill

```
excalidraw-diagram-generator/
├── SKILL.md                              # Diagram type selection logic
├── references/
│   └── excalidraw-json-structure.md
├── scripts/
│   └── validate-excalidraw.py
└── templates/
    ├── flowchart-template.excalidraw
    ├── class-diagram-template.excalidraw
    └── sequence-diagram-template.excalidraw
```

Key characteristics:
- Templates are actual working Excalidraw JSON files the agent can copy and modify
- `SKILL.md` includes a decision table mapping user intent → diagram type → template file
- Script validates generated output

### Example 5: Full Production Skill

```
appinsights-instrumentation/
├── SKILL.md
├── examples/
│   └── appinsights.bicep
├── references/
│   ├── ASPNETCORE.md
│   ├── AUTO.md
│   ├── NODEJS.md
│   └── PYTHON.md
└── scripts/
    └── appinsights.ps1
```

Key characteristics:
- `SKILL.md` first collects context (language, hosting) before recommending a path
- Separate reference files per technology stack — agent only loads the relevant one
- Script is purely declarative (Azure CLI commands) — easy to read and modify

---

## Quick-Start Templates

Ready-to-use templates are bundled in the `templates/` folder:

| Template | Use For |
|----------|---------|
| [minimal-skill-template.md](templates/minimal-skill-template.md) | Simple procedural skills with no bundled assets |
| [standard-skill-template.md](templates/standard-skill-template.md) | Skills with reference files and optional scripts |
| [production-skill-template.md](templates/production-skill-template.md) | Full production layout with scripts, refs, templates, assets |

### How to Use a Template

1. Copy the template to a new skill folder:
   ```bash
   cp skills/skill-guide/templates/standard-skill-template.md \
      skills/my-new-skill/SKILL.md
   ```
2. Update the `name` field to match your folder name
3. Write a keyword-rich `description`
4. Fill in each section, removing placeholder comments
5. Add bundled assets to `scripts/`, `references/`, `templates/`, or `assets/`
6. Validate:
   ```bash
   npm run skill:validate
   ```

---

## References

- [Agent Skills official specification](https://agentskills.io/specification)
- [Frontmatter field reference](references/frontmatter-spec.md)
- [Folder structure patterns](references/folder-structure-patterns.md)
- [Description writing guide](references/description-writing-guide.md)
- [Minimal skill template](templates/minimal-skill-template.md)
- [Standard skill template](templates/standard-skill-template.md)
- [Production skill template](templates/production-skill-template.md)
