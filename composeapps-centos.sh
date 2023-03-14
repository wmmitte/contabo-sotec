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
_docker_volumes_folder="${_docker_folder}/_volumes"
_docker_datas_folder="${_docker_folder}/_datas"
_webserver_config_file="/etc/nginx/conf.d/loadbalancer.conf"
_tools_folder_path="/root/centos"
_instance_core_paquets="docker"
_instance_other_paquets="vim curl net-tools atop telnet git"
#_instance_other_paquets="vim nginx curl net-tools atop telnet policycoreutils policycoreutils-python setools setools-console setroubleshoot"
#docker network create -d bridge mpts-network
# Configuration de la configuration
#mkdir -p ${_docker_datas_folder}/pgadmin4
#mkdir -p ${_docker_volumes_folder}/pgadmin4
 
cd ${_docker_datas_folder}/postgres12
docker-compose up -d
docker ps
cd ${_docker_datas_folder}/pgadmin4
docker-compose up -d
docker ps


