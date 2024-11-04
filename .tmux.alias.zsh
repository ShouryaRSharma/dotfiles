# Function for new tmux session
tn() {
    if [ -z "$1" ]; then
        read "session_name?Enter session name: "
    else
        session_name="$1"
    fi

    if [ -z "$session_name" ]; then
        echo "Session name cannot be empty"
        return 1
    fi

    tmux new -s "$session_name"
}

# Function for attaching to tmux session with fzf
ta() {
    if [ -z "$1" ]; then
        session=$(tmux list-sessions -F '#{session_name}' 2>/dev/null | fzf --height 40% --reverse)
    else
        session="$1"
    fi

    if [ -n "$session" ]; then
        tmux attach -t "$session"
    fi
}

alias tl="tmux ls"
