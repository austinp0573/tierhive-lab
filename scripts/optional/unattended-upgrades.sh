#!/bin/sh
# description: enable daily apk upgrades through crond
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

sh "$SCRIPT_DIR/unattended-upgrades-setup-alpine.sh"
