#!/bin/bash

# GPS U-blox AG-7 - Configuração do Sistema

set -e

CONFIG_FILE="../../app.conf"

echo "==============================="
echo "GPS U-blox AG-7 - Configuração"  
echo "==============================="

# Verificar arquivo de configuração
if [ ! -f "$CONFIG_FILE" ]; then
    echo "❌ Arquivo de config não encontrado: $CONFIG_FILE"
    exit 1
fi

echo "🔄 Corrigindo line endings do arquivo de config..."
# Corrigir line endings (Windows → Linux)
sed -i 's/\r$//' "$CONFIG_FILE" 2>/dev/null || true

source "$CONFIG_FILE"

echo "Configurando gpsd..."

# Criar configuração do gpsd
sudo bash -c "cat > /etc/default/gpsd <<EOF
START_DAEMON=\"true\"
USBAUTO=\"false\"
DEVICES=\"$GPS_DEVICE\"
GPSD_OPTIONS=\"-n\"
EOF"

echo "Configurando serviço GPS Logger..."

# Copiar arquivo de serviço
sudo cp gps_logger.service /etc/systemd/system/

# Recarregar systemd
sudo systemctl daemon-reload

echo "Iniciando serviços..."
sudo systemctl enable gpsd
sudo systemctl restart gpsd

echo "Aguardando inicialização..."
sleep 3

echo "Verificando status do gpsd:"
systemctl status gpsd --no-pager --lines=5 || true

echo "✅ Configuração concluída!"
echo ""
echo "Comandos úteis:"
echo "  - Teste rápido: cgps -s"
echo "  - Monitor: ./03_monitor.sh"
echo "  - Logs: sudo systemctl enable gps_logger && sudo systemctl start gps_logger"