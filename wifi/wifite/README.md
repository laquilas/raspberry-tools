# Wifite - Auditoria de Segurança WiFi

Este módulo configura e gerencia o Wifite para auditoria de segurança de redes WiFi no Raspberry Pi.

## 🚀 Instalação Rápida

```bash
# Setup completo (instalação + configuração)
cd wifi/wifite/
sudo ./setup.sh
```

## 📋 Scripts Disponíveis

### 1. `01_install.sh` - Instalação de Dependências
- Instala Wifite e todas as dependências necessárias
- Configura ferramentas: aircrack-ng, reaver, tshark, macchanger, etc.
- Clona o repositório oficial do Wifite2

### 2. `02_configure.sh` - Configuração do Sistema  
- Detecta interfaces WiFi disponíveis
- Configura modo monitor (quando suportado)
- Para serviços que podem interferir
- Mostra status detalhado das interfaces de rede
- Cria configuração básica do sistema

### 3. `03_monitor.sh` - Monitor em Tempo Real
- Monitora status das interfaces WiFi
- Escaneia redes disponíveis
- Mostra estatísticas do sistema
- Atualização automática a cada 10 segundos

### 4. `setup.sh` - Setup Automático
- Executa todos os scripts na sequência correta
- Instalação completamente automatizada

## 🛠️ Uso Básico

### Instalação Inicial
```bash
# 1. Instalar dependências
./01_install.sh

# 2. Configurar sistema
./02_configure.sh

# 3. Monitorar (opcional)
./03_monitor.sh
```

### Comandos Wifite
```bash
# Escanear redes (somente visualizar)
sudo wifite --no-wps --no-pmkid

# Ataque WPS apenas
sudo wifite --wps-only

# Ataque específico a uma rede
sudo wifite --bssid XX:XX:XX:XX:XX:XX

# Usar dicionário personalizado
sudo wifite --dict /path/to/wordlist.txt

# Modo verbose (mais detalhes)
sudo wifite -vv
```

### Comandos de Rede
```bash
# Ver interfaces disponíveis  
iwconfig

# Status detalhado das interfaces
ifconfig -a

# Colocar interface em modo monitor
sudo airmon-ng start wlan0

# Voltar para modo managed
sudo airmon-ng stop wlan0mon
```

## ⚙️ Configuração

O arquivo `../../app.conf` contém configurações específicas do WiFi:

```bash
# WiFi / WIFITE
WIFI_ENABLED=true
WIFI_INTERFACE_AUTO=true
WIFI_INTERFACE_PREFERRED=""       # ex: wlan0
WIFI_SCAN_TIMEOUT=30             
WIFI_ATTACK_TIMEOUT=300          
WIFI_MAX_ATTEMPTS=3              
WIFI_WPS_ENABLED=true            
WIFI_WPA_ENABLED=true            
WIFI_DICT_PATH=""                # caminho para wordlist
WIFI_LOG_ATTACKS=true            
```

## 🔧 Dependências

### Principais
- **Wifite2**: Ferramenta principal
- **aircrack-ng**: Suite de ferramentas WiFi
- **reaver**: Ataques WPS
- **tshark**: Captura de pacotes

### Opcionais (melhoram performance)
- **hashcat**: Quebra de senhas otimizada
- **hcxtools**: Conversão de capturas
- **pixiewps**: Ataques WPS avançados
- **bully**: Alternativa ao reaver

## 📊 Interface Monitor

O script `03_monitor.sh` fornece:

- ✅ **Status das Interfaces**: UP/DOWN, modo atual, MAC
- 🌐 **Redes Disponíveis**: SSID, sinal, canal, criptografia  
- 📊 **Estatísticas**: Contadores, dependências instaladas
- 🔄 **Atualização Automática**: A cada 10 segundos

## ⚠️ Considerações de Segurança

### Uso Ético e Legal
- ✅ **Apenas redes próprias** ou com autorização explícita
- ✅ **Testes de penetração autorizados**
- ❌ **NUNCA usar em redes de terceiros sem permissão**
- ❌ **Atividades maliciosas são crime**

### Adaptadores WiFi Recomendados
Para melhor compatibilidade com modo monitor:
- **Chipsets Ralink** (RT2870/RT3070/RT5370)
- **Chipsets Atheros** (AR9271/AR9170)
- **Alfa / Panda USB adapters**

### Limitações
- Alguns adaptadores não suportam modo monitor
- Drivers proprietários podem não funcionar
- Algumas redes têm proteções avançadas (WPA3, etc.)

## 🚨 Troubleshooting

### Interface não entra em modo monitor
```bash
# Verificar se o driver suporta
iw list | grep monitor

# Tentar com airmon-ng
sudo airmon-ng start wlan0

# Verificar conflitos
sudo airmon-ng check kill
```

### Wifite não encontra interfaces
```bash
# Verificar interfaces WiFi
iwconfig

# Subir interface manualmente
sudo ifconfig wlan0 up

# Verificar se não está sendo usada
sudo lsof | grep wlan0
```

### Erro de dependências
```bash
# Reinstalar dependências
./01_install.sh

# Verificar instalação
wifite --version
aircrack-ng --help
```

### Performance baixa
```bash
# Usar GPU (se disponível)
hashcat --version

# Verificar uso de CPU
htop

# Fechar aplicações desnecessárias
sudo systemctl stop NetworkManager
sudo systemctl stop wpa_supplicant  
```

## 📚 Referências

- [Wifite2 GitHub](https://github.com/derv82/wifite2)
- [Aircrack-ng Documentation](https://www.aircrack-ng.org/)
- [Wireless Security Testing](https://wireless.wiki/)

---

**⚖️ DISCLAIMER**: Esta ferramenta é destinada exclusivamente para testes de segurança autorizados e fins educacionais. O uso inadequado pode violar leis locais e federais.