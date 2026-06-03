#!/bin/sh
# post_image.sh - assemble a bootable disk image from component images
#
# inputs (set by buildroot):
#   ${BINARIES_DIR}/bzImage                - compiled kernel
#   ${BINARIES_DIR}/rootfs.ext4            - target rootfs (256M)
#   ${BINARIES_DIR}/grub2/i386-pc/boot.img - grub2 mbr boot sector
#   ${BINARIES_DIR}/grub2/i386-pc/core.img - grub2 core image
#
# output:
#   ${BINARIES_DIR}/tierhive-base.img
#
# disk layout:
#   sector 0:         mbr (grub2 boot.img boot code + partition table)
#   sectors 1-2047:   mbr gap (grub2 core.img lives here, ~32kb)
#   sectors 2048+:    partition 1 (ext4 rootfs, 256M)
#
# the kernel (bzImage) is inside the rootfs at /boot/bzImage.
# grub reads /boot/grub/grub.cfg from partition 1, then loads /boot/bzImage.
# no initramfs is used.

set -e

BINARIES="${BINARIES_DIR}"
IMG="${BINARIES}/tierhive-base.img"
ROOTFS="${BINARIES}/rootfs.ext4"

# buildroot places grub2 bios files here when BR2_TARGET_GRUB2_X86_BIOS=y
GRUB2_DIR="${BINARIES}/grub2/i386-pc"
GRUB2_BOOT="${GRUB2_DIR}/boot.img"
GRUB2_CORE="${GRUB2_DIR}/core.img"

# fail loudly if expected files are missing
for f in "${ROOTFS}" "${GRUB2_BOOT}" "${GRUB2_CORE}"; do
    if [ ! -f "${f}" ]; then
        echo "error: required file missing: ${f}"
        echo "  verify: BR2_TARGET_GRUB2=y, BR2_TARGET_GRUB2_X86_BIOS=y"
        echo "  available in ${BINARIES}:"
        ls "${BINARIES}"
        exit 1
    fi
done

# 256M rootfs + 1M gap + 1M for mbr rounding
IMG_SIZE_MB=258

echo "assembling ${IMG} (${IMG_SIZE_MB}MB)..."

# 1. create a blank disk image
dd if=/dev/zero of="${IMG}" bs=1M count="${IMG_SIZE_MB}" 2>/dev/null

# 2. write grub2 boot.img to the mbr (512 bytes at offset 0)
#    the partition table area (bytes 446-511) will be overwritten by sfdisk next
dd if="${GRUB2_BOOT}" of="${IMG}" bs=512 count=1 conv=notrunc 2>/dev/null

# 3. write the partition table with sfdisk
#    sfdisk preserves the boot code (bytes 0-445) and writes only bytes 446-511
#    one linux partition starting at sector 2048 (1M), marked bootable
printf 'label: dos\nunit: sectors\nstart=2048, type=83, bootable\n' \
    | sfdisk --no-reread "${IMG}" 2>/dev/null

# 4. write grub2 core.img into the mbr gap (starting at sector 1)
#    core.img is ~32kb; the gap before sector 2048 is 1MB - plenty of room
dd if="${GRUB2_CORE}" of="${IMG}" bs=512 seek=1 conv=notrunc 2>/dev/null

# 5. write rootfs.ext4 into partition 1 (starting at sector 2048 = 1M offset)
dd if="${ROOTFS}" of="${IMG}" bs=512 seek=2048 conv=notrunc 2>/dev/null

echo "done: ${IMG}"
echo ""
echo "deploy with:"
echo "  dd if=${IMG} of=/dev/vda bs=4M status=progress && sync"
