#!/bin/bash

# GPS U-blox AG-7 - Logger Principal

CONFIG_FILE="/home/laquilas/tools/app.conf"

# Verificar configuração
if [ ! -f "$CONFIG_FILE" ]; then
    echo "❌ Arquivo de config não encontrado: $CONFIG_FILE"
    exit 1
fi

# Corrigir line endings (caso necessário)
sed -i 's/\r$//' "$CONFIG_FILE" 2>/dev/null || true

source "$CONFIG_FILE"

# Criar diretórios necessários
mkdir -p "$DATA_DIR" "$LOG_DIR" "$TMP_DIR"

# Função de log
log() {
    local MSG="[$(date '+%Y-%m-%d %H:%M:%S')] $1"
    echo "$MSG"
    if [ "$LOG_TO_FILE" = true ]; then
        echo "$MSG" >> "$LOG_FILE"
    fi
}

# Verificar se GPS está habilitado
if [ "$GPS_ENABLED" != true ]; then
    log "GPS desabilitado na configuração"
    exit 0
fi

log "🚀 Iniciando GPS Logger"
log "📍 Dispositivo: $GPS_DEVICE"
log "⏱️  Intervalo: ${GPS_INTERVAL}s"

# Aguardar inicialização
sleep 5

while true; do

    # Verificar se dispositivo GPS existe
    if [ ! -e "$GPS_DEVICE" ]; then
        log "⚠️  GPS não conectado ($GPS_DEVICE) - aguardando..."
        sleep 10
        continue
    fi

    # Gerar timestamps e paths
    NOW=$(date +"%Y-%m-%d %H:%M:%S")
    YEAR=$(date +"%Y")
    MONTH=$(date +"%m")
    DAY=$(date +"%d")

    DIR="$DATA_DIR/$YEAR/$MONTH"
    FILE="$DIR/${YEAR}_${MONTH}_${DAY}_${DB_PREFIX}.db"

    mkdir -p "$DIR"

    # Obter dados GPS
    DATA=$(timeout 10 gpspipe -w -n "$GPS_MAX_ATTEMPTS" 2>/dev/null | grep TPV | head -n 1)

    if [ -z "$DATA" ]; then
        log "⏳ Sem dados GPS disponíveis"
        sleep "$GPS_INTERVAL" 
        continue
    fi

    # Extrair dados GPS completos
    LAT=$(echo "$DATA" | jq -r '.lat // empty')
    LON=$(echo "$DATA" | jq -r '.lon // empty') 
    MODE=$(echo "$DATA" | jq -r '.mode // 0')
    
    # Acurácia e erros
    EPH=$(echo "$DATA" | jq -r '.eph // null')          # Horizontal accuracy
    EPV=$(echo "$DATA" | jq -r '.epv // null')          # Vertical accuracy  
    EPX=$(echo "$DATA" | jq -r '.epx // null')          # Longitude error
    EPY=$(echo "$DATA" | jq -r '.epy // null')          # Latitude error
    EPS=$(echo "$DATA" | jq -r '.eps // null')          # Speed error
    EPT=$(echo "$DATA" | jq -r '.ept // null')          # Time error
    EPC=$(echo "$DATA" | jq -r '.epc // null')          # Climb error
    EPD=$(echo "$DATA" | jq -r '.epd // null')          # Track error
    
    # Altitude
    ALT=$(echo "$DATA" | jq -r '.alt // null')          # Altitude MSL
    ALT_HAE=$(echo "$DATA" | jq -r '.altHAE // null')   # Height Above Ellipsoid
    ALT_MSL=$(echo "$DATA" | jq -r '.altMSL // null')   # Mean Sea Level
    
    # Movimento
    SPEED=$(echo "$DATA" | jq -r '.speed // null')      # Speed over ground
    TRACK=$(echo "$DATA" | jq -r '.track // null')      # Course over ground
    CLIMB=$(echo "$DATA" | jq -r '.climb // null')      # Rate of climb
    
    # Tempo GPS
    GPS_TIME=$(echo "$DATA" | jq -r '.time // empty')   # GPS timestamp

    # Verificar critérios de gravação
    MIN_FIX_REQUIRED="$GPS_MIN_FIX"
    if [ "$GPS_REQUIRE_3D" = true ]; then
        MIN_FIX_REQUIRED=3
    fi

    # Verificar se tem fix válido
    if [ -n "$LAT" ] && [ -n "$LON" ] && [ "$MODE" -ge "$MIN_FIX_REQUIRED" ]; then

        # Salvar no banco com dados expandidos
        sqlite3 "$FILE" "
        CREATE TABLE IF NOT EXISTS gps (
            timestamp TEXT,
            gps_time TEXT,
            lat REAL,
            lon REAL,
            alt_msl REAL,
            alt_hae REAL,
            speed REAL,
            track REAL,
            climb REAL,
            fix_type INTEGER,
            eph REAL,
            epv REAL,
            epx REAL,
            epy REAL,
            eps REAL,
            ept REAL,
            epc REAL,
            epd REAL
        );

        INSERT INTO gps VALUES (
            '$NOW', '$GPS_TIME', 
            $LAT, $LON, 
            $ALT_MSL, $ALT_HAE,
            $SPEED, $TRACK, $CLIMB,
            $MODE,
            $EPH, $EPV, $EPX, $EPY, 
            $EPS, $EPT, $EPC, $EPD
        );
        "

        case "$MODE" in
            2) FIX_TYPE="2D" ;;
            3) FIX_TYPE="3D" ;;
            *) FIX_TYPE="$MODE" ;;
        esac

        # Log expandido com mais dados
        SPEED_DISPLAY="${SPEED:-0.0}"
        ALT_DISPLAY="${ALT_MSL:-n/a}"
        TRACK_DISPLAY="${TRACK:-n/a}"
        
        log "✅ GPS salvo | LAT=$LAT LON=$LON ALT=${ALT_DISPLAY}m SPD=${SPEED_DISPLAY}km/h TRK=${TRACK_DISPLAY}° FIX=$FIX_TYPE ERR=${EPH:-n/a}m"
    else
        log "❌ Fix GPS inválido (mode=$MODE)"
    fi

    sleep "$GPS_INTERVAL"
done