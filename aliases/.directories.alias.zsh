ls() {
    if [[ "$*" == *"-l"* ]]; then
        eza -a --color=always --long --git --icons=always --no-time --no-user --no-permissions "$@"
    else
        eza -a --color=always --icons=always --grid "$@"
    fi
}

# Zoxide (better cd)
eval "$(zoxide init zsh)"
alias cd="z"
