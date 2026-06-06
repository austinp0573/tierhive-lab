#!/bin/sh
# description: install and configure rootful podman

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

. "$SCRIPT_DIR/lib/common.sh"

require_root

if command -v podman > /dev/null 2>&1; then
    echo "podman is already installed"
    podman --version
    exit 0
fi

apk update
# iptables is required for netavark container networking
apk add podman iptables

# cgroups must be mounted for the container runtime to function
rc-update add cgroups boot
rc-service cgroups start 2>/dev/null || true

# ipv6 is disabled at the kernel level by the alpine minimal setup
# netavark may log ipv6 warnings at runtime but ipv4 container networking works normally

echo ""
if podman info > /dev/null 2>&1; then
    echo "podman is working"
else
    echo "podman info failed - a reboot may be needed to fully apply cgroup changes"
fi

echo ""
podman --version
