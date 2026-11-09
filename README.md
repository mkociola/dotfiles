# dotfiles

Personal configuration files, managed with GNU stow as per-tool packages.

## Requirements

Everything comes from the [Brewfile](Brewfile): stow, neovim, tree-sitter CLI, ripgrep, tmux,
gh, node, Ghostty and the two Nerd Fonts. Version floors: neovim 0.12+ (nvim-treesitter `main`
branch), tree-sitter CLI 0.26.1+, tmux 3.2+ (`terminal-features`).

## Install

```bash
git clone git@github.com:mkociola/dotfiles.git ~/dotfiles
cd ~/dotfiles
brew bundle
stow ghostty git nvim tmux zsh
stow --no-folding claude
```

The `claude` package must be stowed with `--no-folding`. A plain `stow claude` turns
`~/.claude` into one symlink pointing at `claude/.claude/`, which makes this repo the place
Claude Code writes session transcripts, prompt history and caches at runtime. With
`--no-folding`, `~/.claude` stays a real local directory and only the tracked files are
linked into it.

Install only what you need — each top-level directory is an independent stow package:

```bash
stow nvim                   # just neovim
stow --no-folding claude    # claude always takes the flag, including on restow
stow -D ghostty             # uninstall ghostty package
```

### Tmux setup

After stowing the `tmux` package:

```bash
git clone https://github.com/tmux-plugins/tpm ~/.config/tmux/plugins/tpm
~/.config/tmux/plugins/tpm/scripts/install_plugins.sh
```

Or inside a tmux session: `prefix + I` (capital i) to install plugins.

### Claude Code setup

The `claude` package stows global settings and instructions into `~/.claude/`. Every generic
preference (`tui`, theme, permissions, attribution, plugins) is tracked in
`claude/.claude/settings.json`, so a fresh machine needs nothing beyond
`stow --no-folding claude`. Model and effort are never tracked. When Claude Code itself writes
into that file, commit plugin installs and marketplaces, and `git checkout` any `model`,
`effortLevel` or `modelSettings` it adds.

Anything machine-specific and private, a skill with an employer's internal hostnames for
instance, is simply not stowed: put it straight in `~/.claude/skills/<name>/` or
`~/.claude/commands/`, where it stays outside the repo.

Claude Code reads no user-level local settings file, so per-machine overrides go in
`~/.claude/settings.local.json` and `zsh/.zshrc` passes it with `--settings` whenever it exists.
That flag outranks user and project settings, so a key set there wins. Create the file only on a
machine that needs one; on a machine that talks to Bedrock instead of a subscription (work):

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

The alias reaches terminal sessions only. The desktop app launches the binary directly, and the
one untracked file it also honors is managed settings at
`/Library/Application Support/ClaudeCode/managed-settings.json` (needs sudo, outranks everything,
can't be overridden per project).

MCP servers live in `~/.claude.json` (never tracked), so a server only one machine needs is
simply added there with `-s user`. Re-add the shared ones on a new machine:

```bash
claude mcp add context7 -s user -- npx -y @upstash/context7-mcp@4.0.4
claude mcp add playwright -s user -- npx -y @playwright/mcp@0.0.80
```

See [CLAUDE.md](CLAUDE.md) for layout and conventions.
