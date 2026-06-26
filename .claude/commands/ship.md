---
description: Branch, commit, and open a PR for the current work
argument-hint: [short description of the feature or fix]
allowed-tools: Bash(git:*), Bash(gh:*), Bash(cd:*), Read, Grep, Glob
---

You are shipping the current work as a pull request. The user's description: **$ARGUMENTS**

This is a monorepo where the root (`/Users/gagzi/Code/DPM`) is **not** a git repo — each platform is its own repo (`DPMSwift/`, `cloud-functions/`, `DPM.org/`, `DPMAndroid/`, `admin-board/`, `firebase-admin/`). All git/gh commands MUST run inside the correct sub-repo.

## Steps

1. **Locate the repo with changes.** Run `git -C <subdir> status --porcelain` across the sub-repos to find which one(s) have uncommitted changes.
   - If exactly one has changes, use it.
   - If several do, STOP and ask the user which repo to ship (changes spanning repos are separate PRs).
   - If none do, the work may already be committed on a feature branch — check `git -C <subdir> branch --show-current` / `git -C <subdir> log`; otherwise tell the user there's nothing to ship.

2. **Review what's changing.** Run `git -C <repo> diff` (and `git -C <repo> diff --staged`) and read enough to write an accurate branch name, commit message, and PR body. Do not skip this — never describe a change you haven't looked at.

3. **Branch off the default branch.** Determine the default branch with `git -C <repo> symbolic-ref refs/remotes/origin/HEAD` (fall back to `main`/`master`).
   - If currently ON the default branch, create a new branch first: `feat/<slug>` for features, `fix/<slug>` for fixes — pick the prefix from the nature of the change, slug derived from "$ARGUMENTS".
   - If already on a suitable feature branch, stay on it (don't create another).
   - Never commit directly to the default branch.

4. **Commit.** Stage the relevant files and commit. Use `EDITOR=vim VISUAL=vim` for any git command that may open an editor (per project convention — never nano). Write a concise, conventional commit message (imperative subject line, body explaining the *why* if non-trivial). End the commit message with:

   ```
   Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>
   ```

5. **Push and open the PR.** `git -C <repo> push -u origin <branch>`, then `gh pr create` (run from inside `<repo>`) with a clear title and a body that summarizes what changed and why, plus a test plan / verification notes if relevant. End the PR body with:

   ```
   🤖 Generated with [Claude Code](https://claude.com/claude-code)
   ```

6. **Report.** Print the PR URL `gh` returns.

## Rules

- Confirm the target repo, branch name, and commit message plan with the user **before** pushing if anything is ambiguous; pushing and PR creation are outward-facing, so don't guess on those.
- If `gh` isn't authenticated (`gh auth status` fails), stop and tell the user to run `! gh auth login` rather than failing silently.
- One repo = one PR. Don't bundle unrelated changes.
- If `$ARGUMENTS` is empty, infer the description from the diff and confirm it with the user before committing.
