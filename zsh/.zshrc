# Basic zsh history settings
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS

# Enable colors
alias ls="ls -G"
alias grep="grep --color=auto"

# Tokyonight palette (matches nvim/tmux)
#   blue #7aa2f7  cyan #7dcfff  green #9ece6a  magenta #bb9af7
#   red  #f7768e  yellow #e0af68  fg #c0caf5  comment #565f89

# Prompt: cwd (blue) + git branch (magenta) + ❯ (green/red on exit)
autoload -Uz vcs_info
zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:git:*' formats ' %F{#bb9af7}%b%f'
precmd() { vcs_info }
setopt PROMPT_SUBST
PROMPT='%F{#7aa2f7}%~%f${vcs_info_msg_0_} %(?.%F{#9ece6a}.%F{#f7768e})❯%f '

# BSD ls colors (macOS): bold blue dirs, magenta symlinks, green exec
export CLICOLOR=1
export LSCOLORS="ExFxDxCxBxegedabagacad"

# grep highlight color
export GREP_COLORS="ms=01;38;5;215"

# Colored man pages via less
export LESS="-R"
export LESS_TERMCAP_mb=$'\e[1;31m'
export LESS_TERMCAP_md=$'\e[1;38;2;122;162;247m'
export LESS_TERMCAP_me=$'\e[0m'
export LESS_TERMCAP_so=$'\e[1;38;2;26;27;38;48;2;224;175;104m'
export LESS_TERMCAP_se=$'\e[0m'
export LESS_TERMCAP_us=$'\e[4;38;2;187;154;247m'
export LESS_TERMCAP_ue=$'\e[0m'

# Per-machine overrides (not tracked)
[ -f "$HOME/.zshrc.local" ] && . "$HOME/.zshrc.local"
