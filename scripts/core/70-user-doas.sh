#!/bin/sh
# description: create a non-root doas user
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

sh "$SCRIPT_DIR/non-doas-setup.sh"
