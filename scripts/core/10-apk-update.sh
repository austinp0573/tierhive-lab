#!/bin/sh
# description: refresh apk package indexes
set -e

echo "refreshing package index"
apk update
