#!/bin/bash

set -e

echo "[+] Instalando dependências..."
apt sudo apt-get install build-essential autoconf automake libtool pkg-config libnl-3-dev libnl-genl-3-dev libssl-dev ethtool shtool rfkill zlib1g-dev libpcap-dev libsqlite3-dev libpcre2-dev libhwloc-dev libcmocka-dev hostapd wpasupplicant tcpdump screen iw usbutils expect hcxtools hcxdumptool
# https://github.com/aircrack-ng/aircrack-ng