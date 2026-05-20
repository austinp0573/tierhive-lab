#!/bin/sh

# interactively offers to run every .sh file in the scripts directory
# skips itself so it doesn't recurse

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

if [ "$(id -u)" -ne 0 ]; then
    echo "must be run as root"
    exit 1
fi

echo ""
echo "available scripts in $SCRIPT_DIR:"
echo ""

for script in "$SCRIPT_DIR"/*.sh; do
    name=$(basename "$script")

    # skip this script
    [ "$name" = "run-scripts.sh" ] && continue

    printf "run %s? [y/n, default: n]: " "$name"
    read -r run_it
    if [ "${run_it:-n}" = "y" ]; then
        echo ""
        sh "$script"
        echo ""
    fi
done

echo "done"
