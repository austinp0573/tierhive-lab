#!/bin/sh
# description: install and start a tiny nginx site
# todo: replace with inlined idempotent version (setup_webserver.sh needs a rewrite first)
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

sh "$SCRIPT_DIR/legacy/setup_webserver.sh"
