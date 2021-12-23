#!/bin/bash

##
# Autor    : Marcos Pablo Russo
# E-Mail   : marcospr1974@gmail.com
# Fecha    : 23/12/2021
# Licencia : GPL-3
#
# Descripcion:
#
#   Mediante este script nos permite realizar el capitulo 5 de Linux From Scratch.
#   De esta forma podemos automatizar toda la creaciÃn de los paquetes.
#   Esta basado en LFS-11.0
#
#   https://www.linuxfromscratch.org/lfs/view/stable/index.html
#
##

#
# Configuracion de variables
#
#   lfs
#   LFS-11.0
#       - logs          -> Contene log los de configure, make y make install
#       - sources
#            - packages -> Paquetes sources.
#            - patches  -> Patch.
#            - files    -> Paquetes descomprimidos.
#       - scripts -> Script de creacion.
#       - tools	  -> Contenido de la primer etapa.
#

source ./vars.sh

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
   echo -e "\n\n\t${grayColour}[p0]${endColour}${yellowColour} Crear Directorios (backup, sources, files)${endColour}"
   echo -e "\t${grayColour}[p1]${endColour}${yellowColour} Crear Directorios (etc,var,usr/bin,usr/lib,usr/sbin)${endColour}"
   echo -e "\t${grayColour}[p2]${endColour}${yellowColour} Compilar binutils${endColour}"
   echo -e "\t${grayColour}[p3]${endColour}${yellowColour} Compilar gcc paso 1${endColour}"
   echo -e "\t${grayColour}[p4]${endColour}${yellowColour} Compilar linux-api-headers${endColour}"
   echo -e "\t${grayColour}[p5]${endColour}${yellowColour} Compilar glibc${endColour}"
   echo -e "\t${grayColour}[p6]${endColour}${yellowColour} Compilar libstdc++${endColour}"
   echo -e "\t${grayColour}[p7]${endColour}${yellowColour} Realizar backup${endColour}"
   echo -e "\t${grayColour}[all]${endColour}${yellowColour} Realizar todos los pasos${endColour}"
   echo -e "\t${grayColour}[h]${endColour}${yellowColour}   Muestra la ayuda${endColour}"
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
  echo -e "${grayColour}- Finalizacion de la compilaciÃ³n dle paquete${endColour}"
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
# Crear directorio principales de trabajo
#
function crear_directorios() {
  inicio "directorios base"
  [[ -d ${BACKUP} ]] || mkdir -pv ${BACKUP}
  [[ -d ${SRC_SOURCES} ]] || mkdir -pv ${SRC_SOURCES}
  [[ -d ${SRC_FILES} ]] || mkdir -pv ${SRC_FILES}
  [[ -d ${LFS_LOGS} ]] || mkdir -pv ${LFS_LOGS}
}


#
# Crear directorios
#
function crear() {
  inicio "directorios"

  mkdir -pv $LFS/{etc,var} $LFS/usr/{bin,lib,sbin}

  for i in bin lib sbin; do
    ln -sv usr/$i $LFS/$i
  done

  case $(uname -m) in
    x86_64) mkdir -pv $LFS/lib64 ;;
  esac

  mkdir -pv $LFS_TOOLS

  chown -v lfs $LFS/{usr{,/*},lib,var,etc,bin,sbin,tools}
  case $(uname -m) in
	    x86_64) chown -v lfs $LFS/lib64 ;;
  esac
  echo "----------------------------------------------------------------"
}


#
# Build binutils
#
function binutils() {
  descomprimir "binutils" "binutils"

  mkdir build && cd build

  ../configure --prefix=$LFS_TOOLS \
              --with-sysroot=$LFS \
              --target=$LFS_TGT   \
              --disable-nls       \
              --disable-werror  &> ${LFS_LOGS}/configure-${PKG_NAME}.log || exit 1

  make &> ${LFS_LOGS}/make-${PKG_NAME}.log || exit 1

  # Si hay problemas de compilacion poner -j1
  make install ${J} &> ${LFS_LOGS}/make-install-${PKG_NAME}.log || exit 1

  final ${PKG_NAME}
}


#
# Build gcc-pass-1
#
function gcc-pass-1() {
  descomprimir "gcc" "gcc-pass-1"

  tar xf ${SRC_SOURCES}/mpfr-*
  mv -v mpfr-* mpfr

  tar xf ${SRC_SOURCES}/gmp-*
  mv -v gmp-* gmp

  tar xf ${SRC_SOURCES}/mpc-*
  mv -v mpc-* mpc

  case $(uname -m) in
    x86_64)
      sed -e '/m64=/s/lib64/lib/' \
          -i.orig gcc/config/i386/t-linux64
      ;;
  esac

  mkdir build && cd build

  ../configure                                     \
    --target=$LFS_TGT                              \
    --prefix=$LFS/tools                            \
    --with-glibc-version=2.11                      \
    --with-sysroot=$LFS                            \
    --with-newlib                                  \
    --without-headers                              \
    --enable-initfini-array                        \
    --disable-nls                                  \
    --disable-shared                               \
    --disable-multilib                             \
    --disable-decimal-float                        \
    --disable-threads                              \
    --disable-libatomic                            \
    --disable-libgomp                              \
    --disable-libquadmath                          \
    --disable-libssp                               \
    --disable-libvtv                               \
    --disable-libstdcxx                            \
    --enable-languages=c,c++ &> ${LFS_LOGS}/configure-${PKG_NAME}.log || exit 1

  make ${J} &> ${LFS_LOGS}/make-${PKG_NAME}.log || exit 1
  make install &> ${LFS_LOGS}/make-install-${PKG_NAME}.log || exit 1

  cd ..
  cat gcc/limitx.h gcc/glimits.h gcc/limity.h > \
  `dirname $($LFS_TGT-gcc -print-libgcc-file-name)`/install-tools/include/limits.h

  final ${PKG_NAME}
}


#
# Build linux-api-headers
#
function linux-api-headers() {
  descomprimir "linux" "linux-api-headers"

  make mrproper &> ${LFS_LOGS}/make-${PKG_NAME}.log || exit 1
  make headers &>> ${LFS_LOGS}/make-${PKG_NAME}.log || exit 1
  find usr/include -name '.*' -delete
  rm usr/include/Makefile
  cp -rv usr/include $LFS/usr

  final ${PKG_NAME}
}


#
# Build glibc
#
function glibc() {
  descomprimir "glibc" "glibc"

  case $(uname -m) in
     i?86)   ln -sfv ld-linux.so.2 $LFS/lib/ld-lsb.so.3
     ;;
     x86_64) ln -sfv ../lib/ld-linux-x86-64.so.2 $LFS/lib64
             ln -sfv ../lib/ld-linux-x86-64.so.2 $LFS/lib64/ld-lsb-x86-64.so.3
     ;;
  esac

  # Patches
  patch -Np1 -i ${SRC_PATCH}/glibc-2.34-fhs-1.patch

  mkdir build && cd build

  echo "rootsbindir=/usr/sbin" > configparms
  ../configure                             \
      --prefix=/usr                      \
      --host=$LFS_TGT                    \
      --build=$(../scripts/config.guess) \
      --enable-kernel=3.2                \
      --with-headers=$LFS/usr/include    \
      libc_cv_slibdir=/usr/lib &> ${LFS_LOGS}/configure-${PKG_NAME}.log || exit 1

  make ${J} &> ${LFS_LOGS}/make-${PKG_NAME}.log || exit 1
  make DESTDIR=$LFS install &> ${LFS_LOGS}/make-install-${PKG_NAME}.log || exit 1

  sed '/RTLDLIST=/s@/usr@@g' -i $LFS/usr/bin/ldd

  $LFS/tools/libexec/gcc/$LFS_TGT/11.2.0/install-tools/mkheaders

  final ${PKG_NAME}
}


#
# Build libstdc++
#
function libstdc++() {
  descomprimir "gcc" "libstdc++"

  mkdir build && cd build

  ../libstdc++-v3/configure          \
     --host=$LFS_TGT                 \
     --build=$(../config.guess)      \
     --prefix=/usr                   \
     --disable-multilib              \
     --disable-nls                   \
     --disable-libstdcxx-pch         \
     --with-gxx-include-dir=/tools/$LFS_TGT/include/c++/11.2.0 &> ${LFS_LOGS}/configure-${PKG_NAME}.log || exit 1

  make ${J} &> ${LFS_LOGS}/make-${PKG_NAME}.log || exit 1
  make DESTDIR=$LFS install &> ${LFS_LOGS}/make-install-${PKG_NAME}.log || exit 1

  final ${PKG_NAME}
}


#
# Backup
#
function backup(){
 cd ${BACKUP}
 tar cvfj 00-backup-lfs-cross-toolchain-$(date +"%d-%m-%Y").tar.bz2 ${LFS}
}

#
# All
#
function all() {
   crear_directorios
   sleep 1
   crear
   sleep 1
   binutils
   sleep 1
   gcc-pass-1
   sleep 1
   linux-api-headers
   sleep 1
   glibc
   sleep 1
   libstdc++
   sleep 1
   backup
}

# Menu principal
if [ $# -eq 0 ]; then
  ayuda
elif [ $# -eq 1 ]; then
   case ${1} in
     p0)  crear_directorios
          ;;
     p1)  crear
          ;;
     p2)  binutils
          ;;
     p3)  gcc-pass-1
          ;;
     p4)  linux-api-headers
          ;;
     p5)  glibc
          ;;
     p6)  libstdc++
          ;;
     p7)  backup
          ;;
     all) all
          ;;
     h)   ayuda
	  ;;
     *)   ayuda
	  ;;
   esac
else
  ayuda
fi
