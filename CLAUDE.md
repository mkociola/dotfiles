# CLAUDE.md

Personal dotfiles, managed with GNU stow. Each top-level directory is a stow package that mirrors a subtree of `$HOME`.

## Layout

```
dotfiles/
├── claude/    → ~/.claude/
├── ghostty/   → ~/.config/ghostty/
├── git/       → ~/.config/git/
├── nvim/      → ~/.config/nvim/
├── tmux/      → ~/.config/tmux/
└── zsh/       → ~/.zshrc
```

A package directory mirrors the install target. Inside `nvim/`, the path is `nvim/.config/nvim/init.lua`; after `stow nvim`, `~/.config/nvim/init.lua` is a symlink into the repo.

## Install

From repo root:

```bash
stow ghostty git nvim tmux zsh          # all but claude
stow --no-folding claude                # claude: see below, never plain `stow claude`
stow nvim                               # one
stow -D nvim                            # uninstall
stow -R nvim                            # restow after moving files
```

`claude` needs `--no-folding`. Without it stow makes `~/.claude` a single symlink to
`claude/.claude/`, and then everything Claude Code writes at runtime (session transcripts,
prompt history, skills, caches) physically lands in this working tree. On a work machine that
puts confidential material one `git add -f` away from a public push. With `--no-folding`,
`~/.claude` stays a real local directory and only the tracked files are symlinked into it.

`.stow-local-ignore` keeps `README.md`, `CLAUDE.md`, `.git*` out of `$HOME`.

## Conventions

- **Commits**: Conventional Commits, scoped to the package: `feat(nvim):`, `fix(nvim):`, `refactor(nvim):`, `feat(zsh):`, etc.
- **Lua** (`nvim/`): 2-space indent, formatted by stylua via conform.nvim `format_on_save`.
- **No secrets in repo.** `.config/github-copilot/` (OAuth tokens) and `uv-receipt.json` are gitignored. Copilot re-auths from nvim on first use.
- **Adding a new tool**: create `<tool>/.config/<tool>/...` (or `<tool>/.<dotfile>` for `$HOME`-level files). Don't reintroduce a single flat package.
- **Per-machine config**: tracked `zsh/.zshrc` sources `~/.zshrc.local` at the end if present. Put machine-specific lines (uv env source, work paths, proxies, secrets) there — `~/.zshrc.local` is never tracked. If an installer mutates `zsh/.zshrc`, move its line into `~/.zshrc.local` and `git checkout zsh/.zshrc`.

## Nvim

- Plugin manager: lazy.nvim, bootstrapped by `init.lua`.
- Treesitter: nvim-treesitter **`main` branch**, which needs nvim 0.12+ and the `tree-sitter`
  CLI on PATH (`brew install tree-sitter-cli`). The `master` branch is frozen at nvim 0.11 and
  its queries crash 0.12 (`attempt to call method 'range'` on markdown), so don't move back.
  `main` ships no modules: parsers come from an explicit `ts.install({...})` list (no
  `auto_install`), and highlight plus indent are turned on per buffer by the `FileType`
  autocmd in the plugin spec. Add a language by adding it to that list, then `:TSUpdate`.
- `lazy-lock.json` is tracked — keeps plugin versions reproducible across machines.
- LSP: native `vim.lsp.config` + `vim.lsp.enable`; nvim-lspconfig ships server configs; mason + mason-tool-installer auto-installs server binaries by mason package name (e.g. `lua-language-server`, not `lua_ls`).
- Completion: blink.cmp with copilot, LSP, snippets, buffer, path sources.
- File explorer: oil.nvim. netrw disabled at top of `init.lua`.

## Tmux

- Config: `~/.config/tmux/tmux.conf` (XDG-style; tmux 3.1+).
- Plugin manager: tpm. First-time setup:
  ```bash
  git clone https://github.com/tmux-plugins/tpm ~/.config/tmux/plugins/tpm
  tmux              # launch, then press: prefix + I    (capital i to install)
  ```
- Plugins: tmux-sensible, tmux-yank, tmux-resurrect, tmux-continuum (auto-save/restore).
- Theme: tokyonight-night palette inline (matches nvim). No theme plugin.
- `~/.config/tmux/plugins/` is not tracked.

## Claude Code

- Package: `claude/.claude/` → `~/.claude/` (global, applies to every project).
- `CLAUDE.md` — global instructions: attribution, Conventional Commits, style (concise,
  answer-first, `Action required:` list when something needs me), and a "run with it"
  autonomy trigger. Keep it lean — always-on behavioral rules are the thing that degrades
  responses, so every addition earns its place.
- `commands/commit.md` — `/commit`, which splits the current changes into Conventional
  Commits and pushes to the current branch (`/commit branch [name]` for a new one).
- `commands/design.md` — `/design [PR# | url | branch]`, the design and simplicity pass
  `/code-review` lacks: architecture and KISS only, refute-first filter, no bug hunting. Runs as a
  background fork pinned to `xhigh`. Pair it with `/code-review`.
- `settings.json` — every generic preference: model, effort, `tui`, theme, permissions,
  attribution. If Claude Code writes machine state into it (plugin installs, marketplaces),
  commit it or `git checkout` it — same rule as `zsh/.zshrc`.
- Per-machine settings: Claude Code has no user-level local file, so `zsh/.zshrc` passes
  `~/.claude/settings.local.json` via `--settings` when it exists (terminal sessions only, not
  the desktop app). Create it on a machine that needs its own hooks, env, or permissions.
- Per-machine MCP servers: `claude mcp add --scope user …` stores them in `~/.claude.json`,
  which lives outside the package and is never tracked.
- **Stowed with `--no-folding`**, see Install. `~/.claude` is a real local directory and only
  `CLAUDE.md`, `settings.json` and the two `commands/*.md` are symlinks into the repo, so
  nothing Claude Code generates at runtime touches this working tree. Verify with
  `find claude -mindepth 1`: two directories and four files, nothing else, ever. The
  `.gitignore` entries for `claude/.claude/` state are a backstop in case the fold ever comes
  back.
- Per-machine skills and commands: anything with employer-internal detail (project keys,
  hostnames, internal URLs) is simply left unstowed in `~/.claude/skills/<name>/` or
  `~/.claude/commands/`, which is now genuinely outside the repo. This machine has
  `skills/jira-ticket/` (Jira house style per project, plus a `PostToolUse` hook that logs
  filed tickets) and `commands/jira-learn.md` (diffs those tickets against their current state
  and folds repeated edits back into the skill). To share a skill, add it under
  `claude/.claude/skills/` and restow.
- Rest of `~/.claude/` (sessions, history, plugins cache, telemetry) is state — never track it.
