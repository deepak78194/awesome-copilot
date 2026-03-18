# Description Writing Guide

The `description` field is the most important part of a skill. It determines whether the skill is discovered and activated. This guide explains how to write descriptions that work.

---

## Why Description Matters

When a user sends a message to GitHub Copilot, the agent scans all available skill descriptions to decide which skills to load. A vague description means the skill never triggers. An over-broad description triggers the skill when it shouldn't.

**The description is your only marketing copy.**

---

## The WHAT + WHEN Formula

Every production-quality description follows this structure:

```
[WHAT the skill does] + [WHEN / TRIGGER CONDITIONS] + [KEYWORD CLUSTERS]
```

### Example breakdown

```
"Comprehensive guide for setting up and configuring CodeQL code scanning
 via GitHub Actions workflows and the CodeQL CLI."
 ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
 WHAT: what the skill does

"This skill should be used when users need help with code scanning
 configuration, CodeQL workflow files, CodeQL CLI commands, SARIF output,
 security analysis setup, or troubleshooting CodeQL analysis."
 ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
 WHEN + KEYWORDS: triggers and keyword clusters
```

---

## Keyword Categories

Include keywords from each relevant category to maximize discoverability:

### 1. Action Verbs (what the agent does)

```
create, generate, configure, debug, deploy, migrate, analyze,
scaffold, instrument, validate, publish, install, convert,
troubleshoot, review, optimize, visualize, automate, integrate
```

### 2. Object Nouns (what is being acted on)

```
workflow, Dockerfile, Bicep template, SARIF, OpenAPI spec,
commit message, GitHub Action, database schema, API endpoint,
test suite, migration script, architecture diagram, README
```

### 3. Technology Names (specific tools/frameworks)

```
Azure, Docker, Kubernetes, TypeScript, pytest, Playwright,
GitHub Actions, CodeQL, Terraform, Bicep, React, Next.js,
FastAPI, Spring Boot, Semantic Kernel, Cosmos DB
```

### 4. User Intent Phrases (what users say)

```
"set up", "get started", "add telemetry", "deploy to",
"scaffold a", "generate a", "create a", "troubleshoot",
"debug", "fix", "optimize", "migrate from ... to ..."
```

### 5. Error / Symptom Keywords (for debugging skills)

```
"build fails", "SIGILL", "out of memory", "403 error",
"authentication fails", "quota exceeded", "no source code",
"native binary crash", "mmap alignment"
```

### 6. Slash Commands / Trigger Phrases

```
"/commit", "/review", "/test", "create a skill",
"make a diagram", "scaffold a project"
```

---

## Length Guidelines

| Description Quality | Length | Effect |
|--------------------|--------|--------|
| Minimal (too short) | 10–30 chars | Rarely triggers; vague |
| Adequate | 30–150 chars | Triggers on obvious requests |
| Good | 150–400 chars | Triggers on most relevant requests |
| Production | 400–800 chars | High recall; triggers on edge cases too |
| Too long | > 1024 chars | Validation fails |

**Sweet spot for production:** 300–700 characters.

---

## Good vs. Poor Examples

### Example 1: Git skill

```yaml
# ❌ Poor — no triggers, no keywords
description: 'Git commit helper'

# ❌ Okay — has WHAT but no WHEN
description: 'Creates conventional commit messages using the Conventional Commits specification.'

# ✅ Good — has WHAT + WHEN + keywords
description: 'Execute git commit with conventional commit message analysis,
  intelligent staging, and message generation. Use when user asks to commit
  changes, create a git commit, or mentions "/commit". Supports:
  (1) Auto-detecting type and scope from changes,
  (2) Generating conventional commit messages from diff,
  (3) Interactive commit with optional type/scope/description overrides,
  (4) Intelligent file staging for logical grouping'
```

### Example 2: Testing skill

```yaml
# ❌ Poor
description: 'Playwright testing'

# ❌ Okay
description: 'Generate Playwright tests for web applications.'

# ✅ Good
description: 'Generate a Playwright test based on a scenario using Playwright
  MCP. Use when asked to verify frontend functionality, debug UI behavior,
  capture browser screenshots, or view browser console logs. Supports
  Chrome, Firefox, and WebKit.'
```

### Example 3: Azure skill

```yaml
# ❌ Poor
description: 'Azure stuff'

# ❌ Okay
description: 'Help with Azure resource management and deployment.'

# ✅ Production
description: 'Run preflight checks before deploying Azure resources via Bicep
  or ARM templates. Use when asked to validate a deployment, check quotas,
  verify permissions, or dry-run a deployment. Covers subscription quota
  validation, RBAC permission checks, resource provider registration,
  naming convention validation, and dependency resolution before applying
  any changes.'
```

---

## Trigger Phrase Patterns

Include at least 3–5 different ways a user might phrase the same request.

### Same intent, different phrasings

| Intent | Trigger Phrases to Include |
|--------|---------------------------|
| Create a commit | "commit changes", "create a git commit", "/commit", "stage and commit" |
| Generate a diagram | "create a diagram", "make a flowchart", "visualize", "draw", "generate an Excalidraw file" |
| Set up telemetry | "add telemetry", "instrument the app", "enable App Insights", "add observability" |
| Install npm packages | "install packages", "npm install", "set up node_modules", "install dependencies" |
| Create a skill | "create a skill", "make a new skill", "scaffold a skill", "build a skill" |

---

## Multi-Audience Skills

If a skill serves multiple use cases, list each in the description:

```yaml
description: 'Analyze Azure resource groups and generate detailed Mermaid
  architecture diagrams showing relationships between individual resources.
  Use this skill when the user asks for a diagram of their Azure resources,
  help in understanding how the resources relate to each other, wants to
  document their cloud architecture, or needs to audit resource dependencies
  for compliance or cost optimization.'
```

---

## Common Description Mistakes

### Mistake 1: Only stating the name

```yaml
# ❌ The skill name is already known — description adds no value
name: playwright-generate-test
description: 'Playwright test generator'
```

**Fix:** Describe the workflow, inputs, outputs, and triggers.

### Mistake 2: Using only passive voice

```yaml
# ❌ Hard to match against user's active intent
description: 'Tests are generated for frontend applications by analyzing user scenarios.'
```

**Fix:** Use active voice and action verbs that match how users phrase requests.

### Mistake 3: Missing triggers

```yaml
# ❌ WHAT is clear but WHEN is missing
description: 'Configures CodeQL scanning for GitHub repositories using GitHub Actions workflows.'
```

**Fix:** Add `Use when...` clause with specific trigger phrases.

### Mistake 4: Over-broad description

```yaml
# ❌ Too vague — will trigger on unrelated requests
description: 'Helps with coding tasks in JavaScript and TypeScript applications.'
```

**Fix:** Be specific about the workflow and context.

### Mistake 5: Technology soup

```yaml
# ❌ Lists technologies without context
description: 'Azure, Bicep, ARM, RBAC, Azure CLI, Azure Portal, Resource Groups, Subscriptions'
```

**Fix:** Embed technology names within natural phrases.

---

## Testing Your Description

Before committing, test your description against these questions:

1. **Would a colleague reading only the description know what this skill does?**
2. **If I typed "[common user request for this skill]" in Copilot, would the description match?**
3. **Are there 3+ different phrasings a user might use included?**
4. **Does it include at least one error/symptom keyword if this is a debugging skill?**
5. **Is it between 100 and 900 characters?**

---

## Quick Template

Copy and fill in:

```yaml
description: '[WHAT: one-sentence capability summary]. Use when [TRIGGER 1],
  [TRIGGER 2], [TRIGGER 3], or [TRIGGER 4]. [OPTIONAL: Supports TECHNOLOGY/PLATFORM].
  [OPTIONAL: Covers TOPIC1, TOPIC2, TOPIC3, or TOPIC4 scenarios.]'
```

**Example filled:**

```yaml
description: 'Scaffold and configure MCP (Model Context Protocol) servers in
  Python. Use when asked to create an MCP server, build a Copilot plugin,
  add tool-calling to an AI agent, or integrate with the MCP protocol.
  Supports FastMCP and the official Python MCP SDK. Covers authentication,
  tool registration, resource endpoints, and deployment to cloud platforms.'
```
