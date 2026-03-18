---
name: {skill-name}
description: '{WHAT this skill does}. Use when {TRIGGER SCENARIO 1}, {TRIGGER SCENARIO 2},
  {TRIGGER SCENARIO 3}, or {TRIGGER SCENARIO 4}. Supports {TECHNOLOGY/PLATFORM}.
  Covers {TOPIC 1}, {TOPIC 2}, {TOPIC 3}, and troubleshooting {ERROR/SYMPTOM KEYWORD}.'
license: MIT
compatibility: '{Required tools/env, e.g., Docker 24+, Node.js 18+, gh CLI authenticated}'
metadata:
  author: {team-or-author}
  version: 1.0.0
  tags: {tag1, tag2, tag3}
  approvedBy: {team-name}
allowed-tools: Bash
---

# {Skill Title}

{One-paragraph overview: what this skill does, what problem it solves, and why it exists.}

---

## When to Use This Skill

Use this skill when:

- User asks to "{trigger phrase 1}"
- User needs to "{trigger phrase 2}"
- User reports error: "{common error or symptom}"
- User is working with {file type or technology}
- User wants to automate {operation}

## Prerequisites

### Required

- {Tool/runtime, e.g., Python 3.11+} — [install](https://python.org)
- {CLI tool, e.g., Azure CLI (`az`)} — authenticated with `az login`
- {Access requirement, e.g., Azure subscription with Contributor role}

### Optional

- {Optional tool} — enables {feature or capability}
- {MCP server name} — for {enhanced capability}

## Architecture Overview

{Optional: brief diagram or explanation of how the skill's components interact.}

```
User Request
    │
    ▼
SKILL.md (orchestration)
    ├── scripts/setup.sh        → environment preparation
    ├── references/api-ref.md   → detailed API lookup
    ├── templates/starter.yml   → scaffolded output
    └── assets/schema.json      → validation schema
```

---

## Workflow

### Phase 1: Collect Context

{Always gather necessary information before acting.}

1. Determine {context variable 1} from {source}
2. Confirm {context variable 2} with the user if not provided
3. Validate prerequisites are met

### Phase 2: Setup / Preparation

Run the setup script:

```bash
bash SKILL_DIR/scripts/setup.sh \
  --workspace /path/to/project \
  --{option} {value}
```

If the script reports a missing dependency, follow the install instructions it prints.

### Phase 3: Main Workflow

{Core operation. Be specific — list every sub-step.}

#### 3a. {Sub-step}

```{language}
{code}
```

#### 3b. {Sub-step}

```{language}
{code}
```

> For detailed {topic}, see [references/{reference-file}.md](references/{reference-file}.md)
> Search patterns: `{keyword1}`, `{keyword2}`, `{keyword3}`

### Phase 4: Validate Output

Run the validation script:

```bash
python3 SKILL_DIR/scripts/validate.py --input {output-path}
```

Expected output:
```
✅ Validation passed: {n} checks passed, 0 warnings
```

---

## Common Patterns

### Pattern: {Pattern Name}

**When:** {Scenario where this pattern applies.}

```{language}
{reusable code pattern}
```

### Pattern: {Pattern Name}

**When:** {Scenario where this pattern applies.}

See template: [templates/{template-file}](templates/{template-file})

Copy and customize:
```bash
cp SKILL_DIR/templates/{template-file} ./{output-file}
# Edit placeholders: {PLACEHOLDER_1}, {PLACEHOLDER_2}
```

---

## Troubleshooting

### Common Errors

| Error / Symptom | Root Cause | Fix |
|-----------------|-----------|-----|
| `{error message}` | {cause} | {fix} |
| `{error message}` | {cause} | Run `{command}` |
| {symptom} | {cause} | See [references/troubleshooting.md](references/troubleshooting.md) |

> For comprehensive troubleshooting:
> `references/troubleshooting.md`
> Search patterns: `{error keyword 1}`, `{symptom 1}`, `{error keyword 2}`

### Diagnostic Commands

```bash
# Verify {component} is available and authenticated
{diagnostic command}

# Check {configuration or state}
{diagnostic command}
```

---

## Configuration Reference

| Setting | Default | Description |
|---------|---------|-------------|
| `{SETTING_1}` | `{default}` | {What it controls} |
| `{SETTING_2}` | `{default}` | {What it controls} |
| `{SETTING_3}` | `{default}` | {What it controls} |

> For all configuration options: `references/configuration.md`

---

## Security Guidelines

- **Never** hardcode credentials in scripts or templates — use environment variables
- **Always** validate input paths before writing files
- **Prefer** least-privilege access (read-only where possible)
- **Audit** generated files before committing to version control
- **Rotate** any credentials that were accidentally logged

---

## References

- [references/api-reference.md](references/api-reference.md) — Full API/CLI reference
  Search patterns: `{api method}`, `{endpoint}`, `{parameter name}`
- [references/configuration.md](references/configuration.md) — All settings with defaults
  Search patterns: `{setting name}`, `configuration`, `options`
- [references/troubleshooting.md](references/troubleshooting.md) — Error diagnosis guide
  Search patterns: `{error keyword}`, `{symptom}`, `debug`
- [references/best-practices.md](references/best-practices.md) — Recommendations and anti-patterns
  Search patterns: `best practice`, `avoid`, `recommended`

## Templates

- [templates/{template-name}](templates/{template-name}) — {What the template is for}
- [templates/{template-name}](templates/{template-name}) — {What the template is for}

## Assets

- [assets/{asset-name}](assets/{asset-name}) — {What the asset is for}
