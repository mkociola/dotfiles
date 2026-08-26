# dotfiles

Personal configuration files, managed with GNU stow as per-tool packages.

## Requirements

- [stow](https://www.gnu.org/software/stow/) — symlink farm manager
- zsh
- neovim
- ghostty
- tmux (3.1+ for XDG config path)
- ripgrep (telescope live grep)

### Fonts

- JetBrains Mono Nerd Font
- Symbols Only Nerd Font

## Install

```bash
git clone git@github.com:mkociola/dotfiles.git ~/dotfiles
cd ~/dotfiles
stow claude ghostty git nvim tmux zsh
```

Install only what you need — each top-level directory is an independent stow package:

```bash
stow nvim          # just neovim
stow -D ghostty    # uninstall ghostty package
```

### Tmux setup

After stowing the `tmux` package:

```bash
git clone https://github.com/tmux-plugins/tpm ~/.config/tmux/plugins/tpm
~/.config/tmux/plugins/tpm/scripts/install_plugins.sh
```

Or inside a tmux session: `prefix + I` (capital i) to install plugins.

### Claude Code setup

The `claude` package stows global settings and instructions into `~/.claude/`. Machine- and
account-specific values are **not** tracked — after stowing on a new machine, create
`~/.claude/settings.local.json`:

```json
{
  "model": "opus[1m]",
  "effortLevel": "high",
  "tui": "fullscreen"
}
```

Plugins and marketplaces are re-enabled from Claude Code itself and land in the same file.

See [CLAUDE.md](CLAUDE.md) for layout and conventions.
