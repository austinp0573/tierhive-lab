#!/bin/sh
# post_image.sh - assemble a bootable disk image from component images
#
# inputs (set by buildroot):
#   ${BINARIES_DIR}/rootfs.ext4  - target rootfs
#   boot.img                     - grub2 mbr boot sector (found via find)
#   grub.img                     - grub2 core image (found via find)
#
# output:
#   ${BINARIES_DIR}/tierhive-<target>.img
#
# disk layout:
#   sector 0:       mbr (grub2 boot code + partition table)
#   sectors 1-2047: mbr gap (grub2 core image, ~32kb)
#   sectors 2048+:  partition 1 (ext4 rootfs)
#
# the kernel (bzImage) is inside the rootfs at /boot/bzImage via
# BR2_LINUX_KERNEL_INSTALL_TARGET=y. grub reads /boot/grub/grub.cfg
# from partition 1, then loads /boot/bzImage. no initramfs is used.

set -e

BINARIES="${BINARIES_DIR}"
IMG_NAME="tierhive-$(basename "$(dirname "${BINARIES_DIR}")").img"
IMG="${BINARIES}/${IMG_NAME}"
ROOTFS="${BINARIES}/rootfs.ext4"

# buildroot generates grub.img in BINARIES_DIR, but boot.img remains in the build tree
BUILD_DIR="$(dirname "${BINARIES_DIR}")/build"
GRUB2_BOOT=$(find "${BUILD_DIR}" -path "*/grub2-*/build-*/grub-core/boot.img" 2>/dev/null | head -n 1)
GRUB2_CORE=$(find "${BINARIES}" -name "grub.img" 2>/dev/null | head -n 1)


for f in "${ROOTFS}" "${GRUB2_BOOT}" "${GRUB2_CORE}"; do
    if [ ! -f "${f}" ]; then
        echo "error: required file missing: ${f}"
        echo "  grub2 files found in ${BINARIES}:"
        find "${BINARIES}" -name "*.img" 2>/dev/null
        exit 1
    fi
done

# size the image as rootfs + 10M overhead for mbr gap and alignment
ROOTFS_SIZE=$(stat -c%s "${ROOTFS}")
IMG_SIZE=$((ROOTFS_SIZE + 10 * 1024 * 1024))

echo "assembling ${IMG}..."

# 1. create a sparse blank disk image
dd if=/dev/zero of="${IMG}" bs=1 count=0 seek="${IMG_SIZE}" status=none

# 2. write grub2 boot.img to the mbr (512 bytes at offset 0)
dd if="${GRUB2_BOOT}" of="${IMG}" bs=512 count=1 conv=notrunc status=none

# 3. write partition table (sfdisk preserves boot code at bytes 0-445)
printf 'label: dos\nunit: sectors\nstart=2048, type=83, bootable\n' \
    | sfdisk --no-reread "${IMG}" 2>/dev/null

# 4. write grub2 core image into the mbr gap (sectors 1-2047)
dd if="${GRUB2_CORE}" of="${IMG}" bs=512 seek=1 conv=notrunc status=none

# 5. write rootfs into partition 1 (sector 2048 = 1M offset)
dd if="${ROOTFS}" of="${IMG}" bs=512 seek=2048 conv=notrunc status=none

echo "done: ${IMG}"
echo ""
echo "deploy with:"
echo "  dd if=${IMG} of=/dev/vda bs=4M status=progress && sync"
