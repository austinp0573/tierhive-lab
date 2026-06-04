#!/bin/sh
set -e

if [ ! -s /root/.ssh/authorized_keys ]; then
    echo "no authorized_keys found in /root/.ssh - skipping ssh hardening to avoid lockout"
    exit 0
fi

if rc-update show default 2>/dev/null | grep -q dropbear || \
   rc-service dropbear status >/dev/null 2>&1; then
    DROPBEAR_CONF="/etc/conf.d/dropbear"

    if grep -q "^DROPBEAR_OPTS=" "$DROPBEAR_CONF" 2>/dev/null; then
        if ! grep "^DROPBEAR_OPTS=" "$DROPBEAR_CONF" | grep -q "\-s"; then
            sed -i 's|^DROPBEAR_OPTS="\(.*\)"|DROPBEAR_OPTS="-s \1"|' "$DROPBEAR_CONF"
        fi
    else
        echo 'DROPBEAR_OPTS="-s"' >> "$DROPBEAR_CONF"
    fi

    echo "dropbear password auth disabled"
else
    SSHD_CONFIG="/etc/ssh/sshd_config"

    set_sshd_opt() {
        key="$1"
        val="$2"

        if grep -q "^#*${key}" "$SSHD_CONFIG"; then
            sed -i "s|^#*${key}.*|${key} ${val}|" "$SSHD_CONFIG"
        else
            echo "${key} ${val}" >> "$SSHD_CONFIG"
        fi
    }

    set_sshd_opt "PasswordAuthentication" "no"
    set_sshd_opt "PermitRootLogin" "prohibit-password"
    set_sshd_opt "ChallengeResponseAuthentication" "no"

    rc-service sshd reload 2>/dev/null || true
    echo "openssh password auth disabled"
fi
