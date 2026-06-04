#!/bin/sh

# interactively offers the optional scripts

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
OPTIONAL_DIR="$SCRIPT_DIR/optional"

if [ "$(id -u)" -ne 0 ]; then
    echo "must be run as root"
    exit 1
fi

echo ""
echo "available optional scripts:"
echo ""

for script in "$OPTIONAL_DIR"/*.sh; do
    [ -e "$script" ] || continue
    name=$(basename "$script")

    printf "run %s? [y/n, default: n]: " "$name"
    read -r run_it
    if [ "${run_it:-n}" = "y" ]; then
        echo ""
        sh "$script"
        echo ""
    fi
done

echo "done"
