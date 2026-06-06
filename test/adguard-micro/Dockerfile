# Stage 1: Fetch and Extract
FROM alpine:3.19 AS builder
ARG AGH_VERSION=v0.107.43
RUN apk add --no-cache wget tar ca-certificates
RUN wget -qO- https://github.com/AdguardTeam/AdGuardHome/releases/download/${AGH_VERSION}/AdGuardHome_linux_amd64.tar.gz | tar xz

# Stage 2: Minimal Runtime
FROM scratch
# Bring in CA certs for upstream DoH/DoT resolution
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=builder /AdGuardHome/AdGuardHome /AdGuardHome

# Aggressive Go memory tuning
ENV GOMEMLIMIT=40MiB
ENV GOGC=30

EXPOSE 53/tcp 53/udp 80/tcp 443/tcp 3000/tcp

WORKDIR /opt/adguardhome
ENTRYPOINT ["/AdGuardHome", "--no-check-update", "-c", "/opt/adguardhome/conf/AdGuardHome.yaml", "-w", "/opt/adguardhome/work"]
