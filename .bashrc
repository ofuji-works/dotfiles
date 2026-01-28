# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias vi='nvim'
alias vim='nvim'
alias view='nvim -R'

eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv bash)"
eval "$(/home/linuxbrew/.linuxbrew/bin/mise activate bash)"

# git
source ~/.bash/completion/git-completion.bash
source ~/.bash/git-prompt.sh
GIT_PS1_SHOWDIRTYSTATE=true
PS1='\[\033[32m\]\u@\h\[\033[00m\]:\[\033[34m\]\w\[\033[31m\]$(__git_ps1)\[\033[00m\]\n\$ '
