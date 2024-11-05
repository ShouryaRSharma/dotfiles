# Default color scheme
fg="#ffffff"
bg="#16181a"
bg_highlight="#3c4048"
purple="#bd5eff"
blue="#5ea1ff"
cyan="#5ef1ff"

# Check if the system is Linux
if [[ "$(uname)" == "Linux" ]]; then
    # Linux-specific color scheme
    fg="#CBE0F0"
    bg="#011628"
    bg_highlight="#143652"
    purple="#B388FF"
    blue="#06BCE4"
    cyan="#2CF9ED"
fi

# Set FZF default options with color references
export FZF_DEFAULT_OPTS="--color=fg:${fg},bg:${bg},hl:${purple},fg+:${fg},bg+:${bg_highlight},hl+:${purple},info:${blue},prompt:${cyan},pointer:${cyan},marker:${cyan},spinner:${cyan},header:${cyan}"

# FZF configuration
source <(fzf --zsh)
source ~/fzf-git.sh/fzf-git.sh

# Default commands - exclude dotfiles but include gitignored files, max depth 2 from HOME
export FZF_DEFAULT_COMMAND="fd --type f --no-ignore-vcs --exclude '.*' --strip-cwd-prefix --exclude .git --max-depth 2"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="fd --type d --no-ignore-vcs --exclude '.*' --strip-cwd-prefix --exclude .git --max-depth 2"

# Preview commands
show_file_or_dir_preview="if [ -d {} ]; then eza --tree --color=always {} | head -200; else bat -n --color=always --line-range :500 {}; fi"
export FZF_CTRL_T_OPTS="--preview '$show_file_or_dir_preview'"
export FZF_ALT_C_OPTS="--preview 'eza --tree --color=always {} | head -200'"

# Enhanced directory navigation function with zoxide and fzf fallback
smart_cd() {
    if [[ "$#" -eq 0 ]]; then
        # No arguments, go to home directory
        cd ~
    elif [[ "$#" -eq 1 ]] && [[ -d "$1" ]]; then
        # If argument is a valid directory, go there directly
        cd "$1"
    else
        # Try zoxide first
        local dir
        dir=$(zoxide query "$@")
        if [[ $? -eq 0 ]] && [[ -d "$dir" ]]; then
            cd "$dir"
        else
            # If zoxide fails, use fzf with the search term
            dir=$(fd --type d --no-ignore-vcs --exclude '.*' --exclude .git --max-depth 2 . "$HOME" \
                | fzf --query "$*" \
                    --preview 'eza --tree --color=always {} | head -200' \
                    --preview-window='right:60%' \
                    --bind='ctrl-/:toggle-preview' \
                    --height=80% \
                    --border=rounded \
                    --prompt="📁 CD > ")
            if [[ -n "$dir" ]]; then
                cd "$dir"
                # Add to zoxide database after changing directory
                zoxide add "$dir"
            fi
        fi
    fi
}

# FZF completion functions
_fzf_compgen_path() {
    fd --no-ignore-vcs --exclude '.*' --exclude .git --max-depth 2 . "$1"
}

_fzf_compgen_dir() {
    fd --type d --no-ignore-vcs --exclude '.*' --exclude .git --max-depth 2 . "$1"
}

_fzf_comprun() {
    local command=$1
    shift
    case "$command" in
        cd)           fzf --preview 'eza --tree --color=always {} | head -200' "$@" ;;
        export|unset) fzf --preview "eval 'echo \${}'"         "$@" ;;
        ssh)          fzf --preview 'dig {}'                   "$@" ;;
        *)            fzf --preview "$show_file_or_dir_preview" "$@" ;;
    esac
}
# Initialize zoxide
eval "$(zoxide init zsh)"
alias cd="smart_cd"
