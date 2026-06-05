#!/bin/sh
# adapted from https://tierhive.com/blog/tierhive-howto/how-to-run-alpine-with-just-23mb-ram
# shared base for alpine minimalization
# handles kernel blacklist, package cleanup, service cleanup, and sysctl tuning
# does not touch the ssh daemon - callers handle that

set -e

if [ "$(id -u)" -ne 0 ]; then
    echo "must be run as root"
    exit 1
fi

echo "1. kernel module blacklist and initramfs"

cat > /etc/modprobe.d/blacklist-unnecessary.conf << 'EOF'
# graphics (headless server)
blacklist drm
blacklist drm_kms_helper
blacklist simpledrm
blacklist virtio_gpu
blacklist fb
# kvm (not nesting vms)
blacklist kvm
blacklist kvm_amd
blacklist kvm_intel
# legacy devices
blacklist floppy
blacklist cdrom
blacklist sr_mod
blacklist isofs
# hid/input (headless)
blacklist hid
blacklist usbhid
blacklist hid_generic
blacklist psmouse
blacklist mousedev
# wrong cloud drivers (not gcp/aws)
blacklist gve
blacklist ena
# force block drm
install drm /bin/true
install drm_kms_helper /bin/true
install simpledrm /bin/true
install fb /bin/true
# usb (not needed on vps)
blacklist usbcore
blacklist xhci_hcd
blacklist xhci_pci
blacklist usb_common
# i2c (not needed)
blacklist i2c_core
blacklist i2c_smbus
blacklist i2c_piix4
# input (headless)
blacklist evdev
blacklist button
# misc
blacklist loop
blacklist ata_generic
blacklist i6300esb
blacklist qemu_fw_cfg
# memory ballooning
blacklist virtio_balloon
# hard block loop device
install loop /bin/true
EOF

# assumes virtio-blk; change to "base ext4 scsi virtio" for virtio-scsi
sed -i 's/^features=.*/features="base ext4 virtio"/' /etc/mkinitfs/mkinitfs.conf

# strip unnecessary modules from bootloader and apply kernel tuning flags
sed -i 's/,usb-storage,ext4,ena,gve/,ext4 ipv6.disable=1 audit=0 nowatchdog/' /boot/extlinux.conf
sed -i 's/,usb-storage,ext4,ena,gve/,ext4/' /etc/update-extlinux.conf
sed -i 's/default_kernel_opts="/default_kernel_opts="ipv6.disable=1 audit=0 nowatchdog /' /etc/update-extlinux.conf

mkinitfs

echo "2. removing cloud-init and python"
# remove the py3-|python3|pyc part of the grep if ansible or python is needed on this host
apk del $(grep "^P:" /lib/apk/db/installed | sed 's/^P://' | grep -E "^(cloud-init|cloud-utils|py3-|python3|pyc)")

echo "3. package cleanup"

# swap chrony for busybox ntpd - chrony is heavier than needed here
if rc-service chronyd status 2>/dev/null; then
    rc-service chronyd stop
fi
rc-update del chronyd default || true
rc-update add ntpd default
apk del chrony chrony-openrc

# remove non-runtime utilities and hypervisor tools not needed on a deployed vps
apk del bash sudo nvme-cli syslinux mtools numactl curl e2fsprogs-extra partx qemu-guest-agent qemu-guest-agent-openrc

# remove orphaned libraries left behind by the packages above
apk del readline gdbm mpdecimal sqlite-libs yaml p11-kit libtasn1 gnutls nettle gmp libidn2 libunistring libexpat libedit libffi shadow tzdata libseccomp libncursesw libpanelw ncurses-terminfo-base

# assumes static ip - remove if dhcp is needed
apk del dhcpcd dhcpcd-openrc

rm -rf /var/cache/apk/*

echo "4. service cleanup"
rc-update del acpid boot || true
rc-update del hwclock boot || true
rc-update del swap boot || true

echo "5. system tuning"

# ipv6 is disabled in the kernel above, so suppress the resulting sysctl warnings
sed -i '/net\.ipv6/s/^/# /' /usr/lib/sysctl.d/00-alpine.conf

# prevent debugfs and tracefs from mounting - not needed and saves a few ms at boot
sed -i 's/mount -n -t debugfs/: #mount -n -t debugfs/' /etc/init.d/sysfs
sed -i 's/mount -n -t tracefs/: #mount -n -t tracefs/' /etc/init.d/sysfs

cat > /etc/sysctl.d/10-minvps.conf << 'EOF'
# reduce network socket buffers
net.core.rmem_default = 32768
net.core.wmem_default = 32768
net.core.rmem_max = 131072
net.core.wmem_max = 131072
net.core.netdev_max_backlog = 64
net.core.somaxconn = 128
# reclaim inode and dentry caches more aggressively under memory pressure
vm.vfs_cache_pressure = 500
# reduce pid table overhead
kernel.pid_max = 4096
# dirty page writeback thresholds
vm.dirty_background_ratio = 5
vm.dirty_ratio = 10
# disable watchdog
kernel.watchdog = 0
EOF

# switch syslog to an in-memory circular buffer to avoid disk writes for logs
sed -i 's/SYSLOGD_OPTS="-t"/SYSLOGD_OPTS="-t -C64"/' /etc/conf.d/syslog

# reduce block device read-ahead; the default is too large for a vps doing small random i/o
# detect the primary virtio block device - almost always vda on tierhive vps
BLKDEV=$(ls /sys/block/ | grep -m1 "^vd" 2>/dev/null || echo "vda")
echo 128 > /sys/block/$BLKDEV/queue/read_ahead_kb
cat > /etc/local.d/readahead.start << EOF
#!/bin/sh
echo 128 > /sys/block/${BLKDEV}/queue/read_ahead_kb
EOF
chmod +x /etc/local.d/readahead.start
rc-update add local default
