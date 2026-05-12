# dotfiles

Personal configuration files, managed with GNU stow as per-tool packages.

## Requirements

- [stow](https://www.gnu.org/software/stow/) — symlink farm manager
- zsh
- neovim
- ghostty
- ripgrep (telescope live grep)
- make (required to build avante.nvim)

### Fonts

- JetBrains Mono Nerd Font
- Symbols Only Nerd Font

## AI Tool Configuration

This repository includes configuration files for AI coding assistants:

- `.copilot/copilot-instructions.md` - GitHub Copilot instructions (includes "caveman" communication style)

## Install

```bash
git clone git@github.com:mkociola/dotfiles.git ~/dotfiles
cd ~/dotfiles
stow fish ghostty git nvim zsh
```

Install only what you need — each top-level directory is an independent stow package:

```bash
stow nvim          # just neovim
stow -D ghostty    # uninstall ghostty package
```

See [CLAUDE.md](CLAUDE.md) for layout and conventions.
