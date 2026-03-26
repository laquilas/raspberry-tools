#!/bin/bash

# Wifite - Configuração do Sistema

set -e

CONFIG_FILE="../../app.conf"

echo "================================"
echo "🔧 Wifite - Configuração"  
echo "================================"

# Verificar arquivo de configuração
if [ ! -f "$CONFIG_FILE" ]; then
    echo "❌ Arquivo de config não encontrado: $CONFIG_FILE"
    exit 1
fi

echo "🔄 Corrigindo line endings do arquivo de config..."
# Corrigir line endings (Windows → Linux)
sed -i 's/\r$//' "$CONFIG_FILE" 2>/dev/null || true

source "$CONFIG_FILE"

echo "📡 Detectando interfaces WiFi..."
echo "Interfaces de rede disponíveis:"
ifconfig -a | grep -E "^(wlan|wlp)" || echo "⚠️ Nenhuma interface WiFi detectada"
echo ""

echo "📋 Configurações de rede atuais:"
echo "═══════════════════════════════"
# Mostrar todas as interfaces WiFi
for iface in $(ls /sys/class/net/ | grep -E "^(wlan|wlp)"); do
    echo "🔹 Interface: $iface"
    if ifconfig "$iface" 2>/dev/null | grep -q "UP"; then
        echo "   Status: 🟢 ATIVA"
        ifconfig "$iface" | grep -E "inet |ether" | sed 's/^/   /'
    else
        echo "   Status: 🔴 INATIVA"
        echo "   MAC: $(cat /sys/class/net/$iface/address 2>/dev/null || echo 'N/A')"
    fi
    echo "   Modo: $(iwconfig $iface 2>/dev/null | grep Mode | awk '{print $4}' | cut -d: -f2 || echo 'N/A')"
    echo ""
done

echo "🛠️ Preparando sistema para Wifite..."

# Verificar se há interfaces WiFi
WIFI_INTERFACES=$(ls /sys/class/net/ | grep -E "^(wlan|wlp)" || echo "")
if [ -z "$WIFI_INTERFACES" ]; then
    echo "⚠️ AVISO: Nenhuma interface WiFi encontrada!"
    echo "   Verifique se o adaptador WiFi está conectado."
else
    echo "✅ Interfaces WiFi encontradas: $WIFI_INTERFACES"
fi

# Parar serviços que podem interferir
echo "🔧 Parando serviços que podem interferir..."
sudo systemctl stop wpa_supplicant 2>/dev/null || true
sudo systemctl stop NetworkManager 2>/dev/null || true
sudo systemctl stop dhcpcd 2>/dev/null || true

echo "🔄 Configurando modo monitor (se suportado)..."
for iface in $WIFI_INTERFACES; do
    echo "Testando interface $iface..."
    
    # Desativar interface
    sudo ifconfig "$iface" down 2>/dev/null || true
    
    # Tentar mudar para modo monitor
    if sudo iwconfig "$iface" mode monitor 2>/dev/null; then
        sudo ifconfig "$iface" up
        echo "✅ $iface configurada para modo monitor"
    else
        echo "⚠️ $iface não suporta modo monitor ou precisa de driver específico"
        # Voltar para modo managed
        sudo iwconfig "$iface" mode managed 2>/dev/null || true
        sudo ifconfig "$iface" up
    fi
done

echo "🎯 Criando configuração do Wifite..."
# Criar diretório de configuração
sudo mkdir -p /etc/wifite

# Criar configuração básica
sudo bash -c "cat > /etc/wifite/wifite.conf <<EOF
# Configuração do Wifite
[general]
interface_auto = true
timeout = 60
max_attempts = 5

[wps]
wps_timeout = 120
pixie_timeout = 300

[wpa]
dict_timeout = 3600
handshake_timeout = 30
EOF"

echo "📊 Status final das interfaces:"
echo "═══════════════════════════════"
for iface in $WIFI_INTERFACES; do
    echo "📡 $iface:"
    iwconfig "$iface" 2>/dev/null | grep -E "Mode|Access Point" | sed 's/^/   /' || echo "   Informações não disponíveis"
done

echo "✅ Configuração concluída!"
echo ""
echo "📋 Comandos úteis:"
echo "   🔍 Escanear redes: sudo wifite --no-wps --no-pmkid"
echo "   🎯 Ataque WPS: sudo wifite --wps-only"
echo "   📊 Status interfaces: iwconfig"
echo "   🔧 Modo monitor manual: sudo airmon-ng start <interface>"
echo "   📖 Ajuda: wifite --help"
echo ""
echo "⚠️ IMPORTANTE:"
echo "   • Use apenas em redes próprias ou com autorização"
echo "   • Alguns adaptadores podem precisar de drivers específicos"
echo "   • Para melhor compatibilidade, use adaptadores com chipsets Ralink/Atheros"