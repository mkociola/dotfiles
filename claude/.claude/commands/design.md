---
description: Design and simplicity review of a PR, a branch, or the current diff — the big-picture pass /code-review doesn't do
argument-hint: [PR# | url | branch]
context: fork
effort: xhigh
disable-model-invocation: true
allowed-tools: Bash(git diff:*), Bash(git log:*), Bash(git show:*), Bash(git branch:*), Bash(git merge-base:*), Bash(git status:*), Bash(gh pr:*), Bash(gh repo:*)
---

- Branch: !`git branch --show-current`
- Default branch: !`gh repo view --json defaultBranchRef -q .defaultBranchRef.name 2>/dev/null || echo main`
- Open PR for this branch: !`gh pr view --json number,title,url 2>/dev/null || echo none`

Target: `$ARGUMENTS` — a PR number, a PR URL, a branch name, or empty for the current branch.

Review the target for design and simplicity only. Correctness, reuse of existing helpers, and
micro-efficiency are `/code-review`'s job; do not report them here.

## 1. Resolve the target and read around it

- **PR number or URL** → `gh pr diff <n>` for the diff, `gh pr view <n>` for the description.
- **Branch name** → `git diff $(git merge-base <default> <branch>) <branch>`.
- **Empty** → `git diff $(git merge-base HEAD <default>)`, which includes uncommitted work, plus
  untracked files from `git status --short`.

Read the whole diff, then the files around it: callers, siblings, the module's other users. A diff
can't tell you whether an abstraction has three other users off-screen, or whether the guard you'd
ask for already lives in the caller. Do this before forming a single finding.

## 2. Two passes

**Design.** Boundary and layering violations. Abstractions that fit this one case but not the next
obvious one. Data-model, schema, and wire-format choices that are hard to walk back. State reachable
from two places. New coupling between things that were independent. Failure modes bolted on rather
than designed in. Special cases layered on shared infrastructure where the mechanism underneath
should generalize instead. Anything much more expensive to change in six months than today.

**Simplification.** Complexity that isn't earned: an abstraction with one caller, a config knob
nobody asked for, indirection that only forwards, a pattern applied because it's a pattern. Nesting
that flattens with an early return or a lookup table. State that could be derived instead of stored.
Parameters and flags with one call site. Two code paths that want to be one. Frame every one of
these as a deletion.

KISS governs. When a finding can be phrased as "add X" or "remove Y", prefer "remove Y". When two
findings conflict, the simpler design wins. Never recommend structure to satisfy a principle in the
abstract.

## 3. Filter, before anything is shown

Drop a finding, silently, unless it passes every gate:

- **Concrete scenario.** Inputs or state that produce a concrete wrong, slow, or expensive outcome,
  or a concrete future change this makes expensive. "In theory" is not a finding.
- **Refute it first.** Go back to the code and try to prove yourself wrong. Keep only survivors.
- **In scope.** Pre-existing problems the diff merely sits next to don't count unless the diff makes
  them worse.
- **Matches the repo.** If the surrounding code already answers the question a different way, that's
  the convention, not a finding.
- **No speculative scale.** "Won't hold at 10M rows" needs evidence that 10M rows is coming.
- **The real-PR test.** Would you actually type this on someone's PR, or shrug and approve? If you'd
  shrug, drop it.
- **Simplifications name what goes away** — a file, a branch, a parameter, a concept — and confirm
  behavior is unchanged. The same size in different clothes is not a simplification.

## 4. Report

Findings in priority order, each as two blocks:

1. **In plain terms** — `file:line`, then one or two jargon-free sentences: what's wrong and what
   it costs.
2. **Proposed change** — what should happen to the code, in one or two lines.

Then one line: `Dropped N findings that didn't survive the filter.` Zero findings is a complete
answer: "The design is sound, nothing worth raising."
