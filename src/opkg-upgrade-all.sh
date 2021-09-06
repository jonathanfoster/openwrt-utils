#!/usr/bin/env sh

echo "Updating package list."
opkg update

echo "Checking for upgradable packages."
opkg list-upgradable

echo "Upgrading packages."
opkg list-upgradable | sed -e "s/\s.*//" | while read -r PKG_NAME; do opkg upgrade "${PKG_NAME}"; done
