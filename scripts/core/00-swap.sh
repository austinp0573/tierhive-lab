#!/bin/sh
# description: create and activate disk swap before apk work
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

sh "$SCRIPT_DIR/setup-swap.sh"
