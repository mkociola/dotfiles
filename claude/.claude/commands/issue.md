---
description: Take a GitHub issue from triage to a simplified, reviewed implementation
argument-hint: [issue# | url] [unattended] [hint]
disable-model-invocation: true
allowed-tools: Bash(git branch:*), Bash(git status:*), Bash(gh issue view:*), Bash(gh issue list:*), Bash(gh repo view:*)
---

- Branch: !`git branch --show-current`
- Default branch: !`gh repo view --json defaultBranchRef -q .defaultBranchRef.name 2>/dev/null || echo main`
- Working tree: !`git status --short`
- Next available issue: !`gh issue list --search 'no:assignee -linked:pr author:@me sort:created-asc' --limit 1 --json number,title 2>/dev/null || echo unknown`

Issue: `$ARGUMENTS` (a number or URL; the word `unattended` switches on the section of that name;
any other text is a hint about intent). With no number, take the next available issue above. If
there is none, say so and stop.

Take the issue through the phases below, in order. The test suite passes before you leave each
phase. Work autonomously between phases; stop only where a phase says to.

## Models

This session makes every decision: triage, design, the plan, which review findings are real, which
one is out of scope enough to become a new issue. Whenever you dispatch a subagent, pass `model` and `effort` on the call:

- `opus`, `high`: implementers and any other subagent that writes code.
- `sonnet`, `medium`: the fleet. Codebase searches, the duplicate-issue search, running the tests
  and summarizing failures.

The inline paths in phase 2 stay in this session; don't delegate a small fix just to change model.

## Unattended

Applies only when the arguments contain `unattended`. Nobody is there to answer, and another run
follows this one.

- Never ask. Where a phase or a skill would put a question to me (the design approval in
  superpowers:brainstorming included), make the call yourself and record it under "Decisions" in the
  PR body.
- Where a phase says stop, comment on the issue with what is needed from me, then end the run.
- Phase 5 is: push the branch and `gh pr create` with `Closes #<n>` in the body. Never merge. When
  round three of the review still had a blocker or major, open the PR as a draft and list it.

## 1. Triage

If the working tree is dirty, stop before anything else. Assign the issue to yourself
(`gh issue edit <n> --add-assignee @me`), which is what takes it out of the next-available list.

`gh issue view <n> --comments`, then read the code it touches. State in two or three lines what it
asks for, whether it is a bug or a feature, and how big. Stop and say so if it is already fixed, a
duplicate, or blocked on an answer only I have. Otherwise the issue is the spec: don't ask me
anything it already answers.

If on the default branch, branch off as `<n>-<short-slug>`.

## 2. Implement

Use superpowers, scaled to what triage found:

- **Bug**: superpowers:systematic-debugging to the root cause, then
  superpowers:test-driven-development for the fix.
- **Feature, or anything with a real design choice**: superpowers:brainstorming (ask only what the
  issue leaves open), superpowers:writing-plans, then execute the plan, with
  superpowers:subagent-driven-development when its tasks are independent.
- **Obvious one-file change**: superpowers:test-driven-development, no plan document.

Finish with superpowers:verification-before-completion.

Every commit on the branch is a Conventional Commit, `type(scope): subject`, one concern each. That
covers commit commands written into a plan and commits made by subagents, so state the rule in each
subagent brief. The PR title uses the same form.

## 3. Simplify

Run ponytail:ponytail-review on the branch diff, once. Apply every cut that keeps behavior and rerun
the tests. Run it a second time only if the first pass removed something substantial.

## 4. Review loop

Run `/code-review high --fix` against the branch (pass the branch as the target when the work is already
committed). Treat findings per superpowers:receiving-code-review: check each against the code
before acting on it. Fix blockers and majors, rerun the tests, and go again.

Exit when a round reports no blocker or major. Hard cap: three rounds. If round three still has
one, stop and report it instead of starting a fourth. Minors and nits never start another round,
but they are fixed in the same pass like everything else.

Every real finding is fixed on this branch, in the round that finds it, whatever its severity and
whether or not the branch touched the line. A caller, a sibling, a neighbouring file the change
reaches, an old divergence a probe turned up next to the feature: all fixed here, each in a commit
of its own. A finding is real when you can show it with a failing test or a probe; one you cannot
show is dropped, and listed under "Not filed" in the report.

The one exception is a finding that is completely out of scope: it sits in a part of the codebase
the issue has nothing to do with, and fixing it would make the PR about two unrelated things.
"Untouched code" and "too big for this PR" are not reasons on their own. Such a finding always
gets a new issue of its own, `gh issue create` with `file:line`, the concrete failure scenario,
and "Found while working on #<n>"; never only a comment on an existing issue, which I will miss.
Check `gh issue list --search` first, and name any related issue in the new one's body. Say in the report why it was out of scope. A run that files more than one issue says so
at the top of the report.

## 5. Finish

superpowers:finishing-a-development-branch, with `Closes #<n>` in the PR body if I pick a PR
(unattended runs: see that section). Then report: what changed and why, review rounds used,
findings fixed outside the issue's own lines, findings not filed, issues filed (with links and
the reason each was out of scope).
