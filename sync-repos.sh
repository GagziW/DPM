#!/usr/bin/env bash
# Safely fast-forward every Git repository in the DPM workspace.
set -u

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPOSITORIES=(
  "."
  "DopaminingSwift"
  "DPM_cloud_functions"
  "DPM.org"
  "DPMAndroid"
  "DPM_admin_board"
  "docs"
)

updated=0
current=0
skipped=0
failed=0

for repository in "${REPOSITORIES[@]}"; do
  path="${ROOT_DIR}/${repository}"
  label="${repository}"
  [[ "${repository}" == "." ]] && label="DPM (workspace)"

  printf '\n==> %s\n' "${label}"

  if [[ ! -d "${path}/.git" ]]; then
    echo "SKIP: repository is not cloned"
    ((skipped += 1))
    continue
  fi

  if [[ -n "$(git -C "${path}" status --porcelain)" ]]; then
    echo "SKIP: working tree has local changes"
    git -C "${path}" status --short
    ((skipped += 1))
    continue
  fi

  branch="$(git -C "${path}" symbolic-ref --quiet --short HEAD 2>/dev/null || true)"
  if [[ -z "${branch}" ]]; then
    echo "SKIP: HEAD is detached"
    ((skipped += 1))
    continue
  fi

  upstream="$(git -C "${path}" rev-parse --abbrev-ref --symbolic-full-name '@{upstream}' 2>/dev/null || true)"
  if [[ -z "${upstream}" ]]; then
    echo "SKIP: ${branch} has no upstream branch"
    ((skipped += 1))
    continue
  fi

  before="$(git -C "${path}" rev-parse HEAD)"
  if ! git -C "${path}" pull --ff-only; then
    echo "FAIL: could not fast-forward ${branch} from ${upstream}" >&2
    ((failed += 1))
    continue
  fi

  after="$(git -C "${path}" rev-parse HEAD)"
  if [[ "${before}" == "${after}" ]]; then
    ((current += 1))
  else
    ((updated += 1))
  fi
done

printf '\nSync complete: %d updated, %d already current, %d skipped, %d failed.\n' \
  "${updated}" "${current}" "${skipped}" "${failed}"

if ((skipped > 0 || failed > 0)); then
  exit 1
fi
