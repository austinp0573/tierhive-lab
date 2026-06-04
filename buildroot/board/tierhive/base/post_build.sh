#!/bin/sh
# post_build.sh - runs after rootfs is populated, before image packing
# used for permission fixups and files that can't be set via the overlay
#
# buildroot calls this with TARGET_DIR and BINARIES_DIR set

set -e

# /root/.ssh must be 700 for dropbear to accept authorized_keys
mkdir -p "${TARGET_DIR}/root/.ssh"
chmod 700 "${TARGET_DIR}/root/.ssh"

# /tmp sticky bit
chmod 1777 "${TARGET_DIR}/tmp"
