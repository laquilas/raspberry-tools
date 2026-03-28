#!/bin/bash
set -e

echo "[+] Detectando interfaces wireless..."
# lista interfaces gerenciadas pelo `iw`
IFS_LIST=$(iw dev | awk '/Interface/ {print $2}')
MON_IFACE=""
for i in $IFS_LIST; do
	if [ "$i" != "wlan0" ]; then
		MON_IFACE=$i
		break
	fi
done

if [ -z "$MON_IFACE" ]; then
	echo "[!] Nenhuma interface wireless alternativa encontrada (diferente de wlan0)" >&2
	exit 1
fi

echo "[+] Usando interface para monitor: $MON_IFACE"
echo "[+] Derrubando interface..."
ip link set $MON_IFACE down

echo "[+] Setando modo monitor..."
iw dev $MON_IFACE set type monitor

echo "[+] Subindo interface..."
ip link set $MON_IFACE up

echo "[+] Status atual:"
iw dev

# Imprime o nome da interface para o chamador (útil para scripts que invocam este)
echo "$MON_IFACE"
