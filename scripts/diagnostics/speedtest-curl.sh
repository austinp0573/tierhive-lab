#!/bin/sh
# description: run curl-based ipv4 and ipv6 speed tests

set -e

if ! command -v curl > /dev/null 2>&1; then
    echo "curl is not installed - install it with: apk add curl"
    exit 1
fi

# clean up temp files if the script is interrupted mid-test
trap "rm -f /tmp/speed_v4.txt /tmp/speed_v6.txt" EXIT

echo ""
echo "ipv4 test"
curl -4 -o /dev/null -w "%{speed_download}" http://ping.online.net/1000Mo.dat > /tmp/speed_v4.txt
RAW_V4=$(cat /tmp/speed_v4.txt)
MBPS_V4=$(awk "BEGIN {printf \"%.2f\", ($RAW_V4 * 8) / 1000000}")
echo ""
echo "result: $MBPS_V4 mbps"

echo ""
echo "ipv6 test"
curl -6 -o /dev/null -w "%{speed_download}" http://ping6.online.net/1000Mo.dat > /tmp/speed_v6.txt
RAW_V6=$(cat /tmp/speed_v6.txt)
MBPS_V6=$(awk "BEGIN {printf \"%.2f\", ($RAW_V6 * 8) / 1000000}")
echo ""
echo "result: $MBPS_V6 mbps"

echo ""
echo "done"
