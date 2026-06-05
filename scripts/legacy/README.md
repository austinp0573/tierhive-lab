# legacy

these are the original standalone scripts from before the modular runner was built.

they have been superseded by the scripts in core/ and optional/ but are kept here for reference.
do not use these in new setups.

note: scripts that sourced lib/common.sh (setup-swap.sh, setup-zram.sh, non-doas-setup.sh) used
a relative path that assumed they lived at the scripts root. they will fail if run directly from
this legacy/ directory. they are kept for reference only.

| script | superseded by |
| ------ | ------------- |
| alpine-minimal.sh | alternates/minimal-openssh.sh |
| alpine-minimal-dropbear.sh | core/30-minimal-dropbear.sh |
| ipv6_and_net_optimization.sh | optional/network-ipv6.sh |
| non-doas-setup.sh | core/70-user-doas.sh |
| profile-alias.sh | core/60-profile.sh |
| set-hostname.sh | optional/set-hostname.sh |
| setup-swap.sh | core/00-swap.sh |
| setup-zram.sh | core/20-zram.sh |
| setup_webserver.sh | optional/webserver-nginx.sh |
| speedtest-go-setup.sh | core/50-speedtest-go.sh |
| speedtest-script.sh | diagnostics/speedtest-curl.sh |
| unattended-upgrades-setup-alpine.sh | optional/unattended-upgrades.sh |
