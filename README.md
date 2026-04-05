```
# Zabbix + Grafana para Debian 12

Autor: Carlos Silva
Sistema: Debian 12 (Bookworm)

Scripts para instalar y configurar un sistema de monitoreo completo con Zabbix 7.0 y Grafana, incluyendo la integración entre ambos.

================================================================================

SCRIPT 1: Instalar Zabbix 7.0

PASO 1: Dar permisos y ejecutar el script
------------------------------------------------
chmod +x instalar-zabbix-debian12.sh
sudo ./instalar-zabbix-debian12.sh

PASO 2: Configurar en el navegador
------------------------------------------------
Abre: http://IP_DEL_SERVIDOR/zabbix

Campos:
- Tipo de base de datos: MySQL
- Usuario de BD: zabbixservidores
- Contraseña de BD: venezuela
- Versión de Zabbix: 7.0 LTS

PASO 3: Iniciar sesión
------------------------------------------------
Usuario: Admin
Contraseña: zabbix

PASO 4: Cambiar contraseña del Admin
------------------------------------------------
1. Administration -> Users
2. Clic en Admin
3. Change password
4. Ingresa tu nueva contraseña
5. Update

PASO 5: Si falla el paquete de lenguaje
------------------------------------------------
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
systemctl restart mariadb zabbix-server apache2
systemctl status zabbix-server

================================================================================

SCRIPT 2: Instalar Grafana

PASO 1: Dar permisos y ejecutar el script
------------------------------------------------
chmod +x instalar-grafana-debian12.sh
sudo ./instalar-grafana-debian12.sh

PASO 2: Acceder a la interfaz web
------------------------------------------------
Abre: http://IP_DEL_SERVIDOR:3000
Usuario: admin
Contraseña: admin
(En el primer inicio cambia la contraseña)

================================================================================

INTEGRACIÓN: Conectar Grafana con Zabbix

PASO 1: Agregar fuente de datos Zabbix
------------------------------------------------
Configuration (rueda dentada) -> Data sources -> Add data source -> Buscar Zabbix

PASO 2: Configurar conexión
------------------------------------------------
Zabbix API URL: http://IP_DEL_ZABBIX/zabbix/api_jsonrpc.php
Zabbix Version: 6.0
Username (API): Admin
Password (API): (la contraseña que asignaste en Zabbix)

PASO 3: Guardar y probar
------------------------------------------------
Clic en Save & Test -> Debe decir "Zabbix API version: 6.0"

================================================================================

NOTAS IMPORTANTES
------------------------------------------------
- Cambia la contraseña "venezuela" antes de usar en producción
- Scripts diseñados para Debian 12
- Ejecutar con sudo o como root

CONTACTO
------------------------------------------------
GitHub: CarlosSilva32d-blip
Correo: carlossilva32d@gmail.com

LICENCIA: Uso libre para fines educativos y profesionales.
```
