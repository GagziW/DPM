#!/usr/bin/env bash
# Install the canonical global skill set once and share it between Codex and Claude.
set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
GLOBAL_SKILLS_DIR="${HOME}/.agents/skills"
CLAUDE_DIR="${HOME}/.claude"
CLAUDE_SKILLS="${CLAUDE_DIR}/skills"

MATT_SKILLS=(
  ask-matt
  code-review
  codebase-design
  domain-modeling
  grill-me
  grill-with-docs
  grilling
  handoff
  implement
  improve-codebase-architecture
  research
  resolving-merge-conflicts
  setup-matt-pocock-skills
  tdd
  to-spec
  to-tickets
  triage
  wayfinder
  wizard
  writing-for-agents
)

EXPECTED_SKILLS=("${MATT_SKILLS[@]}" find-skills)

if ! command -v npx >/dev/null 2>&1; then
  echo "npx is required. Install Node.js, then rerun this script." >&2
  exit 1
fi

npx --yes skills@latest add mattpocock/skills \
  --global --yes --agent codex claude-code --skill "${MATT_SKILLS[@]}"
npx --yes skills@latest add vercel-labs/skills \
  --global --yes --agent codex claude-code --skill find-skills

mkdir -p "${CLAUDE_DIR}"
if [[ -L "${CLAUDE_SKILLS}" ]]; then
  if [[ "$(readlink "${CLAUDE_SKILLS}")" != "../.agents/skills" ]]; then
    echo "Refusing to replace unexpected symlink: ${CLAUDE_SKILLS}" >&2
    exit 1
  fi
elif [[ -e "${CLAUDE_SKILLS}" ]]; then
  echo "Refusing to replace existing path: ${CLAUDE_SKILLS}" >&2
  echo "Move it aside, then rerun this script." >&2
  exit 1
else
  ln -s ../.agents/skills "${CLAUDE_SKILLS}"
fi

expected_list="$(printf '%s\n' "${EXPECTED_SKILLS[@]}" | sort)"
installed_list="$({
  find "${GLOBAL_SKILLS_DIR}" -mindepth 1 -maxdepth 1 -type d -exec basename {} \;
} | sort)"

missing="$(comm -23 <(printf '%s\n' "${expected_list}") <(printf '%s\n' "${installed_list}"))"
extra="$(comm -13 <(printf '%s\n' "${expected_list}") <(printf '%s\n' "${installed_list}"))"

if [[ -n "${missing}" ]]; then
  echo "Missing global skills:" >&2
  printf '%s\n' "${missing}" >&2
  exit 1
fi

if [[ -n "${extra}" ]]; then
  echo "Unexpected global skills (left untouched):" >&2
  printf '%s\n' "${extra}" >&2
  exit 1
fi

project_skills_dir="${ROOT_DIR}/.agents/skills"
if [[ -d "${project_skills_dir}" ]]; then
  project_list="$({
    find "${project_skills_dir}" -mindepth 1 -maxdepth 1 -type d -exec basename {} \;
  } | sort)"
  duplicates="$(comm -12 <(printf '%s\n' "${installed_list}") <(printf '%s\n' "${project_list}"))"
  if [[ -n "${duplicates}" ]]; then
    echo "Duplicate global/project skill names:" >&2
    printf '%s\n' "${duplicates}" >&2
    exit 1
  fi
fi

echo "Agent skills are synchronized: ${#EXPECTED_SKILLS[@]} global skills, one shared copy."
