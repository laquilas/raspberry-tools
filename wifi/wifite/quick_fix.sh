#!/bin/bash

# Wifite - Correção Rápida Baseada no Diagnóstico

echo "==============================="
echo "🔧 Correção Rápida Wifite"
echo "==============================="

echo "🔍 Analisando sistema atual..."

# Verificar o que está faltando
MISSING_AIRCRACK=false
MISSING_WIFITE=false
WIFI_OK=false

# Verificar aircrack-ng
if ! command -v aircrack-ng >/dev/null 2>&1; then
    MISSING_AIRCRACK=true
    echo "❌ aircrack-ng não encontrado"
else
    echo "✅ aircrack-ng presente"
fi

# Verificar Wifite
if ! command -v wifite >/dev/null 2>&1; then
    if [ -f "/opt/wifite2/wifite.py" ]; then
        echo "⚠️ Wifite presente mas link quebrado"
        MISSING_WIFITE=true
    else
        echo "❌ Wifite não instalado"  
        MISSING_WIFITE=true
    fi
else
    echo "✅ Wifite presente"
fi

# Verificar interfaces WiFi
WIFI_COUNT=$(ls /sys/class/net/ 2>/dev/null | grep -E "^(wlan|wlp)" | wc -l)
if [ "$WIFI_COUNT" -gt 0 ]; then
    echo "✅ $WIFI_COUNT interface(s) WiFi detectada(s)"
    WIFI_OK=true
else
    echo "❌ Nenhuma interface WiFi detectada"
fi

echo ""
echo "🚀 EXECUTANDO CORREÇÕES AUTOMÁTICAS:"
echo "═══════════════════════════════════════════════════════════════"

# Correção 1: aircrack-ng
if [ "$MISSING_AIRCRACK" = true ]; then
    echo ""
    echo "🔸 [1/3] Instalando aircrack-ng..."
    echo "   Método 1: APT..."
    if sudo apt update && sudo apt install -y aircrack-ng 2>/dev/null; then
        echo "   ✅ aircrack-ng instalado via APT"
    else
        echo "   ⚠️ APT falhou, tentando Snap..."
        if command -v snap >/dev/null 2>&1; then
            if sudo snap install aircrack-ng 2>/dev/null; then
                echo "   ✅ aircrack-ng instalado via Snap"
                export PATH=$PATH:/snap/bin
                echo 'export PATH=$PATH:/snap/bin' >> ~/.bashrc
                echo "   📝 PATH atualizado para incluir /snap/bin"
            else
                echo "   ❌ Snap também falhou"
            fi
        else
            echo "   ❌ Snap não disponível"
        fi
    fi
else
    echo "🔸 [1/3] aircrack-ng: ✅ Já presente"
fi

# Correção 2: Wifite
if [ "$MISSING_WIFITE" = true ]; then
    echo ""
    echo "🔸 [2/3] Corrigindo Wifite..."
    
    # Se diretório existe, só criar link
    if [ -d "/opt/wifite2" ]; then
        echo "   📁 Diretório /opt/wifite2 encontrado, criando link..."
        sudo chmod +x /opt/wifite2/wifite.py
        sudo ln -sf /opt/wifite2/wifite.py /usr/local/bin/wifite
        echo "   ✅ Link criado: /usr/local/bin/wifite"
    else
        echo "   📥 Baixando Wifite2 do GitHub..."
        if sudo git clone https://github.com/derv82/wifite2.git /opt/wifite2; then
            sudo chmod +x /opt/wifite2/wifite.py
            sudo ln -sf /opt/wifite2/wifite.py /usr/local/bin/wifite
            echo "   ✅ Wifite2 instalado e link criado"
        else
            echo "   ❌ Falha ao baixar Wifite2"
        fi
    fi
else
    echo "🔸 [2/3] Wifite: ✅ Já presente"
fi

# Correção 3: Verificação final e teste
echo ""
echo "🔸 [3/3] Verificação final..."

# Testar aircrack-ng
if command -v aircrack-ng >/dev/null 2>&1; then
    AIRCRACK_VERSION=$(aircrack-ng --help 2>&1 | head -1 | grep -o '[0-9]\+\.[0-9]\+' || echo "detectado")
    echo "   ✅ aircrack-ng: $AIRCRACK_VERSION"
else
    echo "   ❌ aircrack-ng ainda não funciona"
fi

# Testar Wifite
if command -v wifite >/dev/null 2>&1; then
    if timeout 3s wifite --version >/dev/null 2>&1; then
        WIFITE_VERSION=$(wifite --version 2>&1 | head -1 || echo "detectado")
        echo "   ✅ Wifite: $WIFITE_VERSION"
    else
        echo "   ⚠️ Wifite presente mas com problemas de execução"
    fi
else
    echo "   ❌ Wifite ainda não funciona"
fi

echo ""
echo "📊 RESUMO DOS RESULTADOS:"
echo "═══════════════════════════════════════════════════════════════"

# Status final
AIRCRACK_FINAL=false
WIFITE_FINAL=false

if command -v aircrack-ng >/dev/null 2>&1; then
    echo "✅ aircrack-ng: FUNCIONANDO"
    AIRCRACK_FINAL=true
else
    echo "❌ aircrack-ng: AINDA COM PROBLEMAS"
fi

if command -v wifite >/dev/null 2>&1 && timeout 3s wifite --version >/dev/null 2>&1; then
    echo "✅ Wifite: FUNCIONANDO"
    WIFITE_FINAL=true
else
    echo "❌ Wifite: AINDA COM PROBLEMAS"
fi

if [ "$WIFI_OK" = true ]; then
    echo "✅ Hardware WiFi: $WIFI_COUNT interface(s)"
else
    echo "⚠️ Hardware WiFi: Nenhuma interface detectada"
fi

echo ""

# Recomendações finais
if [ "$AIRCRACK_FINAL" = true ] && [ "$WIFITE_FINAL" = true ] && [ "$WIFI_OK" = true ]; then
    echo "🎉 SUCESSO TOTAL! Sistema pronto para uso."
    echo ""
    echo "🚀 PRÓXIMOS COMANDOS:"
    echo "   ./03_monitor.sh                    # Monitor WiFi"
    echo "   sudo wifite --no-wps --no-pmkid   # Scan seguro"
    echo "   wifite --help                     # Ver todas opções"
    
elif [ "$AIRCRACK_FINAL" = true ] && [ "$WIFITE_FINAL" = true ]; then
    echo "🟡 PARCIALMENTE FUNCIONAL"
    echo "   Software OK, mas sem hardware WiFi detectado"
    echo ""
    echo "💡 CONECTE um adaptador USB WiFi e teste novamente"
    
elif [ "$AIRCRACK_FINAL" = true ] || [ "$WIFITE_FINAL" = true ]; then
    echo "🟠 SUCESSO PARCIAL"
    echo "   Algumas ferramentas funcionam, outras precisam atenção manual"
    echo ""
    echo "🔧 EXECUTE para diagnóstico detalhado:"
    echo "   ./diagnostic.sh"
    
else
    echo "🔴 AINDA COM PROBLEMAS"
    echo "   Correção automática não resolveu todos os problemas"
    echo ""
    echo "📋 AÇÕES MANUAIS NECESSÁRIAS:"
    
    if [ "$AIRCRACK_FINAL" = false ]; then
        echo "   • Instalar aircrack-ng manualmente:"
        echo "     sudo apt install aircrack-ng"
        echo "     OU baixar de: https://www.aircrack-ng.org/"
    fi
    
    if [ "$WIFITE_FINAL" = false ]; then
        echo "   • Verificar instalação do Wifite:"
        echo "     ls -la /opt/wifite2/"
        echo "     python3 /opt/wifite2/wifite.py --version"
    fi
fi

echo ""
echo "📝 LOGS E AJUDA:"
echo "   ./diagnostic.sh          # Diagnóstico completo"
echo "   cat README.md           # Documentação completa" 
echo "   ./03_monitor.sh         # Sempre funciona para monitor"
echo ""
echo "🔒 LEMBRE-SE: Use apenas em redes autorizadas!"