#!/bin/sh

# main vps setup script
# runs numbered core scripts in order, then optionally offers extras

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CORE_DIR="$SCRIPT_DIR/core"
OPTIONAL_DIR="$SCRIPT_DIR/optional"

. "$SCRIPT_DIR/lib/common.sh"

require_root

echo ""
echo "tierhive vps setup"
echo "=================="
echo ""

for script_path in "$CORE_DIR"/*.sh; do
    name=$(basename "$script_path")
    echo ""
    echo "running $name"
    sh "$script_path"
done

# done

echo ""
echo "core setup complete"
echo "-------------------"
echo ""

# optional scripts

printf "run any additional scripts? [y/n, default: n]: "
read -r RUN_OPTIONAL
RUN_OPTIONAL="${RUN_OPTIONAL:-n}"

if [ "$RUN_OPTIONAL" = "y" ]; then
    echo ""
    for script_path in "$OPTIONAL_DIR"/*.sh; do
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
fi

echo ""
echo "all done."
echo "a reboot is strongly recommended to apply all kernel and service changes."
echo ""
printf "reboot now? [y/n, default: n]: "
read -r DO_REBOOT
if [ "${DO_REBOOT:-n}" = "y" ]; then
    reboot
fi
