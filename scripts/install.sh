#!/usr/bin/env ash
# shellcheck shell=dash

echo "Installing coreutils-base64"
opkg install coreutils-base64
mkdir -p /usr/local/bin

files="$(find ./src/*.sh)"

echo "Creating symlinks to /usr/local/bin"
for file in $files; do
  path=$(readlink -f "$file")
  filename=$(basename "$file" .sh)
  ln -sf "$path" "/usr/local/bin/$filename"
done
