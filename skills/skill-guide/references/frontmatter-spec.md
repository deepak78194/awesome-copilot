# Frontmatter Field Specification

Complete reference for all YAML frontmatter fields supported in `SKILL.md` files.

---

## Frontmatter Block Syntax

```yaml
---
name: my-skill-name
description: 'What this skill does and when to trigger it.'
license: MIT
compatibility: 'Requires Node.js 18+, GitHub CLI authenticated'
metadata:
  author: your-name
  version: 1.0.0
  tags: azure, deployment, bicep
allowed-tools: Bash Python
context: fork
---
```

---

## Field Reference

### `name` (Required)

The unique identifier for the skill. Must match the containing folder name exactly.

**Type:** string
**Constraints:**
- Length: 1–64 characters
- Characters: `[a-z0-9-]` (lowercase letters, digits, hyphens)
- No consecutive hyphens (`--`)
- No leading or trailing hyphens

**Examples:**

```yaml
# ✅ Valid
name: git-commit
name: codeql
name: azure-deployment-preflight
name: python-mcp-server-generator

# ❌ Invalid
name: GitCommit          # uppercase
name: git_commit         # underscore
name: -git-commit        # leading hyphen
name: git--commit        # consecutive hyphens
```

**Validation:** The validator checks that `name` matches the folder name exactly using string comparison. Renaming the folder without updating `name` (or vice versa) will fail validation.

---

### `description` (Required)

The primary discovery signal. Copilot uses this field to determine whether to activate the skill for a given user request.

**Type:** string
**Constraints:**
- Length: 10–1024 characters
- Must be wrapped in single quotes to allow special characters
- Should describe WHAT the skill does AND WHEN to trigger it

**Structure:**

```yaml
description: '[WHAT it does]. Use when [TRIGGER SCENARIOS]. [OPTIONAL KEYWORDS].'
```

**Examples:**

```yaml
# Minimal acceptable
description: 'Generate Playwright tests from natural language scenarios.'

# Production quality
description: 'Generate a Playwright test based on a scenario using Playwright
  MCP. Use when asked to test frontend behavior, capture browser screenshots,
  verify UI interactions, or debug web application behavior in Chrome, Firefox,
  or WebKit.'

# With error/symptom keywords
description: 'Install npm packages in a Docker sandbox environment. Use this
  skill whenever you need to install, reinstall, or update node_modules inside
  a container where the workspace is mounted via virtiofs. Native binaries
  (esbuild, lightningcss, rollup) crash on virtiofs, so packages must be
  installed on the local ext4 filesystem and symlinked back.'
```

**Multi-line strings** in YAML use a block scalar or a quoted string with newlines:

```yaml
# Block scalar (|) — preserves literal newlines
description: |
  Comprehensive skill for Azure deployments.
  Use when provisioning or updating Azure resources.

# Folded scalar (>) — folds newlines into spaces
description: >
  Comprehensive skill for Azure deployments.
  Use when provisioning or updating Azure resources.

# Quoted inline (recommended for compatibility)
description: 'Comprehensive skill for Azure deployments. Use when provisioning or updating Azure resources.'
```

---

### `license` (Optional)

Specifies the license covering bundled assets (scripts, templates, data).

**Type:** string
**Examples:**

```yaml
# SPDX identifier
license: MIT
license: Apache-2.0
license: GPL-3.0

# Reference to bundled license file
license: Complete terms in LICENSE.txt
```

If your skill includes scripts or templates, specify a license. If omitted, the repository's default license (MIT for awesome-copilot) applies.

---

### `compatibility` (Optional)

Documents environment requirements, tool prerequisites, or platform constraints. Shown to users to help them decide whether a skill fits their environment.

**Type:** string
**Constraints:** Maximum 500 characters

**Examples:**

```yaml
# Tool version requirements
compatibility: 'Requires Node.js 18+, npm 9+'

# Platform-specific
compatibility: 'Tested on Ubuntu 22.04 and macOS 14. Windows support via WSL2.'

# MCP server requirements
compatibility: 'Works best with Microsoft Learn MCP Server. Falls back to mslearn CLI.'

# Multi-line with YAML block scalar
compatibility: |
  - Node.js 18 or higher
  - GitHub CLI (gh) authenticated
  - Docker Desktop 4.x (optional, for container-based workflows)
```

---

### `metadata` (Optional)

Arbitrary key-value pairs for tracking authorship, version, tags, or any organization-specific metadata.

**Type:** YAML mapping (key-value pairs)

**Common conventions:**

```yaml
metadata:
  author: jane.doe@example.com
  version: 2.1.0
  tags: azure, bicep, infrastructure
  team: platform-engineering
  updated: 2025-06-01
  reviewedBy: security-team
```

**Organization usage:** Use `metadata` to tag skills for internal cataloging, ownership tracking, or governance workflows. For example:

```yaml
metadata:
  owner: platform-team
  approval: security-approved-2025-Q2
  classification: internal
```

---

### `allowed-tools` (Optional, Experimental)

A space-delimited list of tools that the skill is pre-authorized to use, reducing confirmation prompts during execution.

**Type:** string (space-separated tool names)

**Common tool names:**

| Tool Name | Capability |
|-----------|-----------|
| `Bash` | Run shell commands in a terminal |
| `Python` | Execute Python scripts |
| `EditFiles` | Read and write files in the workspace |
| `Fetch` | Make HTTP requests |
| `GitHubAPI` | Call GitHub REST/GraphQL APIs |

**Examples:**

```yaml
# Single tool
allowed-tools: Bash

# Multiple tools
allowed-tools: Bash Python EditFiles

# Complex workflow
allowed-tools: Bash Fetch GitHubAPI
```

> **Note:** This field is experimental and behavior may vary across Copilot versions and clients. Test in your target environment.

---

### `context` (Optional)

Controls how the skill's context window is managed.

**Type:** string

| Value | Behavior |
|-------|---------|
| `fork` | Creates a separate context branch for the skill, keeping it isolated from the main conversation |

**Example:**

```yaml
context: fork
```

Use `context: fork` when the skill performs a substantial self-contained workflow that should not bleed into the ongoing chat session.

---

## Complete Production Example

```yaml
---
name: azure-deployment-preflight
description: 'Run preflight checks before deploying Azure resources via Bicep or
  ARM templates. Use when asked to validate a deployment, check quotas, verify
  permissions, or dry-run an Azure deployment before applying it. Covers
  subscription limits, RBAC, resource provider registration, and naming
  convention validation.'
license: MIT
compatibility: 'Requires Azure CLI (az) authenticated. Tested with Azure CLI
  2.50+. Optional: Bicep CLI 0.20+ for Bicep-specific validations.'
metadata:
  author: platform-team@example.com
  version: 1.2.0
  tags: azure, bicep, arm, deployment, validation
  approvedBy: cloud-security-team
  updated: 2025-03-01
allowed-tools: Bash
---
```
