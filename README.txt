an extension to oh-myzsh

------------
installation
------------
clone this repo outside of oh-my-zsh to stop it interfering with its updates. Then symlink the files included here into ~/.oh-my-zsh/custom/ to add them into oh-my-zshlist of commands.

in ~/.oh-my-zsh/plugins/git/git.plugin.zsh file comment out the below lines by starting them with a # or delete the lines
alias gk='\gitk --all --branches'
compdef _git gk='gitk'
