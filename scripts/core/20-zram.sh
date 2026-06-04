#!/bin/sh
# description: configure compressed swap in ram
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

sh "$SCRIPT_DIR/setup-zram.sh"
