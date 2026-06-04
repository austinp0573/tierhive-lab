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
            y|Y|yes|YES)
                return 0
                ;;
            n|N|no|NO)
                return 1
                ;;
            *)
                echo "enter y or n"
                ;;
        esac
    done
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

        echo ""
        echo "running $name"
        sh "$script_path"
    done
}

offer_scripts_in_dir() {
    scripts_dir="$1"

    for script_path in "$scripts_dir"/*.sh; do
        [ -e "$script_path" ] || continue
        name=$(basename "$script_path")

        if prompt_yes_no "run $name?" "n"; then
            echo ""
            sh "$script_path"
            echo ""
        fi
    done
}
