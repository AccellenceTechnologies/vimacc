#!/usr/bin/env bash
set -euo pipefail

RESOLUTION="${RESOLUTION:-1600x900}"

# Must run as user 'vimacc'
if [ "$(id -un)" != "vimacc" ]; then
  echo "start_vnc.sh should be run as user 'vimacc' (supervisor user=vimacc)."
  exit 1
fi

if ! command -v vncserver >/dev/null 2>&1; then
  echo "vncserver not found; GUI/VNC likely disabled. Skipping."
  exit 0
fi

echo "Starting VNC server as 'vimacc' on :1 at ${RESOLUTION}..."

# Clean previous session (tolerant)
vncserver -kill :1 >/dev/null 2>&1 || true
rm -f "$HOME/.vnc/$(hostname)":1.pid "$HOME/.X1-lock" 2>/dev/null || true

# Start in foreground (TigerVNC supports -fg)
exec vncserver :1 -geometry "${RESOLUTION}" -fg \
  -localhost no \
  -SecurityTypes VncAuth \
  -PasswordFile "$HOME/.vnc/passwd"