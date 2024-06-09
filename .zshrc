# homebrew
export PATH=/opt/homebrew/bin:$PATH

# git
fpath=(~/.zsh/completion $fpath)
autoload -U compinit && compinit -u

source ~/.zsh/git-prompt.sh
GIT_PS1_SHOWDIRTYSTATE=true

setopt PROMPT_SUBST
PS1='%F{cyan}%~  %F{red}$(__git_ps1 "(%s)")
%F{green}$ '

# alias
alias ll='ls -la'
alias vi='nvim'
alias vim='nvim'
alias view='nvim -R'

alias g='git'
alias push='git push origin'
alias pull='git pull origin'
alias gs='git status'
alias allbranchrm='git branch | grep feature | xargs git branch -d'
alias empty:commit='git commit --allow-empty'

# terraform
autoload -U +X bashcompinit && bashcompinit
complete -o nospace -C /opt/homebrew/bin/terraform terraform

# mise
eval "$(/opt/homebrew/bin/mise activate zsh)"

### MANAGED BY RANCHER DESKTOP START (DO NOT EDIT)
export PATH="~/.rd/bin:$PATH"
### MANAGED BY RANCHER DESKTOP END (DO NOT EDIT)
