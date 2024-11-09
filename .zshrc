# ======================
# ~/.zshrc (Main file)
# ======================
# Load common configuration
source ~/.zshrc.common

# Load OS-specific configuration
if [[ "$(uname)" == "Darwin" ]]; then
    source ~/.zshrc_mac
elif [[ "$(uname)" == "Linux" ]]; then
    source ~/.zshrc_linux
fi

# Load syntax highlighting and autosuggestions
export ZSH_HIGHLIGHT_HIGHLIGHTERS_DIR=$(brew --prefix)/share/zsh-syntax-highlighting/highlighters

# Load theme configurations
source ~/themes/.cyberdream.theme.zsh

# Finally, load the syntax highlighting and autosuggestions
source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
