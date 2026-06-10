#!/usr/bin/env bash
# Bootstrap the DPM workspace: clone every product repo into place.
# Idempotent — skips anything already cloned.
set -euo pipefail
cd "$(dirname "$0")"

clone() {
  if [ -d "$2/.git" ]; then
    echo "✓ $2 already cloned"
  else
    git clone "$1" "$2"
  fi
}

clone git@github.com:GagziW/DopaminingSwift.git     DPMSwift
clone git@github.com:GagziW/DPM_cloud_functions.git cloud-functions
clone git@github.com:GagziW/DPM.org.git             website
clone git@github.com:GagziW/DPMAndroid.git          DPMAndroid
clone git@github.com:GagziW/DPM_admin_board.git     admin-board
clone git@github.com:GagziW/DPMdocs.git             docs

echo
echo "Done. Next steps:"
echo "  1. firebase login   (project: dopaminingswift)"
echo "  2. Open Claude Code from this directory — it picks up CLAUDE.md/AGENTS.md,"
echo "     .claude/ (skills, agents, hooks, settings) and .mcp.json automatically."
echo "  3. Read docs/CONTRACT.md before touching any shared Firestore field,"
echo "     callable, or security rule."
