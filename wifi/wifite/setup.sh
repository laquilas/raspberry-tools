#!/bin/bash

# Wifite - Setup Automático Completo

echo "🔥==============================🔥"
echo "🚀    WIFITE - SETUP COMPLETO   🚀"
echo "🔥==============================🔥"
echo ""

# Verificar permissões
if [ "$EUID" -ne 0 ]; then
    echo "❌ Este script precisa ser executado como root (sudo)"
    echo "💡 Use: sudo ./setup.sh"
    exit 1
fi

# Verificar se os scripts existem
SCRIPTS=("01_install.sh" "02_configure.sh")
for script in "${SCRIPTS[@]}"; do
    if [ ! -f "$script" ]; then
        echo "❌ Script não encontrado: $script"
        exit 1
    fi
    if [ ! -x "$script" ]; then
        chmod +x "$script"
    fi
done

# Permitir execução do monitor
if [ -f "03_monitor.sh" ]; then
    chmod +x "03_monitor.sh"
fi

echo "🎯 Iniciando setup do Wifite..."
echo ""

# Variáveis para controle de status
INSTALL_SUCCESS=false
CONFIG_SUCCESS=false

# Etapa 1: Instalação (permitir falhas parciais)
echo "🔸 ETAPA 1/3: Instalação de dependências"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if ./01_install.sh; then
    INSTALL_SUCCESS=true
    echo "✅ Instalação concluída com sucesso"
else
    echo "⚠️ Instalação teve problemas, mas continuando..."
    INSTALL_SUCCESS=false
fi
echo ""

# Aguardar um pouco entre etapas
sleep 2

# Etapa 2: Configuração  
echo "🔸 ETAPA 2/3: Configuração do sistema"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if ./02_configure.sh; then
    CONFIG_SUCCESS=true
    echo "✅ Configuração concluída com sucesso"
else
    echo "⚠️ Configuração teve problemas, mas continuando..."
    CONFIG_SUCCESS=false
fi
echo ""

# Aguardar um pouco antes do teste
sleep 2

# Etapa 3: Teste de funcionamento
echo "🔸 ETAPA 3/3: Verificação final"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

echo "🔍 Testando instalação do Wifite..."
WIFITE_OK=false
if command -v wifite >/dev/null 2>&1; then
    WIFITE_VERSION=$(wifite --version 2>&1 | head -1 | grep -o 'v[0-9]\+\.[0-9]\+' || echo "versão desconhecida")
    echo "✅ Wifite encontrado: $WIFITE_VERSION"
    WIFITE_OK=true
else
    echo "❌ Wifite não encontrado no PATH"
    if [ -f "/opt/wifite2/wifite.py" ]; then
        echo "💡 Wifite parece estar em /opt/wifite2/ mas link não foi criado"
        echo "   Tente: sudo ln -sf /opt/wifite2/wifite.py /usr/local/bin/wifite"
    fi
fi

echo ""
echo "🔍 Verificando interfaces WiFi..."
WIFI_COUNT=$(ls /sys/class/net/ 2>/dev/null | grep -E "^(wlan|wlp)" | wc -l)
if [ "$WIFI_COUNT" -gt 0 ]; then
    echo "✅ $WIFI_COUNT interface(s) WiFi detectada(s):"
    ls /sys/class/net/ | grep -E "^(wlan|wlp)" | sed 's/^/   - /'
    WIFI_OK=true
else
    echo "❌ Nenhuma interface WiFi detectada"
    echo "   💡 Conecte um adaptador USB WiFi compatível"
    echo "   💡 Adaptadores recomendados: com chipsets Ralink/Atheros"
    WIFI_OK=false
fi

echo ""
echo "🔍 Verificando dependências essenciais..."
ESSENTIAL_TOOLS=("git" "python3" "iw" "iwconfig")
MISSING_ESSENTIAL=0
for tool in "${ESSENTIAL_TOOLS[@]}"; do
    if command -v "$tool" >/dev/null 2>&1; then
        echo "✅ $tool"
    else
        echo "❌ $tool (ESSENCIAL)"
        ((MISSING_ESSENTIAL++))
    fi
done

echo ""
echo "🔍 Verificando ferramentas opcionais..."
OPTIONAL_TOOLS=("aircrack-ng" "reaver" "hashcat" "macchanger" "tshark")
MISSING_OPTIONAL=0
for tool in "${OPTIONAL_TOOLS[@]}"; do
    if command -v "$tool" >/dev/null 2>&1; then
        echo "✅ $tool"
    else
        echo "⚠️ $tool (opcional)"
        ((MISSING_OPTIONAL++))
    fi
done

echo ""
echo "📊 RESUMO DO SETUP:"
echo "═══════════════════════════════════════════════════════════════"

# Status geral
if [ "$MISSING_ESSENTIAL" -eq 0 ] && [ "$WIFITE_OK" = true ]; then
    SETUP_STATUS="✅ SUCESSO"
    SETUP_COLOR="🟢"
elif [ "$MISSING_ESSENTIAL" -eq 0 ]; then
    SETUP_STATUS="⚠️ PARCIAL"  
    SETUP_COLOR="🟡"
else
    SETUP_STATUS="❌ FALHA"
    SETUP_COLOR="🔴"
fi

echo "$SETUP_COLOR Setup Status: $SETUP_STATUS"
echo ""

# Detalhes do que funcionou
echo "📋 Detalhes:"
[ "$INSTALL_SUCCESS" = true ] && echo "✅ Instalação de dependências" || echo "⚠️ Instalação de dependências"
[ "$CONFIG_SUCCESS" = true ] && echo "✅ Configuração do sistema" || echo "⚠️ Configuração do sistema"  
[ "$WIFITE_OK" = true ] && echo "✅ Wifite instalado e funcionando" || echo "❌ Wifite com problemas"
[ "$WIFI_OK" = true ] && echo "✅ Interfaces WiFi detectadas" || echo "❌ Nenhuma interface WiFi"
[ "$MISSING_ESSENTIAL" -eq 0 ] && echo "✅ Todas as dependências essenciais" || echo "❌ $MISSING_ESSENTIAL dependência(s) essencial(is) faltando"
[ "$MISSING_OPTIONAL" -eq 0 ] && echo "✅ Todas as ferramentas opcionais" || echo "⚠️ $MISSING_OPTIONAL ferramenta(s) opcional(is) faltando"

echo ""
echo "🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉"
echo "🎊               SETUP CONCLUÍDO!               🎊"
echo "🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉"
echo ""

if [ "$MISSING_ESSENTIAL" -eq 0 ] && [ "$WIFITE_OK" = true ] && [ "$WIFI_OK" = true ]; then
    echo "🟢 Sistema totalmente funcional!"
elif [ "$MISSING_ESSENTIAL" -eq 0 ] && [ "$WIFITE_OK" = true ]; then
    echo "🟡 Sistema funcional (mas sem interfaces WiFi detectadas)"
else
    echo "🔴 Sistema com problemas - verifique dependências faltantes"
fi

echo ""
echo "📋 PRÓXIMOS PASSOS:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔴 IMPORTANTE: Use apenas em redes próprias ou autorizadas!"
echo ""
echo "🚀 COMANDOS BÁSICOS:"
echo "   • Monitor WiFi:        ./03_monitor.sh"
echo "   • Escanear redes:      sudo wifite --no-wps --no-pmkid"
echo "   • Ataque WPS:          sudo wifite --wps-only"
echo "   • Ajuda completa:      wifite --help"
echo ""
echo "🔧 COMANDOS DE REDE:"
echo "   • Ver interfaces:      iwconfig"
echo "   • Modo monitor:        sudo airmon-ng start wlan0"
echo "   • Status detalhado:    ifconfig -a"
echo ""
echo "📖 DOCUMENTAÇÃO:"
echo "   • README completo:     cat README.md"
echo "   • Configurações:       ../../app.conf"
echo ""

# Verificar se quer executar o monitor
echo -n "🤔 Executar o monitor WiFi agora? (y/N): "
read -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo ""
    echo "🚀 Iniciando monitor WiFi..."
    echo "💡 Pressione Ctrl+C para sair do monitor"
    sleep 2
    ./03_monitor.sh
else
    echo ""
    echo "👋 Setup concluído! Execute './03_monitor.sh' quando quiser monitorar."
fi

echo ""
echo "🔒 Lembre-se: Use responsavelmente e apenas onde autorizado!"