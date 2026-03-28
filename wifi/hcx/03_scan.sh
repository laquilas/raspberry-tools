

#!/bin/bash
set -e

SCAN_OUT="scan_raw.txt"
NETS_LIST="networks.list"

echo "[+] Escaneando em wlan0 por 60 segundos..."
timeout 60 iw dev wlan0 scan | egrep 'BSS|SSID|DS Parameter set|signal' > "$SCAN_OUT" || true

echo "[+] Gerando lista de redes..."
awk '\
/^BSS/ { if(mac) print mac "|" ssid "|" channel; mac=$2; ssid=""; channel=""; next } \
/^\s*SSID:/ {sub(/^\s*SSID: /,""); ssid=$0; next } \
/^\s*DS Parameter set/ { sub(/.*: /,""); channel=$0; next } \
END { if(mac) print mac "|" ssid "|" channel }' "$SCAN_OUT" > "$NETS_LIST"

if [ ! -s "$NETS_LIST" ]; then
	echo "[!] Nenhuma rede encontrada em wlan0"
	exit 1
fi

echo "[+] Lista de redes escrita em $NETS_LIST"
exit 0