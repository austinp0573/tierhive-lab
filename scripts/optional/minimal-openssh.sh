#!/bin/sh
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

echo "running the openssh minimal path"
echo "dropbear is the default core path; use this only if you want to keep openssh"

sh "$SCRIPT_DIR/alpine-minimal.sh"
