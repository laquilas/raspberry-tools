#!/bin/bash
set -e

# Uso / Ajuda
usage(){
  cat <<EOF
run_full_flow.sh - Orquestra o fluxo HCX (02 -> 03 -> 04 -> 05) usando tmux

Usage:
  ./run_full_flow.sh            # inicia a sessão tmux e executa o fluxo
  ./run_full_flow.sh --clean    # mata sessão tmux existente e reinicia
  ./run_full_flow.sh -h|--help  # mostra esta ajuda

O script:
  - executa `02_config.sh` localmente para detectar a interface de monitor
  - cria uma sessão tmux `hcx_flow` com janelas para scan/logs
  - espera `networks.list` gerado por `03_scan.sh` e cria janelas `capture-*` e `extract-*`
  - salva hashes em `hashes_all.hc22000` quando encontrados

Saídas relevantes (diretório `wifi/hcx`):
  - config.out    : saída de `02_config.sh`
  - scan.out      : saída de `03_scan.sh`
  - capture_*.pcapng
  - extract_*.out
  - tmp_hashes_*.hc22000
  - hashes_all.hc22000

Para acessar a sessão tmux:
  tmux attach -t hcx_flow

EOF
}

# parse args
if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
  usage; exit 0
fi

# opção --clean (mata sessão existente antes de iniciar)
if [ "$1" = "--clean" ]; then
  if tmux has-session -t hcx_flow 2>/dev/null; then
    echo "[+] Matando sessão tmux hcx_flow existente..."
    tmux kill-session -t hcx_flow
  fi
fi

# Orquestrador usando tmux: cada etapa roda em uma janela separada
REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$REPO_DIR"

SESSION="hcx_flow"

for cmd in tmux iw timeout hcxdumptool hcxpcapngtool; do
  if ! command -v $cmd >/dev/null 2>&1; then
    echo "[!] Aviso: $cmd não encontrado no PATH"
  fi
done

# define TMUX_TMPDIR alternativo para evitar erros em /tmp/tmux-0
TMUX_TMPDIR_FALLBACK="/tmp/hcx_tmux"
mkdir -p "$TMUX_TMPDIR_FALLBACK" 2>/dev/null || true
chmod 700 "$TMUX_TMPDIR_FALLBACK" 2>/dev/null || true
export TMUX_TMPDIR="$TMUX_TMPDIR_FALLBACK"

# tenta iniciar o servidor tmux (evita erro 'no server running on /tmp/...')
TMUX_OK=1
if command -v tmux >/dev/null 2>&1; then
  tmux start-server 2>/dev/null || TMUX_OK=0
else
  TMUX_OK=0
fi

if [ $TMUX_OK -eq 1 ]; then
  if tmux has-session -t "$SESSION" 2>/dev/null; then
    echo "[!] Sessão tmux '$SESSION' já existe. Por segurança, remova com: tmux kill-session -t $SESSION" >&2
    exit 1
  fi
else
  echo "[!] tmux não disponível ou servidor não pôde ser iniciado — usando modo sem tmux" >&2
fi

echo "[+] Executando 02_config.sh localmente para obter monitor iface..."
MON_IFACE=$(./02_config.sh) || { echo "[!] Falha ao configurar monitor"; exit 1; }

# prepara diretório de saída em /tmp/data/ANO/MES/DIA e prefixo ANO_MES_DIA_
YEAR=$(date +%Y)
MONTH=$(date +%m)
DAY=$(date +%d)
DATE_PREFIX="${YEAR}_${MONTH}_${DAY}"
OUT_DIR="/tmp/data/${YEAR}/${MONTH}/${DAY}"
mkdir -p "$OUT_DIR"

CONFIG_OUT="$OUT_DIR/${DATE_PREFIX}_config.out"
echo "[+] Monitor iface detectada: $MON_IFACE" | tee "$CONFIG_OUT"

echo "[+] Criando sessão tmux '$SESSION' (detached) com janelas: scan, logs"

# cria sessão e janela scan que executa 03_scan.sh
SCAN_OUT="$OUT_DIR/${DATE_PREFIX}_scan.out"
tmux new-session -d -s "$SESSION" -n scan "bash -lc 'export SESSION=$SESSION; ./03_scan.sh 2>&1 | tee "$SCAN_OUT"; echo "[scan done]"; bash'"

# janela logs: tail do arquivo de hashes
tmux new-window -t "$SESSION" -n logs "bash -lc 'while true; do if [ -f hashes_all.hc22000 ]; then tail -n +1 -f hashes_all.hc22000; else echo "[waiting for hashes_all.hc22000]"; sleep 5; fi; done'"

echo "[+] Aguarde a conclusão do scan (esperando networks.list)..."
WAIT_MAX=90; WAIT=0
while [ ! -f networks.list ] && [ $WAIT -lt $WAIT_MAX ]; do sleep 1; WAIT=$((WAIT+1)); done
if [ ! -f networks.list ]; then
  echo "[!] networks.list não foi gerado em $WAIT_MAX segundos" >&2
  echo "Sessão tmux criada — conecte-se com: tmux attach -t $SESSION" 
  exit 1
fi

echo "[+] networks.list encontrado — criando janelas de captura/extração para cada rede"
while IFS='|' read -r mac ssid channel; do
  SAN_MAC=$(echo "$mac" | sed 's/://g')
  if [ -z "$channel" ]; then channel=6; fi
  DURATION=30
  OUT_CAPTURE="$OUT_DIR/${DATE_PREFIX}_capture_${SAN_MAC}.pcapng"
  OUT_CAPTURE_DONE="${OUT_CAPTURE}.done"
  TMP_HASHES="$OUT_DIR/${DATE_PREFIX}_tmp_hashes_${SAN_MAC}.hc22000"
  TMP_HASHES_DONE="${TMP_HASHES}.done"

  echo "[+] Criando janela tmux capture-$SAN_MAC"
  tmux new-window -t "$SESSION" -n "capture-$SAN_MAC" "bash -lc './04_capture.sh \"$mac\" \"$channel\" \"$MON_IFACE\" $DURATION > \"$OUT_CAPTURE\" 2>&1; echo done > \"$OUT_CAPTURE_DONE\"; bash'"

  # espera a captura terminar
  WAIT_MAX_CAP=$((DURATION+20)); WAIT_CAP=0
  while [ ! -f "$OUT_CAPTURE_DONE" ] && [ $WAIT_CAP -lt $WAIT_MAX_CAP ]; do sleep 1; WAIT_CAP=$((WAIT_CAP+1)); done
  if [ ! -f "$OUT_CAPTURE_DONE" ]; then
    echo "[!] Timeout na captura $mac — pulando"
    continue
  fi

  echo "[+] Criando janela tmux extract-$SAN_MAC"
  EXTRACT_OUT="$OUT_DIR/${DATE_PREFIX}_extract_${SAN_MAC}.out"
  tmux new-window -t "$SESSION" -n "extract-$SAN_MAC" "bash -lc './05_extrair_hash.sh \"$OUT_CAPTURE\" \"$TMP_HASHES\" > \"$EXTRACT_OUT\" 2>&1; echo done > \"$TMP_HASHES_DONE\"; bash'"

  WAIT_EX=20; WAIT_E=0
  while [ ! -f "$TMP_HASHES_DONE" ] && [ $WAIT_E -lt $WAIT_EX ]; do sleep 1; WAIT_E=$((WAIT_E+1)); done

  if [ -f "$TMP_HASHES" ] && [ -s "$TMP_HASHES" ]; then
    HASHES_ALL="$OUT_DIR/${DATE_PREFIX}_hashes_all.hc22000"
    echo "[+] Hash encontrado para $mac — salvando em $HASHES_ALL"
    cat "$TMP_HASHES" >> "$HASHES_ALL"
    echo "[+] Hash salvo. Finalizando fluxo."
    echo "Sessão tmux: tmux attach -t $SESSION"
    exit 0
  else
    echo "[+] Nenhum hash para $mac — prosseguindo"
  fi
done < networks.list

echo "[+] Varredura completa — nenhum hash encontrado"
echo "Sessão tmux ainda está rodando: tmux attach -t $SESSION"
exit 0
