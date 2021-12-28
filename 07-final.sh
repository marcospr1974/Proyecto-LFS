#!/bin/bash

##
# Autor    : Marcos Pablo Russo
# E-Mail   : marcospr1974@gmail.com
# Fecha    : 27/12/2021
# Licencia : GPL-3
#
# Descripcion:
#
#   Mediante este script nos permite realizar el capitulo 11 de Linux From Scratch.
#   De esta forma podemos automatizar toda la creacion de los paquetes.
#   Esta basado en LFS-11.0
#
#   https://www.linuxfromscratch.org/lfs/view/stable/index.html
#
##

#
# Configuracion de variables
#
#   lfs
#

# Colores
greenColour="\e[0;32m\033[1m"
endColour="\033[0m\e[0m"
redColour="\e[0;31m\033[1m"
blueColour="\e[0;34m\033[1m"
yellowColour="\e[0;33m\033[1m"
purpleColour="\e[0;35m\033[1m"
turquoiseColour="\e[0;36m\033[1m"
grayColour="\e[0;37m\033[1m"

# Variables globales
LFS=/mnt/lfs

clear

trap ctrl_c INT

#
# Si preciona la tecla control-c
#
function ctrl_c() {
  echo -e "\n${redColour}[!] Saliendo...\n${endColour}"

  exit 1
}


#
# Muestra la ayuda si no se le pasa ningun parametro
#
function ayuda() {
   echo -e "\n${redColour}[!] Uso: ./${0}${endColour}"
   for i in $(seq 1 80); do
     echo -ne "${redColour}-"
   done
   echo -ne "${endColour}"
   echo -e "\n\n\t${grayColour}[p0]${endColour}${yellowColour} Final${endColour}"
   echo -e "\t${grayColour}[p1]${endColour}${yellowColour} Realizar Backup${endColour}"
   echo -e "\t${grayColour}[h]${endColour}${yellowColour}  Muestra la ayuda${endColour}\n"
}

#
# Final
#
function final() {
  echo -e "${grayColour}----------------------------------------------------------------${endColour}"
  echo -e "${grayColour}- Realizar: ${endColour}${yellowColour}Final...${endColour}"

  echo 11.0 > ${LFS}/etc/lfs-release

cat > ${LFS}//etc/lsb-release << "EOF"
DISTRIB_ID="Linux From Scratch"
DISTRIB_RELEASE="11.0"
DISTRIB_CODENAME="1.0"
DISTRIB_DESCRIPTION="Linux From Scratch"
EOF

cat > ${LFS}/etc/os-release << "EOF"
NAME="Linux From Scratch"
VERSION="11.0"
ID=lfs
PRETTY_NAME="Linux From Scratch 11.0"
VERSION_CODENAME="1.0"
EOF
}


#
# Backup
#
function backup(){
  cd ${BACKUP}
  tar cvfj 06-backup-lfs-final-$(date +"%m-%d-%y").tar.bz2 ${LFS}
}


# Verifico el ID
if [ $(id | cut -d '(' -f2 | cut -d ')' -f1) != "root" ]; then
  echo -e "\n${redColour}[!] Solo se puede ejecutar como root...\n${endColour}"
  echo -e "\n${redColour}\t sudo ${0}\n${endColour}"
  exit
fi

# Menu principal
if [ $# -eq 0 ]; then
  ayuda
elif [ $# -eq 1 ]; then
   case ${1} in
     p0) final
         ;;
     p1) backup
         ;;
     h)  ayuda
         ;;
     *)  ayuda
         ;;
   esac
else
  ayuda
fi

