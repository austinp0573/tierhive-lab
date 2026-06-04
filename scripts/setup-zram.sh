#!/bin/sh

# configure zram compressed swap in ram
# lz4 = fastest with good ratio (recommended for low-ram vps)
# lzo  = slightly better compression, slightly more cpu
# zstd = best compression, most cpu
# see: https://linuxreviews.org/Comparison_of_Compression_Algorithms#zram_block_drive_compression

set -e

if [ "$(id -u)" -ne 0 ]; then
    echo "must be run as root"
    exit 1
fi

if grep -q "^/dev/zram" /proc/swaps 2>/dev/null; then
    echo "zram swap is already active"
    cat /proc/swaps
    exit 0
fi

apk add zram-init

echo ""
echo "zram compression algorithm options:"
echo "  lz4   - fastest, good compression ratio (recommended)"
echo "  lzo   - balanced"
echo "  zstd  - best compression, more cpu"
echo ""
printf "algorithm [default: lz4]: "
read -r ALGO
ALGO="${ALGO:-lz4}"

# default to 50% of ram - zram still needs room to operate in the ram it compresses into
MEM_MB=$(awk '/MemTotal/ {print int($2/1024)}' /proc/meminfo)
DEFAULT_SIZE=$((MEM_MB / 2))

echo ""
printf "zram size in MB [default: %s, half of %sMB ram]: " "$DEFAULT_SIZE" "$MEM_MB"
read -r SIZE
SIZE="${SIZE:-$DEFAULT_SIZE}"

cat > /etc/conf.d/zram-init << EOF
load_on_start="yes"
unload_on_stop="yes"
num_devices="1"
type0="swap"
size0="$SIZE"
algo0="$ALGO"
priority0="100"
EOF

rc-update add zram-init boot
rc-service zram-init start

echo ""
echo "zram configured: ${SIZE}MB using ${ALGO} compression"
cat /proc/swaps
free -h