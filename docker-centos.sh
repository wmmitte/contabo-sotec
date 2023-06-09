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


####################################################################################################
## INSTALLATIONS DE PAQUETS
####################################################################################################
yum install -y ${_instance_core_paquets} ${_instance_other_paquets}

####################################################################################################
## CONFIGURATION DE DOCKER
####################################################################################################
# Install Docker-compose
curl -L "https://github.com/docker/compose/releases/download/1.26.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
docker-compose --version
systemctl start docker
systemctl enable docker
echo "Fin - INSTALLATION DOCKER && DOCKER-COMPOSE"
echo "ok"

# Configuration de la configuration
mkdir -p ${_docker_volumes_folder}
mkdir -p ${_docker_datas_folder}
chmod -R 777 ${_docker_folder}
chmod -R 777 ${_docker_volumes_folder}
chmod -R 777 ${_docker_datas_folder}

# Install httpd
yum install -y httpd
systemctl enable httpd
# Install firewalld
yum install -y firewalld
systemctl enable firewalld
# reboot
# firewall-cmd --state
# firewall-cmd --zone=public --permanent --add-service=http
# firewall-cmd --zone=public --permanent --add-service=https
# firewall-cmd --zone=public --permanent --add-port=8069/tcp
# firewall-cmd --list-all
# firewall-cmd --get-zones
# firewall-cmd --zone=public --list-all
# firewall-cmd --zone=public --list-ports
# firewall-cmd --permanent --zone=public --add-interface=docker0


