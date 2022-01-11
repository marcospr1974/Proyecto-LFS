#!/bin/bash

##
# Autor    : Marcos Pablo Russo
# E-Mail   : marcospr1974@gmail.com
# Fecha    : 25/12/2021
# Licencia : GPL-3
#
# Descripcion:
#
#   Mediante este script nos permite realizar el capitulo 7.7 de Linux From Scratch.
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
   echo -e "\n\n\t${grayColour}[p0]${endColour}${yellowColour}  Compilar libstdc++${endColour}"
   echo -e "\t${grayColour}[p1]${endColour}${yellowColour}  Compilar gettext${endColour}"
   echo -e "\t${grayColour}[p2]${endColour}${yellowColour}  Compilar bison${endColour}"
   echo -e "\t${grayColour}[p3]${endColour}${yellowColour}  Compilar perl${endColour}"
   echo -e "\t${grayColour}[p4]${endColour}${yellowColour}  Compilar Python${endColour}"
   echo -e "\t${grayColour}[p5]${endColour}${yellowColour}  Compilar texinfo${endColour}"
   echo -e "\t${grayColour}[p6]${endColour}${yellowColour}  Compilar util-linux${endColour}"
   echo -e "\t${grayColour}[p7]${endColour}${yellowColour}  Limpieza${endColour}"
   echo -e "\t${grayColour}[p8]${endColour}${yellowColour}  Realizar desmontaje${endColour}"
   echo -e "\t${grayColour}[p9]${endColour}${yellowColour}  Realizar backup${endColour}"
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
# Build gcc
#
function gcc-pass-2() {
  descomprimir "gcc" "Libstdc ++" 

  ln -s gthr-posix.h libgcc/gthr-default.h

  mkdir -v build && cd build

  ../libstdc++-v3/configure            \
	CXXFLAGS="-g -O2 -D_GNU_SOURCE"  \
	--prefix=/usr                    \
	--disable-multilib               \
	--disable-nls                    \
	--host=$(uname -m)-lfs-linux-gnu \
	--disable-libstdcxx-pch

  make ${J}
  make install 

  final ${PKG_NAME}
}


#
# Build gettext
#
function gettext() {
  descomprimir "gettext" "gettext" 

  ./configure --disable-shared

  make ${J}
  cp -v gettext-tools/src/{msgfmt,msgmerge,xgettext} /usr/bin

  final ${PKG_NAME}
}


#
# Build bison
#
function bison() {
  descomprimir "bison" "bison" 

  ./configure --prefix=/usr \
              --docdir=/usr/share/doc/bison-3.7.6

  make ${J}
  make install

  final ${PKG_NAME}
}


#
# Build perl
#
function perl() {
  descomprimir "perl" "perl" 

  sh Configure -des                                        \
               -Dprefix=/usr                               \
               -Dvendorprefix=/usr                         \
               -Dprivlib=/usr/lib/perl5/5.34/core_perl     \
               -Darchlib=/usr/lib/perl5/5.34/core_perl     \
               -Dsitelib=/usr/lib/perl5/5.34/site_perl     \
               -Dsitearch=/usr/lib/perl5/5.34/site_perl    \
               -Dvendorlib=/usr/lib/perl5/5.34/vendor_perl \
               -Dvendorarch=/usr/lib/perl5/5.34/vendor_perl

  make ${J}
  make install

  final ${PKG_NAME}
}


#
# Build Python
#
function Python() {
  descomprimir "Python" "Python" 

  ./configure --prefix=/usr   \
	      --enable-shared \
	      --without-ensurepip

  make ${J}
  make install

  final ${PKG_NAME}
}


#
# Build texinfo
#
function texinfo() {
  descomprimir "texinfo" "texinfo" 

  sed -e 's/__attribute_nonnull__/__nonnull/' \
      -i gnulib/lib/malloc/dynarray-skeleton.c

  ./configure --prefix=/usr

  make ${J}
  make install

  final ${PKG_NAME}
}


#
# Build util-linux
#
function util-linux() {
  descomprimir "util-linux" "util-linux" 

  mkdir -pv /var/lib/hwclock

  ./configure ADJTIME_PATH=/var/lib/hwclock/adjtime    \
         --libdir=/usr/lib    \
         --docdir=/usr/share/doc/util-linux-2.37.2 \
         --disable-chfn-chsh  \
         --disable-login      \
         --disable-nologin    \
         --disable-su         \
         --disable-setpriv    \
         --disable-runuser    \
         --disable-pylibmount \
         --disable-static     \
         --without-python     \
	 runstatedir=/run

  make ${J}
  make install

  final ${PKG_NAME}
}


#
# Limpieza
# 
function limpieza() {
   rm -rfv /usr/share/{info,man,doc}/*
   find /usr/{lib,libexec} -name \*.la -delete
   rm -rfv /tools
}


#
# Backup
#
function backup(){
   cd ${BACKUP}
   tar cvfj 03-backup-lfs-build-$(date +"%m-%d-%y").tar.bz2 ${LFS}
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

   final "desmontaje"
}


#
# All
#
function all() {
   gcc-pass-2
   sleep 1
   gettext
   sleep 1
   bison
   sleep 1
   perl
   sleep 1
   Python
   sleep 1
   textinfo
   sleep 1
   util-linux
   sleep 1
   limpieza
}

# Menu principal
if [ $# -eq 0 ]; then
	  ayuda
elif [ $# -eq 1 ]; then
   case ${1} in
       p0)   gcc-pass-2
	     ;;
       p1)   gettext
	     ;;
       p2)   bison
	     ;;
       p3)   perl
	     ;;
       p4)   Python
	     ;;
       p5)   texinfo
	     ;;
       p6)   util-linux
	     ;;
       p7)   limpieza
	     ;;
       p8)   desmontaje
	     ;;
       p9)   backup
	     ;;
       all)  all
	     ;;
	*)   ayuda
             ;;
   esac
fi
