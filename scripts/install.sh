#!/usr/bin/env ash
# shellcheck shell=dash

opkg install coreutils-base64
mkdir -p ~/openwrt-utils

files="$(find ./src/*.sh)"

for file in $files
do
  filename=$(basename -- "$file")
  cp "$filename" "$HOME/openwrt-utils/"
  chmod +x "$HOME/openwrt-utils/$filename"
done
