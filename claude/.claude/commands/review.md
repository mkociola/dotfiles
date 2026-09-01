---
description: Review a PR or the current diff — architecture and simplicity first, then correctness
argument-hint: [PR# | url | branch]
allowed-tools: Bash(git diff:*), Bash(git log:*), Bash(git branch:*), Bash(git merge-base:*), Bash(gh pr:*), Bash(gh api:*)
---

- Branch: !`git branch --show-current`
- PR for this branch: !`gh pr view --json number,title,headRefName,baseRefName 2>/dev/null || echo "none"`
- Default branch: !`gh repo view --json defaultBranchRef -q .defaultBranchRef.name 2>/dev/null || echo "main"`
- Diffstat vs merge base (includes uncommitted): !`git diff --stat "$(git merge-base HEAD origin/HEAD 2>/dev/null || git merge-base HEAD main 2>/dev/null || echo HEAD)" 2>/dev/null | tail -20`
- Untracked: !`git ls-files --others --exclude-standard | head -10`

Review the target below. Architecture and simplicity first, correctness second, style barely at all.

## 1. Resolve the target

`$ARGUMENTS` is a PR number, a PR URL, a branch name, or empty.

- **PR number or URL** → `gh pr diff <n>` for the diff, `gh pr view <n>` for the description and
  the head SHA. Comment loop **on**.
- **Branch name** → diff it against its merge base with the default branch. Comment loop on only if
  that branch has an open PR.
- **Empty** → everything since the merge base *including uncommitted work* — `git diff <merge-base>`,
  plus any untracked files listed in the preamble. Comment loop on only if the current branch has an
  open PR (see the preamble above); if there's uncommitted work, say so and review it in the
  terminal rather than posting, since it isn't on GitHub yet.

Read the diff in full. Then read the *files around it* — a diff can't tell you whether the guard
you're about to ask for already lives in the caller, or whether the abstraction you're about to
question has three other users off-screen. Do this before forming a single finding.

## 2. Review passes, in priority order

**Architecture and design — primary.** Boundary and layering violations. Abstractions that fit this
one case but not the next obvious one. Data-model and schema choices that are hard to walk back.
State now reachable from two places. New coupling between things that were independent. API or
wire-format changes that break callers. Failure modes designed in versus bolted on. Anything much
more expensive to change in six months than today. And complexity that isn't earned: an abstraction
with one caller, a config knob nobody asked for, a layer of indirection that only forwards, a
pattern applied because it's a pattern.

**Simplification — primary.** Could this do the same job with materially less? Logic the repo
already has a utility for. Hand-rolled stdlib, or a dep that's already in the manifest. Nesting that
flattens with an early return or a lookup table. State that could be derived instead of stored.
Parameters and flags with one call site. Dead paths the diff leaves behind. Two code paths that want
to be one. Frame every one of these as a deletion.

**Correctness and robustness.** Does it do what the PR claims? Edge cases: empty, single, boundary,
unicode, concurrent, retried, partially failed. Error paths and cleanup. Off-by-one, unchecked
nil/None, silently swallowed errors. Tests that assert the wrong thing, or don't cover the branch
the diff adds.

**Quality — only when it matters.** Raise it only when it materially hurts readability or
maintainability. Not taste. Not anything the formatter or linter owns.

KISS is the governing bias. Simplicity outranks cleverness, completeness, and pattern-conformance.
When a finding can be phrased as "add X" or "remove Y", prefer "remove Y". When two findings
conflict, the simpler design wins. Never recommend adding structure to satisfy a principle in the
abstract.

## 3. Filter, before anything is shown

Every finding must pass every gate. Drop it otherwise — silently.

- **Name the scenario.** Concrete inputs or state producing a concrete wrong, slow, or expensive
  outcome. "In theory this could…" is not a finding.
- **Refute it first.** Go back to the code and actively try to prove yourself wrong. Is the guard
  already in the caller, the framework, the type system, a migration, a test? Keep only survivors.
- **Stay in scope.** Pre-existing problems the diff merely sits next to don't count unless the diff
  makes them worse.
- **Match the repo, not your preference.** If the surrounding code already answers the question a
  different way, that's the convention — not a finding.
- **No speculative scale.** "This won't hold at 10M rows" needs evidence that 10M rows is coming.
- **The real-PR test.** Would you actually type this on someone's PR, or would you shrug and hit
  approve? If you'd shrug, drop it.
- **Simplification findings need one more thing.** Name what concretely *goes away* — a file, a
  branch, a parameter, a concept the reader no longer has to hold — and confirm behavior is
  unchanged. A rewrite that's the same size in different clothes is not a simplification.

Then one line: `Dropped N findings that didn't survive the filter.` Count only — never the contents.

Zero findings is a complete answer. "The design is sound, nothing worth raising" is a good review.

## 4. Walk the findings

In priority order, one at a time. Three blocks each:

1. **In plain terms** — `file:line`, then one or two jargon-free sentences: what's wrong and what it
   costs, in terms someone skimming on a phone would follow. This is for me, and it comes first.
2. **Proposed change** — concretely what should happen to the code. One or two lines.
3. **Draft comment** — the text that would be posted, in my voice. One to three sentences, first
   person, no preamble, no "Great work!", no emoji, no "Consider…" boilerplate. A question when it's
   genuinely a question ("is X guaranteed here, or should this fall back?"), an assertion when it
   isn't. Name a specific alternative only when there is one worth naming. Nothing that reads as
   machine-written, and no attribution footer.

Then wait for **approve / edit / skip**. Approved and edited drafts accumulate; nothing is posted
yet. Blocks 1 and 2 are for me only — they never reach GitHub.

No PR? Show blocks 1 and 2 for each finding, skip block 3 and the prompt, and stop there.

## 5. Post once, at the end

Submit a single review:

```
gh api repos/{owner}/{repo}/pulls/{n}/reviews -f event=COMMENT -f body=... --input -
```

with a `comments[]` array (`path`, `line`, `side`, `body`) built from the approved drafts, and a
short summary body — a few lines framing the main architectural concern.

- **Never a verdict.** `event` is always `COMMENT`. Never `APPROVE`, never `REQUEST_CHANGES` — I
  make that call in the GitHub UI.
- Show the exact payload and get one final confirmation before it goes out.
- If GitHub rejects a line anchor because it falls outside a diff hunk, retry that comment with
  `subject_type: file` rather than dropping it, and say which ones moved.
- Report the review URL when it lands.
