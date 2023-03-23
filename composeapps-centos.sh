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
cd ..
ln -s repo/docker-compose.yml odoo14/docker-compose.yml
cd odoo14
docker-compose up -d
chmod -R 777 ${_docker_folder}




