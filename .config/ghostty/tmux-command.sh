#!/bin/bash
if [[ $TERM_PROGRAM == "ghostty" ]]; then
	[[ -e ~/.zprofile ]] && source ~/.zprofile
	[[ -e ~/.zshrc ]] && source ~/.zshrc
fi
tmux attach || tmux
