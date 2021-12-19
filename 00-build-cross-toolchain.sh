#!/bin/bash

##
# Autor  : Marcos Pablo Russo
# E-Mail : marcospr1974@gmail.com
# Licencia: GPL-3
#
# DescripciÃn:
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
#       - sources
#            - packages -> Paquetes sources.
#            - patches  -> Patch.
#            - files    -> Paquetes descomprimidos.
#       - scripts -> Script de creacion.
#       - tools	  -> Contenido de la primer etapa.
#
export BUILD_ROOT=/mnt/lfs/LFS-11.0
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
# Crear directorios
#
function crear() {
  mkdir -pv $LFS/{etc,var} $LFS/usr/{bin,lib,sbin}
  for i in bin lib sbin; do
    ln -sv usr/$i $LFS/$i
  done

  case $(uname -m) in
    x86_64) mkdir -pv $LFS/lib64 ;;
  esac

  mkdir -pv $LFS_TOOLS
}


#
# Build binutils
#
function binutils() {
  cd ${SRC_FILES}
  export PKG_NAME="binutils"
  export PKG_DIR=$(echo ${SRC_FILES}/${PKG_NAME}*)
  echo "- Building binutil..."
  tar xf ${SRC_SOURCES}/${PKG_NAME}* || exit 1
  cd ${PKG_DIR}
  mkdir -v build
  cd build
  ../configure --prefix=$LFS_TOOLS \
             --with-sysroot=$LFS \
             --target=$LFS_TGT   \
             --disable-nls       \
             --disable-werror || exit 1
  make || exit 1

  # Si hay problemas de compilacion poner -j1
  make install ${J} || exit 1

  echo "- Borrando ${PKG_DIR}"
  rm -rf ${SRC_FILES}/${PKG_NAME}*
}

#
# Build gcc-pass-1
#
function gcc-pass-1() {
  cd ${SRC_FILES}
  export PKG_NAME="gcc"
  export PKG_DIR=$(echo ${SRC_FILES}/${PKG_NAME}*)
  echo "- Building gcc-pass-1..."
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
    --enable-languages=c,c++

  make ${J}
  make install

  cd ..
  cat gcc/limitx.h gcc/glimits.h gcc/limity.h > \
  `dirname $($LFS_TGT-gcc -print-libgcc-file-name)`/install-tools/include/limits.h

  echo "- Borrando ${PKG_DIR}"
  rm -rf ${SRC_FILES}/${PKG_NAME}*
}

#
# Build linux-api-headers
#
function linux-api-headers() {
  cd ${SRC_FILES}
  export PKG_NAME="linux"
  export PKG_DIR=$(echo ${SRC_FILES}/${PKG_NAME}*)
  echo "- Building linux-api-headers..."
  tar xf ${SRC_SOURCES}/${PKG_NAME}* || exit 1
  cd ${PKG_DIR}
  
  make mrproper
  make headers
  find usr/include -name '.*' -delete
  rm usr/include/Makefile
  cp -rv usr/include $LFS/usr

  echo "- Borrando ${PKG_DIR}"
  rm -rf ${SRC_FILES}/${PKG_NAME}*
}


#
# Build glibc
#
function glibc() {
  cd ${SRC_FILES}
  export PKG_NAME="glibc"
  export PKG_DIR=$(echo ${SRC_FILES}/${PKG_NAME}*)
  echo "- Building glibc..."
  tar xf ${SRC_SOURCES}/${PKG_NAME}* || exit 1
  cd ${PKG_DIR}

  case $(uname -m) in
     i?86)   ln -sfv ld-linux.so.2 $LFS/lib/ld-lsb.so.3
     ;;
     x86_64) ln -sfv ../lib/ld-linux-x86-64.so.2 $LFS/lib64
             ln -sfv ../lib/ld-linux-x86-64.so.2 $LFS/lib64/ld-lsb-x86-64.so.3
     ;;
  esac

  # Patches
  patch -Np1 -i ${SRC_PATCH}/glibc-2.34-fhs-1.patch

  mkdir -v build
  cd build
  echo "rootsbindir=/usr/sbin" > configparms
  ../configure                             \
      --prefix=/usr                      \
      --host=$LFS_TGT                    \
      --build=$(../scripts/config.guess) \
      --enable-kernel=3.2                \
      --with-headers=$LFS/usr/include    \
      libc_cv_slibdir=/usr/lib

  make ${J}
  make DESTDIR=$LFS install

  sed '/RTLDLIST=/s@/usr@@g' -i $LFS/usr/bin/ldd

  $LFS/tools/libexec/gcc/$LFS_TGT/11.2.0/install-tools/mkheaders

  echo "- Borrando ${PKG_DIR}"
  rm -rf ${SRC_FILES}/${PKG_NAME}*
}


#
# Build libstdc++
#
function libstdc++() {
  cd ${SRC_FILES}
  export PKG_NAME="gcc"
  export PKG_DIR=$(echo ${SRC_FILES}/${PKG_NAME}*)
  echo "- Building gcc libstdc++..."
  tar xf ${SRC_SOURCES}/${PKG_NAME}* || exit 1
  cd ${PKG_DIR}


  mkdir -v build
  cd build

  ../libstdc++-v3/configure           \
     --host=$LFS_TGT                 \
     --build=$(../config.guess)      \
     --prefix=/usr                   \
     --disable-multilib              \
     --disable-nls                   \
     --disable-libstdcxx-pch         \
     --with-gxx-include-dir=${LFS_TOOLS}/$LFS_TGT/include/c++/11.2.0

  make ${J} || exit 1
  make DESTDIR=$LFS install

  echo "- Borrando ${PKG_DIR}"
  rm -rf ${SRC_FILES}/${PKG_NAME}*
}

#
# Backup
#
function backup(){
 cd ${BACKUP}
 tar cvfj backup-lfs-cross-toolchain-$(date +"%m-%d-%y").tar.bz2 ${LFS}/{bin,etc,lib,lib64,mnt,sbin,tools,usr,var}
}

#
# All
#
function all() {
   crear_directorios
   crear
   binutils
   gcc-pass-1
   linux-api-headers
   glibc
   libstdc++
   backup
}

all
