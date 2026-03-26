#!/bin/bash

# Wifite - Configuração do Sistema

CONFIG_FILE="../../app.conf"

echo "================================"
echo "🔧 Wifite - Configuração"  
echo "================================"

# Verificar arquivo de configuração
if [ ! -f "$CONFIG_FILE" ]; then
    echo "❌ Arquivo de config não encontrado: $CONFIG_FILE"
    echo "💡 Criando configuração básica..."
    
    # Criar configuração básica se não existe
    cat > "$CONFIG_FILE" << 'EOF'
# ==============================
# APP GERAL
# ==============================
APP_NAME="raspberry-tools"
ENV="prod"
BASE_DIR="/home/laquilas/tools"

# ==============================  
# WIFI / WIFITE
# ==============================
WIFI_ENABLED=true
WIFI_INTERFACE_AUTO=true
WIFI_SCAN_TIMEOUT=30
WIFI_WPS_ENABLED=true
EOF
    echo "✅ Configuração básica criada"
fi

echo "🔄 Corrigindo line endings do arquivo de config..."
# Corrigir line endings (Windows → Linux)
sed -i 's/\r$//' "$CONFIG_FILE" 2>/dev/null || true

# Carregar configurações (com fallback para defaults)
if source "$CONFIG_FILE" 2>/dev/null; then
    echo "✅ Configurações carregadas de $CONFIG_FILE"
else
    echo "⚠️ Problema ao carregar $CONFIG_FILE, usando defaults"
    WIFI_ENABLED=true
    WIFI_INTERFACE_AUTO=true
fi

echo "📡 Detectando interfaces WiFi..."
echo "Interfaces de rede disponíveis:"
if command -v ifconfig >/dev/null 2>&1; then
    ifconfig -a | grep -E "^(wlan|wlp)" || echo "⚠️ Nenhuma interface WiFi detectada"
else
    ip link show | grep -E "(wlan|wlp)" || echo "⚠️ Nenhuma interface WiFi detectada"
fi
echo ""

echo "📋 Configurações de rede atuais:"
echo "═══════════════════════════════"

# Mostrar todas as interfaces WiFi
WIFI_INTERFACES=$(ls /sys/class/net/ 2>/dev/null | grep -E "^(wlan|wlp)" || echo "")
if [ -n "$WIFI_INTERFACES" ]; then
    for iface in $WIFI_INTERFACES; do
        echo "🔹 Interface: $iface"
        
        # Verificar se está ativa
        if ip link show "$iface" 2>/dev/null | grep -q "state UP"; then
            echo "   Status: 🟢 ATIVA"
            if command -v ifconfig >/dev/null 2>&1; then
                ifconfig "$iface" 2>/dev/null | grep -E "inet |ether" | sed 's/^/   /' || true
            fi
        else
            echo "   Status: 🔴 INATIVA"
            echo "   MAC: $(cat /sys/class/net/$iface/address 2>/dev/null || echo 'N/A')"
        fi
        
        # Verificar modo (se iwconfig disponível)
        if command -v iwconfig >/dev/null 2>&1; then
            MODE=$(iwconfig "$iface" 2>/dev/null | grep "Mode:" | awk -F"Mode:" '{print $2}' | awk '{print $1}' || echo 'N/A')
            echo "   Modo: $MODE"
        fi
        echo ""
    done
else
    echo "⚠️ AVISO: Nenhuma interface WiFi encontrada!"
    echo "   💡 Verifique se o adaptador WiFi está conectado"
    echo "   💡 Para USB WiFi, tente desconectar e reconectar"
    echo "   💡 Use 'lsusb' para ver dispositivos USB conectados"
fi

echo "🛠️ Preparando sistema para Wifite..."

# Parar serviços que podem interferir (não falhar se der erro)
echo "🔧 Parando serviços que podem interferir..."
echo "   Parando wpa_supplicant..."
sudo systemctl stop wpa_supplicant 2>/dev/null && echo "   ✅ wpa_supplicant parado" || echo "   ⚠️ wpa_supplicant não estava rodando"

echo "   Parando NetworkManager..."  
sudo systemctl stop NetworkManager 2>/dev/null && echo "   ✅ NetworkManager parado" || echo "   ⚠️ NetworkManager não estava rodando"

echo "   Parando dhcpcd..."
sudo systemctl stop dhcpcd 2>/dev/null && echo "   ✅ dhcpcd parado" || echo "   ⚠️ dhcpcd não estava rodando"
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