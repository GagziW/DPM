#!/usr/bin/env bash
# Safely fast-forward every Git repository in the DPM workspace.
#
# Local changes stay in place. When an incoming commit also changes a file you
# changed, the script stashes your changes around the fast-forward, but only after
# it has checked that they apply again without conflicts.
set -u

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPOSITORIES=(
  "."
  "DPMv4"
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

  if ! git -C "${path}" fetch --quiet; then
    echo "FAIL: could not fetch ${upstream}" >&2
    ((failed += 1))
    continue
  fi

  if ! counts="$(git -C "${path}" rev-list --left-right --count "HEAD...${upstream}" 2>/dev/null)"; then
    echo "FAIL: could not compare ${branch} with ${upstream}" >&2
    ((failed += 1))
    continue
  fi
  read -r ahead behind <<<"${counts}"
  changed="$(git -C "${path}" status --porcelain | wc -l | tr -d ' ')"
  ((changed > 0)) && echo "Keeping ${changed} local change(s)."

  if ((behind == 0)); then
    echo "${branch} is up to date with ${upstream}."
    ((ahead > 0)) && echo "${branch} has ${ahead} commit(s) not pushed to ${upstream}."
    ((current += 1))
    continue
  fi

  if ((ahead > 0)); then
    echo "FAIL: ${branch} has ${ahead} local commit(s) not on ${upstream} and is ${behind} behind." >&2
    echo "      Replay them on top and publish: git -C \"${path}\" pull --rebase --autostash && git -C \"${path}\" push" >&2
    ((failed += 1))
    continue
  fi

  # Files that you changed and that the incoming commits also change.
  overlap="$(comm -12 \
    <(git -C "${path}" diff --name-only HEAD "${upstream}" | sort) \
    <(git -C "${path}" diff --name-only HEAD | sort))"

  merge_args=(--ff-only)
  if [[ -n "${overlap}" ]]; then
    # Merge a snapshot of the working tree with the incoming commits in memory.
    # This does not touch the working tree, the index or the stash list.
    snapshot="$(git -C "${path}" stash create)"
    if ! conflicts="$(git -C "${path}" merge-tree --write-tree --name-only --no-messages \
      --merge-base=HEAD "${snapshot}" "${upstream}")"; then
      echo "FAIL: the incoming commits conflict with your changes in:" >&2
      tail -n +2 <<<"${conflicts}" | sed 's/^/      /' >&2
      echo "      Commit or stash these changes, then run the script again." >&2
      ((failed += 1))
      continue
    fi
    merge_args+=(--autostash)
  fi

  if ! git -C "${path}" merge "${merge_args[@]}" "${upstream}"; then
    echo "FAIL: could not fast-forward ${branch} from ${upstream}" >&2
    ((failed += 1))
    continue
  fi

  unmerged="$(git -C "${path}" diff --name-only --diff-filter=U)"
  if [[ -n "${unmerged}" ]]; then
    echo "FAIL: your changes did not apply cleanly after the fast-forward. They are safe in the stash." >&2
    echo "${unmerged}" | sed 's/^/      /' >&2
    echo "      Fix the conflict markers in these files, then run: git -C \"${path}\" stash drop" >&2
    ((failed += 1))
    continue
  fi

  ((updated += 1))
done

printf '\nSync complete: %d updated, %d already current, %d skipped, %d failed.\n' \
  "${updated}" "${current}" "${skipped}" "${failed}"

if ((skipped > 0 || failed > 0)); then
  exit 1
fi
