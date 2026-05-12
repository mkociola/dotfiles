# CLAUDE.md

Personal dotfiles, managed with GNU stow. Each top-level directory is a stow package that mirrors a subtree of `$HOME`.

## Layout

```
dotfiles/
├── fish/      → ~/.config/fish/
├── ghostty/   → ~/.config/ghostty/
├── git/       → ~/.config/git/
├── nvim/      → ~/.config/nvim/
└── zsh/       → ~/.zshrc
```

A package directory mirrors the install target. Inside `nvim/`, the path is `nvim/.config/nvim/init.lua`; after `stow nvim`, `~/.config/nvim/init.lua` is a symlink into the repo.

## Install

From repo root:

```bash
stow fish ghostty git nvim zsh   # all
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

## Nvim

- Plugin manager: lazy.nvim, bootstrapped by `init.lua`.
- `lazy-lock.json` is tracked — keeps plugin versions reproducible across machines.
- LSP via mason + mason-lspconfig + nvim-lspconfig.
- Completion: nvim-cmp with copilot, LSP, luasnip, buffer, path sources.
