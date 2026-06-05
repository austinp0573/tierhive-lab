#!/bin/sh
# description: strip alpine down and switch ssh to dropbear
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

if [ "$(id -u)" -ne 0 ]; then
    echo "must be run as root"
    exit 1
fi

# install dropbear and the sftp subsystem before removing other packages
# openssh-sftp-server needed to retain scp function
apk add dropbear openssh-sftp-server
rc-update del sshd default || true
rc-update add dropbear default

sh "$SCRIPT_DIR/lib/alpine-minimal-base.sh"

# remove openssh last
# removing it over an active ssh session can drop the connection
apk del openssh openssh-client-common openssh-client-default openssh-keygen openssh-server \
    openssh-server-common openssh-server-common-openrc openssh-server-pam || true
rm -rf /var/cache/apk/*

# start dropbear now so the session survives if sshd was the active daemon
rc-service dropbear start 2>/dev/null || true

echo ""
echo "alpine minimalization complete"
echo "reboot to apply kernel and service changes"
