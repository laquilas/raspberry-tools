# Estrutura de Módulos - Raspberry Tools

## 📁 Anatomia de um Módulo

### Estrutura Obrigatória

```
[category]/[tool_name]/
├── README.md              # Documentação completa
├── 01_install.sh          # Instalação de dependências
├── 02_configure.sh        # Configuração do sistema  
├── 03_monitor.sh          # Monitor em tempo real
├── setup.sh               # Setup automático completo
├── [tool_specific].sh     # Scripts específicos da ferramenta
├── [tool_specific].service # Systemd services (opcional)
└── config/                 # Configs específicas (opcional)
```

### Categorias Estabelecidas

1. **gps/** - Módulos de GPS/GNSS
2. **wifi/** - Módulos WiFi/Wireless
3. **network/** - Ferramentas de rede (futuro)
4. **security/** - Ferramentas de segurança (futuro)
5. **hardware/** - Controle de hardware (futuro)

## 🛠️ Módulos Implementados

### GPS U-blox AG-7 (`gps/u_box_ag_7/`)

**Funcionalidade**: Logging GPS contínuo com SQLite
**Dependências**: gpsd, gpsd-clients, sqlite3, jq
**Serviço**: gps_logger.service
**Configuração**: 
```bash
GPS_ENABLED=true
GPS_DEVICE="/dev/ttyACM0"
GPS_INTERVAL=120
GPS_MAX_ATTEMPTS=15
GPS_MIN_FIX=2
GPS_LOG_EXTENDED=true
GPS_REQUIRE_3D=false
```

**Scripts específicos**:
- `gps_logger.sh` - Script principal de logging
- `gps_logger.service` - Systemd service
- `update.sh` - Update do serviço GPS

### WiFi Wifite (`wifi/wifite/`)

**Funcionalidade**: Auditoria de segurança WiFi
**Dependências**: wifite2, aircrack-ng, reaver, tshark, macchanger
**Serviço**: N/A (ferramenta interativa)
**Configuração**:
```bash
WIFI_ENABLED=true
WIFI_INTERFACE_AUTO=true
WIFI_INTERFACE_PREFERRED=""
WIFI_SCAN_TIMEOUT=30
WIFI_ATTACK_TIMEOUT=300
WIFI_MAX_ATTEMPTS=3
WIFI_WPS_ENABLED=true
WIFI_WPA_ENABLED=true
WIFI_DICT_PATH=""
WIFI_LOG_ATTACKS=true
```

**Scripts específicos**: N/A (usa wifite diretamente)

## ➕ Como Adicionar um Novo Módulo

### Passo 1: Definir Estrutura

```bash
# Exemplo: módulo Bluetooth scanner
mkdir -p bluetooth/bluez_scanner/
cd bluetooth/bluez_scanner/
```

### Passo 2: Criar Scripts Base

#### 1. README.md
```bash
touch README.md
# Usar template do CODING_STANDARDS.md
```

#### 2. 01_install.sh
```bash
#!/bin/bash

# Bluetooth Scanner - Instalação de Dependências

set -e

echo "=============================="
echo "🔧 Bluetooth Scanner - Instalação"
echo "=============================="

echo "📦 Atualizando pacotes do sistema..."
sudo apt update

echo "🔧 Instalando dependências Bluetooth..."
sudo apt install -y \
    bluez \
    bluez-tools \
    bluetooth \
    sqlite3 \
    jq

echo "✅ Instalação concluída!"
echo ""
echo "📋 Próximo passo: ./02_configure.sh"
```

#### 3. 02_configure.sh
```bash
#!/bin/bash

# Bluetooth Scanner - Configuração do Sistema

set -e

CONFIG_FILE="../../app.conf"

echo "==============================="  
echo "🔧 Bluetooth Scanner - Configuração"
echo "==============================="

# [CÓDIGO PADRÃO DE CONFIG]

echo "🔧 Configurando Bluetooth..."
# Configurações específicas

echo "✅ Configuração concluída!"
```

#### 4. 03_monitor.sh
```bash
#!/bin/bash

# Bluetooth Scanner - Monitor em Tempo Real

# [TEMPLATE PADRÃO DO MONITOR]
```

#### 5. setup.sh
```bash
#!/bin/bash

# Bluetooth Scanner - Setup Automático Completo

set -e

echo "🔥============================🔥"
echo "🚀    BLUETOOTH - SETUP COMPLETO   🚀" 
echo "🔥============================🔥"

# [TEMPLATE PADRÃO DO SETUP]
```

### Passo 3: Configurar app.conf

Adicionar seção no `app.conf`:
```bash
# ==============================
# BLUETOOTH / BLUEZ SCANNER
# ==============================
BLUETOOTH_ENABLED=true
BLUETOOTH_INTERFACE_AUTO=true
BLUETOOTH_INTERFACE_PREFERRED=""  # hci0, hci1, etc
BLUETOOTH_SCAN_INTERVAL=30
BLUETOOTH_SCAN_TIMEOUT=120
BLUETOOTH_LOG_DEVICES=true
BLUETOOTH_LOG_SERVICES=false
BLUETOOTH_RSSI_THRESHOLD=-80
```

### Passo 4: Criar Script de Update

`update_bluetooth.bat`:
```batch
@echo off
title Update Bluetooth Scanner - Raspberry Tools

set "REMOTE_USER=laquilas"
set "REMOTE_HOST=192.168.1.249"
set "REMOTE_DIR=/home/laquilas/tools"
set "LOCAL_DIR=E:\OneDrive\Github\raspberry-tools"

echo ========================================
echo   Update Bluetooth Scanner
echo ========================================

# [TEMPLATE PADRÃO DOS UPDATES]
```

## 🎯 Checklist para Novos Módulos

### ✅ Arquivos Obrigatórios
- [ ] README.md (documentação completa)
- [ ] 01_install.sh (instalação de dependências)
- [ ] 02_configure.sh (configuração do sistema)
- [ ] 03_monitor.sh (monitor em tempo real)
- [ ] setup.sh (setup automático)

### ✅ Configuração
- [ ] Seção no app.conf
- [ ] Variáveis seguindo padrão `MODULE_PARAM`
- [ ] Defaults sensatos

### ✅ Update Remote
- [ ] update_[module].bat
- [ ] Seguindo template dos existentes
- [ ] Comandos de uso no final

### ✅ Documentação
- [ ] README.md completo
- [ ] Seção troubleshooting
- [ ] Comandos de uso básico
- [ ] Considerações de segurança (se aplicável)

### ✅ Testes
- [ ] Scripts executam sem erro
- [ ] Dependências instalam corretamente
- [ ] Monitor funciona
- [ ] Setup automático completo

## 🌟 Módulos Sugeridos (Futuro)

### Network Tools
- **nmap/nmap_scanner** - Port scanning e discovery
- **netcat/nc_listener** - Network listener e testing  
- **tcpdump/packet_capture** - Packet capture e analysis

### Security Tools  
- **metasploit/msf_toolkit** - Penetration testing
- **john/password_cracker** - Password cracking
- **hydra/brute_force** - Brute force attacks

### Hardware Control
- **gpio/pin_control** - GPIO pin manipulation
- **camera/pi_camera** - Camera module control
- **sensors/environmental** - Temperature, humidity sensors

### Communication
- **lora/radio_comm** - LoRa/radio communication
- **bluetooth/ble_tools** - BLE scanning e communication
- **serial/uart_tools** - Serial communication tools

## 📊 Matriz de Compatibilidade

| Categoria | Requer Root | Network | Hardware | Storage |
|-----------|-------------|---------|----------|---------|
| GPS | No | No | Yes | Yes |
| WiFi | Yes | Yes | Yes | Optional |
| Network | Yes | Yes | No | Optional |
| Security | Yes | Yes | Optional | Optional |
| Hardware | Yes | No | Yes | Optional |

---

**Use este documento como guia ao adicionar novos módulos ao projeto!**