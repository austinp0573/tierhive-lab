#!/bin/sh
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

sh "$SCRIPT_DIR/unattended-upgrades-setup-alpine.sh"
