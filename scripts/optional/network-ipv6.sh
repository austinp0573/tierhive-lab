#!/bin/sh
# description: tune networking and optionally enable static ipv6
# socket buffer sizes scale based on detected ram
# bbr tcp congestion control is applied to all systems
# note: alpine-minimal-base.sh disables ipv6 at the kernel level (ipv6.disable=1)
# if you enable ipv6 here, that flag is removed and ipv6 will be active after reboot

set -e

if [ "$(id -u)" -ne 0 ]; then
    echo "must be run as root"
    exit 1
fi

echo "network optimization"
echo ""

# scale buffer sizes based on available ram
MEM_MB=$(awk '/MemTotal/ {print int($2/1024)}' /proc/meminfo)
echo "detected ${MEM_MB}MB ram"

if [ "$MEM_MB" -le 256 ]; then
    RMEM_MAX=131072
    WMEM_MAX=131072
    TCP_RMEM="4096 87380 131072"
    TCP_WMEM="4096 65536 131072"
    BACKLOG=256
    SOMAXCONN=128
elif [ "$MEM_MB" -le 512 ]; then
    RMEM_MAX=1048576
    WMEM_MAX=1048576
    TCP_RMEM="4096 87380 1048576"
    TCP_WMEM="4096 65536 1048576"
    BACKLOG=1000
    SOMAXCONN=256
elif [ "$MEM_MB" -le 1024 ]; then
    RMEM_MAX=4194304
    WMEM_MAX=4194304
    TCP_RMEM="4096 87380 4194304"
    TCP_WMEM="4096 65536 4194304"
    BACKLOG=4000
    SOMAXCONN=512
else
    RMEM_MAX=16777216
    WMEM_MAX=16777216
    TCP_RMEM="4096 87380 16777216"
    TCP_WMEM="4096 65536 16777216"
    BACKLOG=10000
    SOMAXCONN=1024
fi

echo "buffer sizes set for ${MEM_MB}MB ram (rmem_max=${RMEM_MAX})"

echo ""
printf "enable ipv6? [y/n, default: n]: "
read -r WANT_IPV6
WANT_IPV6="${WANT_IPV6:-n}"

USER_IPV6=""
USER_GATEWAY=""
IPV6_WAS_KERNEL_DISABLED=0

if [ "$WANT_IPV6" = "y" ]; then
    printf "ipv6 address (e.g. 2a11:6c7:1900:2017::2): "
    read -r USER_IPV6
    printf "ipv6 gateway (e.g. 2a11:6c7:1900:2017::1): "
    read -r USER_GATEWAY

    if [ -z "$USER_IPV6" ] || [ -z "$USER_GATEWAY" ]; then
        echo "ipv6 address and gateway are required - skipping ipv6"
        WANT_IPV6=n
    fi

    # check if the minimal base disabled ipv6 at the kernel level and remove the flag if so
    if grep -q "ipv6\.disable=1" /boot/extlinux.conf 2>/dev/null; then
        IPV6_WAS_KERNEL_DISABLED=1
        echo ""
        echo "ipv6 was disabled at the kernel level - removing the flag..."
        sed -i 's/ ipv6\.disable=1//g' /boot/extlinux.conf 2>/dev/null || true
        sed -i 's/ ipv6\.disable=1//g' /etc/update-extlinux.conf 2>/dev/null || true
        sed -i 's/ipv6\.disable=1 //g' /etc/update-extlinux.conf 2>/dev/null || true
        echo "done - ipv6 will be active after reboot"
    fi
fi

# named 99- so it takes precedence over the 10-minvps.conf written by alpine-minimal-base.sh
echo ""
echo "writing /etc/sysctl.d/99-network.conf..."

cat > /etc/sysctl.d/99-network.conf << EOF
# bbr congestion control
net.core.default_qdisc=fq
net.ipv4.tcp_congestion_control=bbr

# socket buffers (scaled for ${MEM_MB}MB ram)
net.core.rmem_default=32768
net.core.wmem_default=32768
net.core.rmem_max=$RMEM_MAX
net.core.wmem_max=$WMEM_MAX
net.ipv4.tcp_rmem=$TCP_RMEM
net.ipv4.tcp_wmem=$TCP_WMEM

# connection handling
net.core.netdev_max_backlog=$BACKLOG
net.core.somaxconn=$SOMAXCONN
net.ipv4.tcp_tw_reuse=1
net.ipv4.tcp_fin_timeout=15
EOF

if [ "$WANT_IPV6" = "y" ]; then
    cat >> /etc/sysctl.d/99-network.conf << 'EOF'

# ipv6
net.ipv6.conf.all.disable_ipv6=0
net.ipv6.conf.default.disable_ipv6=0
net.ipv6.conf.all.accept_ra=2
EOF
fi

# if ipv6 was kernel-disabled and we just removed the flag, the ipv6 sysctl keys
# won't exist until reboot, so apply only ipv4 settings now to avoid errors
if [ "$WANT_IPV6" = "y" ] && [ "$IPV6_WAS_KERNEL_DISABLED" -eq 1 ]; then
    sysctl -w net.core.default_qdisc=fq 2>/dev/null || true
    sysctl -w net.ipv4.tcp_congestion_control=bbr 2>/dev/null || true
    sysctl -w "net.core.rmem_max=$RMEM_MAX" 2>/dev/null || true
    sysctl -w "net.core.wmem_max=$WMEM_MAX" 2>/dev/null || true
    sysctl -w "net.core.netdev_max_backlog=$BACKLOG" 2>/dev/null || true
    sysctl -w "net.core.somaxconn=$SOMAXCONN" 2>/dev/null || true
    sysctl -w net.ipv4.tcp_tw_reuse=1 2>/dev/null || true
    sysctl -w net.ipv4.tcp_fin_timeout=15 2>/dev/null || true
    echo "ipv4 sysctl settings applied"
    echo "ipv6 sysctl settings will apply after reboot"
else
    sysctl -p /etc/sysctl.d/99-network.conf 2>/dev/null || true
    echo "sysctl settings applied"
fi

if [ "$WANT_IPV6" = "y" ]; then
    echo ""
    echo "configuring static ipv6 in /etc/network/interfaces"

    if grep -q "iface eth0 inet6" /etc/network/interfaces 2>/dev/null; then
        echo "ipv6 block already present in /etc/network/interfaces, skipping"
    else
        cat >> /etc/network/interfaces << EOF

iface eth0 inet6 static
    address $USER_IPV6
    netmask 64
    gateway $USER_GATEWAY
EOF
        echo "ipv6 static address configured"
    fi

    # prefer ipv6 for dns resolution
    cat > /etc/gai.conf << 'EOF'
precedence ::ffff:0:0/96  10
precedence ::/0          40
EOF
    echo "ipv6 dns priority set"
fi

echo ""
echo "network optimization complete"
echo "  bbr tcp congestion control enabled"
echo "  socket buffers scaled for ${MEM_MB}MB ram"
if [ "$WANT_IPV6" = "y" ]; then
    echo "  ipv6 address: $USER_IPV6"
    if [ "$IPV6_WAS_KERNEL_DISABLED" -eq 1 ]; then
        echo "  note: reboot required to activate ipv6"
    fi
else
    echo "  ipv6: disabled"
fi
