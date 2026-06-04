#!/bin/sh
# description: create and activate disk swap before apk work
# swap must run before apk update 
# on the smallest vps, apk update OOMs without it

set -eu

SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

. "$SCRIPT_DIR/lib/common.sh"

require_root

SWAP_PATH="/swapfile"

if grep -q "^[^ ]* $SWAP_PATH " /proc/swaps || grep -q "^$SWAP_PATH " /proc/swaps; then
    echo "swap is already active at ${SWAP_PATH}"
    free -h
    exit 0
fi

if [ -f "$SWAP_PATH" ]; then
    echo "using existing swapfile at ${SWAP_PATH}"
else
    prompt_positive_int "swap size in MB" "512"
    SWAP_SIZE_MB="$PROMPT_RESULT"

    echo "creating ${SWAP_SIZE_MB}MB swapfile at ${SWAP_PATH}..."
    dd if=/dev/zero of="$SWAP_PATH" bs=1M count="$SWAP_SIZE_MB"
    chmod 600 "$SWAP_PATH"

    echo "formatting swap space"
    mkswap "$SWAP_PATH"
fi

echo "activating swap"
swapon "$SWAP_PATH"

echo "adding to /etc/fstab for persistence"
if ! grep -q "$SWAP_PATH" /etc/fstab; then
    echo "$SWAP_PATH none swap sw 0 0" >> /etc/fstab
fi

echo "setting swappiness to 10 (prefer ram, minimize disk i/o)..."
echo "vm.swappiness=10" > /etc/sysctl.d/swap.conf
sysctl -p /etc/sysctl.d/swap.conf

echo ""
echo "swap configured at ${SWAP_PATH}"
free -h
