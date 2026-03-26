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

WIFITE_INSTALLED=false
WIFITE_WORKING=false

if command -v wifite >/dev/null 2>&1; then
    WIFITE_INSTALLED=true
    echo "✅ Wifite encontrado no PATH"
    
    # Verificar se consegue executar
    if timeout 5s wifite --help >/dev/null 2>&1; then
        WIFITE_WORKING=true
        echo "✅ Wifite executa corretamente"
    else
        echo "⚠️ Wifite instalado mas com problemas na execução"
    fi
    
    # Mostrar versão
    VERSION=$(wifite --version 2>&1 | head -1 || echo "versão desconhecida")
    echo "   Versão: $VERSION"
elif [ -f "/opt/wifite2/wifite.py" ]; then
    echo "⚠️ Wifite encontrado em /opt/wifite2/ mas não está no PATH"
    echo "💡 Solução rápida: sudo ln -sf /opt/wifite2/wifite.py /usr/local/bin/wifite"
    
    # Testar se funciona diretamente
    if timeout 5s python3 /opt/wifite2/wifite.py --help >/dev/null 2>&1; then
        echo "✅ Wifite funciona quando chamado diretamente"
        WIFITE_WORKING=true
    else
        echo "❌ Wifite tem problemas mesmo quando chamado diretamente"
    fi
else
    echo "❌ Wifite não encontrado"
    echo "💡 Instalar: sudo git clone https://github.com/derv82/wifite2.git /opt/wifite2"
fi

echo ""
echo "🎯 SOLUÇÕES ESPECÍFICAS para seu sistema:"
echo "═══════════════════════════════════════════════════════════════"

WIFI_COUNT=$(ls /sys/class/net/ 2>/dev/null | grep -E "^(wlan|wlp)" | wc -l)
AIRCRACK_MISSING=false
if ! command -v aircrack-ng >/dev/null 2>&1; then
    AIRCRACK_MISSING=true
fi

# Priorizada baseada no status atual
echo "📋 Ações recomendadas por prioridade:"
echo ""

if [ "$AIRCRACK_MISSING" = true ]; then
    echo "🚨 CRÍTICO: Instalar aircrack-ng (ferramenta essencial)"
    echo "   Método 1 (preferido):"
    echo "     sudo apt update"
    echo "     sudo apt install aircrack-ng"
    echo ""
    echo "   Método 2 (se método 1 falhar):"
    echo "     sudo snap install aircrack-ng"
    echo "     export PATH=\$PATH:/snap/bin"
    echo "     echo 'export PATH=\$PATH:/snap/bin' >> ~/.bashrc"
    echo ""
    echo "   Método 3 (Ubuntu 22.04+):"
    echo "     sudo apt install software-properties-common"
    echo "     sudo add-apt-repository universe"
    echo "     sudo apt update && sudo apt install aircrack-ng"
    echo ""
fi

if [ "$WIFITE_INSTALLED" = false ]; then
    echo "🔧 IMPORTANTE: Instalar Wifite2"
    echo "   cd /tmp"
    echo "   sudo git clone https://github.com/derv82/wifite2.git /opt/wifite2"
    echo "   sudo chmod +x /opt/wifite2/wifite.py"
    echo "   sudo ln -sf /opt/wifite2/wifite.py /usr/local/bin/wifite"
    echo ""
elif [ "$WIFITE_WORKING" = false ]; then
    echo "🔧 CORRIGIR: Link do Wifite"
    echo "   sudo ln -sf /opt/wifite2/wifite.py /usr/local/bin/wifite"
    echo "   # Testar: wifite --version"
    echo ""
fi

if [ "$WIFI_COUNT" -eq 0 ]; then
    echo "📡 HARDWARE: Resolver interface WiFi"
    echo "   • Conectar adaptador USB WiFi compatível"
    echo "   • Verificar reconhecimento: lsusb | grep -i wifi"
    echo "   • Reiniciar se necessário"
    echo ""
else
    echo "✅ Hardware WiFi: OK ($WIFI_COUNT interface(s) detectada(s))"
    echo ""
fi

echo "⚡ COMANDO RÁPIDO para seu caso:"
echo "───────────────────────────────────────────────────────────────"

if [ "$AIRCRACK_MISSING" = true ] && [ "$WIFITE_INSTALLED" = false ]; then
    echo "# Instalar tudo de uma vez:"
    echo "sudo apt update"
    echo "sudo apt install aircrack-ng || sudo snap install aircrack-ng"
    echo "sudo git clone https://github.com/derv82/wifite2.git /opt/wifite2 2>/dev/null || echo 'Wifite já existe'"
    echo "sudo chmod +x /opt/wifite2/wifite.py"
    echo "sudo ln -sf /opt/wifite2/wifite.py /usr/local/bin/wifite"
    echo ""
    echo "# Testar instalação:"
    echo "wifite --version"
    echo "aircrack-ng --help | head -3"
elif [ "$AIRCRACK_MISSING" = true ]; then
    echo "# Só falta o aircrack-ng:"
    echo "sudo apt install aircrack-ng || sudo snap install aircrack-ng"
    echo ""
elif [ "$WIFITE_INSTALLED" = false ] || [ "$WIFITE_WORKING" = false ]; then
    echo "# Só corrigir o Wifite:"
    echo "sudo ln -sf /opt/wifite2/wifite.py /usr/local/bin/wifite"
    echo "wifite --version"
    echo ""
else
    echo "# Sistema parece estar funcionando, teste:"
    echo "wifite --no-wps --no-pmkid    # Scan seguro"
    echo "./03_monitor.sh               # Monitor de interfaces"
    echo ""
fi

echo "💡 DEPOIS DE CORRIGIR, execute:"
echo "   ./diagnostic.sh              # Verificar novamente" 
echo "   ./03_monitor.sh              # Monitor em tempo real"
echo "   sudo wifite --no-wps --no-pmkid  # Scan de redes (seguro)"

echo ""
echo "🎯 Próximos Passos Sistemáticos:"
echo "═══════════════════════════════════════════════════════════════"

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