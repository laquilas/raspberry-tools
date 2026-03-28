


#!/bin/bash
set -e

if [ $# -lt 3 ]; then
	echo "Usage: $0 MAC CHANNEL MON_IFACE [DURATION]" >&2
	exit 1
fi

MAC="$1"
CHANNEL="$2"
MON_IFACE="$3"
DURATION="${4:-30}"

OUT="capture_${MAC}.pcapng"
OUT=$(echo "$OUT" | sed 's/://g')

echo "[+] Capturando AP $MAC no canal $CHANNEL usando $MON_IFACE por $DURATION segundos..."
# garante monitor mode e canal
ip link set $MON_IFACE down || true
iw dev $MON_IFACE set type monitor || true
ip link set $MON_IFACE up || true
iw dev $MON_IFACE set channel $CHANNEL 2>/dev/null || true

# limita duração com timeout
timeout $DURATION hcxdumptool -i "$MON_IFACE" -c "$CHANNEL" --filterlist_ap="$MAC" -o "$OUT" --enable_status=1 || true

echo "$OUT"