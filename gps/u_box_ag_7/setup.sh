#!/bin/bash

# GPS U-blox AG-7 - Setup Completo

set -e

echo "======================================="
echo "🛰️  GPS U-blox AG-7 - Setup Completo 🛰️ "
echo "======================================="
echo ""

# Verificar se está sendo executado como root para partes necessárias
if [[ $EUID -ne 0 ]] && ! command -v sudo > /dev/null; then
   echo "❌ Este script precisa de sudo para instalar pacotes"
   exit 1
fi

# 1. Instalação
echo "📦 PASSO 1: Instalando dependências..."
./01_install.sh
echo ""

# 2. Configuração  
echo "⚙️  PASSO 2: Configurando sistema..."
./02_configure.sh
echo ""

# 3. Permissões
echo "🔐 PASSO 3: Configurando permissões..."
chmod +x gps_logger.sh
chmod +x 03_monitor.sh

# 4. Habilitar e iniciar serviço
echo "🚀 PASSO 4: Iniciando serviço GPS Logger..."
sudo systemctl enable gps_logger
sudo systemctl start gps_logger

sleep 2

echo ""
echo "======================================="
echo "✅ Setup concluído com sucesso!"
echo "======================================="
echo ""
echo "📊 Status dos serviços:"
echo "  GPSD: $(systemctl is-active gpsd)"
echo "  GPS Logger: $(systemctl is-active gps_logger)"
echo ""
echo "🔧 Comandos úteis:"
echo "  Status:    sudo systemctl status gps_logger"
echo "  Logs:      sudo journalctl -u gps_logger -f"
echo "  Monitor:   ./03_monitor.sh"
echo "  Parar:     sudo systemctl stop gps_logger"
echo "  Reiniciar: sudo systemctl restart gps_logger"
echo ""
echo "📁 Dados salvos em: \$DATA_DIR/YYYY/MM/"