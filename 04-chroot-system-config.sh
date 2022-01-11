#!/bin/bash

##
# Autor    : Marcos Pablo Russo
# E-Mail   : marcospr1974@gmail.com
# Fecha    : 27/12/2021
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
SOURCE=/mnt/LFS-11.0/sources
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
   echo -e "\n\n\t${grayColour}[m]${endColour}${yellowColour} Realizar montaje${endColour}"
   echo -e "\t${grayColour}[u]${endColour}${yellowColour} Realizar un desmontaje${endColour}"
   echo -e "\t${grayColour}[c]${endColour}${yellowColour} Entrarn en el chroot${endColour}"
   echo -e "\t${grayColour}[h]${endColour}${yellowColour} Muestra la ayuda${endColour}\n"
}


#
# El comienzo de cada compilacion el titulo
#
function inicio() {
  echo -e "${grayColour}----------------------------------------------------------------${endColour}"
  echo -e "${grayColour}- Realizar: ${endColour}${yellowColour}${1}...${endColour}"
}


#
# Lo que realiza cuando termina de compilar
#
function final() {
  echo -e "${grayColour}- Finalizacion del: ${endColour}${yellowColour}${1}...${endColour}"
  echo -e "${grayColour}----------------------------------------------------------------${endColour}"
}


#
# Cambiar permisos y montaje
#
function montaje() {
  inicio "motaje"

  if [ $(mount | grep $LFS/dev | wc -l) -eq 0 ]; then
    mount -v --bind /dev $LFS/dev
  else
    echo -e "\t${redColour}[!] Ya esta montado: ${LFS}/dev${endColour}"
  fi

  if [ $(mount | grep $LFS/dev/pts | wc -l) -eq 0 ]; then
    mount -v --bind /dev/pts $LFS/dev/pts
  else
    echo -e "\t${redColour}[!] Ya esta montado: ${LFS}/dev/pts${endColour}"
  fi

  if [ $(mount | grep $LFS/dev/proc | wc -l) -eq 0 ]; then
    mount -vt proc proc $LFS/proc
  else
    echo -e "\t${redColour}[!] Ya esta montado: ${LFS}/proc${endColour}"
  fi

  if [ $(mount | grep $LFS/sys | wc -l) -eq 0 ]; then
    mount -vt sysfs sysfs $LFS/sys
  else
    echo -e "\t${redColour}[!] Ya esta montado: ${LFS}/sys${endColour}"
  fi

  if [ $(mount | grep $LFS/run | wc -l) -eq 0 ]; then
    mount -vt tmpfs tmpfs $LFS/run
  else
    echo -e "\t${redColour}[!] Ya esta montado: ${LFS}/run${endColour}"
  fi

  if [ -h $LFS/dev/shm ]; then
	    mkdir -pv $LFS/$(readlink $LFS/dev/shm)
  fi

  final "montaje"
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

  rm -v ${LFS}/04-01*.sh

  final "desmontaje"
}


#
# Entrando en chroot
#
function entrar() {

  inicio "Entrando en el chroot"

  cp -v 04-01*.sh $LFS

  # Si no existe el directorio
  if [ ! -d ${LFS}/packages ]; then
    echo "[*] Copiando ${SOURCE}"
    cp -a ${SOURCE} ${LFS}
  fi

  chroot "$LFS" /usr/bin/env -i   \
         HOME=/root                  \
         TERM="$TERM"                \
         PS1='(lfs chroot) \u:\w\$ ' \
         PATH=/usr/bin:/usr/sbin     \
	 /bin/bash --login +h
  final "Saliendo del chroot"
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
     m)  montaje
         ;;
     u)  desmontaje
         ;;
     c)  entrar
         ;;
     h)  ayuda
         ;;
     *)  ayuda
         ;;
   esac
else
  ayuda
fi

