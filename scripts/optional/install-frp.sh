#!/bin/sh

set -eu

if [ "$(id -u)" -ne 0 ]; then
    printf "Error: This script must be run as root or via sudo (or doas).\n" >&2
    exit 1
fi

DETECTED_ARCH=$(uname -m)
case "$DETECTED_ARCH" in
    x86_64)  ARCH="amd64" ;;
    aarch64) ARCH="arm64" ;;
    armv7l)  ARCH="arm" ;;
    *)
        printf "Unsupported architecture: %s\n" "$DETECTED_ARCH" >&2
        exit 1
        ;;
esac

VERSION="0.69.1"
FRP_RELEASE="frp_${VERSION}_linux_${ARCH}"
FRP_RELEASE_GZ="${FRP_RELEASE}.tar.gz"
FRP_RELEASE_URL="https://github.com/fatedier/frp/releases/download/v${VERSION}/${FRP_RELEASE_GZ}"
FRP_ROLE=""

# Create a secure, isolated temporary workspace
WORK_DIR=$(mktemp -d)
cd "$WORK_DIR"

printf "Downloading frp v%s for %s...\n" "$VERSION" "$ARCH"
wget -q "$FRP_RELEASE_URL"

tar -xzf "$FRP_RELEASE_GZ"
cd "$FRP_RELEASE"

while true; do
    printf "ENTER: frp-server (s) or frp-client (c) [s/c]: "
    read -r RESPONSE

    case "$RESPONSE" in
        [sS])
            FRP_ROLE="frps"
            break
            ;;
        [cC])
            FRP_ROLE="frpc"
            break
            ;;
        *)
            printf "Invalid input. Please enter 's' or 'c'.\n\n"
            ;;
    esac
done

mv "$FRP_ROLE" "/usr/local/bin/$FRP_ROLE"
chmod +x "/usr/local/bin/$FRP_ROLE"

mkdir -p /etc/frp
if [ ! -f "/etc/frp/${FRP_ROLE}.toml" ]; then
    touch "/etc/frp/${FRP_ROLE}.toml"
fi

rm -rf "$WORK_DIR"
printf "Successfully installed %s to /usr/local/bin/%s\n" "$FRP_ROLE" "$FRP_ROLE"

printf "To create the openrc for frp:"
printf "apk update"
printf "apk add frp-openrc"
printf "configure /etc/init.d/{frps or frpc}"
printf "rc-update add {frps or frpc} default"
printf "rc-service {frps or frpc} start"