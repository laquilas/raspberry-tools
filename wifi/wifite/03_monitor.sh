#!/bin/bash

# Wifite - Monitor de Redes WiFi

CONFIG_FILE="../../app.conf"

echo "==============================="
echo "🔥 Wifite - Monitor WiFi"
echo "==============================="

# Verificar arquivo de configuração
if [ -f "$CONFIG_FILE" ]; then
    echo "🔄 Carregando configuração..."
    sed -i 's/\r$//' "$CONFIG_FILE" 2>/dev/null || true
    source "$CONFIG_FILE"
fi

# Função para mostrar status das interfaces
show_interfaces() {
    echo ""
    echo "📡 INTERFACES WiFi:"
    echo "══════════════════════════════════════════════════════════════"
    
    for iface in $(ls /sys/class/net/ | grep -E "^(wlan|wlp)" 2>/dev/null); do
        echo "🔸 Interface: $iface"
        
        # Status da interface
        if ip link show "$iface" 2>/dev/null | grep -q "state UP"; then
            echo "   Status: 🟢 ATIVA"
        else
            echo "   Status: 🔴 INATIVA"
        fi
        
        # MAC Address
        MAC=$(cat "/sys/class/net/$iface/address" 2>/dev/null || echo "N/A")
        echo "   MAC: $MAC"
        
        # Modo atual
        MODE=$(iwconfig "$iface" 2>/dev/null | grep "Mode:" | awk -F"Mode:" '{print $2}' | awk '{print $1}' || echo "N/A")
        echo "   Modo: $MODE"
        
        # Frequência/Canal
        FREQ=$(iwconfig "$iface" 2>/dev/null | grep "Frequency:" | awk -F"Frequency:" '{print $2}' | awk '{print $1}' || echo "N/A")
        if [ "$FREQ" != "N/A" ]; then
            echo "   Frequência: $FREQ"
        fi
        
        # Access Point conectado (se houver)
        AP=$(iwconfig "$iface" 2>/dev/null | grep "Access Point:" | awk -F"Access Point: " '{print $2}' | awk '{print $1}' || echo "N/A")
        if [ "$AP" != "N/A" ] && [ "$AP" != "Not-Associated" ]; then
            echo "   Access Point: $AP"
        fi
        
        echo ""
    done
}

# Função para mostrar redes disponíveis
show_networks() {
    echo "🌐 REDES DISPONÍVEIS:"
    echo "══════════════════════════════════════════════════════════════"
    
    # Encontrar uma interface ativa
    WIFI_IFACE=""
    for iface in $(ls /sys/class/net/ | grep -E "^(wlan|wlp)" 2>/dev/null); do
        if ip link show "$iface" 2>/dev/null | grep -q "state UP"; then
            WIFI_IFACE="$iface"
            break
        fi
    done
    
    if [ -z "$WIFI_IFACE" ]; then
        echo "❌ Nenhuma interface WiFi ativa encontrada"
        return
    fi
    
    echo "📡 Escaneando com interface: $WIFI_IFACE"
    echo ""
    
    # Escanear redes
    timeout 10s sudo iw dev "$WIFI_IFACE" scan 2>/dev/null | grep -E "^BSS|SSID: |signal: |freq: " | \
    while read line; do
        if [[ $line =~ ^BSS ]]; then
            MAC=$(echo $line | awk '{print $2}' | sed 's/(.*//')
            echo "🔸 AP: $MAC"
        elif [[ $line =~ SSID: ]]; then
            SSID=$(echo $line | cut -d':' -f2- | xargs)
            if [ -n "$SSID" ]; then
                echo "   Nome: $SSID"
            else
                echo "   Nome: [HIDDEN]"
            fi
        elif [[ $line =~ signal: ]]; then
            SIGNAL=$(echo $line | awk '{print $2}')
            echo "   Sinal: $SIGNAL dBm"
        elif [[ $line =~ freq: ]]; then
            FREQ=$(echo $line | awk '{print $2}')
            CHANNEL=$(expr \( $FREQ - 2412 \) / 5 + 1 2>/dev/null || echo "?")
            echo "   Canal: $CHANNEL ($FREQ MHz)"
            echo ""
        fi
    done
}

# Função para mostrar estatísticas
show_stats() {
    echo "📊 ESTATÍSTICAS:"
    echo "══════════════════════════════════════════════════════════════"
    
    # Contar interfaces
    TOTAL_IFACES=$(ls /sys/class/net/ | grep -E "^(wlan|wlp)" | wc -l)
    ACTIVE_IFACES=$(ls /sys/class/net/ | grep -E "^(wlan|wlp)" | xargs -I {} sh -c 'ip link show {} | grep -q "state UP" && echo {}' | wc -l)
    
    echo "🔢 Interfaces WiFi: $ACTIVE_IFACES/$TOTAL_IFACES ativas"
    
    # Verificar se Wifite está instalado
    if command -v wifite >/dev/null 2>&1; then
        echo "✅ Wifite: Instalado ($(wifite --version 2>&1 | head -1 || echo "versão desconhecida"))"
    else
        echo "❌ Wifite: Não instalado"
    fi
    
    # Verificar dependências importantes
    echo "🔧 Dependências:"
    for tool in aircrack-ng reaver tshark macchanger; do
        if command -v "$tool" >/dev/null 2>&1; then
            echo "   ✅ $tool"
        else
            echo "   ❌ $tool"
        fi
    done
    
    echo ""
}

# Loop principal
clear
while true; do
    echo "$(date '+%Y-%m-%d %H:%M:%S') - Monitor WiFi Ativo"
    echo ""
    
    show_stats
    show_interfaces
    show_networks
    
    echo "══════════════════════════════════════════════════════════════"
    echo "🔄 Atualizando em 10 segundos... (Ctrl+C para sair)"
    echo "💡 Comandos úteis:"
    echo "   • sudo wifite --help - Ajuda do Wifite"
    echo "   • sudo airmon-ng - Gerenciar modo monitor"
    echo "   • iwconfig - Status das interfaces"
    
    # Aguardar ou sair se Ctrl+C
    for i in {10..1}; do
        echo -ne "\rPróxima atualização em: ${i}s "
        sleep 1
    done
    
    clear
done