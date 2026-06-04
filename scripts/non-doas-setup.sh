#!/bin/sh

# creates a non-root user with:
#   - wheel group membership (doas access)
#   - ash-compatible .profile and .ashrc
#   - optional ssh key copy from root

set -e

if [ "$(id -u)" -ne 0 ]; then
    echo "must be run as root"
    exit 1
fi

echo "creating non-root user"

read_secret() {
    prompt="$1"
    old_stty="$(stty -g)"

    printf "%s" "$prompt"
    trap 'stty "$old_stty"; echo ""; exit 1' INT TERM
    stty -echo
    read -r SECRET_VALUE
    stty "$old_stty"
    trap - INT TERM
    echo ""
}

printf "new username: "
read -r NEW_USER

if [ -z "$NEW_USER" ]; then
    echo "no username entered, skipping user creation"
    exit 0
fi

if id "$NEW_USER" >/dev/null 2>&1; then
    echo "user $NEW_USER already exists, skipping"
    exit 0
fi

# password

while :; do
    read_secret "password for ${NEW_USER}: "
    NEW_PASS="$SECRET_VALUE"

    if [ -z "$NEW_PASS" ]; then
        echo "no password entered, aborting"
        exit 1
    fi

    read_secret "confirm password for ${NEW_USER}: "
    NEW_PASS_CONFIRM="$SECRET_VALUE"

    if [ "$NEW_PASS" = "$NEW_PASS_CONFIRM" ]; then
        break
    fi

    echo "passwords did not match, try again"
done

# create user

echo "creating user $NEW_USER..."
adduser -D -s /bin/ash "$NEW_USER"
printf "%s:%s\n" "$NEW_USER" "$NEW_PASS" | chpasswd

echo "adding $NEW_USER to wheel group..."
adduser "$NEW_USER" wheel

# doas

echo "configuring doas for wheel group..."
mkdir -p /etc/doas.d
echo "permit persist :wheel" > /etc/doas.d/wheel.conf
chmod 640 /etc/doas.d/wheel.conf

# ssh keys

USER_HOME="/home/$NEW_USER"

printf "copy /root/.ssh/authorized_keys to %s? [y/n, default: y]: " "$NEW_USER"
read -r COPY_KEYS
COPY_KEYS="${COPY_KEYS:-y}"

if [ "$COPY_KEYS" = "y" ]; then
    if [ -s /root/.ssh/authorized_keys ]; then
        mkdir -p "$USER_HOME/.ssh"
        cp /root/.ssh/authorized_keys "$USER_HOME/.ssh/authorized_keys"
        chown -R "${NEW_USER}:${NEW_USER}" "$USER_HOME/.ssh"
        chmod 700 "$USER_HOME/.ssh"
        chmod 600 "$USER_HOME/.ssh/authorized_keys"
        echo "ssh keys copied to $USER_HOME/.ssh/authorized_keys"
    else
        echo "no authorized_keys found in /root/.ssh/, skipping"
    fi
fi

# shell config

# .profile: ash-compatible, minimal (profile.d handles aliases/prompt/welcome globally)
cat > "$USER_HOME/.profile" << 'EOF'
export EDITOR=vi
export PAGER=less

if [ -d "$HOME/bin" ]; then
    export PATH="$HOME/bin:$PATH"
fi
EOF

# .ashrc: sources global aliases so they work in non-login interactive shells too
# (alpine's /etc/profile sets ENV=~/.ashrc for interactive non-login shells)
cat > "$USER_HOME/.ashrc" << 'EOF'
[ -f /etc/profile.d/10-aliases.sh ] && . /etc/profile.d/10-aliases.sh
EOF

chown "${NEW_USER}:${NEW_USER}" "$USER_HOME/.profile" "$USER_HOME/.ashrc"
chmod 644 "$USER_HOME/.profile" "$USER_HOME/.ashrc"

# summary

echo ""
echo "user $NEW_USER created"
echo "  shell:  /bin/ash"
echo "  groups: $(id -Gn "$NEW_USER")"
echo "  doas:   permit persist :wheel"
if [ "$COPY_KEYS" = "y" ] && [ -s "$USER_HOME/.ssh/authorized_keys" ]; then
    echo "  ssh:    keys copied from root"
fi
