#!/bin/bash -e
#############################################################################################################
## SCRIPT INSTALLATION DOCKER KST
#############################################################################################################

### --------------------------------------------------------
### -- VARIABLES GLOBALES
### --------------------------------------------------------
_os_version="centos 7"
_elk_version="7.13.2"
#_docker_folder="/opt/docker-home"
_docker_folder="/srv/backupdatas/docker-home"

_postgres_global_database="postgres"
_postgres_global_database_version="12"
_postgres_global_exposed_port="5435"
_docker_postgres_dir="postgres12"
_docker_postgres_datas="datas00"

_pgadmin_global="pgadmin"
_pgadmin_global_version="4"
_pgadmin_global_exposed_port="9191"
_docker_pgadmin_dir="pgadmin4"
_docker_pgadmin_datas="datas00"

_odoo_global="odoo"
_odoo_global_version="14.0"
_odoo_global_exposed_port="8069"
_odoo_global_custom_addons_name="kst_addons_customs"
_docker_odoo_dir="odoo14"
_docker_odoo_datas="datas00"

_docker_volumes_folder="${_docker_folder}/_volumes"
_docker_datas_folder="${_docker_folder}/_datas"
_webserver_config_file="/etc/nginx/conf.d/loadbalancer.conf"
_tools_folder_path="/root/centos"
_docker_external_netwok="kst"
_database_user="kst"
_database_password="kst"
_instance_core_paquets="docker"
_instance_other_paquets="vim curl net-tools atop telnet git"

#_instance_other_paquets="vim nginx curl net-tools atop telnet policycoreutils policycoreutils-python setools setools-console setroubleshoot"
yum install -y ${_instance_core_paquets} ${_instance_other_paquets}

####################################################################################################
## CONFIGURATION DE DOCKER
####################################################################################################
# Install Docker-compose
curl -L "https://github.com/docker/compose/releases/download/1.26.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose || true
docker-compose --version
systemctl start docker
systemctl enable docker
echo "Fin - INSTALLATION DOCKER && DOCKER-COMPOSE"
echo "ok"
docker network create -d bridge ${_docker_external_netwok} || true

####################################################################################################
## CONFIGURATION DE POSTGRESQL
####################################################################################################
mkdir -p ${_docker_datas_folder}/${_docker_postgres_dir}
mkdir -p ${_docker_volumes_folder}/${_docker_postgres_dir}/${_docker_postgres_datas}
chmod -R 777 ${_docker_volumes_folder}
chmod -R 777 ${_docker_datas_folder}

cat >${_docker_datas_folder}/${_docker_postgres_dir}/docker-compose.yml <<EOF
version: '3'

services:
  postgres_:
    image: ${_postgres_global_database}:${_postgres_global_database_version}-bullseye
    container_name: ${_postgres_global_database}${_postgres_global_database_version}
    environment: 
      - POSTGRES_USER=${_database_user}
      - POSTGRES_PASSWORD=${_database_password}
    volumes: 
      - ${_docker_volumes_folder}/${_docker_postgres_dir}/${_docker_postgres_datas}:/var/lib/postgresql/data
    ports:
      - ${_postgres_global_exposed_port}:5432
    networks:
      - ${_docker_external_netwok}
    restart: always
networks:
  ${_docker_external_netwok}:
    external: true
EOF
cat ${_docker_datas_folder}/${_docker_postgres_dir}/docker-compose.yml
docker-compose -f ${_docker_datas_folder}/${_docker_postgres_dir}/docker-compose.yml up -d --force-recreate

####################################################################################################
## CONFIGURATION DE PGADMIN
####################################################################################################
mkdir -p ${_docker_datas_folder}/${_docker_pgadmin_dir}
mkdir -p ${_docker_volumes_folder}/${_docker_pgadmin_dir}/${_docker_pgadmin_datas}
chmod -R 777 ${_docker_volumes_folder}
chmod -R 777 ${_docker_datas_folder}

cat >${_docker_datas_folder}/${_docker_pgadmin_dir}/docker-compose.yml <<EOF
version: '3'

services:
  pgadmin:
    image: dpage/pgadmin4:7.5
    container_name: ${_pgadmin_global}${_pgadmin_global_version}
    environment: 
      - PGADMIN_DEFAULT_EMAIL=${_database_user}@gmail.com
      - PGADMIN_DEFAULT_PASSWORD=${_database_password}
      - DEFAULT_SERVER=127.0.0.1
      - DEFAULT_SERVER_PORT=5050
      - PGADMIN_LISTEN_ADDRESS=0.0.0.0
      - PGADMIN_LISTEN_PORT=80
      - PGADMIN_CONFIG_ENHANCED_COOKIE_PROTECTION=True
      - PGADMIN_CONFIG_LOGIN_BANNER="Seules les utilisateurs autorisés par ${_database_user} peuvent se connecter ici!"
      - PGADMIN_CONFIG_CONSOLE_LOG_LEVEL=10
    volumes: 
      - ${_docker_volumes_folder}/${_docker_pgadmin_dir}/${_docker_pgadmin_datas}:/var/lib/pgadmin
      - ${_docker_volumes_folder}/${_docker_pgadmin_dir}/config_local/config_local.py:/pgadmin4/config_local.py
      - ${_docker_volumes_folder}/${_docker_pgadmin_dir}/server_json/servers.json:/pgadmin4/servers.json
    ports:
      - ${_pgadmin_global_exposed_port}:80
    networks:
      - ${_docker_external_netwok}
    restart: always
networks:
  ${_docker_external_netwok}:
    external: true
EOF
cat ${_docker_datas_folder}/${_docker_pgadmin_dir}/docker-compose.yml
#docker-compose -f ${_docker_datas_folder}/${_docker_pgadmin_dir}/docker-compose.yml up -d --force-recreate

####################################################################################################
## CONFIGURATION DE ODOO14
####################################################################################################
mkdir -p ${_docker_datas_folder}/${_docker_odoo_dir}
mkdir -p ${_docker_volumes_folder}/${_docker_odoo_dir}/${_docker_odoo_datas}
mkdir -p ${_docker_volumes_folder}/${_docker_odoo_dir}/${_docker_odoo_datas}/config
chmod -R 777 ${_docker_volumes_folder}
chmod -R 777 ${_docker_datas_folder}

cat >${_docker_datas_folder}/${_docker_odoo_dir}/docker-compose.yml <<EOF
version: '3.1'
services:
  web:
    image: ${_odoo_global}:${_odoo_global_version}
    container_name: odoo${_odoo_global_version}
    depends_on:
      - db
    ports:
      - "${_odoo_global_exposed_port}:8069"
    volumes:
      - ${_docker_volumes_folder}/${_docker_odoo_dir}/${_docker_odoo_datas}/odoo-web-data:/var/lib/odoo
      - ${_docker_volumes_folder}/${_docker_odoo_dir}/${_docker_odoo_datas}/config:/etc/odoo
      - ${_docker_volumes_folder}/${_docker_odoo_dir}/${_docker_odoo_datas}/${_odoo_global_custom_addons_name}:/mnt/extra-addons
    environment:
      - HOST=db
      - USER=${_database_user}
      - PASSWORD=${_database_password}
  db:
    image: postgres:${_postgres_global_database_version}-bullseye
    container_name: pg${_postgres_global_database_version}odoo${_odoo_global_version}
    environment:
      - POSTGRES_DB=postgres
      - POSTGRES_PASSWORD=${_database_password}
      - POSTGRES_USER=${_database_user}
      - PGDATA=/var/lib/postgresql/data/pgdata
    volumes:
      - ${_docker_volumes_folder}/${_docker_odoo_dir}/${_docker_odoo_datas}/odoo-db-data:/var/lib/postgresql/data/pgdata
volumes:
  odoo-web-data:
  odoo-db-data:
EOF
cat ${_docker_datas_folder}/${_docker_odoo_dir}/docker-compose.yml
cat >${_docker_volumes_folder}/${_docker_odoo_dir}/${_docker_odoo_datas}/config/odoo.conf <<EOF
[options]
addons_path = /mnt/extra-addons
admin_passwd = 
csv_internal_sep = ,
data_dir = /var/lib/odoo
db_host = db
db_maxconn = 64
db_name = False
db_password = ${_database_password}
db_port = 5432
db_sslmode = prefer
db_template = template0
db_user = ${_database_user}
dbfilter = 
demo = {}
email_from = False
geoip_database = /usr/share/GeoIP/GeoLite2-City.mmdb
http_enable = True
http_interface = 
http_port = 8069
import_partial = 
limit_memory_hard = 2684354560
limit_memory_soft = 2147483648
limit_request = 8192
limit_time_cpu = 60
limit_time_real = 120
limit_time_real_cron = -1
list_db = True
log_db = False
log_db_level = warning
log_handler = :INFO
log_level = info
logfile = 
longpolling_port = 8072
max_cron_threads = 2
osv_memory_age_limit = False
osv_memory_count_limit = False
pg_path = 
pidfile = 
proxy_mode = False
reportgz = False
screencasts = 
screenshots = /tmp/odoo_tests
server_wide_modules = base,web
smtp_password = False
smtp_port = 25
smtp_server = localhost
smtp_ssl = False
smtp_user = False
syslog = False
test_enable = False
test_file = 
test_tags = None
transient_age_limit = 1.0
translate_modules = ['all']
unaccent = False
upgrade_path = 
without_demo = False
workers = 0
EOF
docker-compose -f ${_docker_datas_folder}/${_docker_odoo_dir}/docker-compose.yml up -d --force-recreate
chmod -R 777 ${_docker_volumes_folder}
chmod -R 777 ${_docker_datas_folder}