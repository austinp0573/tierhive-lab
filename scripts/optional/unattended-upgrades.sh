#!/bin/sh
# description: enable daily apk upgrades through crond
# writes a reboot alert to /etc/motd when kernel or critical libs are updated
# the login welcome script (core/60-profile.sh) displays /etc/motd on login

set -e

if [ "$(id -u)" -ne 0 ]; then
    echo "must be run as root"
    exit 1
fi

echo "setting up unattended upgrades"

cat << 'EOF' > /etc/periodic/daily/unattended-upgrades
#!/bin/sh
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

if apk upgrade -U -a -q; then
    if apk version -l '<' | grep -E -q "linux-|musl|openssl|zlib"; then
        printf "\n[!] system updates require a reboot to take effect.\n\n" > /etc/motd
    else
        > /etc/motd
    fi
    apk cache clean
else
    printf "%s: error - alpine upgrade failed\n" "$(date)" >&2
    exit 1
fi
EOF

chmod 755 /etc/periodic/daily/unattended-upgrades
chown root:root /etc/periodic/daily/unattended-upgrades

rc-update add crond default
rc-service crond start

echo "unattended upgrades enabled (runs daily via crond)"
