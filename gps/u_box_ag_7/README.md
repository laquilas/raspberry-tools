# GPS U-blox AG-7 Module

Sistema de logging GPS para dispositivos u-blox AG-7 em Raspberry Pi.

## Arquivos

### Instalação e Configuração
1. `01_install.sh` - Instala dependências (gpsd, sqlite3, jq)
2. `02_configure.sh` - Configura e inicia serviços do sistema
3. `setup.sh` - Setup completo (executa 01 e 02)

### Scripts de Operação
- `gps_logger.sh` - Script principal de logging em SQLite
- `gps_logger.service` - Service do systemd
- `03_monitor.sh` - Monitor em tempo real do GPS

## Uso Rápido

```bash
# Setup inicial completo
sudo ./setup.sh

# Monitor em tempo real
./03_monitor.sh

# Verificar status do serviço
sudo systemctl status gps_logger
```

## Configuração

O módulo utiliza o arquivo `../../app.conf` para configurações. Principais variáveis:

- `GPS_ENABLED` - Habilita/desabilita GPS
- `GPS_DEVICE` - Dispositivo GPS (ex: /dev/ttyACM0)
- `GPS_INTERVAL` - Intervalo de leitura em segundos
- `DATA_DIR` - Diretório dos dados SQLite

## Estrutura dos Dados

Os dados são salvos em: `$DATA_DIR/YYYY/MM/YYYY_MM_DD_gps.db`

Tabela: `gps`

### Campos Principais
- `timestamp` - Data/hora local da leitura
- `gps_time` - Timestamp GPS original
- `lat` - Latitude (graus)
- `lon` - Longitude (graus)
- `fix_type` - Tipo de fix (2=2D, 3=3D)

### Altitude
- `alt_msl` - Altitude Mean Sea Level (metros)
- `alt_hae` - Height Above Ellipsoid (metros)

### Movimento
- `speed` - Velocidade sobre solo (m/s)
- `track` - Course over ground (graus)
- `climb` - Taxa de subida/descida (m/s)

### Precisão/Erros
- `eph` - Erro horizontal estimado (metros)
- `epv` - Erro vertical estimado (metros)  
- `epx` - Erro longitude (metros)
- `epy` - Erro latitude (metros)
- `eps` - Erro velocidade (m/s)
- `ept` - Erro tempo (segundos)
- `epc` - Erro climb (m/s)
- `epd` - Erro track (graus)

### Consulta Exemplo
```sql
SELECT timestamp, lat, lon, alt_msl, speed, track, eph 
FROM gps 
WHERE fix_type >= 3 
ORDER BY timestamp DESC 
LIMIT 10;
```

## Troubleshooting

### Line endings (Windows/Linux)
Se encontrar erro como `$'\r': command not found`:
- Os scripts automaticamente corrigem line endings do app.conf
- Caso persista: `sed -i 's/\r$//' ../../app.conf`

### GPS não detectado
- Verificar dispositivo: `ls /dev/tty*`
- Ajustar GPS_DEVICE no app.conf
- Verificar conexão física

### Serviço não inicia
```bash
sudo systemctl status gps_logger
sudo journalctl -u gps_logger -n 20
```