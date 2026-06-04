#!/bin/sh
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

echo "running the openssh minimal path"
echo "dropbear is the default core path; run this manually if you want openssh instead"

sh "$SCRIPT_DIR/alpine-minimal.sh"
