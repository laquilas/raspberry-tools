#!/bin/bash

# Wifite - Instalação de Dependências

set -e

echo "=============================="
echo "🔧 Wifite - Instalação"
echo "=============================="

echo "📦 Atualizando pacotes do sistema..."
sudo apt update

echo "📡 Instalando dependências do Wifite..."
sudo apt install -y \
    git \
    python3 \
    python3-pip \
    aircrack-ng \
    reaver \
    tshark \
    cowpatty \
    pyrit \
    macchanger \
    hashcat \
    hcxtools \
    hcxdumptool \
    pixiewps \
    bully \
    wireless-tools \
    net-tools \
    iw \
    sqlite3 \
    jq

echo "🌐 Instalando Wifite..."
if [ ! -d "/opt/wifite2" ]; then
    sudo git clone https://github.com/derv82/wifite2.git /opt/wifite2
    sudo chmod +x /opt/wifite2/wifite.py
    sudo ln -sf /opt/wifite2/wifite.py /usr/local/bin/wifite
else
    echo "Wifite já instalado, atualizando..."
    cd /opt/wifite2
    sudo git pull
fi

echo "🔍 Verificando instalação..."
wifite --version || echo "⚠️ Wifite pode precisar de configuração adicional"

echo "✅ Instalação concluída!"
echo ""
echo "📋 Próximo passo: ./02_configure.sh"
echo "💡 Para testar: sudo wifite --help"