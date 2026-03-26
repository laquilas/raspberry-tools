#!/bin/bash

# Wifite - Diagnóstico de Sistema

echo "==============================="
echo "🔍 Diagnóstico Wifite"
echo "==============================="

echo "📊 Informações do Sistema:"
echo "═══════════════════════════════════════════════════════════════"
echo "   Distribuição: $(lsb_release -d 2>/dev/null | cut -f2- || echo 'Desconhecida')"
echo "   Kernel: $(uname -r)"
echo "   Arquitetura: $(uname -m)"
echo ""

echo "📡 Hardware WiFi:"
echo "═══════════════════════════════════════════════════════════════"
echo "🔍 Dispositivos USB WiFi:"
lsusb | grep -i -E "(wifi|wireless|802\.11|atheros|ralink|realtek)" || echo "   Nenhum dispositivo WiFi USB óbvio detectado"
echo ""

echo "🔍 Interfaces de rede:"
if ls /sys/class/net/ | grep -E "^(wlan|wlp)" >/dev/null; then
    for iface in $(ls /sys/class/net/ | grep -E "^(wlan|wlp)"); do
        echo "   📶 $iface"
        echo "      Dispositivo: $(readlink /sys/class/net/$iface/device/driver 2>/dev/null | xargs basename || echo 'driver desconhecido')"
        echo "      MAC: $(cat /sys/class/net/$iface/address 2>/dev/null || echo 'N/A')"
        
        # Status
        if ip link show "$iface" | grep -q "state UP"; then
            echo "      Status: 🟢 UP"
        else
            echo "      Status: 🔴 DOWN"
        fi
        
        # Capacidades (se disponível)
        if command -v iw >/dev/null 2>&1; then
            if iw "$iface" info >/dev/null 2>&1; then
                TYPE=$(iw "$iface" info | grep "type" | awk '{print $2}' || echo 'unknown')
                echo "      Tipo: $TYPE"
                
                # Verificar suporte a monitor mode
                if iw phy phy0 info 2>/dev/null | grep -q "monitor"; then
                    echo "      Monitor Mode: ✅ Suportado"
                else
                    echo "      Monitor Mode: ❌ Não suportado/Não detectado"
                fi
            fi
        fi
        echo ""
    done
else
    echo "   ❌ Nenhuma interface WiFi encontrada"
    echo ""
    echo "💡 Possíveis causas:"
    echo "   • Adaptador USB WiFi não conectado"
    echo "   • Driver não instalado"
    echo "   • Dispositivo não compatível"
    echo ""
    echo "🔧 Soluções para testar:"
    echo "   • Desconectar e reconectar o adaptador USB"
    echo "   • Tentar em outra porta USB"
    echo "   • Verificar se o adaptador funciona em outro sistema"
    echo ""
fi

echo "🛠️ Ferramentas WiFi Instaladas:"
echo "═══════════════════════════════════════════════════════════════"

# Lista de ferramentas para verificar
TOOLS=(
    "wifite:Wifite2 (ferramenta principal)"
    "aircrack-ng:Suite aircrack-ng"
    "reaver:Ataques WPS"
    "hashcat:Quebra de senhas"
    "macchanger:Alteração de MAC"
    "tshark:Captura de packets"
    "iwconfig:Configuração wireless"
    "iw:Ferramenta wireless moderna"
    "ifconfig:Configuração de rede"
    "hcxdumptool:Captura de handshakes"
    "pixiewps:WPS pixie attacks"
)

INSTALLED_COUNT=0
TOTAL_COUNT=${#TOOLS[@]}

for tool_info in "${TOOLS[@]}"; do
    tool_name="${tool_info%%:*}"
    tool_desc="${tool_info##*:}"
    
    if command -v "$tool_name" >/dev/null 2>&1; then
        echo "   ✅ $tool_name - $tool_desc"
        ((INSTALLED_COUNT++))
    else
        echo "   ❌ $tool_name - $tool_desc"
    fi
done

echo ""
echo "📈 RESUMO: $INSTALLED_COUNT/$TOTAL_COUNT ferramentas instaladas"

# Dar sugestões baseadas no que está faltando
echo ""
echo "💡 Sugestões de Instalação:"
echo "═══════════════════════════════════════════════════════════════"

if ! command -v aircrack-ng >/dev/null 2>&1; then
    echo "🔧 Para aircrack-ng (IMPORTANTE):"
    echo "   sudo apt update"
    echo "   sudo apt install aircrack-ng"
    echo "   # Se falhar, tentar: sudo snap install aircrack-ng"
    echo ""
fi

if ! command -v reaver >/dev/null 2>&1; then
    echo "🔧 Para reaver:"
    echo "   sudo apt install reaver"
    echo ""
fi

if ! command -v hashcat >/dev/null 2>&1; then
    echo "🔧 Para hashcat:"
    echo "   sudo apt install hashcat"
    echo ""
fi

# Verificar se Wifite funciona
echo "🧪 Teste funcional:"
echo "═══════════════════════════════════════════════════════════════"

if command -v wifite >/dev/null 2>&1; then
    echo "✅ Wifite encontrado"
    
    # Verificar se consegue executar
    if timeout 5s wifite --help >/dev/null 2>&1; then
        echo "✅ Wifite executa corretamente"
    else
        echo "⚠️ Wifite instalado mas com problemas na execução"
    fi
    
    # Mostrar versão
    VERSION=$(wifite --version 2>&1 | head -1 || echo "versão desconhecida")
    echo "   Versão: $VERSION"
else
    echo "❌ Wifite não encontrado"
    echo "💡 Caminho manual: python3 /opt/wifite2/wifite.py --help"
fi

echo ""
echo "🎯 Próximos Passos Recomendados:"
echo "═══════════════════════════════════════════════════════════════"

WIFI_COUNT=$(ls /sys/class/net/ 2>/dev/null | grep -E "^(wlan|wlp)" | wc -l)

if [ "$WIFI_COUNT" -eq 0 ]; then
    echo "1️⃣ PRIORITÁRIO: Resolver hardware WiFi"
    echo "   • Conectar adaptador USB WiFi compatível"
    echo "   • Verificar se o adaptador é reconhecido (lsusb)"
    echo "   • Instalar drivers se necessário"
    echo ""
fi

if [ "$INSTALLED_COUNT" -lt 5 ]; then
    echo "2️⃣ Instalar dependências essenciais:"
    echo "   ./01_install.sh"
    echo ""
fi

if command -v wifite >/dev/null 2>&1 && [ "$WIFI_COUNT" -gt 0 ]; then
    echo "3️⃣ Testar funcionamento básico:"
    echo "   ./03_monitor.sh"
    echo "   sudo wifite --no-wps --no-pmkid"
    echo ""
fi

echo "📚 Documentação adicional:"
echo "   README.md - Guia completo"
echo "   https://github.com/derv82/wifite2 - Documentação oficial do Wifite"
echo ""
echo "🔒 LEMBRE-SE: Use apenas em redes autorizadas!"