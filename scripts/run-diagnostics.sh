#!/bin/sh

# interactively offers diagnostic scripts

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DIAGNOSTICS_DIR="$SCRIPT_DIR/diagnostics"

. "$SCRIPT_DIR/lib/common.sh"

require_root

echo ""
echo "available diagnostic scripts:"
echo ""

offer_scripts_in_dir "$DIAGNOSTICS_DIR"

echo "done"
