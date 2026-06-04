#!/bin/sh

# interactively offers the optional scripts

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
OPTIONAL_DIR="$SCRIPT_DIR/optional"

. "$SCRIPT_DIR/lib/common.sh"

require_root

echo ""
echo "available optional scripts:"
echo ""

offer_scripts_in_dir "$OPTIONAL_DIR"

echo "done"
