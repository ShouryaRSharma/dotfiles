export ACI_USER="${USER}"

function aci () {
        if ! command -v fzf > /dev/null 2>&1
        then
                echo "Error: fzf is not installed. Please install it first."
                echo "Visit: https://github.com/junegunn/fzf"
                return 1
        fi
        account=$(access-cli get-accounts | grep "^\*" | fzf)
        if [[ -z "$account" ]]
        then
                echo "You must select an account"
                return 1
        fi
        account=$(echo "$account" | grep -o '^[*][[:space:]]*\([^[:space:]]*\)' | cut -c 3- | tr -d "\r")
        echo "Account: $account"
        role=$(access-cli get-roles | grep "^\*" | fzf)
        if [[ -z "$role" ]]
        then
                echo "You must select a role"
                return 1
        fi
        role=$(echo "$role" | grep -o '^[*][[:space:]]*\([^[:space:]]*\)' | cut -c 3- | tr -d "\r")
        echo "Role: $role"
        duration=$(printf "1h\n2h\n4h\n8h" | fzf)
        if [[ -z "$duration" ]]
        then
                echo "You must select a duration"
                return 1
        fi
        echo "Duration: $duration"
        echo -n "Jira: "
        read jira
        echo -n "Reason: "
        read reason

        cmd="access-cli request"
        cmd="$cmd -n $account"
        cmd="$cmd -d $duration"
        cmd="$cmd -r $role"
        if [[ -n "$jira" ]]
        then
                cmd="$cmd -t $jira"
        fi
        cmd="$cmd --reason \"$reason\""
        if [[ -n "$ACI_USER" ]]
        then
                cmd="$cmd -u $ACI_USER"
        fi

        eval $cmd
}

function amfa {
    if ! command -v fzf >/dev/null 2>&1; then
        echo "Error: fzf is not installed. Please install it first."
        echo "Visit: https://github.com/junegunn/fzf"
        return 1
    fi
    account=$(access-cli get-accounts | grep "^\*" | fzf)
    if [[ -z "$account" ]]; then
        echo "You must select an account"
        return 1
    fi
    account=$(echo "$account" | rev | cut -d' ' -f1 | rev | tr -d "\r")
    echo "Account: $account"
    role=$(access-cli get-roles | grep "^\*" | fzf)
    if [[ -z "$role" ]]; then
        echo "You must select a role"
        return 1
    fi
    role=$(echo "$role" | grep -o '^[*][[:space:]]*\([^[:space:]]*\)' | cut -c 3- | tr -d "\r")
    echo "Role: $role"
    duration=$(printf "1h\n2h\n4h\n8h" | fzf)
    if [[ -z "$duration" ]]; then
        echo "You must select a duration"
        return 1
    fi
    duration=$(echo $duration | cut -c1)
    duration=$(($duration * 3600))
    echo "Duration: $duration"

    cmd="aws-mfa"
    cmd="$cmd --assume-role \"arn:aws:iam::${account}:role/${role}\""
    cmd="$cmd --duration $duration"

    echo "Running command: $cmd"
    eval $cmd
}
