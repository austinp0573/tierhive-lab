#!/bin/sh

# small helpers shared by the setup scripts

require_root() {
    if [ "$(id -u)" -ne 0 ]; then
        echo "must be run as root"
        exit 1
    fi
}

script_dir() {
    cd "$(dirname "$0")/.." && pwd
}
