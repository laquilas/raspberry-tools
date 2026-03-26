#!/bin/bash

# Wifite - Setup Automático Completo

set -e

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

# Etapa 1: Instalação
echo "🔸 ETAPA 1/3: Instalação de dependências"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
./01_install.sh
echo ""

# Aguardar um pouco entre etapas
sleep 2

# Etapa 2: Configuração  
echo "🔸 ETAPA 2/3: Configuração do sistema"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
./02_configure.sh
echo ""

# Aguardar um pouco antes do teste
sleep 2

# Etapa 3: Teste de funcionamento
echo "🔸 ETAPA 3/3: Verificação final"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

echo "🔍 Testando instalação do Wifite..."
if command -v wifite >/dev/null 2>&1; then
    echo "✅ Wifite encontrado: $(wifite --version 2>&1 | head -1)"
else
    echo "⚠️ Wifite não encontrado no PATH, mas pode ter sido instalado"
fi

echo ""
echo "🔍 Verificando interfaces WiFi..."
WIFI_COUNT=$(ls /sys/class/net/ 2>/dev/null | grep -E "^(wlan|wlp)" | wc -l)
if [ "$WIFI_COUNT" -gt 0 ]; then
    echo "✅ $WIFI_COUNT interface(s) WiFi detectada(s)"
    ls /sys/class/net/ | grep -E "^(wlan|wlp)" | sed 's/^/   - /'
else
    echo "⚠️ Nenhuma interface WiFi detectada"
    echo "   Verifique se o adaptador USB WiFi está conectado"
fi

echo ""
echo "🔍 Verificando dependências críticas..."
DEPS=("aircrack-ng" "reaver" "tshark" "macchanger")
ALL_OK=true
for dep in "${DEPS[@]}"; do
    if command -v "$dep" >/dev/null 2>&1; then
        echo "✅ $dep"
    else
        echo "❌ $dep"
        ALL_OK=false
    fi
done

echo ""
echo "🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉"
echo "🎊               SETUP CONCLUÍDO!               🎊"
echo "🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉"
echo ""

if [ "$ALL_OK" = true ]; then
    echo "✅ Sistema configurado com sucesso!"
else
    echo "⚠️ Sistema configurado, mas algumas dependências podem estar faltando"
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