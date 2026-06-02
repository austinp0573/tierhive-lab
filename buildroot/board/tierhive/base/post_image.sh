#!/bin/sh
# post_image.sh - assembles a bootable disk image after buildroot finishes
# called by buildroot with BINARIES_DIR pointing to output/images/

set -e

echo "post_image.sh: stub - disk image assembly not yet implemented"
echo "component images are in: ${BINARIES_DIR}"
echo "  kernel:  ${BINARIES_DIR}/bzImage"
echo "  rootfs:  ${BINARIES_DIR}/rootfs.ext4"
