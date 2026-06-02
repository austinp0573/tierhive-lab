#!/bin/sh
# post_build.sh - runs after rootfs is populated, before image packing
# used for permission fixups that can't be done via the overlay mechanism
#
# buildroot calls this with $TARGET_DIR set to the target rootfs
# keep this script minimal and explicit

set -e

TARGET_DIR="${TARGET_DIR}"

# ensure dropbear host key directory exists with correct permissions
# keys are generated at first boot by the init script
mkdir -p "${TARGET_DIR}/etc/dropbear"
chmod 700 "${TARGET_DIR}/etc/dropbear"

# ensure /root/.ssh exists with correct permissions for authorized_keys
mkdir -p "${TARGET_DIR}/root/.ssh"
chmod 700 "${TARGET_DIR}/root/.ssh"

# /tmp must be world-writable with sticky bit
chmod 1777 "${TARGET_DIR}/tmp"
