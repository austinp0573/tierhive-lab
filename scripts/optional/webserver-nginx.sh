#!/bin/sh
# description: install and configure a minimal nginx site

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

. "$SCRIPT_DIR/lib/common.sh"

require_root

if rc-update show default 2>/dev/null | grep -q nginx; then
    echo "nginx is already enabled"
    rc-service nginx status 2>/dev/null || true
    exit 0
fi

printf "web root directory [default: /var/www/html]: "
read -r WEB_ROOT
WEB_ROOT="${WEB_ROOT:-/var/www/html}"

# free memory before installing - helps on very low-ram vps
sync; echo 3 > /proc/sys/vm/drop_caches

apk update
apk add nginx

mkdir -p "$WEB_ROOT"

NGINX_CONF="/etc/nginx/http.d/default.conf"

if [ -f "$NGINX_CONF" ]; then
    echo "nginx config already exists at $NGINX_CONF, skipping write"
else
    cat > "$NGINX_CONF" << EOF
server {
    listen 80;
    listen [::]:80;
    server_name _;

    root $WEB_ROOT;
    index index.html index.htm;

    location / {
        try_files \$uri \$uri/ =404;
    }

    location ~ /\.git {
        deny all;
    }

    location ~ /\.ht {
        deny all;
    }

    access_log off;
    error_log /var/log/nginx/error.log crit;
}
EOF
fi

chown -R nginx:nginx "$WEB_ROOT"
chmod 755 "$WEB_ROOT"

rc-update add nginx default
rc-service nginx start

echo "nginx configured with web root at $WEB_ROOT"
