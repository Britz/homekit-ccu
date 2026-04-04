#!/bin/sh
#
# preinstall.sh — Ensure a compatible Node.js version is available.
#
# Called at the start of the update_script (addon install/update).
# If the system-provided node is missing or too old, this script
# downloads a prebuilt Node.js binary and installs it to /usr/local.
#
# Required version: >=20.0.0 (from package.json "engines")
#

REQUIRED_MAJOR=20
NODE_VERSION="20.18.3"
LOGFILE=/var/log/hkccu-install.log

log() {
  echo "[Preinstall] $1" >>${LOGFILE}
  echo "[Preinstall] $1"
}

# Detect architecture
detect_arch() {
  ARCH=$(uname -m)
  case "${ARCH}" in
    aarch64|arm64) echo "arm64" ;;
    x86_64|amd64)  echo "x64" ;;
    *)
      log "ERROR: unsupported architecture: ${ARCH}"
      return 1
      ;;
  esac
}

# Check if the installed node meets the minimum version requirement.
# Returns 0 if node is present and version >= REQUIRED_MAJOR, 1 otherwise.
check_node_version() {
  if ! command -v node >/dev/null 2>&1; then
    log "Node.js not found in PATH"
    return 1
  fi

  CURRENT_VERSION=$(node --version 2>/dev/null)
  if [ -z "${CURRENT_VERSION}" ]; then
    log "Node.js found but could not determine version"
    return 1
  fi

  # Strip leading 'v' and extract major version
  CURRENT_MAJOR=$(echo "${CURRENT_VERSION}" | sed 's/^v//' | cut -d. -f1)

  if [ "${CURRENT_MAJOR}" -ge "${REQUIRED_MAJOR}" ] 2>/dev/null; then
    log "Node.js ${CURRENT_VERSION} is installed and meets requirement (>=${REQUIRED_MAJOR})"
    return 0
  else
    log "Node.js ${CURRENT_VERSION} is too old (need >=${REQUIRED_MAJOR})"
    return 1
  fi
}

# Download and install Node.js to /usr/local
install_node() {
  NODE_ARCH=$(detect_arch) || return 1
  NODE_URL="https://nodejs.org/dist/v${NODE_VERSION}/node-v${NODE_VERSION}-linux-${NODE_ARCH}.tar.xz"

  log "Downloading Node.js v${NODE_VERSION} for ${NODE_ARCH}..."
  log "URL: ${NODE_URL}"

  TMPFILE=/tmp/node-v${NODE_VERSION}.tar.xz

  # Download — try wget first (available on most buildroot systems), fall back to curl
  if command -v wget >/dev/null 2>&1; then
    wget --no-check-certificate -q -O "${TMPFILE}" "${NODE_URL}"
  elif command -v curl >/dev/null 2>&1; then
    curl -fsSL -o "${TMPFILE}" "${NODE_URL}"
  else
    log "ERROR: neither wget nor curl available"
    return 1
  fi

  if [ ! -f "${TMPFILE}" ] || [ ! -s "${TMPFILE}" ]; then
    log "ERROR: download failed"
    return 1
  fi

  log "Installing Node.js to /usr/local..."
  tar -xJf "${TMPFILE}" --strip-components=1 -C /usr/local/
  RC=$?
  rm -f "${TMPFILE}"

  if [ ${RC} -ne 0 ]; then
    log "ERROR: extraction failed"
    return 1
  fi

  # Verify installation
  if command -v node >/dev/null 2>&1; then
    INSTALLED=$(node --version 2>/dev/null)
    log "Successfully installed Node.js ${INSTALLED}"
    return 0
  else
    log "ERROR: node not found after installation"
    return 1
  fi
}

# ---- Main ----
log "Checking Node.js availability..."

if check_node_version; then
  log "Node.js check passed"
  exit 0
fi

log "Installing compatible Node.js..."
if install_node; then
  log "Node.js installation complete"
  exit 0
else
  log "ERROR: Failed to install Node.js. The addon may not work correctly."
  exit 1
fi
