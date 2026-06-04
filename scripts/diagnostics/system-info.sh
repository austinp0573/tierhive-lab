#!/bin/sh
set -e

echo "operating system"
cat /etc/alpine-release 2>/dev/null || cat /etc/os-release

echo ""
echo "kernel"
uname -a

echo ""
echo "virtual hardware"
if [ -r /sys/devices/virtual/dmi/id/sys_vendor ]; then
    printf "vendor: "
    cat /sys/devices/virtual/dmi/id/sys_vendor
fi
if [ -r /sys/devices/virtual/dmi/id/product_name ]; then
    printf "product: "
    cat /sys/devices/virtual/dmi/id/product_name
fi
grep -E 'model name|vendor_id' /proc/cpuinfo | uniq

echo ""
echo "openrc services"
rc-status -s 2>/dev/null || rc-status --all

echo ""
echo "loaded kernel modules"
lsmod
