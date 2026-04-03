#!/bin/sh
# Install hap-homematic into the running OpenCCU as a proper addon,
# mirroring what happens when the .tar.gz is uploaded via the WebUI.
#
# Instead of pulling from npm, it symlinks the workspace source so
# every code change is immediately live — no reinstall needed.

set -e

ADDONNAME=hap-homematic
CONFIG_DIR=/usr/local/etc/config
ADDON_DIR=/usr/local/addons/${ADDONNAME}
ADDONCFG_DIR=${CONFIG_DIR}/addons/${ADDONNAME}
ADDONWWW_DIR=${CONFIG_DIR}/addons/www/${ADDONNAME}
RCD_DIR=${CONFIG_DIR}/rc.d
WORKSPACE=/workspace
LOGFILE=/var/log/hmhapinstall.log

echo "=== hap-homematic addon installer (dev mode) ==="
echo ""

# ---- 1. Wait for CCU services ----
echo "[1/6] Waiting for CCU services..."
"$(dirname "$0")/wait-for-ccu.sh" || exit 1
echo ""

# ---- 2. Create directory structure (same as update_script) ----
echo "[2/6] Creating addon directory structure..."
mkdir -p "${ADDON_DIR}"
mkdir -p "${ADDONCFG_DIR}/etc"
mkdir -p "${ADDONWWW_DIR}"
mkdir -p "${RCD_DIR}"
chmod 755 "${ADDON_DIR}" "${RCD_DIR}"
echo "  ${ADDON_DIR}"
echo "  ${ADDONCFG_DIR}/etc"
echo "  ${ADDONWWW_DIR}"

# ---- 3. Install via symlink instead of npm ----
# The real postinstall.sh does: cd $ADDON_DIR && npm i hap-homematic
# We create the same node_modules/hap-homematic path but as a symlink
# to /workspace so live edits take effect immediately.
echo "[3/6] Linking workspace as installed addon..."
mkdir -p "${ADDON_DIR}/node_modules"
# Remove existing (symlink or dir) to ensure clean state
rm -rf "${ADDON_DIR}/node_modules/${ADDONNAME}"
ln -sf "${WORKSPACE}" "${ADDON_DIR}/node_modules/${ADDONNAME}"
# Install dependencies from the workspace package.json
cd "${WORKSPACE}"
if [ ! -d node_modules ]; then
  echo "  Running npm install (first time)..."
  npm install --loglevel=error
fi
# Marker file the postinstall.sh checks to skip re-install
touch "${ADDON_DIR}/.nobackup"
echo "  -> ${ADDON_DIR}/node_modules/${ADDONNAME} -> ${WORKSPACE}"

# ---- 4. Install web UI files ----
echo "[4/6] Installing WebUI files..."
# Copy config UI static files (HTML/JS/CSS) so lighttpd serves them at /addons/hap-homematic/
cp -rf "${WORKSPACE}/lib/configurationsrv/html/"* "${ADDONWWW_DIR}/"
cp -f "${WORKSPACE}/addon_installer/etc/www/update-check.cgi" "${ADDONWWW_DIR}/"
cp -f "${WORKSPACE}/addon_installer/etc/www/hap-homematic-logo.png" "${ADDONWWW_DIR}/"
chmod +x "${ADDONWWW_DIR}/update-check.cgi"
# Install lighttpd proxy config (proxies external ports to config server)
mkdir -p /etc/config/lighttpd
cp -f "${WORKSPACE}/etc/hap-homematic.conf" "/etc/config/lighttpd/${ADDONNAME}.conf"
# Open proxy ports in firewall via TCL library (persists through WebUI saves)
if [ -f /lib/libfirewall.tcl ]; then
  tclsh - <<'FWEOF'
source /lib/libfirewall.tcl
Firewall_loadConfiguration
global Firewall_USER_PORTS
foreach port {9874 49874} {
  if {[lsearch $Firewall_USER_PORTS $port] == -1} {
    lappend Firewall_USER_PORTS $port
  }
}
Firewall_saveConfiguration
Firewall_configureFirewall
FWEOF
  echo "  Opened ports 9874, 49874 in firewall"
fi
# Reload lighttpd to pick up the new proxy config
killall -HUP lighttpd 2>/dev/null || true
echo "  ${ADDONWWW_DIR}/index.html"
echo "  /etc/config/lighttpd/${ADDONNAME}.conf"

# ---- 5. Install rc.d init script ----
echo "[5/6] Installing rc.d init script..."
cp -f "${WORKSPACE}/addon_installer/rc.d/${ADDONNAME}" "${RCD_DIR}/${ADDONNAME}"
chmod +x "${RCD_DIR}/${ADDONNAME}"
# Copy the postinstall.sh (rc.d calls it on start, but it will be a no-op
# since index.js already exists via symlink)
cp -f "${WORKSPACE}/addon_installer/etc/postinstall.sh" "${ADDONCFG_DIR}/etc/"
chmod +x "${ADDONCFG_DIR}/etc/postinstall.sh"
echo "  ${RCD_DIR}/${ADDONNAME}"

# ---- 6. Register addon button in CCU WebUI ----
echo "[6/6] Registering addon in CCU WebUI..."
# Ensure the hm_addons.cfg exists
touch /etc/config/hm_addons.cfg
node "${WORKSPACE}/etc/hm_addon.js" hap "${WORKSPACE}/etc/hap_addon.cfg"
echo "  Registered 'hap' in /etc/config/hm_addons.cfg"

echo ""
echo "=== Installation complete ==="
echo ""
echo "The addon is now installed exactly as the CCU sees it."
echo "Source is symlinked — edit files in /workspace and restart to pick up changes."
echo ""
echo "Usage:"
echo "  ${RCD_DIR}/${ADDONNAME} start     # start as daemon (background)"
echo "  ${RCD_DIR}/${ADDONNAME} stop      # stop daemon"
echo "  ${RCD_DIR}/${ADDONNAME} restart   # restart daemon"
echo "  ${RCD_DIR}/${ADDONNAME} info      # addon info (version, URL)"
echo "  node ${WORKSPACE}/index.js -D     # run in foreground with debug"
echo ""
echo "WebUI addon button: http://localhost:8080/addons/${ADDONNAME}/index.html"
echo "Config UI:          http://localhost:9874/"
