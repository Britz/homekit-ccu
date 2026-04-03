FROM ghcr.io/openccu/openccu:latest

# OpenCCU is a buildroot image with /sbin/init as entrypoint.
# We layer Node.js on top so hap-homematic can run inside the CCU
# just like a real addon — connecting to localhost ports directly.

# Install Node.js 20 — detect arch at build time (buildah doesn't set TARGETARCH)
RUN ARCH=$(uname -m) \
    && case "${ARCH}" in \
         aarch64) NODE_ARCH="arm64" ;; \
         x86_64)  NODE_ARCH="x64" ;; \
         *)       NODE_ARCH="x64" ;; \
       esac \
    && wget --no-check-certificate -q -O /tmp/node.tar.xz \
       "https://nodejs.org/dist/v20.18.3/node-v20.18.3-linux-${NODE_ARCH}.tar.xz" \
    && tar -xJf /tmp/node.tar.xz --strip-components=1 -C /usr/local/ \
    && rm /tmp/node.tar.xz

# Create the addon directory structure matching a real CCU addon install
RUN mkdir -p /usr/local/etc/config/addons/hap-homematic/etc \
    && mkdir -p /usr/local/addons/hap-homematic

WORKDIR /workspace
