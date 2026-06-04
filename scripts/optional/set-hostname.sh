#!/bin/sh
# description: set the system hostname
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

sh "$SCRIPT_DIR/set-hostname.sh"
