#!/bin/sh
HAPDIR=/usr/local/addons/homekit-ccu/node_modules/homekit-ccu
LOGFILE=/var/log/hkccu-server.log

exec node $HAPDIR/index.js 2>&1 | tee -a $LOGFILE 