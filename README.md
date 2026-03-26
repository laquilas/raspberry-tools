# 🛰️ Raspberry Tools

Ferramentas modulares para automação, monitoramento e auditoria de segurança em Raspberry Pi.

## 🎯 Sistema Modular Cross-Platform

- **Desenvolvimento**: Windows (OneDrive/GitHub)
- **Execução**: Raspberry Pi (Linux)  
- **Sincronização**: Automática via SCP/SSH
- **Configuração**: Centralizada no `app.conf`

## 📁 Estrutura do Projeto

```
raspberry-tools/
├── .copilot/               # 🧠 Documentação do projeto (AI memory)
├── gps/                    # 🛰️ Módulos GPS/GNSS
│   └── u_box_ag_7/        #     └─ GPS U-blox AG-7
├── wifi/                   # 📡 Módulos WiFi
│   └── wifite/            #     └─ Wifite (auditoria segurança)
├── app.conf               # ⚙️ Configuração centralizada
├── *.bat                  # 🪟 Scripts Windows (sync/update)
├── *.sh                   # 🐧 Scripts Linux (utilitários)
└── README.md              # 📖 Este arquivo
```

## 🧠 Documentação do Projeto

**IMPORTANTE**: Para desenvolvedores e AI, consulte primeiro:
- **[.copilot/README.md](.copilot/README.md)** - Instruções principais
- **[.copilot/PROJECT_MEMORY.md](.copilot/PROJECT_MEMORY.md)** - Memória completa
- **[.copilot/CODING_STANDARDS.md](.copilot/CODING_STANDARDS.md)** - Padrões obrigatórios
- **[.copilot/MODULE_STRUCTURE.md](.copilot/MODULE_STRUCTURE.md)** - Como criar módulos
- **[.copilot/BATCH_SCRIPTS.md](.copilot/BATCH_SCRIPTS.md)** - Scripts Windows

## 🚀 Início Rápido

### 1. GPS U-blox AG-7 (Logging Contínuo)
```bash
cd gps/u_box_ag_7/
sudo ./setup.sh           # Setup completo
./03_monitor.sh           # Monitor em tempo real
```

**Do Windows:**
```cmd
update_gps.bat           # Sync + update remoto
```

### 2. WiFi Wifite (Auditoria Segurança)
```bash
cd wifi/wifite/
sudo ./setup.sh           # Setup completo  
./03_monitor.sh           # Monitor WiFi
sudo wifite --no-wps --no-pmkid  # Escanear (sem ataques)
```

**Do Windows:**
```cmd
update_wifi.bat          # Sync + update remoto
```

### 3. Sincronização Geral
```cmd
sync.bat                 # Todos os arquivos
fix_lineendings.bat      # Corrigir CRLF→LF
```

## 📦 Módulos Disponíveis

### 🛰️ GPS U-blox AG-7 (`gps/u_box_ag_7/`)
**Sistema completo de logging GPS com SQLite**

- ✅ Logging contínuo de coordenadas (SQLite)
- ✅ Monitor em tempo real 
- ✅ Service systemd automático
- ✅ 18 campos GPS (lat/lon/alt/speed/track/erros)
- ✅ Auto-restart e recuperação de falhas

```bash
cd gps/u_box_ag_7/
sudo ./setup.sh        # Setup completo automático
./03_monitor.sh         # Monitor GPS tempo real
systemctl status gps_logger    # Status do serviço
```

📖 [Documentação completa](gps/u_box_ag_7/README.md)

### 📡 WiFi Wifite (`wifi/wifite/`)  
**Auditoria de segurança WiFi com Wifite2**

- ✅ Instalação completa do Wifite2
- ✅ All dependencies (aircrack-ng, reaver, tshark, etc)
- ✅ Detecção automática de interfaces WiFi
- ✅ Configuração modo monitor
- ✅ Monitor WiFi em tempo real
- ✅ Avisos éticos e uso responsável

```bash
cd wifi/wifite/
sudo ./setup.sh           # Setup completo automático
./03_monitor.sh           # Monitor interfaces/redes
sudo wifite --no-wps --no-pmkid  # Escanear (modo seguro)
```

📖 [Documentação completa](wifi/wifite/README.md)

## ⚙️ Configuração Centralizada

Toda configuração fica no arquivo **[app.conf](app.conf)**:

```bash
# ==============================
# APP GERAL  
# ==============================
APP_NAME="raspberry-tools"
ENV="prod"
BASE_DIR="/home/laquilas/tools"

# ==============================
# GPS
# ==============================
GPS_ENABLED=true
GPS_DEVICE="/dev/ttyACM0"
GPS_INTERVAL=120
GPS_LOG_EXTENDED=true

# ==============================  
# WIFI / WIFITE
# ==============================
WIFI_ENABLED=true
WIFI_INTERFACE_AUTO=true
WIFI_SCAN_TIMEOUT=30
WIFI_WPS_ENABLED=true
WIFI_LOG_ATTACKS=true
```

## 🔧 Scripts de Gerenciamento

### Windows (Desenvolvimento)
- **`sync.bat`** - Sincronização geral via SCP
- **`update_gps.bat`** - Update completo módulo GPS
- **`update_wifi.bat`** - Update completo módulo WiFi  
- **`fix_lineendings.bat`** - Correção line endings via SSH

### Linux (Raspberry Pi)
- **`fix_lineendings.sh`** - Correção line endings local
- **Cada módulo**: `setup.sh`, `01_install.sh`, `02_configure.sh`, `03_monitor.sh`

## 🛠️ Criando Novos Módulos

1. **Estrutura**: Siga **[.copilot/MODULE_STRUCTURE.md](.copilot/MODULE_STRUCTURE.md)**
2. **Padrões**: Use **[.copilot/CODING_STANDARDS.md](.copilot/CODING_STANDARDS.md)**
3. **Config**: Adicione seção no `app.conf`
4. **Update**: Crie `update_[module].bat`

### Template Rápido:
```bash  
mkdir -p category/tool_name/
cd category/tool_name/
# Criar: README.md, 01_install.sh, 02_configure.sh, 03_monitor.sh, setup.sh
````

## 🚨 Troubleshooting

### ❌ Line Endings (CRLF vs LF)
**Sintoma:** `$'\r': command not found`

**Soluções:**
```cmd
fix_lineendings.bat     # Windows → Pi via SSH
```
```bash  
./fix_lineendings.sh    # Localmente no Pi
```
*Todos os scripts fazem auto-correção do app.conf*

### ❌ Permission Denied  
**SSH/SCP falha de autenticação**
```bash
ssh-copy-id user@192.168.1.249    # Copiar SSH key
ssh-add -l                         # Verificar keys
```

### ❌ Device Not Found (GPS)
```bash
ls /dev/tty*              # Listar dispositivos
lsusb                     # Ver dispositivos USB
sudo dmesg | grep tty     # Logs do kernel
```

### ❌ WiFi Interface Not Found  
```bash
iwconfig                  # Ver interfaces WiFi
ip link show              # Todas as interfaces
sudo rfkill list          # Verificar RF block
```

## 🔒 Considerações de Segurança

### ⚖️ Uso Ético - WiFi/Wifite
- ✅ **USE APENAS**: Redes próprias ou autorizadas  
- ✅ **LEGAL**: Testes de penetração autorizados
- ❌ **NUNCA**: Redes de terceiros sem permissão
- ❌ **CRIME**: Uso malicioso é violação da lei

### 🔐 SSH Security
- Use SSH keys (não senhas)
- Configure firewall apropriado
- Monitore logs de acesso

---

**🧠 Para desenvolvimento: Sempre consulte [.copilot/README.md](.copilot/README.md) primeiro!**