#!/bin/bash -e
#############################################################################################################
## SCRIPT INSTALLATION DOCKER
#############################################################################################################

### --------------------------------------------------------
### -- VARIABLES GLOBALES
### --------------------------------------------------------
_os_version="centos 7"
_elk_version="7.13.2"
_docker_folder="/opt/docker-home"
_docker_database="postgres"
_docker_database_version="12"
_docker_database_dir="postgres12"
_docker_database_datas="datas01"
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
mkdir -p ${_docker_volumes_folder}/${_docker_database_dir}/${_docker_database_datas}
 
cat >${_docker_datas_folder}/${_docker_database_dir}/docker-compose.yml <<EOF
version: '3'

services:
  postgres_:
    image: ${_docker_database}:${_docker_database_version}
    container_name: ${_docker_database_dir}
    environment: 
      - POSTGRES_USER=${_database_user}
      - POSTGRES_PASSWORD=${_database_password}
    volumes: 
      - ${_docker_volumes_folder}/${_docker_database_dir}/${_docker_database_datas}:/var/lib/postgresql/data
    ports:
      - 5435:5432
    networks:
      - ${_docker_external_netwok}
    restart: always
networks:
  ${_docker_external_netwok}:
    external: true
EOF

cat ${_docker_datas_folder}/${_docker_database_dir}/docker-compose.yml
docker-compose -f ${_docker_datas_folder}/${_docker_database_dir}/docker-compose.yml up -d --force-recreate