
# 🛰️ Raspberry Tools

Ferramentas para automação e monitoramento em Raspberry Pi.

## 📁 Estrutura do Projeto

```
raspberry-tools/
├── gps/                     # Módulos GPS
│   └── u_box_ag_7/         # GPS U-blox AG-7
├── wifi/                   # Configurações Wi-Fi
├── app.conf               # Configuração principal
├── sync.bat               # Sincronização Windows→Pi
├── fix_lineendings.bat    # Fix CRLF→LF (Windows)
└── fix_lineendings.sh     # Fix CRLF→LF (Linux)
```

## 🚀 Início Rápido

### 1. Sincronizar Arquivos (Windows)
```cmd
sync.bat
```

### 2. Corrigir Line Endings
**No Windows (via SSH):**
```cmd
fix_lineendings.bat
```

**No Raspberry Pi:**
```bash
./fix_lineendings.sh
```

## 📦 Módulos Disponíveis

### GPS U-blox AG-7
Sistema completo de logging GPS com SQLite.

```bash
cd gps/u_box_ag_7
sudo ./setup.sh        # Setup completo
./03_monitor.sh         # Monitor em tempo real
```

[Ver documentação completa](gps/u_box_ag_7/README.md)

## ⚙️ Configuração

Edite o arquivo [app.conf](app.conf) para ajustar:
- Caminhos de dados e logs
- Configurações GPS
- Intervalos de sync
- Credenciais de API/MQTT

## 🔧 Solução de Problemas

### Line Endings (CRLF vs LF)
**Problema:** `$'\r': command not found`

**Soluções:**
1. Execute `fix_lineendings.bat` (Windows)  
2. Execute `./fix_lineendings.sh` (Pi)
3. Os scripts GPS fazem auto-correção

### Tmux (Sessões)
```bash
tmux attach -t gps_logger   # entrar
tmux detach                 # sair (Ctrl+B, depois D)  
tmux kill-session -t gps_logger  # parar
tmux ls                     # listar sessões
```

## 📊 Monitoramento

- **GPS Status:** `sudo systemctl status gps_logger`
- **GPS Logs:** `sudo journalctl -u gps_logger -f`  
- **Dados SQLite:** `$DATA_DIR/YYYY/MM/`

## 🔗 Links Úteis

- [GPS U-blox AG-7](gps/u_box_ag_7/) - Logging GPS com SQLite
- [Configuração](app.conf) - Arquivo principal de config