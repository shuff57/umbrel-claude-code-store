#!/bin/bash
# Runs as root on every container start (linuxserver custom-cont-init.d).
set -e
ORCA_VER=1.4.224

if ! command -v orca-ide >/dev/null 2>&1; then
  curl -fsSL -o /tmp/orca.deb "https://github.com/stablyai/orca/releases/download/v${ORCA_VER}/orca-ide_${ORCA_VER}_amd64.deb"
  apt-get update
  DEBIAN_FRONTEND=noninteractive apt-get install -y /tmp/orca.deb nodejs npm git ripgrep
  rm -f /tmp/orca.deb
fi

PFX=/config/.npm-global
if [ ! -x "$PFX/bin/claude" ]; then
  su abc -c "npm install -g --prefix $PFX @anthropic-ai/claude-code"
fi
echo 'export PATH=/config/.npm-global/bin:$PATH' > /etc/profile.d/claude.sh
grep -q npm-global /config/.bashrc 2>/dev/null || echo 'export PATH=/config/.npm-global/bin:$PATH' >> /config/.bashrc

# Autostart Orca in the desktop session (Electron needs --no-sandbox in a container)
mkdir -p /config/.config/autostart
cat > /config/.config/autostart/orca.desktop <<EOF
[Desktop Entry]
Type=Application
Name=Orca
Exec=env PATH=/config/.npm-global/bin:/usr/local/bin:/usr/bin:/bin /opt/Orca/orca-ide --no-sandbox
EOF
chown -R abc:abc /config/.config /config/.bashrc 2>/dev/null || true