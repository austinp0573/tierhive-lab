#!/bin/sh

podman run -d \
  --name adguard-home \
  --memory=64m \
  --memory-swap=128m \
  --cpus=0.5 \
  --restart unless-stopped \
  -p 53:53/tcp \
  -p 53:53/udp \
  -p 3000:3000/tcp \
  -v /opt/adguard-deploy/data/conf:/opt/adguardhome/conf:Z \
  -v /opt/adguard-deploy/data/work:/opt/adguardhome/work:Z \
  adguard-micro:latest
