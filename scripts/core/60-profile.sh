#!/bin/sh
# description: configure shell aliases, prompt, and login welcome
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

sh "$SCRIPT_DIR/profile-alias.sh"
