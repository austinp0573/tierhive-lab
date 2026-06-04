#!/bin/sh
# description: install and start a tiny nginx site
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

sh "$SCRIPT_DIR/setup_webserver.sh"
