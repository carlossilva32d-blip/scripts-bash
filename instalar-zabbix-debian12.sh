#!/bin/bash
# ============================================
# Script: instalar-zabbix-debian12.sh
# Autor: Carlos Silva
# Descripción: Instala Zabbix 7.0 LTS con MariaDB en Debian 12
# Uso: Ejecutar como root o con sudo
# ============================================

# === CONFIGURACIÓN (CAMBIAR ANTES DE USAR) ===
DB_PASS="TU_CONTRASEÑA_SEGURA"   # <--- Cámbiala antes de ejecutar
# =============================================

echo "--- 1. PREPARACIÓN DE APT Y REPARACIÓN INICIAL ---"
dpkg --configure -a
apt --fix-broken install -y
apt update -y
apt install wget gpg curl software-properties-common -y

echo "--- 2. CONFIGURANDO REPOSITORIO ZABBIX 7.0 ---"
mkdir -p /etc/apt/keyrings
curl -s https://repo.zabbix.com/zabbix-official-repo.key | gpg --dearmor | tee /etc/apt/keyrings/zabbix-official-repo.key > /dev/null

cat <<EOF > /etc/apt/sources.list.d/zabbix.list
deb [signed-by=/etc/apt/keyrings/zabbix-official-repo.key] https://repo.zabbix.com/zabbix/7.0/debian bookworm main
deb-src [signed-by=/etc/apt/keyrings/zabbix-official-repo.key] https://repo.zabbix.com/zabbix/7.0/debian bookworm main
EOF
apt update -y

echo "--- 3. INSTALANDO COMPONENTES (MariaDB y Zabbix) ---"
apt install mariadb-server zabbix-server-mysql zabbix-frontend-php zabbix-apache-conf zabbix-agent zabbix-sql-scripts php-mysql -y

echo "--- 4. CONFIGURANDO BASE DE DATOS ---"
ZABBIX_DB="zabbix"
ZABBIX_USER="zabbixservidores"
ZABBIX_CONF="/etc/zabbix/zabbix_server.conf"

systemctl enable mariadb
systemctl start mariadb

mysql -e "CREATE DATABASE IF NOT EXISTS $ZABBIX_DB CHARACTER SET utf8mb4 COLLATE utf8mb4_bin;"
mysql -e "CREATE USER IF NOT EXISTS '$ZABBIX_USER'@'localhost' IDENTIFIED BY '$DB_PASS';"
mysql -e "GRANT ALL PRIVILEGES ON $ZABBIX_DB.* TO '$ZABBIX_USER'@'localhost';"
mysql -e "FLUSH PRIVILEGES;"
zcat /usr/share/zabbix-sql-scripts/mysql/server.sql.gz | mysql -u $ZABBIX_USER -p$DB_PASS $ZABBIX_DB

sed -i "s/^DBHost=.*/DBHost=localhost/" "$ZABBIX_CONF"
sed -i "s/^DBName=.*/DBName=$ZABBIX_DB/" "$ZABBIX_CONF"
sed -i "s/^DBUser=.*/DBUser=$ZABBIX_USER/" "$ZABBIX_CONF"
sed -i "s/^# DBPassword=.*/DBPassword=$DB_PASS/" "$ZABBIX_CONF"

echo "--- 5. AJUSTANDO PHP Y APACHE ---"
PHP_INI_PATH=$(find /etc/php/ -name php.ini -path "*/apache2/*")
if [ -f "$PHP_INI_PATH" ]; then
    sed -i 's/max_execution_time = 30/max_execution_time = 300/' "$PHP_INI_PATH"
    sed -i 's/max_input_time = 60/max_input_time = 300/' "$PHP_INI_PATH"
    sed -i 's/post_max_size = 8M/post_max_size = 16M/' "$PHP_INI_PATH"
fi

a2dismod mpm_event
a2dismod mpm_worker
a2enmod mpm_prefork
a2enconf zabbix.conf

echo "--- 6. GENERANDO LOCALE ---"
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen

echo "--- 7. ARRANCANDO SERVICIOS ---"
systemctl restart apache2 mariadb zabbix-server zabbix-agent
systemctl enable zabbix-server zabbix-agent

echo "--- 8. VERIFICACIÓN FINAL ---"
systemctl status zabbix-server --no-pager

echo "========================================="
echo "✅ Instalación completada"
echo "📌 Cambia la contraseña en el script antes de usarlo"
echo "🌐 Accede a: http://$(hostname -I | awk '{print $1}')/zabbix"
echo "========================================="
