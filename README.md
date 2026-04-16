# dotfiles

Directory containing all of my configuration files

## Requirements

Ensure you have the following installed

- stow (a symlink farm manager)
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

## Installation

First, check out the repository into your home directory

```bash
git clone git@github.com:mkociola/dotfiles.git ~
```

then use GNU stow to create the symlinks

```bash
stow .
```

good to go :)
