---
description: Commit the current changes as Conventional Commits, then push
argument-hint: [branch [name]] [hint]
allowed-tools: Bash(git status:*), Bash(git diff:*), Bash(git log:*), Bash(git branch:*)
---

- Branch: !`git branch --show-current`
- Status: !`git status --short`
- Unstaged: !`git diff --stat`
- Staged: !`git diff --cached --stat`
- Recent messages: !`git log --oneline -10`

Commit everything below as clean history, then push.

1. Read the full diff first. Group it into logical units — one concern per commit. A subject
   that needs an "and" is two commits. Stage per path, or `git add -p` when one file holds two
   concerns. Don't sweep in changes that look accidental (stray lockfile, debug print); leave
   them unstaged and say so.
2. Message per commit: `type(scope): subject`. Imperative, lowercase, no trailing period, under
   ~65 chars. Scope is the package or module touched — reuse the vocabulary in the log above
   rather than inventing one. Body only when the diff doesn't show the *why*.
3. Destination:
   - `$ARGUMENTS` begins with `branch` → branch off the current HEAD first, using the name that
     follows or a short kebab-case one derived from the change, then push with `-u`.
   - Otherwise commit on the current branch and push it.
   - Any other text in `$ARGUMENTS` is a hint about intent — it feeds the message, not the branch.
4. If the push is rejected, stop and report it. Never force-push, never rebase to fix it.
5. Report one line per commit (`hash subject`) and the branch it landed on.
