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

On a machine that talks to Bedrock instead of a subscription (work), the same untracked file
carries the gateway config — everything tracked in the repo stays identical:

```json
{
  "model": "eu.anthropic.claude-sonnet-4-5",
  "env": {
    "CLAUDE_CODE_USE_BEDROCK": "1",
    "AWS_REGION": "eu-central-1"
  },
  "awsAuthRefresh": "aws sso login --profile work"
}
```

AWS credentials come from the normal AWS toolchain (`AWS_PROFILE` in `~/.zshrc.local`);
`awsAuthRefresh` is optional — set it if the account uses SSO so expired credentials
re-login automatically.

MCP servers live in `~/.claude.json` (session state, never tracked) — re-add them on a new
machine:

```bash
claude mcp add context7 -s user -- npx -y @upstash/context7-mcp@4.0.4
claude mcp add playwright -s user -- npx -y @playwright/mcp@0.0.80
```

See [CLAUDE.md](CLAUDE.md) for layout and conventions.
