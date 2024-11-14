alias ecr-login='(pushd ~/dev > /dev/null && aws ecr get-login-password --region eu-west-1 | docker login --username AWS --password-stdin 871716277715.dkr.ecr.eu-west-1.amazonaws.com && popd > /dev/null)'
alias ld="lazydocker"
alias lg="lazygit"
alias cat="bat"
alias cl="clear"
alias sz="source ~/.zshrc"
alias cm="chmod +x"
