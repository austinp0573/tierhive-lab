#!/bin/sh
# description: strip alpine down and switch ssh to dropbear
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

sh "$SCRIPT_DIR/alpine-minimal-dropbear.sh"
rc-service dropbear start 2>/dev/null || true
