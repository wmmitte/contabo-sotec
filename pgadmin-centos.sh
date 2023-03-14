#!/bin/bash -e
#############################################################################################################
## SCRIPT INSTALLATION PGADMIN
#############################################################################################################

### --------------------------------------------------------
### -- VARIABLES GLOBALES
### --------------------------------------------------------
_os_version="centos 7"
_elk_version="7.13.2"
_docker_folder="/opt/docker-home"
_docker_database="postgres"
_docker_database_version="12"
_docker_database_dir="pgadmin4"
_docker_database_datas="datas00"
_docker_volumes_folder="${_docker_folder}/_volumes"
_docker_datas_folder="${_docker_folder}/_datas"
_webserver_config_file="/etc/nginx/conf.d/loadbalancer.conf"
_tools_folder_path="/root/centos"
_docker_external_netwok="sotec"
_database_user="sotec"
_database_password="sotec"
_instance_core_paquets="docker"
_instance_other_paquets="vim curl net-tools atop telnet git"
#_instance_other_paquets="vim nginx curl net-tools atop telnet policycoreutils policycoreutils-python setools setools-console setroubleshoot"
docker network create -d bridge ${_docker_external_netwok} || true
# Configuration de la configuration
mkdir -p ${_docker_datas_folder}/${_docker_database_dir}
mkdir -p ${_docker_volumes_folder}/${_docker_database_dir}
 
cat >${_docker_datas_folder}/${_docker_database_dir}/docker-compose.yml <<EOF
version: '3'

services:
  pgadmin:
    image: dpage/pgadmin4:latest
    container_name: pgadmin
    environment: 
      - PGADMIN_DEFAULT_EMAIL=${_database_user}
      - PGADMIN_DEFAULT_PASSWORD=${_database_password}
      - DEFAULT_SERVER=127.0.0.1
      - DEFAULT_SERVER_PORT=5050
      - PGADMIN_LISTEN_ADDRESS=0.0.0.0
      - PGADMIN_LISTEN_PORT=80
      - PGADMIN_CONFIG_ENHANCED_COOKIE_PROTECTION=True
      - PGADMIN_CONFIG_LOGIN_BANNER="Seules les utilisateurs autorisés par ${_database_user} peuvent se connecter ici!"
      - PGADMIN_CONFIG_CONSOLE_LOG_LEVEL=10
    volumes: 
      - ${_docker_volumes_folder}/${_docker_database_dir}/${_docker_database_datas}:/var/lib/pgadmin
      - ${_docker_volumes_folder}/${_docker_database_dir}/config_local/config_local.py:/pgadmin4/config_local.py
      - ${_docker_volumes_folder}/${_docker_database_dir}/server_json/servers.json:/pgadmin4/servers.json
    ports:
      - 9191:80
    networks:
      - ${_docker_external_netwok}
    restart: always
networks:
  ${_docker_external_netwok}:
    external: true
EOF

cat ${_docker_datas_folder}/${_docker_database_dir}/docker-compose.yml
docker-compose -f ${_docker_datas_folder}/${_docker_database_dir}/docker-compose.yml up -d --force-recreate