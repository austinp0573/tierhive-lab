#!/bin/sh

# small helpers shared by the setup scripts

require_root() {
    if [ "$(id -u)" -ne 0 ]; then
        echo "must be run as root"
        exit 1
    fi
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

        printf "run %s? [y/n, default: n]: " "$name"
        read -r run_it

        if [ "${run_it:-n}" = "y" ]; then
            echo ""
            sh "$script_path"
            echo ""
        fi
    done
}
