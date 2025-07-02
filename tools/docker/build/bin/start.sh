#!/bin/bash

if [ -f /usr/local/bin/start_vnc.sh ]; then
    /usr/local/bin/start_vnc.sh
fi

/usr/local/bin/confd -onetime -backend env -log-level debug
chown vimacc:vimacc /opt/Accellence/vimacc/etc/*

/usr/local/bin/start_vimacc.sh &

/bin/sleep infinity
