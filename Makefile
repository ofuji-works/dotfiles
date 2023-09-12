setup:
	# brew
	brew tap hashicorp/tap && brew install rtx nvim lima docker docker-compose hashicorp/tap/terraform
	# git
	# git-completion
	mkdir ~/.zsh/completion
	(cd ~/.zsh/completion && curl -O https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash && curl -O https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.zsh && mv git-completion.zsh _git)
	# git-prompt
	(cd ~/.zsh && curl -O https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh)
	# nvim
	# packer install
	git clone --depth 1 https://github.com/wbthomason/packer.nvim\
		~/.local/share/nvim/site/pack/packer/start/packer.nvim
