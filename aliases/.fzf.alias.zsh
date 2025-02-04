# Color schemes
fg="#ffffff"
bg="#16181a"
bg_highlight="#3c4048"
purple="#bd5eff"
blue="#5ea1ff"
cyan="#5ef1ff"
[[ "$(uname)" == "Linux" ]] && {
   fg="#CBE0F0"
   bg="#011628"
   bg_highlight="#143652" 
   purple="#B388FF"
   blue="#06BCE4"
   cyan="#2CF9ED"
}

# FZF configuration
export FZF_DEFAULT_OPTS="--color=fg:${fg},bg:${bg},hl:${purple},fg+:${fg},bg+:${bg_highlight},hl+:${purple},info:${blue},prompt:${cyan},pointer:${cyan},marker:${cyan},spinner:${cyan},header:${cyan}"
source <(fzf --zsh)
source ~/fzf-git.sh/fzf-git.sh

# Core FZF commands
fd_base="fd --no-ignore-vcs --exclude '.*' --strip-cwd-prefix --exclude .git --max-depth 2"
export FZF_DEFAULT_COMMAND="$fd_base --type f"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="$fd_base --type d"

# Preview configurations
show_preview="if [ -d {} ]; then eza --tree --color=always {} | head -200; else bat -n --color=always --line-range :500 {}; fi"
export FZF_CTRL_T_OPTS="--preview '$show_preview'"
export FZF_ALT_C_OPTS="--preview 'eza --tree --color=always {} | head -200'"

# Smart directory navigation
smart_cd() {
   if [[ "$#" -eq 0 ]]; then
       cd ~
       return
   fi
   [[ "$#" -eq 1 && -d "$1" ]] && {
       cd "$1"
       return
   }
   local dir
   dir=$(zoxide query "$@")
   if [[ $? -eq 0 && -d "$dir" ]]; then
       cd "$dir"
   else
       dir=$(fd --type d --no-ignore-vcs --exclude '.*' --exclude .git --max-depth 2 . "$HOME" \
           | fzf --query "$*" \
               --preview 'eza --tree --color=always {} | head -200' \
               --preview-window='right:60%' \
               --bind='ctrl-/:toggle-preview' \
               --height=80% \
               --border=rounded \
               --prompt="📁 CD > ")
       [[ -n "$dir" ]] && {
           cd "$dir"
           zoxide add "$dir"
       }
   fi
}

# FZF completion functions
fzf_compgen_path() { $fd_base . "$1" }
fzf_compgen_dir() { $fd_base --type d . "$1" }

# Simple path-aware fzf_comprun
fzf_comprun() {
    local command=$1
    shift

    # Check if we're completing a path (file or directory)
    if [[ -e "$PWD/${COMP_WORDS[-1]}" ]] || [[ -d "$PWD/${COMP_WORDS[-1]}" ]]; then
        fzf --preview "$show_preview" "$@"
    else
        fzf "$@"
    fi
}

# Bind Ctr-space to directory completion
zle -N fzf-smart-completion
bindkey '^@' fzf-smart-completion
fzf-smart-completion() {
    local dir
    dir=$(zoxide query -l | fzf --query "${BUFFER#cd }")
    if [ -n "$dir" ]; then
        BUFFER="cd ${dir}"
        zle accept-line
    fi
}

# Initialize
eval "$(zoxide init zsh)"
alias cd="smart_cd"

# FZF tab completion
source ~/.zsh/fzf-zsh-completions.sh
bindkey '^I' fzf_completion
zstyle ':completion:*' fzf-search-display true
