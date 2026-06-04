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

if prompt_yes_no "run any additional scripts?" "n"; then
    echo ""
    offer_scripts_in_dir "$OPTIONAL_DIR"
fi

echo ""
echo "all done."
echo "a reboot is strongly recommended to apply all kernel and service changes."
echo ""
if prompt_yes_no "reboot now?" "n"; then
    reboot
fi
