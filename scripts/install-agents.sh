#!/bin/bash
# Script to install agents from the awesome-copilot collection into any target directory.
#
# Usage:
#   bash scripts/install-agents.sh                        # List available agents
#   bash scripts/install-agents.sh --agent <name>         # Install a specific agent
#   bash scripts/install-agents.sh --target <dir>         # Override the target directory
#   bash scripts/install-agents.sh --all                  # Install all agents
#
# By default, agents are installed to .github/agents/ in the current working directory.
# GitHub Copilot automatically discovers agents placed in .github/agents/.
# Custom locations can also be used — see README for VS Code workspace settings.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
AGENTS_SRC_DIR="$REPO_ROOT/agents"

TARGET_DIR=".github/agents"
AGENT_NAME=""
INSTALL_ALL=false
FORCE=false

# Parse arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    --agent)
      AGENT_NAME="$2"
      shift 2
      ;;
    --target)
      TARGET_DIR="$2"
      shift 2
      ;;
    --all)
      INSTALL_ALL=true
      shift
      ;;
    --force)
      FORCE=true
      shift
      ;;
    --help|-h)
      echo "Usage: bash scripts/install-agents.sh [options]"
      echo ""
      echo "Options:"
      echo "  --agent <name>   Install a specific agent (file name without .agent.md extension)"
      echo "  --target <dir>   Override the target directory (default: .github/agents)"
      echo "  --all            Install all agents"
      echo "  --force          Overwrite existing agent files"
      echo "  --help           Show this help message"
      echo ""
      echo "Agent locations:"
      echo "  Standard:  .github/agents/   (auto-discovered by GitHub Copilot)"
      echo "  Custom:    any directory configured in VS Code settings"
      echo ""
      echo "VS Code workspace setting to scan custom agent directories:"
      echo '  "github.copilot.chat.agentScanPaths": ["agents", ".github/agents"]'
      exit 0
      ;;
    *)
      echo "Unknown option: $1"
      echo "Run with --help for usage."
      exit 1
      ;;
  esac
done

# List available agents if no action specified
if [[ -z "$AGENT_NAME" && "$INSTALL_ALL" == "false" ]]; then
  echo "Available agents in this collection:"
  echo ""
  for f in "$AGENTS_SRC_DIR"/*.agent.md; do
    basename "$f" .agent.md
  done | sort
  echo ""
  echo "To install an agent, run:"
  echo "  bash scripts/install-agents.sh --agent <name>"
  echo "  bash scripts/install-agents.sh --all"
  exit 0
fi

# Ensure target directory exists
mkdir -p "$TARGET_DIR"

install_agent() {
  local src="$1"
  local dest_dir="$2"
  local filename
  filename="$(basename "$src")"
  local dest="$dest_dir/$filename"

  if [[ -f "$dest" && "$FORCE" == "false" ]]; then
    echo "  [skip] $filename already exists in $dest_dir (use --force to overwrite)"
  else
    cp "$src" "$dest"
    echo "  [ok]   $filename -> $dest"
  fi
}

if [[ "$INSTALL_ALL" == "true" ]]; then
  echo "Installing all agents to $TARGET_DIR ..."
  for f in "$AGENTS_SRC_DIR"/*.agent.md; do
    install_agent "$f" "$TARGET_DIR"
  done
  echo ""
  echo "Done. $(ls "$TARGET_DIR"/*.agent.md 2>/dev/null | wc -l) agent(s) available in $TARGET_DIR"
else
  # Find agent by name (with or without .agent.md extension)
  AGENT_FILE="${AGENT_NAME%.agent.md}.agent.md"
  SRC="$AGENTS_SRC_DIR/$AGENT_FILE"

  if [[ ! -f "$SRC" ]]; then
    echo "Error: Agent '$AGENT_NAME' not found in $AGENTS_SRC_DIR"
    echo ""
    echo "Available agents:"
    for f in "$AGENTS_SRC_DIR"/*.agent.md; do
      echo "  $(basename "$f" .agent.md)"
    done | sort
    exit 1
  fi

  echo "Installing agent '$AGENT_NAME' to $TARGET_DIR ..."
  install_agent "$SRC" "$TARGET_DIR"
  echo ""
  echo "Done. Activate the agent in VS Code via the agent picker or assign it in Copilot coding agent."
fi
