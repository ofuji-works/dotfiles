setup:
	# brew
	brew tap hashicorp/tap && brew tap homebrew/cask-fonts && brew install font-hack-nerd-font rtx nvim lima docker docker-compose hashicorp/tap/terraform
	# git
	# git-completion
	mkdir ~/.zsh/completion
	(cd ~/.zsh/completion && curl -O https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash && curl -O https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.zsh && mv git-completion.zsh _git)
	# git-prompt
	(cd ~/.zsh && curl -O https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh)
	
	# mise install
	mise install
	
	# vim settings
	npm install -g vls

