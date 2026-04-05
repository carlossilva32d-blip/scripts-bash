#!/bin/bash
# ============================================
# Script: instalar-grafana-debian12.sh
# Autor: Carlos Silva
# Descripción: Instala Grafana OSS + plugin Zabbix en Debian 12
# Uso: Ejecutar como root o con sudo
# ============================================

# --- VARIABLES ---
GRAFANA_LIST="/etc/apt/sources.list.d/grafana.list"

# --- FUNCIÓN DE LOG ---
log() {
    echo -e "\n==========================================================="
    echo -e "LOG: $1"
    echo -e "===========================================================\n"
}

# --- 1. ACTUALIZACIÓN DEL SISTEMA ---
log "Actualizando paquetes del sistema e instalando dependencias."
apt update && apt upgrade -y
apt install -y software-properties-common apt-transport-https wget curl

# --- 2. INSTALACIÓN DEL REPOSITORIO DE GRAFANA (MÉTODO MODERNO) ---
log "Añadiendo el repositorio oficial de Grafana."

# 2.1. Crear directorio para keyrings
mkdir -p /etc/apt/keyrings

# 2.2. Descargar y añadir la clave GPG (método moderno)
curl -fsSL https://packages.grafana.com/gpg.key | gpg --dearmor | tee /etc/apt/keyrings/grafana.gpg > /dev/null

# 2.3. Añadir el repositorio estable
echo "deb [signed-by=/etc/apt/keyrings/grafana.gpg] https://packages.grafana.com/oss/deb stable main" | tee $GRAFANA_LIST

# 2.4. Actualizar la lista de paquetes
apt update

# --- 3. INSTALACIÓN DE GRAFANA ---
log "Instalando Grafana Server."
apt install grafana -y

# --- 4. INSTALACIÓN DEL PLUGIN DE ZABBIX ---
log "Instalando el plugin de Zabbix para la conexión API."
grafana-cli plugins install alexanderzobnin-zabbix-app

# --- 5. HABILITAR Y ARRANCAR SERVICIO ---
log "Habilitando y arrancando el servicio de Grafana."
systemctl daemon-reload
systemctl enable grafana-server
systemctl restart grafana-server

# --- 6. VERIFICACIÓN ---
log "Verificando estado del servicio Grafana."
systemctl status grafana-server --no-pager

echo "==========================================================="
echo "✅ INSTALACIÓN DE GRAFANA FINALIZADA"
echo "==========================================================="
echo "🌐 Accede al Frontend de Grafana en: http://$(hostname -I | awk '{print $1}'):3000"
echo "📌 Credenciales iniciales:"
echo "   Usuario: admin"
echo "   Contraseña: admin"
echo "⚠️  Cambia la contraseña en el primer inicio"
echo "==========================================================="
