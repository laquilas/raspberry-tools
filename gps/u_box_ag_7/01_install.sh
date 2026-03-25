#!/bin/bash

# GPS U-blox AG-7 - Instalação de Dependências

set -e

echo "============================"
echo "GPS U-blox AG-7 - Instalação"
echo "============================"

echo "Atualizando pacotes do sistema..."
sudo apt update

echo "Instalando dependências GPS..."
sudo apt install -y gpsd gpsd-clients sqlite3 jq

echo "Parando serviços GPS (caso estejam ativos)..."
sudo systemctl stop gpsd.socket gpsd.service 2>/dev/null || true

echo "✅ Instalação concluída!"
echo ""
echo "Próximo passo: ./02_configure.sh"