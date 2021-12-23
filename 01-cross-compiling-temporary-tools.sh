#!/bin/bash

##
# Autor  : Marcos Pablo Russo
# E-Mail : marcospr1974@gmail.com
# Licencia: GPL-3
#
# DescripciÃn:
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
#       - sources
#            - packages -> Paquetes sources.
#            - patches  -> Patch.
#            - files    -> Paquetes descomprimidos.
#       - scripts -> Script de creacion.
#       - tools	  -> Contenido de la primer etapa.
#
export BUILD_ROOT=/mnt/LFS-11.0
export LFS=/mnt/lfs
export BACKUP=${BUILD_ROOT}/backup
export SRC_SOURCES=${BUILD_ROOT}/sources/packages
export SRC_FILES=${BUILD_ROOT}/sources/files
export SRC_PATCH=${BUILD_ROOT}/sources/patches
export LFS_TOOLS=${LFS}/tools

# FLAGS de Compilacion

LC_ALL=POSIX
LFS_TGT=$(uname -m)-lfs-linux-gnu
PATH=/usr/bin
if [ ! -L /bin ]; then PATH=/bin:$PATH; fi
PATH=$LFS_TOOLS/bin:$PATH
CONFIG_SITE=$LFS/usr/share/config.site
export LFS LC_ALL LFS_TGT PATH CONFIG_SITE

# Cantidad de procesadores
export MAKEFLAGS='-j4'
export J='-j4'

#
# Crear directorio principales de trabajo
#
function crear_directorios() {
  [[ -d ${BACKUP} ]] || mkdir -pv ${BACKUP}
  [[ -d ${SRC_SOURCES} ]] || mkdir -pv ${SRC_SOURCES}
  [[ -d ${SRC_FILES} ]] || mkdir -pv ${SRC_FILES}
  [[ -d ${LFS_TOOLS} ]] || mkdir -pv ${LFS_TOOLS}
}


#
# Build m4
#
function m4() {
  cd ${SRC_FILES}
  export PKG_NAME="m4"
  export PKG_DIR=$(echo ${SRC_FILES}/${PKG_NAME}*)
  echo "- Building m4..."
  tar xf ${SRC_SOURCES}/${PKG_NAME}* || exit 1

  cd ${PKG_DIR}

  ./configure --prefix=/usr   \
	      --host=$LFS_TGT \
	      --build=$(build-aux/config.guess) || exit 1

  make ${J} || exit 1

  # Si hay problemas de compilacion poner -j1
  make DESTDIR=$LFS install || exit 1

  echo "- Borrando ${PKG_DIR}"
  rm -rf ${SRC_FILES}/${PKG_NAME}*
}


#
# Build ncurses
#
function ncurses() {
  cd ${SRC_FILES}
  export PKG_NAME="ncurses"
  export PKG_DIR=$(echo ${SRC_FILES}/${PKG_NAME}*)
  echo "- Building ncurses..."
  tar xf ${SRC_SOURCES}/${PKG_NAME}* || exit 1
  cd ${PKG_DIR}

  sed -i s/mawk// configure || exit 1
  mkdir build || exit 1
  pushd build || exit 1
    ../configure
    make -C include ${J} || exit 1
    make -C progs tic ${J} || exit 1
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
              --enable-widec || exit 1

  make ${J} || exit 1

  make DESTDIR=$LFS TIC_PATH=$(pwd)/build/progs/tic install
  echo "INPUT(-lncursesw)" > $LFS/usr/lib/libncurses.so

  echo "- Borrando ${PKG_DIR}"
  rm -rf ${SRC_FILES}/${PKG_NAME}*
}

#
# Build bash
#
function bash2() {
  cd ${SRC_FILES}
  export PKG_NAME="bash"
  export PKG_DIR=$(echo ${SRC_FILES}/${PKG_NAME}*)
  echo "- Building bash..."
  tar xf ${SRC_SOURCES}/${PKG_NAME}* || exit 1
  cd ${PKG_DIR}

  ./configure --prefix=/usr                   \
              --build=$(support/config.guess) \
              --host=$LFS_TGT                 \
              --without-bash-malloc || exit 1

  make ${J} || exit 1
  make DESTDIR=$LFS install || exit 1

  ln -sv bash $LFS/bin/sh

  echo "- Borrando ${PKG_DIR}"
  rm -rf ${SRC_FILES}/${PKG_NAME}*
}


#
# Build coreutils
#
function coreutils() {
  cd ${SRC_FILES}
  export PKG_NAME="coreutils"
  export PKG_DIR=$(echo ${SRC_FILES}/${PKG_NAME}*)
  echo "- Building coreutils..."
  tar xf ${SRC_SOURCES}/${PKG_NAME}* || exit 1
  cd ${PKG_DIR}

  ./configure --prefix=/usr                     \
              --host=$LFS_TGT                   \
              --build=$(build-aux/config.guess) \
              --enable-install-program=hostname \
              --enable-no-install-program=kill,uptime || exit 1

  make ${J} || exit 1
  make DESTDIR=$LFS install || exit 1

  mv -v $LFS/usr/bin/chroot                    $LFS/usr/sbin
  mkdir -pv $LFS/usr/share/man/man8
  mv -v $LFS/usr/share/man/man1/chroot.1       $LFS/usr/share/man/man8/chroot.8
  sed -i 's/"1"/"8"/'                          $LFS/usr/share/man/man8/chroot.8

  echo "- Borrando ${PKG_DIR}"
  rm -rf ${SRC_FILES}/${PKG_NAME}*
}


#
# Build diffutils
#
function diffutils() {
  cd ${SRC_FILES}
  export PKG_NAME="diffutils"
  export PKG_DIR=$(echo ${SRC_FILES}/${PKG_NAME}*)
  echo "- Building diffutils..."
  tar xf ${SRC_SOURCES}/${PKG_NAME}* || exit 1
  cd ${PKG_DIR}


  ./configure --prefix=/usr --host=$LFS_TGT || exit 1

  make ${J} || exit 1
  make DESTDIR=$LFS install || exit 1
  echo "- Borrando ${PKG_DIR}"
  rm -rf ${SRC_FILES}/${PKG_NAME}*
}


#
# Build file
#
function file2() {
  cd ${SRC_FILES}
  export PKG_NAME="file"
  export PKG_DIR=$(echo ${SRC_FILES}/${PKG_NAME}*)
  echo "- Building file..."
  tar xf ${SRC_SOURCES}/${PKG_NAME}* || exit 1
  cd ${PKG_DIR}

  mkdir build
  pushd build
    ../configure --disable-bzlib      \
                 --disable-libseccomp \
                 --disable-xzlib      \
                 --disable-zlib || exit 1
      make ${J} || exit 1
      popd

  ./configure --prefix=/usr --host=$LFS_TGT --build=$(./config.guess) || exit 1

  make FILE_COMPILE=$(pwd)/build/src/file ${J} || exit 1
  make DESTDIR=$LFS install || exit 1

  echo "- Borrando ${PKG_DIR}"
  rm -rf ${SRC_FILES}/${PKG_NAME}*
}


#
# Build findutils
#
function findutils() {
  cd ${SRC_FILES}
  export PKG_NAME="findutils"
  export PKG_DIR=$(echo ${SRC_FILES}/${PKG_NAME}*)
  echo "- Building fundutils..."
  tar xf ${SRC_SOURCES}/${PKG_NAME}* || exit 1
  cd ${PKG_DIR}


  ./configure --prefix=/usr                   \
              --localstatedir=/var/lib/locate \
              --host=$LFS_TGT                 \
              --build=$(build-aux/config.guess) || exit 1

  make ${J} || exit 1
  make DESTDIR=$LFS install || exit 1

  echo "- Borrando ${PKG_DIR}"
  rm -rf ${SRC_FILES}/${PKG_NAME}*
}


#
# Build gawk
#
function gawk2() {
  cd ${SRC_FILES}
  export PKG_NAME="gawk"
  export PKG_DIR=$(echo ${SRC_FILES}/${PKG_NAME}*)
  echo "- Building linux-api-headers..."
  tar xf ${SRC_SOURCES}/${PKG_NAME}* || exit 1
  cd ${PKG_DIR}


  sed -i 's/extras//' Makefile.in
  ./configure --prefix=/usr   \
	      --host=$LFS_TGT \
	      --build=$(./config.guess) || exit 1

  make ${J} || exit 1
  make DESTDIR=$LFS install || exit 1

  echo "- Borrando ${PKG_DIR}"
  rm -rf ${SRC_FILES}/${PKG_NAME}*
}


#
# Build grep
#
function grep2() {
  cd ${SRC_FILES}
  export PKG_NAME="grep"
  export PKG_DIR=$(echo ${SRC_FILES}/${PKG_NAME}*)
  echo "- Building grep..."
  tar xf ${SRC_SOURCES}/${PKG_NAME}* || exit 1
  cd ${PKG_DIR}

  ./configure --prefix=/usr   \
	      --host=$LFS_TGT || exit 1

  make ${J} || exit 1
  make DESTDIR=$LFS install || exit 1

  echo "- Borrando ${PKG_DIR}"
  rm -rf ${SRC_FILES}/${PKG_NAME}*
}


#
# Build gzip
#
function gzip2() {
  cd ${SRC_FILES}
  export PKG_NAME="gzip"
  export PKG_DIR=$(echo ${SRC_FILES}/${PKG_NAME}*)
  echo "- Building linux-api-headers..."
  tar xf ${SRC_SOURCES}/${PKG_NAME}* || exit 1
  cd ${PKG_DIR}

  ./configure --prefix=/usr --host=$LFS_TGT || exit 1
  make ${J} || exit 1
  make DESTDIR=$LFS install || exit 1

  echo "- Borrando ${PKG_DIR}"
  rm -rf ${SRC_FILES}/${PKG_NAME}*
}


#
# Build make
#
function make2() {
  cd ${SRC_FILES}
  export PKG_NAME="make"
  export PKG_DIR=$(echo ${SRC_FILES}/${PKG_NAME}*)
  echo "- Building make..."
  tar xf ${SRC_SOURCES}/${PKG_NAME}* || exit 1
  cd ${PKG_DIR}

  ./configure --prefix=/usr   \
              --without-guile \
              --host=$LFS_TGT \
              --build=$(build-aux/config.guess) || exit 1

  make ${J} || exit 1
  make DESTDIR=$LFS install || exit 1

  echo "- Borrando ${PKG_DIR}"
  rm -rf ${SRC_FILES}/${PKG_NAME}*
}


#
# Build patch
#
function patch2() {
  cd ${SRC_FILES}
  export PKG_NAME="patch"
  export PKG_DIR=$(echo ${SRC_FILES}/${PKG_NAME}*)
  echo "- Building patch..."
  tar xf ${SRC_SOURCES}/${PKG_NAME}* || exit 1
  cd ${PKG_DIR}




  ./configure --prefix=/usr   \
              --host=$LFS_TGT \
              --build=$(build-aux/config.guess) || exit 1


  make ${J} || exit 1
  make DESTDIR=$LFS install || exit 1

  echo "- Borrando ${PKG_DIR}"
  rm -rf ${SRC_FILES}/${PKG_NAME}*
}


#
# Build sed
#
function sed2() {
  cd ${SRC_FILES}
  export PKG_NAME="sed"
  export PKG_DIR=$(echo ${SRC_FILES}/${PKG_NAME}*)
  echo "- Building sed..."
  tar xf ${SRC_SOURCES}/${PKG_NAME}* || exit 1
  cd ${PKG_DIR}


  ./configure --prefix=/usr   \
              --host=$LFS_TGT || exit 1

  make ${J} || exit 1
  make DESTDIR=$LFS install || exit 1

  echo "- Borrando ${PKG_DIR}"
  rm -rf ${SRC_FILES}/${PKG_NAME}*
}


#
# Build tar
#
function tar2() {
  cd ${SRC_FILES}
  export PKG_NAME="tar"
  export PKG_DIR=$(echo ${SRC_FILES}/${PKG_NAME}*)
  echo "- Building tar..."
  tar xf ${SRC_SOURCES}/${PKG_NAME}* || exit 1
  cd ${PKG_DIR}


  ./configure --prefix=/usr                     \
	      --host=$LFS_TGT                   \
	      --build=$(build-aux/config.guess) || exit 1

  make ${J} || exit 1
  make DESTDIR=$LFS install || exit 1

  echo "- Borrando ${PKG_DIR}"
  rm -rf ${SRC_FILES}/${PKG_NAME}*
}


#
# Build xz
#
function xz2() {
  cd ${SRC_FILES}
  export PKG_NAME="xz"
  export PKG_DIR=$(echo ${SRC_FILES}/${PKG_NAME}*)
  echo "- Building xz..."
  tar xf ${SRC_SOURCES}/${PKG_NAME}* || exit 1
  cd ${PKG_DIR}


  ./configure --prefix=/usr                     \
              --host=$LFS_TGT                   \
              --build=$(build-aux/config.guess) \
              --disable-static                  \
              --docdir=/usr/share/doc/xz-5.2.5 || exit 1

  make ${J} || exit 1
  make DESTDIR=$LFS install || exit 1

  echo "- Borrando ${PKG_DIR}"
  rm -rf ${SRC_FILES}/${PKG_NAME}*
}


#
# Build binutils-pass-2
#
function binutils-pass-2() {
  cd ${SRC_FILES}
  export PKG_NAME="binutils"
  export PKG_DIR=$(echo ${SRC_FILES}/${PKG_NAME}*)
  echo "- Building binutils..."
  tar xf ${SRC_SOURCES}/${PKG_NAME}* || exit 1
  cd ${PKG_DIR}

  mkdir -v build
  cd       build
  ../configure                   \
      --prefix=/usr              \
      --build=$(../config.guess) \
      --host=$LFS_TGT            \
      --disable-nls              \
      --enable-shared            \
      --disable-werror           \
      --enable-64-bit-bfd || exit 1

  make ${J} || exit 1

  make DESTDIR=$LFS install -j1 || exit 1
  install -vm755 libctf/.libs/libctf.so.0.0.0 $LFS/usr/lib || exit 1

  echo "- Borrando ${PKG_DIR}"
  rm -rf ${SRC_FILES}/${PKG_NAME}*
}


#
# Build gcc-pass-2
#
function gcc-pass-2() {
  cd ${SRC_FILES}
  export PKG_NAME="gcc"
  export PKG_DIR=$(echo ${SRC_FILES}/${PKG_NAME}*)
  echo "- Building gcc-pass-2..."
  tar xf ${SRC_SOURCES}/${PKG_NAME}* || exit 1
  cd ${PKG_DIR}

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

  mkdir -v build
  cd build

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
	--enable-languages=c,c++ || exit 1

  make ${J} || exit 1

  make DESTDIR=$LFS install || exit 1

  ln -sv gcc $LFS/usr/bin/cc

  echo "- Borrando ${PKG_DIR}"
  rm -rf ${SRC_FILES}/${PKG_NAME}*
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

all
