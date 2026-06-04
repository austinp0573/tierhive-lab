#!/bin/sh
# description: run the minimal setup while keeping openssh
# dropbear is the default core path
# run this manually if openssh is preferred
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

if [ "$(id -u)" -ne 0 ]; then
    echo "must be run as root"
    exit 1
fi

sh "$SCRIPT_DIR/lib/alpine-minimal-base.sh"

echo ""
echo "alpine minimalization complete (openssh kept)"
echo "reboot to apply kernel and service changes"
