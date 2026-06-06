#!/bin/sh
# description: install and configure rootful podman with resource limits and auto-restart

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
apk add podman iptables

# configure cgroups and Resource Limits
# enable cgroups at boot via OpenRC
rc-update add cgroups boot
rc-service cgroups start 2>/dev/null || true

# force podman to use cgroupfs and file logging
mkdir -p /etc/containers
cat <<EOF > /etc/containers/containers.conf
[engine]
cgroup_manager = "cgroupfs"
events_logger = "file"
EOF

# configure auto-restart on reboot
# create an OpenRC service to handle graceful shutdowns and persistent restart policies
cat <<'EOF' > /etc/init.d/podman-restart
#!/sbin/openrc-run

name="podman auto-restart"
description="Starts and stops podman containers with persistent restart policies"

depend() {
    # ensure the disk is ready before podman tries to read its database
    need localmount net cgroups
}

start() {
    ebegin "starting autostart podman containers"
    # route output to a log file to capture boot-time errors
    /usr/bin/podman start --all --filter restart-policy=always --filter restart-policy=unless-stopped >> /var/log/podman-boot.log 2>&1
    eend $?
}

stop() {
    ebegin "Stopping Podman containers gracefully"
    # --time 10 gives containers 10 seconds to shut down cleanly before forcing a kill
    /usr/bin/podman stop --all --ignore --time 10 >> /var/log/podman-boot.log 2>&1
    eend 0
}
EOF

# make the OpenRC service executable
# add it to the default runlevel
chmod +x /etc/init.d/podman-restart
rc-update add podman-restart default

echo ""
if podman info > /dev/null 2>&1; then
    echo "podman is working"
else
    echo "podman info failed"
    echo "a reboot may be needed to fully apply cgroup changes"
fi

echo ""
podman --version