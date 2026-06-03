#!/bin/sh
# post_build.sh - runs after rootfs is populated, before image packing
# used for permission fixups and files that can't be set via the overlay
#
# buildroot calls this with TARGET_DIR and BINARIES_DIR set

set -e

# copy the kernel into the rootfs at /boot/bzImage
# grub loads it from there at boot time. a separate /boot partition
# is not needed - the root ext4 partition holds everything
mkdir -p "${TARGET_DIR}/boot"
cp "${BINARIES_DIR}/bzImage" "${TARGET_DIR}/boot/bzImage"

# ensure dropbear host key directory exists with correct permissions
# keys are generated at first boot by S04dropbear (dropbear -R)
mkdir -p "${TARGET_DIR}/etc/dropbear"
chmod 700 "${TARGET_DIR}/etc/dropbear"

# /root/.ssh must be 700 for dropbear to accept authorized_keys
mkdir -p "${TARGET_DIR}/root/.ssh"
chmod 700 "${TARGET_DIR}/root/.ssh"

# /tmp sticky bit
chmod 1777 "${TARGET_DIR}/tmp"
