#!/bin/sh

set -eu

ARCH=$(uname -m)

echo "Installing package dependencies..."
echo "---------------------------------------------------------------"
pacman -Syu --noconfirm patchelf libnss_nis nss-mdns nss

echo "Installing debloated packages..."
echo "---------------------------------------------------------------"
get-debloated-pkgs --add-common --prefer-nano

echo "Getting binary..."
echo "---------------------------------------------------------------"

case "$ARCH" in
	x86_64)  farch=amd64;;
	aarch64) farch=arm64;;
esac

release=$(curl -fsSL https://api.github.com/repos/aaif-goose/goose/releases/latest)
version=$(echo $release | jq -r '.tag_name | ltrimstr("v")')
link=$(echo $release | jq -r --arg name "goose_${version}_${farch}-vulkan.deb" '.assets[] | select(.name == $name) | .browser_download_url')

curl -sSfL --retry 30 --retry-connrefused "$link" -o /tmp/temp.deb
echo "$version" > ~/version

echo "Preparing AppDir..."
mkdir -p ./AppDir/
bsdtar -xOf /tmp/temp.deb data.tar.zst | bsdtar -xf - --strip-components=2 -C ./AppDir/

mv -f ./AppDir/lib/goose/* ./AppDir/bin/
rm -rf ./AppDir/lib

rm -f ./AppDir/bin/goose
