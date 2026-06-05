#!/bin/sh
# description: install small daily-use tools and set timezone

set -e

echo "installing base packages"
apk add --no-cache fastfetch doas curl

printf "timezone [default: America/Chicago]: "
read -r TZ_NAME
TZ_NAME="${TZ_NAME:-America/Chicago}"

apk add --no-cache tzdata
if [ ! -f "/usr/share/zoneinfo/$TZ_NAME" ]; then
    echo "timezone not found: $TZ_NAME"
    exit 1
fi
cp "/usr/share/zoneinfo/$TZ_NAME" /etc/localtime
echo "$TZ_NAME" > /etc/timezone
apk del tzdata

echo "timezone set to $TZ_NAME"
