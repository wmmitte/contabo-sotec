#!/bin/bash -e
#############################################################################################################
## SCRIPT INSTALLATION DES APPLICATIONS
#############################################################################################################

### --------------------------------------------------------
### -- VARIABLES GLOBALES
### --------------------------------------------------------
_os_version="centos 7"
_elk_version="7.13.2"
_docker_folder="/opt/docker-home"
_docker_volumes_folder="${_docker_folder}/_volumes"
_docker_datas_folder="${_docker_folder}/_datas"
_webserver_config_file="/etc/nginx/conf.d/loadbalancer.conf"
_tools_folder_path="/root/centos"
_instance_core_paquets="docker"
_instance_other_paquets="vim curl net-tools atop telnet git"

rm -rf ${_docker_folder}

# Configuration de la configuration
mkdir -p ${_docker_volumes_folder}
mkdir -p ${_docker_datas_folder}
chmod -R 777 ${_docker_folder}
chmod -R 777 ${_docker_volumes_folder}
chmod -R 777 ${_docker_datas_folder}

rm -rf repo
cd /root
rm -rf odoo14
mkdir odoo14

git clone https://github.com/wmmitte/contabo-sotec.git repo || true
cd repo
git pull
chmod +x *.sh
bash docker-centos.sh || true
bash postgres-centos.sh || true
bash pgadmin-centos.sh || true
chmod -R 777 ${_docker_folder}
cd /root
ln -s repo/docker-compose.yml odoo14/docker-compose.yml
cd odoo14
mkdir config
cat >config/odoo.conf <<EOF
[options]
addons_path = /mnt/extra-addons
admin_passwd = admin
csv_internal_sep = ,
data_dir = /var/lib/odoo
db_host = db
db_maxconn = 64
db_name = False
db_password = odoo
db_port = 5432
db_sslmode = prefer
db_template = template0
db_user = odoo
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


chmod -R 777 ${_docker_folder}
docker-compose -f /root/repo/docker-compose.yml up -d --force-recreate
docker logs -f odoo14





