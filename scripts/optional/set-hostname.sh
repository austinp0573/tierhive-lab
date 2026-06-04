#!/bin/sh
# description: set the system hostname
# updates /etc/hostname, /etc/hosts, and applies the change live without a reboot

set -e

if [ "$(id -u)" -ne 0 ]; then
    echo "must be run as root"
    exit 1
fi

CURRENT=$(hostname)
echo "current hostname: $CURRENT"
echo ""
printf "new hostname: "
read -r NEW_HOSTNAME

if [ -z "$NEW_HOSTNAME" ]; then
    echo "no hostname entered, aborting"
    exit 1
fi

if [ "$NEW_HOSTNAME" = "$CURRENT" ]; then
    echo "hostname is already $CURRENT, nothing to do"
    exit 0
fi

echo "$NEW_HOSTNAME" > /etc/hostname

# replace any line referencing the old hostname
if grep -q "$CURRENT" /etc/hosts; then
    sed -i "s/$CURRENT/$NEW_HOSTNAME/g" /etc/hosts
else
    echo "127.0.1.1	$NEW_HOSTNAME" >> /etc/hosts
fi

hostname "$NEW_HOSTNAME"

echo "hostname changed: $CURRENT -> $NEW_HOSTNAME"
