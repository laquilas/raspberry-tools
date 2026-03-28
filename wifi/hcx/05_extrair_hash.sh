

#!/bin/bash
set -e

PCAP="${1:-capture.pcapng}"
OUT="${2:-hashes.hc22000}"

if [ ! -f "$PCAP" ]; then
	echo "[!] arquivo de captura não encontrado: $PCAP" >&2
	exit 1
fi

echo "[+] Extraindo hash de $PCAP para $OUT"
hcxpcapngtool -o "$OUT" "$PCAP" || true

if [ -f "$OUT" ] && [ -s "$OUT" ]; then
	echo "$OUT"
	exit 0
else
	echo "[+] Nenhum hash gerado a partir de $PCAP"
	exit 2
fi