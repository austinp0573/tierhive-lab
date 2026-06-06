#!/bin/sh
# description: install and configure rootful podman with JIT compose, resource limits, and auto-restart

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
apk add podman iptables docker-cli-compose

# configure cgroups and Resource Limits
# enable cgroups at boot via OpenRC
rc-update add cgroups boot
rc-service cgroups start 2>/dev/null || true

# force podman to use cgroupfs and file logging
# explicitly set the compose_provider to the wrapper to bypass the alpine plugin directory
mkdir -p /etc/containers
cat <<EOF > /etc/containers/containers.conf
[engine]
cgroup_manager = "cgroupfs"
events_logger = "file"
compose_providers = ["/usr/local/bin/docker-compose"]
compose_warning_logs = false
EOF

# configure just-in-time docker compose wrapper
# creates a temporary podman API socket to allow the go compose binary to function without a permanent daemo
cat << 'EOF' > /usr/local/bin/docker-compose
#!/bin/sh
# description: just-in-time wrapper for docker-compose to handle podman's API socket

SOCKET_PATH="/run/podman/podman.sock"
export DOCKER_HOST="unix://$SOCKET_PATH"

# if the socket doesn't exist, start the API service in the background
if [ ! -S "$SOCKET_PATH" ]; then
    mkdir -p "$(dirname "$SOCKET_PATH")"

    # route output to a log file and increase inactivity timeout to 20s
    podman system service --time 20 unix://$SOCKET_PATH > /var/log/podman-api.log 2>&1 &
    
    # wait up to 15 seconds (30 loops * 0.5s) for slow CPU to bind the socket
    for i in $(seq 1 30); do
        if [ -S "$SOCKET_PATH" ]; then
            break
        fi
        sleep 0.5
    done
fi

# strict failsafe
# do not run compose if the socket failed to bind
if [ ! -S "$SOCKET_PATH" ]; then
    echo "ERROR: Podman API failed to start or took too long to bind."
    echo "---- API Crash Logs (/var/log/podman-api.log) ----"
    cat /var/log/podman-api.log
    exit 1
fi

# pass all arguments to the Go-based compose binary
exec /usr/libexec/docker/cli-plugins/docker-compose "$@"
EOF

chmod +x /usr/local/bin/docker-compose

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
    podman --version
else
    echo "podman info failed"
    echo "a reboot may be needed to fully apply cgroup changes"
fi

echo ""
podman --version
docker-compose --version