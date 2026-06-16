#!/bin/sh
# description: configure shell aliases, prompt, and login welcome
# writes to /etc/profile.d/ for system-wide coverage, and root ~/.profile and ~/.ashrc

set -e

if [ "$(id -u)" -ne 0 ]; then
    echo "must be run as root"
    exit 1
fi

echo "configuring shell environment..."

# clear motd - unattended-upgrades writes alerts here when needed
echo -n "" > /etc/motd

# sourced by /etc/profile for login shells and by ~/.ashrc for non-login interactive shells
cat > /etc/profile.d/10-aliases.sh << 'EOF'
alias ls='ls --color=auto'
alias l='ls --color=auto -Alrth'
alias df='df -h'
alias free='free -h'
alias top='top -d 1'
alias nerd='nerdctl'
alias doas='doas '

c() {
    curl -s "cht.sh/$1"
}
EOF

# ash-compatible prompt: user@short-hostname:cwd with # for root, $ for others
cat > /etc/profile.d/20-prompt.sh << 'EOF'
if [ "$(id -u)" -eq 0 ]; then
    export PS1='${USER:-root}@${HOSTNAME%%.*}:${PWD}# '
else
    export PS1='${USER}@${HOSTNAME%%.*}:${PWD}$ '
fi
EOF

# login welcome: fastfetch + any motd alerts from unattended-upgrades
cat > /etc/profile.d/30-welcome.sh << 'EOF'
clear
echo ""
command -v fastfetch > /dev/null 2>&1 && fastfetch
echo ""
echo "welcome to $HOSTNAME $(whoami) - DATE: $(date)"
if [ -s /etc/motd ]; then
    echo ""
    cat /etc/motd
fi
echo ""
echo ""
EOF

# /etc/profile and profile.d already run before this on login, so only root-specific overrides here
cat > /root/.profile << 'EOF'
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
export EDITOR=vi
export PAGER=less

alias shutdown='halt'
EOF

# sourced by ash for non-login interactive shells (ENV=~/.ashrc set by /etc/profile)
cat > /root/.ashrc << 'EOF'
[ -f /etc/profile.d/10-aliases.sh ] && . /etc/profile.d/10-aliases.sh
alias shutdown='halt'
EOF

chmod 644 /root/.profile /root/.ashrc

echo "done"
echo "  /etc/profile.d/10-aliases.sh  - aliases and c() cheat.sh function"
echo "  /etc/profile.d/20-prompt.sh   - ash-compatible uid-aware prompt"
echo "  /etc/profile.d/30-welcome.sh  - fastfetch + motd on login"
echo "  /root/.profile                - root path/editor/pager + shutdown alias"
echo "  /root/.ashrc                  - aliases for non-login shells"
