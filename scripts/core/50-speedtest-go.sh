#!/bin/sh
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

if command -v speedtest >/dev/null 2>&1; then
    echo "speedtest is already installed"
    speedtest --version
    exit 0
fi

sh "$SCRIPT_DIR/speedtest-go-setup.sh"
