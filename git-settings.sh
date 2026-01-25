# !/bin/bash

# git-completion
mkdir ~/.zsh/completion
(cd ~/.zsh/completion && curl -O https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash && curl -O https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.zsh && mv git-completion.zsh _git)

# git-prompt
(cd ~/.zsh && curl -O https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh)

