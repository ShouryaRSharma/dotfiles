ls() {
    # Default options that will be used in all cases
    local -a base_opts=(
        --color=always
        --icons
        --ignore-glob=".git"
        --group-directories-first
    )

    # Parse options
    local mode="grid"        # default mode
    local depth=2           # default tree depth
    local size_opt=""       # file size option
    local time_style="relative"  # default time style
    local sort_field="name"     # default sort field
    local dirs_only=""      # directory filter option
    local files_only=""     # file filter option

    while [[ "$#" -gt 0 ]]; do
        case "$1" in
            # View modes
            -l|--list)
                mode="list"
                shift
                ;;
            -t|--tree)
                mode="tree"
                shift
                ;;
            -1|--oneline)
                mode="oneline"
                shift
                ;;
            # Depth control
            -d|--depth)
                depth="$2"
                shift 2
                ;;
            # Size display options
            -s|--size)
                size_opt="--bytes"
                shift
                ;;
            -b|--binary)
                size_opt="--binary"
                shift
                ;;
            # Time style options
            --iso)
                time_style="iso"
                shift
                ;;
            --relative)
                time_style="relative"
                shift
                ;;
            # Sorting options
            --sort-size)
                sort_field="size"
                shift
                ;;
            --sort-time)
                sort_field="modified"
                shift
                ;;
            # Filter options
            --dirs)
                dirs_only="--only-dirs"
                shift
                ;;
            --files)
                files_only="--only-files"
                shift
                ;;
            # Git options
            --git-status)
                base_opts+=("--git")
                shift
                ;;
            --no-git)
                base_opts+=("--no-git")
                shift
                ;;
            # All other options are passed through to eza
            *)
                break
                ;;
        esac
    done
    
    case "$mode" in
        "list")
            # Detailed list view
            eza -a "${base_opts[@]}" \
                --long \
                --git \
                --no-time \
                --no-user \
                --no-permissions \
                --time-style="$time_style" \
                --sort="$sort_field" \
                $size_opt \
                $dirs_only \
                $files_only \
                "$@"
            ;;
        "tree")
            # Tree view with specified depth
            eza -a "${base_opts[@]}" \
                --tree \
                --level="$depth" \
                --sort="$sort_field" \
                $size_opt \
                $dirs_only \
                $files_only \
                "$@"
            ;;
        "oneline")
            # One entry per line
            eza -a "${base_opts[@]}" \
                --oneline \
                --sort="$sort_field" \
                $size_opt \
                $dirs_only \
                $files_only \
                "$@"
            ;;
        "grid")
            # Default grid view
            eza -a "${base_opts[@]}" \
                --grid \
                --sort="$sort_field" \
                $size_opt \
                $dirs_only \
                $files_only \
                "$@"
            ;;
    esac
}

# Convenience aliases
alias ll="ls -l"                    # List view
alias lt="ls -t"                    # Tree view
alias lt2="ls -t -d 2"             # Tree view with depth 2
alias lt3="ls -t -d 3"             # Tree view with depth 3
alias l1="ls -1"                   # One entry per line
alias lsd="ls --dirs"               # Only directories
alias lsf="ls --files"              # Only files
alias lsize="ls -l --sort-size"    # Sort by size
alias ltime="ls -l --sort-time"    # Sort by time
alias lsg="ls -l --git-status"      # Show git status

# Keep the zoxide integration
eval "$(zoxide init zsh)"
alias cd="z"

# Yazi aliases
function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	yazi "$@" --cwd-file="$tmp"
	if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
		builtin cd -- "$cwd"
	fi
	rm -f -- "$tmp"
}
