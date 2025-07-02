FROM debian:11 as vimaccdebian11

#install additonal dependencies
RUN apt-get clean \
  && apt-get update
ARG PRODUCT
ARG GUI
ENV container docker
STOPSIGNAL SIGRTMIN+3
     
#install additonal dependencies
RUN apt-get clean
RUN apt-get update -y
RUN apt-get upgrade -y
RUN apt-get install -y \
        systemctl \
        sudo \
        unzip \     
        locales \    
        locales-all \
        wget \
        liblz4-dev \
        libburn-dev \
        libisofs-dev \
        libusb-1.0-0-dev 

RUN apt-get clean
RUN apt-get update -y
RUN apt-get upgrade -y
RUN apt-get install -y --no-install-recommends \        
        systemd \
        systemd-sysv \
        cron \
        anacron

# Install XFCE, VNC server, dbus-x11, and xfonts-base
RUN if [ "$GUI" = "true" ]; then apt-get update && apt-get install -y --no-install-recommends \
    # libxcb
    '^libxcb.*-dev' \
    libglu1-mesa-dev \
    libx11-xcb-dev \
    libxrender-dev \
    libxi-dev \
    libxkbcommon-dev \
    libxkbcommon-x11-dev \
    # Multimeder
    libasound2-dev \
    libgstreamer1.0-dev \
    libgstreamer-plugins-base1.0-dev \
    libgstreamer-plugins-bad1.0-dev \
    alsa-utils \
#more QT
    libxkbfile-dev \
    xfce4 \
    xfce4-goodies \
    tightvncserver \
    dbus-x11 \
    xfonts-base \
    net-tools \
    iputils-ping \
    autocutsel \
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*; fi

RUN apt-get install -y --no-install-recommends ca-certificates

# Configure systemd.
#
# For running systemd inside a Docker container, some additional tweaks are
# required. For a detailed list see:
#
# https://developers.redhat.com/blog/2016/09/13/ \
#   running-systemd-in-a-non-privileged-container/
#
# Additional tweaks will be applied in the final image below.

# To avoid ugly warnings when running this image on a host running systemd, the
# following units will be masked.
#
# NOTE: This will not remove ALL warnings in all Debian releases, but seems to
#       work for stretch.
RUN systemctl mask --   \
    dev-hugepages.mount \
    sys-fs-fuse-connections.mount

# The machine-id should be generated when creating the container. This will be
# done automatically if the file is not present, so let's delete it.
RUN rm -f           \
    /etc/machine-id \
    /var/lib/dbus/machine-id

# Add user vimacc to the image and set password
RUN adduser --quiet vimacc \
  && echo "vimacc:vimacc" | chpasswd \
  && mkdir /home/vimacc/.ssh \
  && chown -R vimacc:vimacc /home/vimacc/.ssh/ \
  && usermod -aG sudo vimacc
ENV USER=vimacc

COPY ./$PRODUCT/deb/*.deb /tmp/deb/
RUN apt-get clean
RUN apt-get update
RUN apt-get install -y --no-install-recommends apt-utils
# Install all packages, modify to fit other requirements
ENV AM_I_IN_A_DOCKER_CONTAINER=yes
RUN find /tmp/deb/ -maxdepth 1 -type f \
      -name \*.deb \
      -exec apt-get install -y {} + 

# Install confd
ADD https://github.com/kelseyhightower/confd/releases/download/v0.16.0/confd-0.16.0-linux-amd64 /usr/local/bin/confd
RUN chmod +x /usr/local/bin/confd 
RUN mkdir -p /etc/confd/conf.d
RUN mkdir -p /etc/confd/templates
    
COPY ./$PRODUCT/conf/confd/ /etc/confd/

RUN apt-get clean && rm -rf /tmp/*
ENV USER_ID=1000
ENV USER_GID=100

RUN chown -R vimacc:vimacc /opt/Accellence/vimacc
RUN echo "$USER ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
COPY ./bin/start_vnc.sh /usr/local/bin/start_vnc.sh
COPY ./bin/start_$PRODUCT.sh /usr/local/bin/start_vimacc.sh
COPY ./bin/start.sh /usr/local/bin/start.sh
COPY ./bin/stop_vimacc.sh /usr/local/bin/stop_vimacc.sh

#RUN if [ "$GUI" = "true" ]; then chmod a+rx /usr/local/bin/start_vnc.sh; else rm /usr/local/bin/start_vnc.sh; fi
RUN chmod a+rx /usr/local/bin/start.sh
RUN chmod a+rx /usr/local/bin/start_vimacc.sh
RUN chmod a+rx /usr/local/bin/stop_vimacc.sh
USER $USER
# Setup VNC server
RUN if [ "$GUI" = "true" ]; then mkdir /home/$USER/.vnc \
    && echo "vimacc" | vncpasswd -f > /home/$USER/.vnc/passwd \
    && chmod 600 /home/$USER/.vnc/passwd \
    && touch /home/$USER/.Xauthority; fi

# Set display resolution (change as needed)
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

ENV RESOLUTION=1920x1080
ENV USER=vimacc
ENV DEBIAN_FRONTEND=noninteractive

ENV LICENSESERVER=

USER root

# cleanup to reduce disk usage
RUN rm -rf /var/lib/apt/lists/* \
  && apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false
RUN rm -rf /opt/microsoft /root/* /tmp/* /var/cache/*
RUN chmod 777 /usr/local
        
RUN apt-get clean
RUN rm -rf                        \
    /var/lib/apt/lists/*          \
    /var/log/alternatives.log     \
    /var/log/apt/history.log      \
    /var/log/apt/term.log         \
    /var/log/dpkg.log

CMD [ "/usr/local/bin/start.sh" ]

# END VIMACCPACKAGE

