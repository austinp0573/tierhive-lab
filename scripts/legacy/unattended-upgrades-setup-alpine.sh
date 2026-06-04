#!/bin/sh

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
    # if a kernel or critical lib was updated, leave a reboot alert in motd
    # profile-alias.sh's 30-welcome.sh will display it on next login
    if apk version -l '<' | grep -E -q "linux-|musl|openssl|zlib"; then
        printf "\n\033[1;31m[!] system updates require a reboot to take effect.\033[0m\n\n" > /etc/motd
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
