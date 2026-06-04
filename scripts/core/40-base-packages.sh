#!/bin/sh
# description: install small daily-use tools and set timezone
set -e

echo "installing base packages"
apk add --no-cache fastfetch doas curl

echo "setting timezone to America/Chicago"
apk add --no-cache tzdata
cp /usr/share/zoneinfo/America/Chicago /etc/localtime
echo "America/Chicago" > /etc/timezone
apk del tzdata
