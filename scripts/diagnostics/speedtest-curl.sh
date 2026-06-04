#!/bin/sh
# description: run curl-based ipv4 and ipv6 speed tests
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

sh "$SCRIPT_DIR/speedtest-script.sh"
