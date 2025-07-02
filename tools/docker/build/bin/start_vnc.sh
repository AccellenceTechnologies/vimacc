#!/bin/bash

echo 'Updating /etc/hosts file...'
HOSTNAME=$(hostname)

echo "Starting VNC server at $RESOLUTION..."
sudo -u vimacc vncserver -kill :1 || true
sudo -u vimacc vncserver -geometry $RESOLUTION &

echo "VNC server started at $RESOLUTION! ^-^"

# echo "Starting tail -f /dev/null..."
# tail -f /dev/null
