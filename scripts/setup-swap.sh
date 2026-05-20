#!/bin/sh

# setup a swapfile
# dd is used instead of fallocate to avoid fragmentation issues on ext4

set -eu

if [ "$(id -u)" -ne 0 ]; then
    echo "must be run as root"
    exit 1
fi

SWAP_PATH="/swapfile"

printf "swap size in MB [default: 512]: "
read -r SWAP_SIZE_MB
SWAP_SIZE_MB="${SWAP_SIZE_MB:-512}"

echo "creating ${SWAP_SIZE_MB}MB swapfile at ${SWAP_PATH}..."
dd if=/dev/zero of="$SWAP_PATH" bs=1M count="$SWAP_SIZE_MB"
chmod 600 "$SWAP_PATH"

echo "formatting swap space"
mkswap "$SWAP_PATH"

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
echo "swap configured: ${SWAP_SIZE_MB}MB at ${SWAP_PATH}"
free -h
