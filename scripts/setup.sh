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

run_scripts_in_dir "$CORE_DIR"

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
    offer_scripts_in_dir "$OPTIONAL_DIR"
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
