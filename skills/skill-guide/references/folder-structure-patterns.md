# Folder Structure Patterns

Detailed examples of each skill layout pattern with annotated file trees and usage guidance.

---

## Pattern A: Minimal

**When:** Simple procedural workflow; all instructions fit in one file; no external resources needed.

```
my-skill/
└── SKILL.md
```

**SKILL.md size:** 50–200 lines

**Real examples:** `git-commit`, `conventional-commit`, `playwright-generate-test`, `boost-prompt`

**Template SKILL.md structure:**

```markdown
---
name: my-skill
description: 'One-sentence what + when.'
---

# My Skill

## When to Use This Skill

## Prerequisites

## Step-by-Step Workflow

## Best Practices
```

---

## Pattern B: With References

**When:** Core instructions fit in `SKILL.md`, but there are deep-dive topics too large to inline.

```
my-skill/
├── SKILL.md
└── references/
    ├── api-reference.md
    ├── configuration-options.md
    ├── troubleshooting.md
    └── best-practices.md
```

**SKILL.md size:** 100–500 lines
**Reference file size:** 50–300 lines each

**Real examples:** `codeql`, `azure-deployment-preflight`, `dependabot`, `semantic-kernel`, `cli-mastery`

### Annotated file tree (codeql)

```
codeql/
├── SKILL.md                          # Core workflows: 406 lines
│                                     # Covers 80% of user tasks
└── references/
    ├── alert-management.md           # Loaded when: alert triage, severity, autofix
    ├── cli-commands.md               # Loaded when: CLI installation, local analysis
    ├── compiled-languages.md         # Loaded when: C++, Java, Swift build issues
    ├── sarif-output.md               # Loaded when: SARIF parsing, upload limits
    ├── troubleshooting.md            # Loaded when: failures, errors, diagnostics
    └── workflow-configuration.md     # Loaded when: advanced triggers, config files
```

### How to cite references in SKILL.md

```markdown
## Troubleshooting

| Problem | Solution |
|---------|----------|
| Common error | Quick fix (one line) |
| Complex failure | See details below |

> For comprehensive troubleshooting with step-by-step solutions:
> search `references/troubleshooting.md`
> Search patterns: `no source code`, `out of disk`, `403 error`, `SARIF upload`
```

The agent uses the "search patterns" hint to know which reference file to load for a given topic.

### Reference file naming conventions

| File Name | Contains |
|-----------|---------|
| `api-reference.md` | Method signatures, endpoints, parameters |
| `configuration-options.md` | All config settings with defaults and examples |
| `troubleshooting.md` | Error messages → diagnosis → solutions |
| `best-practices.md` | Do/Don't recommendations, anti-patterns |
| `getting-started.md` | Quick setup path from zero |
| `architecture.md` | How the system is structured |
| `examples.md` | Code samples and use-case walkthroughs |

---

## Pattern C: With Scripts

**When:** The skill automates terminal operations — installs, file conversions, API calls, data processing.

```
my-skill/
├── SKILL.md
└── scripts/
    ├── setup.sh          # Environment setup
    ├── run.py            # Main workflow
    └── validate.sh       # Post-run verification
```

**Real examples:** `publish-to-pages`, `sandbox-npm-install`, `datanalysis-credit-risk`, `nano-banana-pro-openrouter`

### Annotated file tree (publish-to-pages)

```
publish-to-pages/
├── SKILL.md              # Orchestration logic: 91 lines
│                         # Tells the agent HOW and WHEN to call each script
└── scripts/
    ├── convert-pdf.py    # Converts PDF → HTML using poppler
    ├── convert-pptx.py   # Converts PPTX → HTML using python-pptx
    └── publish.sh        # Creates GitHub repo, pushes HTML, enables Pages
```

### Calling scripts from SKILL.md

```markdown
## Conversion

### PPTX
Run the bundled conversion script:
```bash
python3 SKILL_DIR/scripts/convert-pptx.py INPUT_FILE /tmp/output.html
```
If `python-pptx` is not installed: `pip install python-pptx`

### PDF
```bash
python3 SKILL_DIR/scripts/convert-pdf.py INPUT_FILE /tmp/output.html
```
Requires `poppler-utils`. Install: `apt install poppler-utils`
```

### Script anatomy (bash)

```bash
#!/bin/bash
# =============================================================================
# Script: setup.sh
# Usage:  setup.sh [--workspace <path>] [--dry-run]
# Desc:   Sets up the project environment inside a Docker container.
# =============================================================================
set -euo pipefail

# --- Defaults -----------------------------------------------------------------
WORKSPACE="$(pwd)"
DRY_RUN=false

# --- Argument parsing ---------------------------------------------------------
while [[ $# -gt 0 ]]; do
  case "$1" in
    --workspace|-w) WORKSPACE="$2"; shift 2 ;;
    --dry-run)      DRY_RUN=true; shift ;;
    --help|-h)      echo "Usage: $0 [--workspace PATH] [--dry-run]"; exit 0 ;;
    *)              echo "Unknown option: $1"; exit 1 ;;
  esac
done

# --- Validation ---------------------------------------------------------------
if [[ ! -f "$WORKSPACE/package.json" ]]; then
  echo "ERROR: No package.json found in $WORKSPACE"
  exit 1
fi

# --- Main logic ---------------------------------------------------------------
echo "Setting up workspace: $WORKSPACE"
if [[ "$DRY_RUN" == "true" ]]; then
  echo "Dry run — no changes made"
  exit 0
fi

npm ci --prefix "$WORKSPACE"
echo "✅ Setup complete"
```

### Script anatomy (Python)

```python
#!/usr/bin/env python3
"""
Script: process.py
Usage:  python process.py --input FILE [--output DIR] [--threshold 0.5]
Desc:   Processes input data and writes results to the output directory.
"""
import argparse
import sys
from pathlib import Path


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--input", required=True, type=Path, help="Input file")
    parser.add_argument("--output", type=Path, default=Path("output"), help="Output dir")
    parser.add_argument("--threshold", type=float, default=0.5, help="Score threshold")
    return parser.parse_args()


def main() -> int:
    args = parse_args()

    if not args.input.exists():
        print(f"ERROR: Input file not found: {args.input}", file=sys.stderr)
        return 1

    args.output.mkdir(parents=True, exist_ok=True)

    # Main processing logic here
    print(f"✅ Processed {args.input} → {args.output}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
```

---

## Pattern D: With Templates

**When:** The skill generates or scaffolds files that users will customize (code, config, YAML, JSON).

```
my-skill/
├── SKILL.md
└── templates/
    ├── starter.ts            # Main scaffold
    ├── config.json           # Default configuration
    └── .github/
        └── workflows/
            └── ci.yml        # CI/CD starter
```

**Real examples:** `excalidraw-diagram-generator`, `csharp-mcp-server-generator`, `typescript-mcp-server-generator`

### Annotated file tree (excalidraw-diagram-generator)

```
excalidraw-diagram-generator/
├── SKILL.md                                    # Decision logic: which template to use
├── references/
│   └── excalidraw-json-structure.md            # JSON format spec
├── scripts/
│   └── validate-excalidraw.py                  # Validates output JSON
└── templates/
    ├── flowchart-template.excalidraw           # Starting point for flowcharts
    ├── class-diagram-template.excalidraw       # OOP class diagrams
    ├── er-diagram-template.excalidraw          # Entity-relationship diagrams
    ├── sequence-diagram-template.excalidraw    # Message sequence diagrams
    ├── mindmap-template.excalidraw             # Mind maps
    ├── relationship-template.excalidraw        # Dependency graphs
    ├── data-flow-diagram-template.excalidraw   # Data flow diagrams
    └── business-flow-swimlane-template.excalidraw  # Swimlane diagrams
```

### Template selection in SKILL.md

```markdown
### Step 2: Select Template

| User Intent | Template File |
|-------------|--------------|
| Flowchart, process | `templates/flowchart-template.excalidraw` |
| Class diagram, OOP | `templates/class-diagram-template.excalidraw` |
| Mind map, brainstorm | `templates/mindmap-template.excalidraw` |
| System architecture | `templates/relationship-template.excalidraw` |
| ER diagram, database | `templates/er-diagram-template.excalidraw` |

### Step 3: Customize Template

Copy the appropriate template and modify the elements based on the user's description.
Reference the JSON structure in `references/excalidraw-json-structure.md` for element schema.
```

### Template placeholder conventions

Use consistent placeholder tokens that are easy to find and replace:

```yaml
# Consistent placeholder style: {PLACEHOLDER_NAME} in UPPER_SNAKE_CASE
name: {SKILL_NAME}
description: '{SKILL_DESCRIPTION}'
owner: {GITHUB_OWNER}
repo: {GITHUB_REPO}
version: {VERSION}          # e.g., 1.0.0
language: {LANGUAGE}        # e.g., python, typescript
```

---

## Pattern E: With Assets

**When:** The skill produces or references static files — images, pre-built docs, schemas, binary data.

```
my-skill/
├── SKILL.md
└── assets/
    ├── architecture-diagram.png     # Embedded in output docs
    ├── template-architecture.md     # Document template the agent copies
    └── schema.json                  # JSON Schema for validation
```

**Real examples:** `azure-resource-visualizer`, `make-repo-contribution`, `napkin`, `doublecheck`

### Asset size limits

| Asset Type | Recommended Size | Maximum |
|------------|-----------------|---------|
| PNG/JPEG images | < 500 KB | 5 MB |
| SVG diagrams | < 100 KB | 5 MB |
| JSON/YAML data | < 200 KB | 5 MB |
| Markdown docs | < 100 KB | 5 MB |
| Binary data | Avoid if possible | 5 MB |

> Assets over 5 MB will fail validation. Use external URLs for large assets.

---

## Pattern F: Full Production Layout

**When:** Enterprise skill with multi-technology support, automation, docs, and static resources.

```
my-skill/
├── SKILL.md                          # Core orchestration logic
├── LICENSE.txt                       # License for bundled content
├── references/
│   ├── overview.md                   # Background and concepts
│   ├── api-reference.md              # API endpoints and parameters
│   ├── configuration.md              # All config options with defaults
│   ├── troubleshooting.md            # Error → fix lookup table
│   └── best-practices.md            # Dos and don'ts
├── scripts/
│   ├── setup.sh                      # Environment setup
│   ├── validate.py                   # Post-run validation
│   └── utils/
│       └── helpers.sh                # Shared utilities
├── templates/
│   ├── minimal/
│   │   └── starter.yml              # Bare minimum config
│   └── production/
│       └── full-config.yml          # All options configured
└── assets/
    ├── architecture.svg              # System diagram
    └── example-output.md            # Example generated output
```

**Real example:** `appinsights-instrumentation`

```
appinsights-instrumentation/
├── SKILL.md                     # Context collection → path selection
├── examples/
│   └── appinsights.bicep        # Bicep template to add to existing IaC
├── references/
│   ├── ASPNETCORE.md            # C# ASP.NET Core instrumentation
│   ├── AUTO.md                  # Auto-instrumentation (App Service)
│   ├── NODEJS.md                # Node.js instrumentation
│   └── PYTHON.md                # Python instrumentation
└── scripts/
    └── appinsights.ps1          # Azure CLI commands for resource creation
```

**Design decisions:**
- `SKILL.md` collects context first (language, hosting type) then routes to the right reference
- Each reference file is a complete guide for one technology stack
- The script contains only Azure CLI commands — easy to adapt or copy
- `examples/` holds the Bicep snippet for infrastructure-as-code users

---

## Choosing the Right Pattern

| Skill Complexity | Lines in SKILL.md | Use Pattern |
|-----------------|------------------|------------|
| Simple workflow | < 100 | A (Minimal) |
| Documentation-heavy | 100–500 | B (+ References) |
| Automation-heavy | Any | C (+ Scripts) |
| Generates files | Any | D (+ Templates) |
| Outputs documents/images | Any | E (+ Assets) |
| Enterprise multi-tech | 200–600 | F (Full Production) |

**Rule of thumb:** Start with Pattern A. Add folders only when you need them. A skill with 50 well-written lines beats a skill with 500 padded lines.
