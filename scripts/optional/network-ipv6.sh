#!/bin/sh
# description: tune networking and optionally enable static ipv6
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

sh "$SCRIPT_DIR/ipv6_and_net_optimization.sh"
