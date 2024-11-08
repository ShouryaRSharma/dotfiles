export ACI_USER="${USER}"

function aci {
    # Check if fzf is installed
    if ! command -v fzf >/dev/null 2>&1; then
        echo "Error: fzf is not installed. Please install it first."
        echo "Visit: https://github.com/junegunn/fzf"
        return 1
    fi

    # Select account
    account=$(access-cli get-accounts | grep "^\*" | fzf)
    if [[ -z "$account" ]]; then
        echo "You must select an account"
        return 1
    fi
    account=$(echo "$account" | grep -o '^[*][[:space:]]*\([^[:space:]]*\)' | cut -c 3- | tr -d "\r")
    echo "Account: $account"

    # Select role
    role=$(access-cli get-roles | grep "^\*" | fzf)
    if [[ -z "$role" ]]; then
        echo "You must select a role"
        return 1
    fi
    role=$(echo "$role" | grep -o '^[*][[:space:]]*\([^[:space:]]*\)' | cut -c 3- | tr -d "\r")
    echo "Role: $role"

    # Select duration
    duration=$(printf "1h\n2h\n4h\n8h" | fzf)
    if [[ -z "$duration" ]]; then
        echo "You must select a duration"
        return 1
    fi
    echo "Duration: $duration"

    # Get Jira and reason
    echo -n "Jira: "
    read jira
    echo -n "Reason: "
    read reason

    # Build and execute command
    acparams="request -n $account -d $duration -r $role"
    if [[ -n "$jira" ]]; then
        acparams="$acparams -t $jira"
    fi
    access-cli $acparams --reason "$reason" -u $ACI_USER
}

function amfa {
    # Check if fzf is installed
    if ! command -v fzf >/dev/null 2>&1; then
        echo "Error: fzf is not installed. Please install it first."
        echo "Visit: https://github.com/junegunn/fzf"
        return 1
    fi

    # Select account
    account=$(access-cli get-accounts | grep "^\*" | fzf)
    if [[ -z "$account" ]]; then
        echo "You must select an account"
        return 1
    fi
    account=$(echo "$account" | rev | cut -d' ' -f1 | rev | tr -d "\r")
    echo "Account: $account"

    # Select role
    role=$(access-cli get-roles | grep "^\*" | fzf)
    if [[ -z "$role" ]]; then
        echo "You must select a role"
        return 1
    fi
    role=$(echo "$role" | grep -o '^[*][[:space:]]*\([^[:space:]]*\)' | cut -c 3- | tr -d "\r")
    echo "Role: $role"

    # Select duration
    duration=$(printf "1h\n2h\n4h\n8h" | fzf)
    if [[ -z "$duration" ]]; then
        echo "You must select a duration"
        return 1
    fi
    duration=$(echo $duration | cut -c1)
    duration=$(($duration * 3600))
    echo "Duration: $duration"

    # Build and execute command
    params="--assume-role arn:aws:iam::$account:role/$role --duration $duration"
    echo "Running command: aws-mfa $params"
    aws-mfa $params
}
