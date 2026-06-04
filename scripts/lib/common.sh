#!/bin/sh

# small helpers shared by the setup scripts

require_root() {
    if [ "$(id -u)" -ne 0 ]; then
        echo "must be run as root"
        exit 1
    fi
}

prompt_yes_no() {
    prompt="$1"
    default="${2:-n}"

    while :; do
        printf "%s [y/n, default: %s]: " "$prompt" "$default"
        read -r answer
        answer="${answer:-$default}"

        case "$answer" in
            y|Y|yes|YES|Yes)
                return 0
                ;;
            n|N|no|NO|No)
                return 1
                ;;
            *)
                echo "enter y or n"
                ;;
        esac
    done
}

read_secret() {
    prompt="$1"
    old_stty="$(stty -g)"

    printf "%s" "$prompt"
    trap 'stty "$old_stty"; echo ""; exit 1' INT TERM
    stty -echo
    read -r SECRET_RESULT
    stty "$old_stty"
    trap - INT TERM
    echo ""
}

prompt_positive_int() {
    prompt="$1"
    default="$2"

    while :; do
        printf "%s [default: %s]: " "$prompt" "$default"
        read -r answer
        answer="${answer:-$default}"

        case "$answer" in
            ''|*[!0-9]*|0)
                echo "enter a positive number"
                ;;
            *)
                PROMPT_RESULT="$answer"
                return 0
                ;;
        esac
    done
}

run_scripts_in_dir() {
    scripts_dir="$1"

    for script_path in "$scripts_dir"/*.sh; do
        [ -e "$script_path" ] || continue
        name=$(basename "$script_path")
        script_description "$script_path"

        echo ""
        if [ -n "$SCRIPT_DESCRIPTION" ]; then
            echo "running $name - $SCRIPT_DESCRIPTION"
        else
            echo "running $name"
        fi
        sh "$script_path"
    done
}

script_description() {
    script_path="$1"
    description=$(sed -n 's/^# description: //p' "$script_path" | sed -n '1p')

    if [ -n "$description" ]; then
        SCRIPT_DESCRIPTION="$description"
    else
        SCRIPT_DESCRIPTION=""
    fi
}

offer_scripts_in_dir() {
    scripts_dir="$1"

    for script_path in "$scripts_dir"/*.sh; do
        [ -e "$script_path" ] || continue
        name=$(basename "$script_path")
        script_description "$script_path"

        if [ -n "$SCRIPT_DESCRIPTION" ]; then
            prompt="run $name ($SCRIPT_DESCRIPTION)?"
        else
            prompt="run $name?"
        fi

        if prompt_yes_no "$prompt" "n"; then
            echo ""
            sh "$script_path"
            echo ""
        fi
    done
}
