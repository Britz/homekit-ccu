#!/bin/sh
set -e

# Read version from package.json — single source of truth
VERSION=$(node -p "require('../package.json').version")
echo "Building homekit-ccu addon v${VERSION}"

mkdir -p tmp
rm -rf tmp/*
mkdir -p tmp/hap/etc
mkdir -p tmp/www

# Build the npm package and include it in the archive
# The CCU's postinstall.sh will install from this tgz (no public registry needed)
cd ..
npm pack
TGZFILE=$(ls homekit-ccu-*.tgz | tail -1)
mv "${TGZFILE}" addon_installer/tmp/hap/etc/homekit-ccu.tgz
cd addon_installer

# copy all relevant stuff
cp -a update_script tmp/
cp -a rc.d tmp/
# Generate VERSION file from package.json version
echo "${VERSION}" > tmp/www/VERSION
cp -a etc tmp/hap

# Patch the VER= line in the rc.d script with the actual version
sed -i "s/^VER=.*/VER=${VERSION}/" tmp/rc.d/homekit-ccu

# generate archive
cd tmp
chmod +x update_script
tar --exclude=._* --exclude=.DS_Store -czvf ../homekit-ccu-${VERSION}.tar.gz *
cd ..
rm -rf tmp
echo "Done: homekit-ccu-${VERSION}.tar.gz"
