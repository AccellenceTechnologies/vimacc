#!/usr/bin/env bash
set -euo pipefail

APP_HOME="/opt/Accellence/vimacc"
DEFAULTS="/usr/share/vimacc-defaults"

# Resolve effective IDs of the runtime user
VUID="$(id -u vimacc)"
VGID="$(id -g vimacc)"

# 1) Ensure directories
for d in etc data log; do
  mkdir -p "${APP_HOME}/${d}"
done

# 2) Copy defaults once into empty bind-mounts
copy_if_empty() {
  local d="$1"
  if [ -d "${DEFAULTS}/${d}" ] && [ -z "$(ls -A "${APP_HOME}/${d}" 2>/dev/null)" ]; then
    cp -a "${DEFAULTS}/${d}/." "${APP_HOME}/${d}/"
  fi
}
copy_if_empty etc
copy_if_empty data
copy_if_empty log

# 3) Render config from env (confd is optional)
if command -v confd >/dev/null 2>&1; then
  confd -onetime -backend env -log-level debug || true
fi

# 4) Ensure ownership (after confd) so new files belong to the service user
if [ "$(id -u)" = "0" ]; then
  chown -R "${VUID}:${VGID}" "${APP_HOME}" || true
fi

# 5) Start supervisord in foreground (tini is the real PID1)
exec /usr/bin/supervisord -n -c /etc/supervisor/supervisord.conf
