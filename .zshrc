# Basic zsh history settings
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS

# Starship prompt
eval "$(starship init zsh)"

# Enable colors
alias ls="ls -G"
alias grep="grep --color=auto"
