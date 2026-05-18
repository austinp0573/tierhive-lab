# Tierhive Scripts

There is a new VPS provider called [tierhive](https://tierhive.com/) that allows you to deploy minimal resource VPSs (Down to 128MB RAM & 1GB Disk).

In order to do this rationally, one must utilize one of the low resource distro images that they provide.

This repository contains a collection of shell scripts and configuration files for system setup, optimization, and automation on Alpine Linux (for now, tierhive is great and I'll likely deploy other distos their as well).

## Contents

- **setup-swap.sh**: Creates and configures a swap file, optimizes swappiness for low-RAM systems.
- **profile-alias.sh**: Sets up user profile, environment variables, and useful shell aliases.
- **alpine-minimal.sh**: Minimal setup script for Alpine Linux (see script for details).
- **ipv6_and_net_optimization.sh**: Network and IPv6 optimization tweaks.
- **non-doas-setup.sh**: User setup script without doas (OpenBSD's sudo alternative).
- **speedtest-script.sh**: Script to run network speed tests.
- **setup-webserver.sh**: Web server setup script (see scripts directory).

## Usage

- Most scripts are intended to be run as root or with appropriate privileges.
- These reflect my personal preference and configuration goals, anyone else
using them should have a look at them before executing.

```sh
./scriptname.sh
```

## Notes

- Thus far all of these are exclusively for use with **Alpine Linux**. Running them on other distros would not be advisable.

---

&nbsp;

**466f724a616e6574**