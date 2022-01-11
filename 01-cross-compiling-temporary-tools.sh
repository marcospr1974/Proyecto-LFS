#!/bin/bash

##
# Autor    : Marcos Pablo Russo
# E-Mail   : marcospr1974@gmail.com
# Fecha    : 23/12/2021
# Licencia : GPL-3
#
# Descripcion:
#
#   Mediante este script nos permite realizar el capitulo 6 de Linux From Scratch.
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
   echo -e "\n\n\t${grayColour}[p0]${endColour}${yellowColour}  Compilar m4${endColour}"
   echo -e "\t${grayColour}[p1]${endColour}${yellowColour}  Compilar ncurses${endColour}"
   echo -e "\t${grayColour}[p2]${endColour}${yellowColour}  Compilar bash${endColour}"
   echo -e "\t${grayColour}[p3]${endColour}${yellowColour}  Compilar coreutils${endColour}"
   echo -e "\t${grayColour}[p4]${endColour}${yellowColour}  Compilar diffutils${endColour}"
   echo -e "\t${grayColour}[p5]${endColour}${yellowColour}  Compilar file${endColour}"
   echo -e "\t${grayColour}[p6]${endColour}${yellowColour}  Compilar findutils${endColour}"
   echo -e "\t${grayColour}[p7]${endColour}${yellowColour}  Compilar gawk${endColour}"
   echo -e "\t${grayColour}[p8]${endColour}${yellowColour}  Compilar grep${endColour}"
   echo -e "\t${grayColour}[p9]${endColour}${yellowColour}  Compilar gzip${endColour}"
   echo -e "\t${grayColour}[p10]${endColour}${yellowColour} Compilar make${endColour}"
   echo -e "\t${grayColour}[p11]${endColour}${yellowColour} Compilar patch${endColour}"
   echo -e "\t${grayColour}[p12]${endColour}${yellowColour} Compilar sed${endColour}"
   echo -e "\t${grayColour}[p13]${endColour}${yellowColour} Compilar tar${endColour}"
   echo -e "\t${grayColour}[p14]${endColour}${yellowColour} Compilar xz${endColour}"
   echo -e "\t${grayColour}[p15]${endColour}${yellowColour} Compilar binutils-pass-2${endColour}"
   echo -e "\t${grayColour}[p16]${endColour}${yellowColour} Compilar gcc-pass-2${endColour}"
   echo -e "\t${grayColour}[p17]${endColour}${yellowColour} Realizar backup${endColour}"
   echo -e "\t${grayColour}[all]${endColour}${yellowColour} Realizar todos los pasos${endColour}"
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
  [[ -d ${BACKUP} ]] || mkdir -pv ${BACKUP}
  [[ -d ${SRC_SOURCES} ]] || mkdir -pv ${SRC_SOURCES}
  [[ -d ${SRC_FILES} ]] || mkdir -pv ${SRC_FILES}
  [[ -d ${LFS_LOGS} ]] || mkdir -pv ${LFS_LOGS}
}


#
# Build m4
#
function m4() {
  descomprimir "m4" "m4" 

  ./configure --prefix=/usr   \
	      --host=$LFS_TGT \
	      --build=$(build-aux/config.guess) &> ${LFS_LOGS}/configure-${PKG_NAME}.log || exit 1

  make ${J} &> ${LFS_LOGS}/make-${PKG_NAME}.log || exit 1

  # Si hay problemas de compilacion poner -j1
  make DESTDIR=$LFS install &> ${LFS_LOGS}/make-install-${PKG_NAME}.log  || exit 1

  final ${PKG_NAME}
}


#
# Build ncurses
#
function ncurses() {
  descomprimir "ncurses" "ncurses" 

  sed -i s/mawk// configure || exit 1
  mkdir build || exit 1
  pushd build || exit 1
    ../configure
    make -C include ${J}  &> ${LFS_LOGS}/make-${PKG_NAME}.log || exit 1
    make -C progs tic ${J} &>> ${LFS_LOGS}/make-${PKG_NAME}.log || exit 1
  popd

  ./configure --prefix=/usr                \
              --host=$LFS_TGT              \
              --build=$(./config.guess)    \
              --mandir=/usr/share/man      \
              --with-manpage-format=normal \
              --with-shared                \
              --without-debug              \
              --without-ada                \
              --without-normal             \
              --enable-widec &> ${LFS_LOGS}/configure-${PKG_NAME}.log || exit 1

  make ${J} &>> ${LFS_LOGS}/make-${PKG_NAME}.log || exit 1

  make DESTDIR=$LFS TIC_PATH=$(pwd)/build/progs/tic install &> ${LFS_LOGS}/make-install-${PKG_NAME}.log || exit 1
  echo "INPUT(-lncursesw)" > $LFS/usr/lib/libncurses.so

  final ${PKG_NAME}
}

#
# Build bash
#
function bash2() {
  descomprimir "bash" "bash2" 

  ./configure --prefix=/usr                   \
              --build=$(support/config.guess) \
              --host=$LFS_TGT                 \
              --without-bash-malloc &> ${LFS_LOGS}/configure-${PKG_NAME}.log || exit 1

  make ${J} &> ${LFS_LOGS}/make-${PKG_NAME}.log || exit 1
  make DESTDIR=$LFS install &> ${LFS_LOGS}/make-install-${PKG_NAME}.log || exit 1

  ln -sv bash $LFS/bin/sh

  final ${PKG_NAME}
}


#
# Build coreutils
#
function coreutils() {
  descomprimir "coreutils" "coreutils" 

  ./configure --prefix=/usr                     \
              --host=$LFS_TGT                   \
              --build=$(build-aux/config.guess) \
              --enable-install-program=hostname \
              --enable-no-install-program=kill,uptime &> ${LFS_LOGS}/configure-${PKG_NAME}.log || exit 1

  make ${J} &> ${LFS_LOGS}/make-${PKG_NAME}.log || exit 1
  make DESTDIR=$LFS install &> ${LFS_LOGS}/make-install-${PKG_NAME}.log || exit 1

  mv -v $LFS/usr/bin/chroot                    $LFS/usr/sbin
  mkdir -pv $LFS/usr/share/man/man8
  mv -v $LFS/usr/share/man/man1/chroot.1       $LFS/usr/share/man/man8/chroot.8
  sed -i 's/"1"/"8"/'                          $LFS/usr/share/man/man8/chroot.8

  final ${PKG_NAME}
}


#
# Build diffutils
#
function diffutils() {
  descomprimir "diffutils" "diffutils" 

  ./configure --prefix=/usr --host=$LFS_TGT &> ${LFS_LOGS}/configure-${PKG_NAME}.log || exit 1

  make ${J} &> ${LFS_LOGS}/make-${PKG_NAME}.log || exit 1
  make DESTDIR=$LFS install &> ${LFS_LOGS}/make-install-${PKG_NAME}.log || exit 1

  final ${PKG_NAME}
}


#
# Build file
#
function file2() {
  descomprimir "file" "file2" 

  mkdir build
  pushd build
    ../configure --disable-bzlib      \
                 --disable-libseccomp \
                 --disable-xzlib      \
                 --disable-zlib &> ${LFS_LOGS}/configure-${PKG_NAME}.log || exit 1
      make ${J} &> ${LFS_LOGS}/make-${PKG_NAME}.log || exit 1
      popd

  ./configure --prefix=/usr --host=$LFS_TGT --build=$(./config.guess) &>> ${LFS_LOGS}/configure-${PKG_NAME}.log || exit 1

  make FILE_COMPILE=$(pwd)/build/src/file ${J} &> ${LFS_LOGS}/make-${PKG_NAME}.log || exit 1
  make DESTDIR=$LFS install &> ${LFS_LOGS}/make-install-${PKG_NAME}.log || exit 1

  final ${PKG_NAME}
}


#
# Build findutils
#
function findutils() {
  descomprimir "findutils" "findutils" 

  ./configure --prefix=/usr                   \
              --localstatedir=/var/lib/locate \
              --host=$LFS_TGT                 \
              --build=$(build-aux/config.guess) &> ${LFS_LOGS}/configure-${PKG_NAME}.log || exit 1

  make ${J} &> ${LFS_LOGS}/make-${PKG_NAME}.log || exit 1
  make DESTDIR=$LFS install &> ${LFS_LOGS}/make-install-${PKG_NAME}.log || exit 1

  final ${PKG_NAME}
}


#
# Build gawk
#
function gawk2() {
  descomprimir "gawk" "gawk2" 

  sed -i 's/extras//' Makefile.in
  ./configure --prefix=/usr   \
	      --host=$LFS_TGT \
	      --build=$(./config.guess) &> ${LFS_LOGS}/configure-${PKG_NAME}.log || exit 1

  make ${J} &> ${LFS_LOGS}/make-${PKG_NAME}.log || exit 1
  make DESTDIR=$LFS install &> ${LFS_LOGS}/make-install-${PKG_NAME}.log || exit 1

  final ${PKG_NAME}
}


#
# Build grep
#
function grep2() {
  descomprimir "grep" "grep2" 

  ./configure --prefix=/usr   \
	      --host=$LFS_TGT &> ${LFS_LOGS}/configure-${PKG_NAME}.log || exit 1

  make ${J} &> ${LFS_LOGS}/make-${PKG_NAME}.log || exit 1
  make DESTDIR=$LFS install &> ${LFS_LOGS}/make-install-${PKG_NAME}.log || exit 1

  final ${PK_NAME}
}


#
# Build gzip
#
function gzip2() {
  descomprimir "gzip" "gzip2" 

  ./configure --prefix=/usr --host=$LFS_TGT &> ${LFS_LOGS}/configure-${PKG_NAME}.log || exit 1
  make ${J} &> ${LFS_LOGS}/make-${PKG_NAME}.log || exit 1
  make DESTDIR=$LFS install &> ${LFS_LOGS}/make-install-${PKG_NAME}.log || exit 1

  final ${PKG_NAME}
}


#
# Build make
#
function make2() {
  descomprimir "make" "make2" 

  ./configure --prefix=/usr   \
              --without-guile \
              --host=$LFS_TGT \
              --build=$(build-aux/config.guess) &> ${LFS_LOGS}/configure-${PKG_NAME}.log || exit 1

  make ${J} &> ${LFS_LOGS}/make-${PKG_NAME}.log || exit 1
  make DESTDIR=$LFS install &> ${LFS_LOGS}/make-install-${PKG_NAME}.log || exit 1

  final ${PKG_NAME}
}


#
# Build patch
#
function patch2() {
  descomprimir "patch" "patch2" 

  ./configure --prefix=/usr   \
              --host=$LFS_TGT \
              --build=$(build-aux/config.guess) &> ${LFS_LOGS}/configure-${PKG_NAME}.log || exit 1


  make ${J} &> ${LFS_LOGS}/make-${PKG_NAME}.log || exit 1
  make DESTDIR=$LFS install &> ${LFS_LOGS}/make-install-${PKG_NAME}.log || exit 1

  final ${PKG_NAME}
}


#
# Build sed
#
function sed2() {
  descomprimir "sed" "sed2" 

  ./configure --prefix=/usr   \
              --host=$LFS_TGT &> ${LFS_LOGS}/configure-${PKG_NAME}.log || exit 1

  make ${J} &> ${LFS_LOGS}/make-${PKG_NAME}.log || exit 1
  make DESTDIR=$LFS install &> ${LFS_LOGS}/make-install-${PKG_NAME}.log || exit 1

  final ${PKG_NAME}
}


#
# Build tar
#
function tar2() {
  descomprimir "tar" "tar2" 

  ./configure --prefix=/usr                     \
	      --host=$LFS_TGT                   \
	      --build=$(build-aux/config.guess) &> ${LFS_LOGS}/configure-${PKG_NAME}.log || exit 1

  make ${J} &> ${LFS_LOGS}/make-${PKG_NAME}.log || exit 1
  make DESTDIR=$LFS install &> ${LFS_LOGS}/make-install-${PKG_NAME}.log || exit 1

  final ${PKG_NAME}
}


#
# Build xz
#
function xz2() {
  descomprimir "xz" "xz2" 

  ./configure --prefix=/usr                     \
              --host=$LFS_TGT                   \
              --build=$(build-aux/config.guess) \
              --disable-static                  \
              --docdir=/usr/share/doc/xz-5.2.5 &> ${LFS_LOGS}/configure-${PKG_NAME}.log || exit 1

  make ${J} &> ${LFS_LOGS}/make-${PKG_NAME}.log || exit 1
  make DESTDIR=$LFS install &> ${LFS_LOGS}/make-install-${PKG_NAME}.log || exit 1

  final ${PKG_NAME}
}


#
# Build binutils-pass-2
#
function binutils-pass-2() {
  descomprimir "binutils" "binutils-pass-2" 

  mkdir -v build
  cd       build
  ../configure                   \
      --prefix=/usr              \
      --build=$(../config.guess) \
      --host=$LFS_TGT            \
      --disable-nls              \
      --enable-shared            \
      --disable-werror           \
      --enable-64-bit-bfd &> ${LFS_LOGS}/configure-${PKG_NAME}.log || exit 1

  make ${J} &> ${LFS_LOGS}/make-${PKG_NAME}.log || exit 1

  make DESTDIR=$LFS install -j1 &> ${LFS_LOGS}/make-install-${PKG_NAME}.log || exit 1
  install -vm755 libctf/.libs/libctf.so.0.0.0 $LFS/usr/lib || exit 1

  final ${PKG_NAME}
}


#
# Build gcc-pass-2
#
function gcc-pass-2() {
  descomprimir "gcc" "gcc-pass-2"

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

  mkdir -pv $LFS_TGT/libgcc
  ln -s ../../../libgcc/gthr-posix.h $LFS_TGT/libgcc/gthr-default.h

  ../configure                                       \
        --build=$(../config.guess)                     \
	--host=$LFS_TGT                                \
	--prefix=/usr                                  \
	CC_FOR_TARGET=$LFS_TGT-gcc                     \
	--with-build-sysroot=$LFS                      \
	--enable-initfini-array                        \
	--disable-nls                                  \
	--disable-multilib                             \
	--disable-decimal-float                        \
	--disable-libatomic                            \
	--disable-libgomp                              \
	--disable-libquadmath                          \
	--disable-libssp                               \
	--disable-libvtv                               \
	--disable-libstdcxx                            \
	--enable-languages=c,c++ &> ${LFS_LOGS}/configure-${PKG_NAME}.log || exit 1

  make ${J} &> ${LFS_LOGS}/make-${PKG_NAME}.log || exit 1

  make DESTDIR=$LFS install &> ${LFS_LOGS}/make-install-${PKG_NAME}.log || exit 1

  ln -sv gcc $LFS/usr/bin/cc

  final ${PKG_NAME}
}


#
# Backup
#
function backup(){
 cd ${BACKUP}
 tar cvfj 01-backup-lfs-cross-compiling-temporary-tools-$(date +"%m-%d-%y").tar.bz2 ${LFS}
}


#
# All
#
function all() {
   crear_directorios
   sleep 1
   m4
   sleep 1
   ncurses
   sleep 1
   bash2
   sleep 1
   coreutils
   sleep 1
   diffutils
   sleep 1
   file2
   sleep 1
   findutils
   sleep 1
   gawk2
   sleep 1
   grep2
   sleep 1
   gzip2
   sleep 1
   make2
   sleep 1
   patch2
   sleep 1
   sed2
   sleep 1
   tar2
   sleep 1
   xz2
   sleep 1
   binutils-pass-2
   sleep 1
   gcc-pass-2
   sleep 1
   backup

}

# Menu principal
if [ $# -eq 0 ]; then
  ayuda
elif [ $# -eq 1 ]; then
   case ${1} in
     p0)  m4
          ;;
     p1)  ncurses
          ;;
     p2)  bash2
          ;;
     p3)  coreutils
          ;;
     p4)  diffutils
          ;;
     p5)  file2
          ;;
     p6)  findutils
          ;;
     p7)  gawk2
          ;;
     p8)  grep2
          ;;
     p9)  gzip2
          ;;
     p10) make2
          ;;
     p11) patch2
          ;;
     p12) sed2
          ;;
     p13) tar2
          ;;
     p14) xz2
          ;;
     p15) binutils-pass-2
          ;;
     p16) gcc-pass-2
          ;;
     p17) backup
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

