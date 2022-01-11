#!/bin/bash

##
# Autor    : Marcos Pablo Russo
# E-Mail   : marcospr1974@gmail.com
# Fecha    : 2R85/12/2021
# Licencia : GPL-3
#
# Descripcion:
#
#   Mediante este script nos permite realizar el capitulo 9 de Linux From Scratch.
#   De esta forma podemos automatizar toda la creacion de los paquetes.
#   Esta basado en LFS-11.0
#
#   https://www.linuxfromscratch.org/lfs/view/stable/index.html
#
##

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
SRC_SOURCES=/sources/packages
SRC_FILES=/sources/files
SRC_PATCH=/sources/patches

BUILD_ROOT=/mnt/LFS-11.0
LFS=/mnt/lfs
BACKUP=${BUILD_ROOT}/backup

# Cantidad de procesadores
export MAKEFLAGS='-j4'
export J='-j4'

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
   echo -e "\n\n\t${grayColour}[p0]${endColour}${yellowColour}  Configurar /etc/fstab${endColour}"
   echo -e "\t${grayColour}[p1]${endColour}${yellowColour}  Configurar Kernel${endColour}"
   echo -e "\t${grayColour}[p2]${endColour}${yellowColour}  Configurar Grub${endColour}"
   echo -e "\t${grayColour}[p3]${endColour}${yellowColour}  Realizar limpieza${endColour}"
   echo -e "\t${grayColour}[p4]${endColour}${yellowColour}  Realizar desmontaje${endColour}"
   echo -e "\t${grayColour}[p5]${endColour}${yellowColour}  Realizar backup${endColour}"
   echo -e "\t${grayColour}[all]${endColour}${yellowColour} Compilar todo${endColour}"
   echo -e "\t${grayColour}[h]${endColour}${yellowColour}   Muestra la ayuda${endColour}\n"
}


#
# El comienzo de cada compilacion el titulo
#
function inicio() {
  echo -e "${grayColour}----------------------------------------------------------------${endColour}"
  echo -e "${grayColour}- Building : ${endColour}${yellowColour}${1}...${endColour}"
}


#
# Lo que realiza cuando termina de compilar
#
function final() {
  echo -e "${grayColour}- Finalizacion de la compilació del paquete${endColour}"
  echo -e "\t${yellowColour}[*] ${PKG_NAME}${endColour}${grayColour} con fecha : ${endColour}${yellowColour}$(date)${endColour}"
  echo -e "${grayColour}----------------------------------------------------------------${endColour}"
  rm -rf ${SRC_FILES}/${PKG_NAME}*
}


#
# Realiza la descomprecion del archivo y muestra el inicio de lo que esta
# realizando
#
# ${1} -> Nombre del programa a descomprimir.
# ${2} -> Nombre de la funcion que le pasa a la funcion inicio
#
function descomprimir() {
  cd ${SRC_FILES}
  PKG_NAME=${1}
  PKG_DIR=$(echo ${SRC_FILES}/${PKG_NAME}*)

  inicio "${2}"

  tar xf ${SRC_SOURCES}/${PKG_NAME}* || exit 1
  cd ${PKG_DIR}
}


#
# Configurar /etc/fstab
#
function fstab-config() {
  echo -e "${grayColour}----------------------------------------------------------------${endColour}"
  echo -e "${grayColour}- Building : ${endColour}${yellowColour}/etc/fstab...${endColour}"

cat > /etc/fstab << "EOF"
# Begin /etc/fstab 

# file	system 	mount-point 	type 		options 		dump    fsck
# order 

/dev/<xxx> 	/ 		<fff> 		defaults 		1	1 
/dev/<yyy> 	swap		swap		pri=1			0	0 
proc		/proc		proc		nosuid,noexec,nodev	0	0 
sysfs		/sys		sysfs		nosuid,noexec,nodev	0	0 
devpts		/dev/pts	devpts		gid=5,mode=620		0	0 
tmpfs		/run		tmpfs		defaults		0	0 
devtmpfs	/dev		devtmpfs	mode=0755,nosuid	0	0 

# End /etc/fstab
EOF
}


#
# kernel-config
#
function kernel-config() {
  descomprimir "linux" "linux" 

  make mrproper
  make menuconfig
  make ${J}
  make modules_install

  cp -iv arch/x86/boot/bzImage /boot/vmlinuz-5.13.12-lfs-11.0
  cp -iv System.map /boot/System.map-5.13.12
  cp -iv .config /boot/config-5.13.12
  install -d /usr/share/doc/linux-5.13.12
  cp -r Documentation/* /usr/share/doc/linux-5.13.12

  install -v -m755 -d /etc/modprobe.d
  cat > /etc/modprobe.d/usb.conf << "EOF"
# Begin /etc/modprobe.d/usb.conf

install ohci_hcd /sbin/modprobe ehci_hcd ; /sbin/modprobe -i ohci_hcd ; true
install uhci_hcd /sbin/modprobe ehci_hcd ; /sbin/modprobe -i uhci_hcd ; true

# End /etc/modprobe.d/usb.conf
EOF

  final ${PKG_NAME}
}


#
# grub-config
#
function grub-config(){
  echo -e "${grayColour}----------------------------------------------------------------${endColour}"
  echo -e "${grayColour}- Building : ${endColour}${yellowColour}grub-config...${endColour}"

  #grub-install /dev/sda

  mkdir -p /boot/grub
cat > /boot/grub/grub.cfg << "EOF"
# Begin /boot/grub/grub.cfg
set default=0
set timeout=5

insmod ext2
set root=(hd0,2)

menuentry "GNU/Linux, Linux 5.13.12-lfs-11.0" {
        linux   /boot/vmlinuz-5.13.12-lfs-11.0 root=/dev/sda2 ro
}
EOF
}


#
# Limpieza
#
function limpieza() {
   rm -rfv /sources
}


#
# Backup
#
function backup(){
   cd ${BACKUP}
   tar cvfj 05-backup-lfs-arranque-$(date +"%m-%d-%y").tar.bz2 ${LFS}
}


#
# Desmontaje
#
function desmontaje() {
   inicio "desmontaje"

   umount -v $LFS/dev/pts
   umount -v $LFS/dev
   umount -v $LFS/proc
   umount -v $LFS/sys
   umount -v $LFS/run

   rm -v ${LFS}/05-01*.sh

   final "desmontaje"
}


#
# All
#
function all() {
   fstab-config
   sleep 1
   kernel-config
   sleep 1
   red
   sleep 1
   systemv
   sleep 1
   bash-config
   sleep 1
   inputrc-config
   sleep 1
   limpieza
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
       p0)   fstab-config
	     ;;
       p1)   kernel-config
	     ;;
       p2)   grub-config
	     ;;
       p3)   limpieza
	     ;;
       p4)   desmontaje
	     ;;
       p5)   backup
	     ;;
       all)  all
	     ;;
	*)   ayuda
             ;;
   esac
fi
