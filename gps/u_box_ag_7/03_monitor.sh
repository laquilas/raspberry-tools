#!/bin/bash

# GPS U-blox AG-7 - Monitor em Tempo Real

SESSION_NAME="gps_monitor"
SCRIPT_PATH="$(realpath "$0")"
CONFIG_FILE="../../app.conf"

echo "=========================="
echo "GPS Monitor - Tempo Real"
echo "=========================="

# Se estiver dentro do tmux → executa monitor
if [ -n "$TMUX" ]; then

    if [ ! -f "$CONFIG_FILE" ]; then
        echo "❌ Config não encontrado: $CONFIG_FILE"
        exit 1
    fi
    
    # Corrigir line endings (caso necessário)  
    sed -i 's/\r$//' "$CONFIG_FILE" 2>/dev/null || true
    
    source "$CONFIG_FILE"

    echo "🌍 Monitorando GPS ($GPS_DEVICE)..."
    echo "⏹️  Pressione Ctrl+C para sair"
    echo "📊 Formato: LAT LON | ALT SPD TRK CLB | ERR FIX"
    echo ""

    gpspipe -w | while read -r line; do
        echo "$line" | grep -q '"class":"TPV"' || continue

        # Extrair dados principais
        LAT=$(echo "$line" | jq -r '.lat // empty')
        LON=$(echo "$line" | jq -r '.lon // empty')
        MODE=$(echo "$line" | jq -r '.mode // 0')
        
        # Extrair dados adicionais
        EPH=$(echo "$line" | jq -r '.eph // null')
        ALT_MSL=$(echo "$line" | jq -r '.altMSL // .alt // null')
        SPEED=$(echo "$line" | jq -r '.speed // null')
        TRACK=$(echo "$line" | jq -r '.track // null')
        CLIMB=$(echo "$line" | jq -r '.climb // null')

        if [ -n "$LAT" ] && [ -n "$LON" ] && [ "$MODE" -ge 2 ]; then
            case "$MODE" in
                2) FIX="2D📍" ;;
                3) FIX="3D🎯" ;;
                *) FIX="?❓" ;;
            esac

            # Formatar valores para exibição
            ALT_DISPLAY=$([ "$ALT_MSL" != "null" ] && printf "%.1fm" "$ALT_MSL" || echo "---")
            SPD_DISPLAY=$([ "$SPEED" != "null" ] && printf "%.1fkm/h" "$(echo "$SPEED * 3.6" | bc -l 2>/dev/null)" || echo "---")
            TRK_DISPLAY=$([ "$TRACK" != "null" ] && printf "%.0f°" "$TRACK" || echo "---")
            CLB_DISPLAY=$([ "$CLIMB" != "null" ] && printf "%+.1fm/s" "$CLIMB" || echo "---")
            ERR_DISPLAY=$([ "$EPH" != "null" ] && printf "±%.1fm" "$EPH" || echo "---")

            printf "[%s] LAT:%.6f LON:%.6f | %s %s %s %s | %s %s\n" \
                "$(date '+%H:%M:%S')" "$LAT" "$LON" \
                "$ALT_DISPLAY" "$SPD_DISPLAY" "$TRK_DISPLAY" "$CLB_DISPLAY" \
                "$ERR_DISPLAY" "$FIX"
        else
            printf "[%s] ⏳ Aguardando fix GPS... (mode=%s)\n" "$(date '+%H:%M:%S')" "$MODE"
        fi
    done

# Fora do tmux → cria sessão
else
    tmux has-session -t "$SESSION_NAME" 2>/dev/null

    if [ $? -eq 0 ]; then
        echo "📺 Sessão já ativa. Para conectar:"
        echo "   tmux attach -t $SESSION_NAME"
        echo ""
        echo "👁️  Para ver apenas:"
        echo "   tmux capture-pane -t $SESSION_NAME -p"
    else
        echo "🚀 Iniciando monitor em sessão tmux..."
        tmux new-session -d -s "$SESSION_NAME" "$SCRIPT_PATH"
        echo ""
        echo "✅ Monitor iniciado! Para conectar:"
        echo "   tmux attach -t $SESSION_NAME"
        echo ""
        echo "💡 Comandos tmux úteis:"
        echo "   Ctrl+B, D  = Desconectar (mantém rodando)"
        echo "   Ctrl+C     = Parar monitor"
    fi
fi