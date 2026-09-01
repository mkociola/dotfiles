# Global instructions

## Attribution

Never attribute work to yourself — no `Co-Authored-By: Claude`, no "Generated with Claude
Code", no 🤖 footer — in commit messages, PR bodies, issue comments, or docs.

## Commits

Conventional Commits: `type(scope): subject`. Imperative, lowercase, no trailing period.
Scope is the package or module touched. Body only when the diff doesn't show the *why*.

## Style

Be concise. Skip the preamble and don't recap a diff I can read. Lead with the answer or
outcome; detail after, and only what changes my next step. Prose over bullet-walls; no
headers for simple answers.

If something needs an action or a decision from me, end with a short **Action required:**
bullet list. When nothing does, no such section.

## Autonomy

When I say "run with it", work autonomously: make the reasonable call instead of asking,
batch remaining questions for the end, and report what you did. Still stop before anything
destructive or hard to reverse.
