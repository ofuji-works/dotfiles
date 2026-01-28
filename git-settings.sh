#!/bin/bash

# git-completion
mkdir -p ~/.bash/completion
(cd ~/.bash/completion && curl -O https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash)

# git-prompt
(cd ~/.bash && curl -O https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh)

