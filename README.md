# tierhive-scripts

[Tierhive](https://tierhive.com/) offers VPS instances starting at 128MB RAM and 1GB disk. These scripts set up and configure their Alpine Linux image for minimal resource usage, security, and day-to-day usability.

## usage

Run `setup.sh` first on a fresh VPS. It runs core setup in order, prompts for values where needed, and offers any remaining scripts at the end. Individual scripts can also be run standalone. `run-scripts.sh` walks through everything in the directory interactively.

## scripts

| script | what it does |
|---|---|
| `setup.sh` | main setup — run this first on a fresh VPS |
| `alpine-minimal.sh` | strips the system down: removes cloud-init, python, unused kernel modules, replaces chrony with busybox ntpd, tunes sysctl for low RAM |
| `alpine-minimal-dropbear.sh` | same as above but swaps OpenSSH for Dropbear |
| `setup-swap.sh` | creates a swapfile, prompts for size |
| `setup-zram.sh` | sets up compressed swap in RAM, prompts for size and algorithm |
| `profile-alias.sh` | configures `/etc/profile.d/` with aliases, an ash-compatible prompt, and a fastfetch welcome on login |
| `non-doas-setup.sh` | creates a non-root user, adds them to wheel, configures doas, optionally copies SSH keys |
| `unattended-upgrades-setup-alpine.sh` | daily auto-upgrade via crond, writes a reboot alert to motd when kernel/musl/openssl updates |
| `speedtest-go-setup.sh` | installs speedtest-go |
| `ipv6_and_net_optimization.sh` | network sysctl tuning scaled to available RAM, optional static IPv6 setup |
| `set-hostname.sh` | renames the system hostname cleanly |
| `run-scripts.sh` | walks through every script in the directory and asks if you want to run it |

## notes

- everything here is Alpine Linux only. don't run these on anything else.
- these reflect my personal setup preferences. read them before you run them.
- all scripts must be run as root.

---

&nbsp;

**466f724a616e6574**
