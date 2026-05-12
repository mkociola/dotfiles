# CLAUDE.md

Personal dotfiles, managed with GNU stow. Each top-level directory is a stow package that mirrors a subtree of `$HOME`.

## Layout

```
dotfiles/
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
stow ghostty git nvim tmux zsh   # all
stow nvim                        # one
stow -D nvim                     # uninstall
stow -R nvim                     # restow after moving files
```

`.stow-local-ignore` keeps `README.md`, `CLAUDE.md`, `.git*` out of `$HOME`.

## Conventions

- **Commits**: Conventional Commits, scoped to the package: `feat(nvim):`, `fix(nvim):`, `refactor(nvim):`, `feat(zsh):`, etc.
- **Lua** (`nvim/`): 2-space indent, formatted by stylua via conform.nvim `format_on_save`.
- **No secrets in repo.** `.config/github-copilot/` (OAuth tokens) and `uv-receipt.json` are gitignored. Copilot re-auths from nvim on first use.
- **Adding a new tool**: create `<tool>/.config/<tool>/...` (or `<tool>/.<dotfile>` for `$HOME`-level files). Don't reintroduce a single flat package.
- **Per-machine config**: tracked `zsh/.zshrc` sources `~/.zshrc.local` at the end if present. Put machine-specific lines (uv env source, work paths, proxies, secrets) there — `~/.zshrc.local` is never tracked. If an installer mutates `zsh/.zshrc`, move its line into `~/.zshrc.local` and `git checkout zsh/.zshrc`.

## Nvim

- Plugin manager: lazy.nvim, bootstrapped by `init.lua`.
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
