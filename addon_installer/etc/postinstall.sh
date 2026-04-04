#!/bin/sh

ADDONNAME=homekit-ccu
CONFIG_DIR=/usr/local/etc/config
ADDON_DIR=/usr/local/addons/${ADDONNAME}
HAPDIR=${ADDON_DIR}/node_modules/${ADDONNAME}
ADDONWWW_DIR=${CONFIG_DIR}/addons/www
NPMCACHE_DIR=/tmp/homekit-ccu-cache
RCD_DIR=${CONFIG_DIR}/rc.d
ADDONCFG_DIR=${CONFIG_DIR}/addons/${ADDONNAME}
LOGFILE=/var/log/hkccu-install.log

log() {
  echo "$(date) [Postinstall] $*" | tee -a ${LOGFILE}
}

log "Check existency of the daemon" 
#check if we have our core module; if not go ahead and call the installer stuff
if [ ! -f ${HAPDIR}/index.js ]; then
log "Looks like the daemon is not here so start installer" 
log "Running on node version:" 
node --version | tee -a ${LOGFILE}
log "NPM is :" 
npm --version | tee -a ${LOGFILE}

log "Program Dir is ${ADDON_DIR}" 

log "installing HomeKit-CCU ..."
#create a cache in /tmp
mkdir ${NPMCACHE_DIR}
cd ${ADDON_DIR}
npm i --cache ${NPMCACHE_DIR} ${ADDONCFG_DIR}/etc/homekit-ccu.tgz
#remove the cache
rm -R ${NPMCACHE_DIR}

#copy config UI static files so lighttpd serves them directly
log "installing WebUI files ..."
mkdir -p ${ADDONWWW_DIR}/${ADDONNAME}
cp -af ${HAPDIR}/lib/configurationsrv/html/* ${ADDONWWW_DIR}/${ADDONNAME}

# install lighttpd proxy config
log "installing lighttpd config ..."
mkdir -p /etc/config/lighttpd
cp -af ${HAPDIR}/etc/homekit-ccu.conf /etc/config/lighttpd/${ADDONNAME}.conf
killall lighttpd 2>/dev/null; sleep 1; lighttpd -f /etc/lighttpd/lighttpd.conf

#create the button in system control
log "creating HomeKit Button ..."
node ${HAPDIR}/etc/hm_addon.js hap ${HAPDIR}/etc/hap_addon.cfg
#create the .nobackup file into the plugin directory to prevent backing up all the node depencities
log "Adding .nobackup to addon dir ..."
touch ${ADDON_DIR}/.nobackup
log "we are done ..."
else
log "daemon exists lets light this candle" 
fi
