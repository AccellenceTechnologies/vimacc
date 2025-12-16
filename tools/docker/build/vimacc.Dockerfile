# ------------------------------------------------------------------------------
# vimacc runtime container (Debian 12)
#
# Key points:
# - No systemd inside the container; we use tini (+ supervisord) for PID1/daemon mgmt
# - Optional GUI with TigerVNC (GUI=true)
# - App user "vimacc"
# - Persistent app dirs: /opt/Accellence/vimacc/{etc,data,log}
# - Defaults stored in /usr/share/vimacc-defaults and copied on first start by entrypoint
# - Supervisor manages each service; logs to STDOUT/STDERR
# ------------------------------------------------------------------------------

FROM debian:12 AS runtime

# --- Build arguments (with safe defaults so the build works without Compose args)
ARG PRODUCT=vimacc
ARG GUI=false

# --- Base env settings
ENV DEBIAN_FRONTEND=noninteractive \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8 \
    RESOLUTION=1920x1080
	
# --- System packages (single layer; clean apt lists at the end)
# Keep runtime libs, no systemd/systemctl here. Use tini + supervisor for process mgmt.
RUN set -eux; \
  apt-get update; \
  apt-get install -y --no-install-recommends \
    ca-certificates wget sudo unzip bash locales locales-all \
    liblz4-1 libburn4 libisofs6 libusb-1.0-0 \
    cron anacron \
    supervisor tini nano \
    dbus-x11 xfonts-base net-tools iputils-ping autocutsel; \
  if [ "$GUI" = "true" ]; then \
    apt-get install -y --no-install-recommends \
      xfce4 xfce4-goodies tigervnc-standalone-server tigervnc-tools xauth; \
  fi; \
  rm -rf /var/lib/apt/lists/*


# --- Application user
RUN adduser --quiet --disabled-password --gecos "" vimacc \
 && echo "vimacc:vimacc" | chpasswd \
 && mkdir -p /home/vimacc/.ssh \
 && chown -R vimacc:vimacc /home/vimacc \
 && usermod -aG sudo vimacc \
 && echo "vimacc ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# --- Required directories (NOTE: 'log' is the correct name, not 'logs')
RUN mkdir -p \
      /opt/Accellence/vimacc/etc \
      /opt/Accellence/vimacc/data \
      /opt/Accellence/vimacc/log \
      /usr/share/vimacc-defaults \
      /etc/supervisor/conf.d

# --- Install local .deb packages shipped with the product
# Use a single apt invocation and clean afterward to keep layers small.
COPY ./${PRODUCT}/deb/*.deb /tmp/deb/
ENV AM_I_IN_A_DOCKER_CONTAINER=yes
RUN set -eux; \
  apt-get update; \
  if ls /tmp/deb/*.deb >/dev/null 2>&1; then apt-get install -y /tmp/deb/*.deb; fi; \
  rm -rf /var/lib/apt/lists/* /tmp/deb


# --- Install confd (used by entrypoint to render config from env)
# For production, consider verifying the binary with a SHA256 checksum.
ENV CONFD_VER=0.16.0
RUN set -eux; \
  wget -O /usr/local/bin/confd "https://github.com/kelseyhightower/confd/releases/download/v${CONFD_VER}/confd-${CONFD_VER}-linux-amd64"; \
  chmod +x /usr/local/bin/confd
COPY ./${PRODUCT}/conf/confd/ /etc/confd/

# --- App defaults (optional: ship an initial config file)
# This file will end up in the defaults store below and be copied on first start
# if the bind-mounted /etc dir is empty.
COPY ./${PRODUCT}/conf/configuration/AccVimaccConfig.conf /opt/Accellence/vimacc/etc/

# --- Copy runtime scripts and supervisor configuration
# docker-entrypoint.sh: init dirs/ownership, confd -onetime, then start supervisord
# start_vimacc.sh: placeholder, not used, cause services handled by supervisord
# start_vnc.sh: runs TigerVNC in foreground as vimacc
COPY ./bin/docker-entrypoint.sh /usr/local/bin/entrypoint.sh
COPY ./bin/start_vimacc.sh      /usr/local/bin/start_vimacc.sh
COPY ./bin/start_vnc.sh         /usr/local/bin/start_vnc.sh
COPY ./bin/supervisor.d/        /etc/supervisor/conf.d/
COPY ./bin/supervisord.conf     /etc/supervisor/supervisord.conf
RUN chmod a+rx /usr/local/bin/entrypoint.sh /usr/local/bin/start_vimacc.sh /usr/local/bin/start_vnc.sh

# --- Optional: pre-create VNC artifacts if GUI=true (do it as vimacc)
USER vimacc
RUN if [ "$GUI" = "true" ]; then \
      mkdir -p "$HOME/.vnc" && \
      if command -v vncpasswd >/dev/null 2>&1; then \
        echo "${VNC_PASSWORD:-vimacc}" | vncpasswd -f > "$HOME/.vnc/passwd"; \
      else \
        echo "vncpasswd not found" >&2; exit 1; \
      fi && \
      chmod 600 "$HOME/.vnc/passwd" && \
      touch "$HOME/.Xauthority"; \
    fi
USER root

# --- Snapshot app defaults into a non-mounted location
# The entrypoint will copy these into bind-mounted dirs on first start (if empty).
RUN cp -a /opt/Accellence/vimacc/. /usr/share/vimacc-defaults/ || true

# --- Declare volumes for persistent data (compose will bind-mount these)
VOLUME ["/opt/Accellence/vimacc/etc", "/opt/Accellence/vimacc/data", "/opt/Accellence/vimacc/log"]

# --- Start chain: tini -> entrypoint (does init + runs supervisord in foreground)
ENTRYPOINT ["/usr/bin/tini","--","/usr/local/bin/entrypoint.sh"]
CMD []

# OCI labels
LABEL org.opencontainers.image.title="vimacc"
LABEL org.opencontainers.image.description="Accellence vimacc runtime (Debian 12, supervisord, optional GUI/VNC)."
LABEL org.opencontainers.image.source="https://github.com/AccellenceTechnologies/vimacc"
LABEL org.opencontainers.image.licenses="MIT"

# ------------------------------------------------------------------------------
# Notes for docker-compose.yml (example):
# ------------------------------------------------------------------------------
# services:
#   vimacc:
#     build:
#       context: ./build
#       target: runtime
#       args:
#         PRODUCT: "vimacc"
#         GUI: "false"             # set to "true" to include GUI + TigerVNC
#     image: vimaccvms:latest
#     container_name: vimacc_enterprise
#     restart: unless-stopped
#     volumes:
#       - ./vimacc-server/vimacc/etc:/opt/Accellence/vimacc/etc
#       - ./vimacc-server/vimacc/data:/opt/Accellence/vimacc/data
#       - ./vimacc-server/vimacc/logs:/opt/Accellence/vimacc/log
#     environment:
#       RESOLUTION: "1600x900"
#     stop_signal: SIGTERM
#     stop_grace_period: 90s
#
# Make sure supervisor programs use 'user=vimacc' and write to STDOUT/STDERR.
# ------------------------------------------------------------------------------
