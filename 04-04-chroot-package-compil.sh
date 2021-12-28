#!/bin/bash

##
# Autor    : Marcos Pablo Russo
# E-Mail   : marcospr1974@gmail.com
# Fecha    : 25/12/2021
# Licencia : GPL-3
#
# Descripcion:
#
#   Mediante este script nos permite realizar el capitulo 8 de Linux From Scratch.
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
   echo -e "\n\n\t${grayColour}[p0]${endColour}${yellowColour}  Compilar man-pages${endColour}"
   echo -e "\t${grayColour}[p1]${endColour}${yellowColour}  Compilar iana-etc${endColour}"
   echo -e "\t${grayColour}[p2]${endColour}${yellowColour}  Compilar glibc${endColour}"
   echo -e "\t${grayColour}[p3]${endColour}${yellowColour}  Compilar zlib${endColour}"
   echo -e "\t${grayColour}[p4]${endColour}${yellowColour}  Compilar bzip2${endColour}"
   echo -e "\t${grayColour}[p5]${endColour}${yellowColour}  Compilar xz${endColour}"
   echo -e "\t${grayColour}[p6]${endColour}${yellowColour}  Compilar zstd${endColour}"
   echo -e "\t${grayColour}[p7]${endColour}${yellowColour}  Compilar file${endColour}"
   echo -e "\t${grayColour}[p8]${endColour}${yellowColour}  Compilar readline${endColour}"
   echo -e "\t${grayColour}[p9]${endColour}${yellowColour}  Compilar m4${endColour}"
   echo -e "\t${grayColour}[p10]${endColour}${yellowColour} Compilar bc${endColour}"
   echo -e "\t${grayColour}[p11]${endColour}${yellowColour} Compilar flex${endColour}"
   echo -e "\t${grayColour}[p12]${endColour}${yellowColour} Compilar tcl${endColour}"
   echo -e "\t${grayColour}[p13]${endColour}${yellowColour} Compilar expect${endColour}"
   echo -e "\t${grayColour}[p14]${endColour}${yellowColour} Compilar DejaGNU${endColour}"
   echo -e "\t${grayColour}[p15]${endColour}${yellowColour} Compilar binutils${endColour}"
   echo -e "\t${grayColour}[p16]${endColour}${yellowColour} Compilar gmp${endColour}"
   echo -e "\t${grayColour}[p17]${endColour}${yellowColour} Compilar mpfr${endColour}"
   echo -e "\t${grayColour}[p18]${endColour}${yellowColour} Compilar mpc${endColour}"
   echo -e "\t${grayColour}[p19]${endColour}${yellowColour} Compilar attr${endColour}"
   echo -e "\t${grayColour}[p20]${endColour}${yellowColour} Compilar acl${endColour}"
   echo -e "\t${grayColour}[p21]${endColour}${yellowColour} Compilar libcap${endColour}"
   echo -e "\t${grayColour}[p22]${endColour}${yellowColour} Compilar cracklib${endColour}"
   echo -e "\t${grayColour}[p23]${endColour}${yellowColour} Compilar shadow${endColour}"
   echo -e "\t${grayColour}[p24]${endColour}${yellowColour} Compilar gcc-final${endColour}"
   echo -e "\t${grayColour}[p25]${endColour}${yellowColour} Compilar pkg-config${endColour}"
   echo -e "\t${grayColour}[p26]${endColour}${yellowColour} Compilar ncurses${endColour}"
   echo -e "\t${grayColour}[p27]${endColour}${yellowColour} Compilar sed-final${endColour}"
   echo -e "\t${grayColour}[p28]${endColour}${yellowColour} Compilar psmisc${endColour}"
   echo -e "\t${grayColour}[p29]${endColour}${yellowColour} Compilar gettext${endColour}"
   echo -e "\t${grayColour}[p30]${endColour}${yellowColour} Compilar bison${endColour}"
   echo -e "\t${grayColour}[p31]${endColour}${yellowColour} Compilar grep-final${endColour}"
   echo -e "\t${grayColour}[p32]${endColour}${yellowColour} Compilar bash-final${endColour}"
   echo -e "\t${grayColour}[p33]${endColour}${yellowColour} Compilar libtool${endColour}"
   echo -e "\t${grayColour}[p34]${endColour}${yellowColour} Compilar gdbm${endColour}"
   echo -e "\t${grayColour}[p35]${endColour}${yellowColour} Compilar gperf${endColour}"
   echo -e "\t${grayColour}[p36]${endColour}${yellowColour} Compilar expat${endColour}"
   echo -e "\t${grayColour}[p37]${endColour}${yellowColour} Compilar inetutils${endColour}"
   echo -e "\t${grayColour}[p38]${endColour}${yellowColour} Compilar less-final${endColour}"
   echo -e "\t${grayColour}[p39]${endColour}${yellowColour} Compilar perl-final${endColour}"
   echo -e "\t${grayColour}[p40]${endColour}${yellowColour} Compilar xml-parser${endColour}"
   echo -e "\t${grayColour}[p41]${endColour}${yellowColour} Compilar intltool${endColour}"
   echo -e "\t${grayColour}[p42]${endColour}${yellowColour} Compilar autoconf${endColour}"
   echo -e "\t${grayColour}[p43]${endColour}${yellowColour} Compilar automake${endColour}"
   echo -e "\t${grayColour}[p44]${endColour}${yellowColour} Compilar kmod${endColour}"
   echo -e "\t${grayColour}[p45]${endColour}${yellowColour} Compilar elfutils${endColour}"
   echo -e "\t${grayColour}[p46]${endColour}${yellowColour} Compilar libffi${endColour}"
   echo -e "\t${grayColour}[p47]${endColour}${yellowColour} Compilar openssl${endColour}"
   echo -e "\t${grayColour}[p48]${endColour}${yellowColour} Compilar python-final${endColour}"
   echo -e "\t${grayColour}[p49]${endColour}${yellowColour} Compilar ninja${endColour}"
   echo -e "\t${grayColour}[p50]${endColour}${yellowColour} Compilar meson${endColour}"
   echo -e "\t${grayColour}[p51]${endColour}${yellowColour} Compilar coreutils${endColour}"
   echo -e "\t${grayColour}[p52]${endColour}${yellowColour} Compilar check${endColour}"
   echo -e "\t${grayColour}[p53]${endColour}${yellowColour} Compilar diffutils${endColour}"
   echo -e "\t${grayColour}[p54]${endColour}${yellowColour} Compilar gawk${endColour}"
   echo -e "\t${grayColour}[p55]${endColour}${yellowColour} Compilar findutils${endColour}"
   echo -e "\t${grayColour}[p56]${endColour}${yellowColour} Compilar groff${endColour}"
   echo -e "\t${grayColour}[p57]${endColour}${yellowColour} Compilar grub sin UEFI${endColour}"
   echo -e "\t${grayColour}[p58]${endColour}${yellowColour} Compilar gzip${endColour}"
   echo -e "\t${grayColour}[p59]${endColour}${yellowColour} Compilar iproute2${endColour}"
   echo -e "\t${grayColour}[p60]${endColour}${yellowColour} Compilar kbd${endColour}"
   echo -e "\t${grayColour}[p61]${endColour}${yellowColour} Compilar libpipeline${endColour}"
   echo -e "\t${grayColour}[p62]${endColour}${yellowColour} Compilar make-final${endColour}"
   echo -e "\t${grayColour}[p63]${endColour}${yellowColour} Compilar patch-final${endColour}"
   echo -e "\t${grayColour}[p64]${endColour}${yellowColour} Compilar tar-final${endColour}"
   echo -e "\t${grayColour}[p65]${endColour}${yellowColour} Compilar texinfo${endColour}"
   echo -e "\t${grayColour}[p66]${endColour}${yellowColour} Compilar vim-final${endColour}"
   echo -e "\t${grayColour}[p67]${endColour}${yellowColour} Compilar eudev${endColour}"
   echo -e "\t${grayColour}[p68]${endColour}${yellowColour} Compilar man-db${endColour}"
   echo -e "\t${grayColour}[p69]${endColour}${yellowColour} Compilar procps-ng${endColour}"
   echo -e "\t${grayColour}[p70]${endColour}${yellowColour} Compilar util-linux${endColour}"
   echo -e "\t${grayColour}[p71]${endColour}${yellowColour} Compilar e2fsprogs${endColour}"
   echo -e "\t${grayColour}[p72]${endColour}${yellowColour} Compilar sysklogd${endColour}"
   echo -e "\t${grayColour}[p73]${endColour}${yellowColour} Compilar sysvinit-final${endColour}"
   echo -e "\t${grayColour}[p74]${endColour}${yellowColour} Compilar stripping${endColour}"
   echo -e "\t${grayColour}[p75]${endColour}${yellowColour} Limpieza${endColour}"
   echo -e "\t${grayColour}[p76]${endColour}${yellowColour} Realizar desmontaje${endColour}"
   echo -e "\t${grayColour}[p77]${endColour}${yellowColour} Realizar backup${endColour}"
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
# Build man-pages
#
function man-pages() {
  descomprimir "man-pages" "man-pages" 

  make prefix=/usr install

  final ${PKG_NAME}
}


#
# Build iana-etc
#
function iana-etc() {
  descomprimir "iana-etc" "iana-etc" 

  cp services protocols /etc

  final ${PKG_NAME}
}


#
# Build glibc
#
function glibc() {
  descomprimir "glibc" "glibc" 

  sed -e '/NOTIFY_REMOVED)/s/)/ \&\& data.attr != NULL)/' \
	      -i sysdeps/unix/sysv/linux/mq_notify.c

  patch -Np1 -i ${SRC_PATH}/glibc-2.34-fhs-1.patch

  mkdir -v build && cd build

  echo "rootsbindir=/usr/sbin" > configparms

  ../configure --prefix=/usr                     \
        --disable-werror                         \
        --enable-kernel=3.2                      \
        --enable-stack-protector=strong          \
        --with-headers=/usr/include              \
        libc_cv_slibdir=/usr/lib

  make ${J}

  touch /etc/ld.so.conf

  sed '/test-installation/s@$(PERL)@echo not running@' -i ../Makefile

  make install

  sed '/RTLDLIST=/s@/usr@@g' -i /usr/bin/ldd
  
  cp -v ../nscd/nscd.conf /etc/nscd.conf
  mkdir -pv /var/cache/nscd
  mkdir -pv /usr/lib/locale


  localedef -i es_AR -f ISO-8859-1 es_AR
  localedef -i POSIX -f UTF-8 C.UTF-8 2> /dev/null || true

  #localedef -i cs_CZ -f UTF-8 cs_CZ.UTF-8
  #localedef -i de_DE -f ISO-8859-1 de_DE
  #localedef -i de_DE@euro -f ISO-8859-15 de_DE@euro
  #localedef -i de_DE -f UTF-8 de_DE.UTF-8
  #localedef -i el_GR -f ISO-8859-7 el_GR
  #localedef -i en_GB -f ISO-8859-1 en_GB
  #localedef -i en_GB -f UTF-8 en_GB.UTF-8
  #localedef -i en_HK -f ISO-8859-1 en_HK
  #localedef -i en_PH -f ISO-8859-1 en_PH
  #localedef -i en_US -f ISO-8859-1 en_US
  #localedef -i en_US -f UTF-8 en_US.UTF-8
  #localedef -i es_ES -f ISO-8859-15 es_ES@euro
  #localedef -i es_MX -f ISO-8859-1 es_MX
  #localedef -i fa_IR -f UTF-8 fa_IR
  #localedef -i fr_FR -f ISO-8859-1 fr_FR
  #localedef -i fr_FR@euro -f ISO-8859-15 fr_FR@euro
  #localedef -i fr_FR -f UTF-8 fr_FR.UTF-8
  #localedef -i is_IS -f ISO-8859-1 is_IS
  #localedef -i is_IS -f UTF-8 is_IS.UTF-8
  #localedef -i it_IT -f ISO-8859-1 it_IT
  #localedef -i it_IT -f ISO-8859-15 it_IT@euro
  #localedef -i it_IT -f UTF-8 it_IT.UTF-8
  #localedef -i ja_JP -f EUC-JP ja_JP
  #localedef -i ja_JP -f SHIFT_JIS ja_JP.SIJS 2> /dev/null || true
  #localedef -i ja_JP -f UTF-8 ja_JP.UTF-8
  #localedef -i nl_NL@euro -f ISO-8859-15 nl_NL@euro
  #localedef -i ru_RU -f KOI8-R ru_RU.KOI8-R
  #localedef -i ru_RU -f UTF-8 ru_RU.UTF-8
  #localedef -i se_NO -f UTF-8 se_NO.UTF-8
  #localedef -i ta_IN -f UTF-8 ta_IN.UTF-8
  #localedef -i tr_TR -f UTF-8 tr_TR.UTF-8
  #localedef -i zh_CN -f GB18030 zh_CN.GB18030
  #localedef -i zh_HK -f BIG5-HKSCS zh_HK.BIG5-HKSCS
  #localedef -i zh_TW -f UTF-8 zh_TW.UTF-8

  #make localedata/install-locales
  #localedef -i POSIX -f UTF-8 C.UTF-8 2> /dev/null || true
  #localedef -i ja_JP -f SHIFT_JIS ja_JP.SIJS 2> /dev/null || true

cat > /etc/nsswitch.conf << "EOF"
# Begin /etc/nsswitch.conf

passwd: files
group: files
shadow: files

hosts: files dns
networks: files

protocols: files
services: files
ethers: files
rpc: files

# End /etc/nsswitch.conf
EOF

  tar xf ${SRC_SOURCES}/tzdata2021a.tar.gz

  ZONEINFO=/usr/share/zoneinfo
  mkdir -pv $ZONEINFO/{posix,right}

  for tz in etcetera southamerica northamerica europe africa antarctica  \
            asia australasia backward; do
    zic -L /dev/null   -d $ZONEINFO       ${tz}
    zic -L /dev/null   -d $ZONEINFO/posix ${tz}
    zic -L leapseconds -d $ZONEINFO/right ${tz}
  done

  cp -v zone.tab zone1970.tab iso3166.tab $ZONEINFO
  zic -d $ZONEINFO -p America/New_York
  unset ZONEINFO

  tzselect

  ln -sfv /usr/share/zoneinfo/America/Argentina/Buenos_Aires /etc/localtime

cat > /etc/ld.so.conf << "EOF"
# Begin /etc/ld.so.conf
/usr/local/lib
/opt/lib
EOF

cat >> /etc/ld.so.conf << "EOF"
# Add an include directory
include /etc/ld.so.conf.d/*.conf
EOF

  mkdir -pv /etc/ld.so.conf.d

  final ${PKG_NAME}
}


#
# Build zlib
#
function zlib() {
  descomprimir "zlib" "zlib" 

  ./configure --prefix=/usr

  make ${J}
  make install 

  rm -fv /usr/lib/libz.a

  final ${PKG_NAME}
}


#
# Build bzip2
#
function bzip2() {
  descomprimir "bzip2" "bzip2" 

  patch -Np1 -i ${SRC_PATCH}/bzip2-1.0.8-install_docs-1.patch

  sed -i 's@\(ln -s -f \)$(PREFIX)/bin/@\1@' Makefile

  sed -i "s@(PREFIX)/man@(PREFIX)/share/man@g" Makefile

  make -f Makefile-libbz2_so
  make clean

  make ${J}
  make PREFIX=/usr install

  cp -av libbz2.so.* /usr/lib
  ln -sv libbz2.so.1.0.8 /usr/lib/libbz2.so

  cp -v bzip2-shared /usr/bin/bzip2
  for i in /usr/bin/{bzcat,bunzip2}; do
	    ln -sfv bzip2 $i
  done

  rm -fv /usr/lib/libbz2.a

  final ${PKG_NAME}
}


#
# Build xz
#
function xz() {
  descomprimir "xz" "xz" 

  ./configure --prefix=/usr    \
              --disable-static \
              --docdir=/usr/share/doc/xz-5.2.5

  make ${J}
  make install 

  final ${PKG_NAME}
}


#
# Build zstd
#
function zstd() {
  descomprimir "zstd" "zstd" 

  make ${J}
  make prefix=/usr install
  rm -v /usr/lib/libzstd.a

  final ${PKG_NAME}
}


#
# Build file
#
function file() {
  descomprimir "file" "file" 

  ./configure --prefix=/usr

  make ${J}
  make install 

  final ${PKG_NAME}
}


#
# Build readline
#
function readline() {
  descomprimir "readline" "readline" 

  sed -i '/MV.*old/d' Makefile.in
  sed -i '/{OLDSUFF}/c:' support/shlib-install

  ./configure --prefix=/usr    \
              --disable-static \
              --with-curses    \
              --docdir=/usr/share/doc/readline-8.1

  make SHLIB_LIBS="-lncursesw" ${J}
  make SHLIB_LIBS="-lncursesw" install

  install -v -m644 doc/*.{ps,pdf,html,dvi} /usr/share/doc/readline-8.1

  final ${PKG_NAME}
}


#
# Build m4
#
function m4() {
  descomprimir "m4" "m4" 

  ./configure --prefix=/usr

  make ${J}
  make install 

  final ${PKG_NAME}
}


#
# Build bc
#
function bc() {
  descomprimir "bc" "bc" 

  CC=gcc ./configure --prefix=/usr -G -O3

  make ${J}
  make install 

  final ${PKG_NAME}
}


#
# Build flex
#
function flex() {
  descomprimir "flex" "flex" 

  ./configure --prefix=/usr \
              --docdir=/usr/share/doc/flex-2.6.4 \
              --disable-static

  make ${J}
  make install 

  ln -sv flex /usr/bin/lex

  final ${PKG_NAME}
}


#
# Build tcl
#
function tcl() {
  cd ${SRC_FILES}
  PKG_NAME=tcl8.6.11-src.tar.gz
  PKG_DIR=$(echo ${SRC_FILES}/tcl8.6.11)

  echo -e "${grayColour}----------------------------------------------------------------${endColour}"
  echo -e "${grayColour}- Building : ${endColour}${yellowColour}tcl...${endColour}"

  tar xf ${SRC_SOURCES}/${PKG_NAME} || exit 1
  cd ${PKG_DIR}

  tar -xf ${SRC_SOURCES}/tcl8.6.11-html.tar.gz --strip-components=1

  SRCDIR=$(pwd)
  cd unix
  ./configure --prefix=/usr           \
              --mandir=/usr/share/man \
              $([ "$(uname -m)" = x86_64 ] && echo --enable-64bit)

  make ${J}

  sed -e "s|$SRCDIR/unix|/usr/lib|" \
      -e "s|$SRCDIR|/usr/include|"  \
      -i tclConfig.sh

  sed -e "s|$SRCDIR/unix/pkgs/tdbc1.1.2|/usr/lib/tdbc1.1.2|" \
      -e "s|$SRCDIR/pkgs/tdbc1.1.2/generic|/usr/include|"    \
      -e "s|$SRCDIR/pkgs/tdbc1.1.2/library|/usr/lib/tcl8.6|" \
      -e "s|$SRCDIR/pkgs/tdbc1.1.2|/usr/include|"            \
      -i pkgs/tdbc1.1.2/tdbcConfig.sh

  sed -e "s|$SRCDIR/unix/pkgs/itcl4.2.1|/usr/lib/itcl4.2.1|" \
      -e "s|$SRCDIR/pkgs/itcl4.2.1/generic|/usr/include|"    \
      -e "s|$SRCDIR/pkgs/itcl4.2.1|/usr/include|"            \
      -i pkgs/itcl4.2.1/itclConfig.sh

  unset SRCDIR

  make install 

  chmod -v u+w /usr/lib/libtcl8.6.so
  make install-private-headers
  ln -sfv tclsh8.6 /usr/bin/tclsh
  mv /usr/share/man/man3/{Thread,Tcl_Thread}.3

  final ${PKG_NAME}
}


#
# Build expect
#
function expect() {
  descomprimir "expect" "expect" 


  ./configure --prefix=/usr           \
              --with-tcl=/usr/lib     \
              --enable-shared         \
              --mandir=/usr/share/man \
              --with-tclinclude=/usr/include

  make ${J}
  make install 

  ln -svf expect5.45.4/libexpect5.45.4.so /usr/lib

  final ${PKG_NAME}
}


#
# Build dejagnu
#
function dejagnu() {
  descomprimir "dejagnu" "dejagnu" 

  mkdir -v build && cd build

  ../configure --prefix=/usr
  makeinfo --html --no-split -o doc/dejagnu.html ../doc/dejagnu.texi
  makeinfo --plaintext       -o doc/dejagnu.txt  ../doc/dejagnu.texi

  make install
  install -v -dm755  /usr/share/doc/dejagnu-1.6.3
  install -v -m644   doc/dejagnu.{html,txt} /usr/share/doc/dejagnu-1.6.3

  final ${PKG_NAME}
}


#
# Build binutils
#
function binutils() {
  descomprimir "binutils" "binutils" 

  expect -c "spawn ls"
  spawn ls
  patch -Np1 -i ${SRC_PATCH}binutils-2.37-upstream_fix-1.patch

  sed -i '63d' etc/texi2pod.pl
  find -name \*.1 -delete

  mkdir -v build && cd build 

  ../configure --prefix=/usr       \
               --enable-gold       \
               --enable-ld=default \
               --enable-plugins    \
               --enable-shared     \
               --disable-werror    \
               --enable-64-bit-bfd \
               --with-system-zlib

  make tooldir=/usr ${J} 
  make tooldir=/usr install -j1
  rm -fv /usr/lib/lib{bfd,ctf,ctf-nobfd,opcodes}.a

  final ${PKG_NAME}
}


#
# Build gmp
#
function gmp() {
  descomprimir "gmp" "gmp" 

  ./configure --prefix=/usr    \
              --enable-cxx     \
              --disable-static \
              --docdir=/usr/share/doc/gmp-6.2.1

  make ${J}
  make html ${J}

  make install
  make install-html

  final ${PKG_NAME}
}


#
# Build mpfr
#
function mpfr() {
  descomprimir "mpfr" "mpfr" 

  ./configure --prefix=/usr        \
              --disable-static     \
              --enable-thread-safe \
   	      --docdir=/usr/share/doc/mpfr-4.1.0


  make ${J}
  make html ${J}

  make install
  make install-html

  final ${PKG_NAME}
}


#
# Build mpc
#
function mpc() {
  descomprimir "mpc" "mpc" 

  ./configure --prefix=/usr    \
	      --disable-static \
	      --docdir=/usr/share/doc/mpc-1.2.1

  make ${J}
  make html ${J}

  make install
  make install-html

  final ${PKG_NAME}
}


#
# Build attr
#
function attr() {
  descomprimir "attr" "attr" 

  ./configure --prefix=/usr     \
              --disable-static  \
              --sysconfdir=/etc \
              --docdir=/usr/share/doc/attr-2.5.1

  make ${J}
  make install 

  final ${PKG_NAME}
}


#
# Build acl
#
function acl() {
  descomprimir "acl" "acl" 

  ./configure --prefix=/usr         \
              --disable-static      \
              --docdir=/usr/share/doc/acl-2.3.1

  make ${J}
  make install 

  final ${PKG_NAME}
}


#
# Build libcap
#
function libcap() {
  descomprimir "libcap" "libcap" 

  sed -i '/install -m.*STA/d' libcap/Makefile

  make prefix=/usr lib=lib ${J}

  make prefix=/usr lib=lib install

  chmod -v 755 /usr/lib/lib{cap,psx}.so.2.53

  final ${PKG_NAME}
}


#
# Build cracklib
#
function cracklib() {
  descomprimir "cracklib-2.9.7" "cracklib" 

  sed -i '/skipping/d' util/packer.c &&

  sed -i '15209 s/.*/am_cv_python_version=3.10/' configure &&

  PYTHON=python3 CPPFLAGS=-I/usr/include/python3.10 \
  ./configure --prefix=/usr    \
              --disable-static \
             --with-default-dict=/usr/lib/cracklib/pw_dict 


  make ${J}
  make install 

  install -v -m644 -D ${SRC_SOURCES}/cracklib-words-2.9.7.bz2 \
        /usr/share/dict/cracklib-words.bz2    &&

  bunzip2 -v               /usr/share/dict/cracklib-words.bz2    &&
  ln -v -sf cracklib-words /usr/share/dict/words                 &&
  echo $(hostname) >>      /usr/share/dict/cracklib-extra-words  &&
  install -v -m755 -d      /usr/lib/cracklib                     &&
  create-cracklib-dict     /usr/share/dict/cracklib-words \
                           /usr/share/dict/cracklib-extra-words

  final ${PKG_NAME}
}


#
# Build shadow
#
function shadow() {
  descomprimir "shadow" "shadow" 

  sed -i 's/groups$(EXEEXT) //' src/Makefile.in
  find man -name Makefile.in -exec sed -i 's/groups\.1 / /'   {} \;
  find man -name Makefile.in -exec sed -i 's/getspnam\.3 / /' {} \;
  find man -name Makefile.in -exec sed -i 's/passwd\.5 / /'   {} \;


  sed -e 's:#ENCRYPT_METHOD DES:ENCRYPT_METHOD SHA512:' \
      -e 's:/var/spool/mail:/var/mail:'                 \
      -e '/PATH=/{s@/sbin:@@;s@/bin:@@}'                \
      -i etc/login.defs

  # Para ser utilizado con cracklib
  sed -i 's:DICTPATH.*:DICTPATH\t/lib/cracklib/pw_dict:' etc/login.defs

  sed -e "224s/rounds/min_rounds/" -i libmisc/salt.c

  touch /usr/bin/passwd
  ./configure --sysconfdir=/etc \
              --with-group-name-max-length=32

  make ${J}

  make exec_prefix=/usr install
  make -C man install-man
  mkdir -p /etc/default
  useradd -D --gid 999

  pwconv
  grpconv

  > /var/log/faillog

  final ${PKG_NAME}
}


#
# Build gcc-final
#
function gcc-final() {
  descomprimir "gcc" "gcc" 

  sed -e '/static.*SIGSTKSZ/d' \
      -e 's/return kAltStackSize/return SIGSTKSZ * 4/' \
      -i libsanitizer/sanitizer_common/sanitizer_posix_libcdep.cpp

  case $(uname -m) in
    x86_64)
        sed -e '/m64=/s/lib64/lib/' \
            -i.orig gcc/config/i386/t-linux64
        ;;
  esac

  mkdir -v build && cd  build
  ../configure --prefix=/usr            \
               LD=ld                    \
               --enable-languages=c,c++ \
               --disable-multilib       \
               --disable-bootstrap      \
               --with-system-zlib

  make ${J}

  make install

  rm -rf /usr/lib/gcc/$(gcc -dumpmachine)/11.2.0/include-fixed/bits/

  chown -v -R root:root \
	      /usr/lib/gcc/*linux-gnu/11.2.0/include{,-fixed}
  ln -svr /usr/bin/cpp /usr/lib

  ln -sfv ../../libexec/gcc/$(gcc -dumpmachine)/11.2.0/liblto_plugin.so \
	          /usr/lib/bfd-plugins/

  mkdir -pv /usr/share/gdb/auto-load/usr/lib
  mv -v /usr/lib/*gdb.py /usr/share/gdb/auto-load/usr/lib

  final ${PKG_NAME}
}


#
# Build pkg-config
#
function pkg-config() {
  descomprimir "pkg-config" "pkg-config" 

  ./configure --prefix=/usr              \
              --with-internal-glib       \
              --disable-host-tool        \
              --docdir=/usr/share/doc/pkg-config-0.29.2

  make ${J}
  make install 

  final ${PKG_NAME}
}


#
# Build ncurses
#
function ncurses() {
  descomprimir "ncurses" "ncurses" 

  ./configure --prefix=/usr           \
              --mandir=/usr/share/man \
              --with-shared           \
              --without-debug         \
              --without-normal        \
              --enable-pc-files       \
              --enable-widec

  make ${J}
  make install 

  for lib in ncurses form panel menu ; do
      rm -vf /usr/lib/lib${lib}.so
      echo "INPUT(-l${lib}w)" > /usr/lib/lib${lib}.so
      ln -sfv ${lib}w.pc        /usr/lib/pkgconfig/${lib}.pc
  done

  rm -vf                     /usr/lib/libcursesw.so
  echo "INPUT(-lncursesw)" > /usr/lib/libcursesw.so
  ln -sfv libncurses.so      /usr/lib/libcurses.so

  rm -fv /usr/lib/libncurses++w.a

  mkdir -v       /usr/share/doc/ncurses-6.2
  cp -v -R doc/* /usr/share/doc/ncurses-6.2

  # Las instrucciones anteriores no crean bibliotecas Ncurses de caracteres que no sean anchos, 
  # ya que ningún paquete instalado compilando a partir de fuentes se vincularía con ellas en tiemp
  # o de ejecución. Sin embargo, las únicas aplicaciones conocidas solo binarias que se vinculan co
  # bibliotecas Ncurses de carácter no ancho requieren la versión 5
  # Si debe tener dichas bibliotecas debido a alguna aplicación solo binaria o para ser compatible
  # con LSB, compile el paquete nuevamente con lo siguiente comandos:
  make distclean
  ./configure --prefix=/usr    \
	      --with-shared    \
	      --without-normal \
	      --without-debug  \
	      --without-cxx-binding \
	      --with-abi-version=5 

  make sources libs ${J}
  cp -av lib/lib*.so.5* /usr/lib

  final ${PKG_NAME}
}


#
# Build sed-final
#
function sed-final() {
  descomprimir "sed" "sed" 

  ./configure --prefix=/usr

  make ${J}
  make html ${J}

  install -d -m755           /usr/share/doc/sed-4.8
  install -m644 doc/sed.html /usr/share/doc/sed-4.8

  final ${PKG_NAME}
}


#
# Build psmisc
#
function psmisc() {
  descomprimir "psmisc" "psmisc" 

  ./configure --prefix=/usr

  make ${J}
  make install 

  final ${PKG_NAME}
}


#
# Build gettext
#
function gettext() {
  descomprimir "gettext" "gettext" 

  ./configure --prefix=/usr    \
	      --disable-static \
	      --docdir=/usr/share/doc/gettext-0.21

  make ${J}
  make install 

  chmod -v 0755 /usr/lib/preloadable_libintl.so

  final ${PKG_NAME}
}


#
# Build bison
#
function bison() {
  descomprimir "bison" "bison" 


  ./configure --prefix=/usr --docdir=/usr/share/doc/bison-3.7.6

  make ${J}
  make install 

  final ${PKG_NAME}
}


#
# Build grep-final
#
function grep-final() {
  descomprimir "grep" "grep" 

  ./configure --prefix=/usr

  make ${J}
  make install 

  final ${PKG_NAME}
}


#
# Build bash-final
#
function bash-final() {
  descomprimir "bash" "bash" 

  ./configure --prefix=/usr                      \
              --docdir=/usr/share/doc/bash-5.1.8 \
              --without-bash-malloc              \
              --with-installed-readline

  make ${J}
  make install 

  final ${PKG_NAME}
}


#
# Build libtool
#
function libtool() {
  descomprimir "libtool" "libtool" 

  ./configure --prefix=/usr

  make ${J}
  make install 

  rm -fv /usr/lib/libltdl.a

  final ${PKG_NAME}
}


#
# Build gdbm
#
function gdbm() {
  descomprimir "gdbm" "gdbm" 

  ./configure --prefix=/usr    \
	      --disable-static \
	      --enable-libgdbm-compat

  make ${J}
  make install 

  final ${PKG_NAME}
}


#
# Build gperf
#
function gperf() {
  descomprimir "gperf" "gperf" 

  ./configure --prefix=/usr --docdir=/usr/share/doc/gperf-3.1

  make ${J}
  make install 

  final ${PKG_NAME}
}


#
# Build expat
#
function expat() {
  descomprimir "expat" "expat" 

  ./configure --prefix=/usr    \
              --disable-static \
              --docdir=/usr/share/doc/expat-2.4.1

  make ${J}
  make install 

  install -v -m644 doc/*.{html,png,css} /usr/share/doc/expat-2.4.1

  final ${PKG_NAME}
}


#
# Build inetutils
#
function inetutils() {
  descomprimir "inetutils" "inetutils" 

  ./configure --prefix=/usr        \
	      --bindir=/usr/bin    \
	      --localstatedir=/var \
	      --disable-logger     \
	      --disable-whois      \
	      --disable-rcp        \
	      --disable-rexec      \
	      --disable-rlogin     \
	      --disable-rsh        \
	      --disable-servers

  make ${J}
  make install 

  mv -v /usr/{,s}bin/ifconfig

  final ${PKG_NAME}
}


#
# Build less-final
#
function less-final() {
  descomprimir "less" "less" 

  ./configure --prefix=/usr --sysconfdir=/etc

  make ${J}
  make install 

  final ${PKG_NAME}
}


#
# Build perl-final
#
function perl-final() {
  descomprimir "perl" "perl" 

  patch -Np1 -i ${SRC_PATH}/perl-5.34.0-upstream_fixes-1.patch

  export BUILD_ZLIB=False
  export BUILD_BZIP2=0

  sh Configure -des                                         \
               -Dprefix=/usr                                \
               -Dvendorprefix=/usr                          \
               -Dprivlib=/usr/lib/perl5/5.34/core_perl      \
               -Darchlib=/usr/lib/perl5/5.34/core_perl      \
               -Dsitelib=/usr/lib/perl5/5.34/site_perl      \
               -Dsitearch=/usr/lib/perl5/5.34/site_perl     \
               -Dvendorlib=/usr/lib/perl5/5.34/vendor_perl  \
               -Dvendorarch=/usr/lib/perl5/5.34/vendor_perl \
               -Dman1dir=/usr/share/man/man1                \
               -Dman3dir=/usr/share/man/man3                \
               -Dpager="/usr/bin/less -isR"                 \
               -Duseshrplib                                 \
               -Dusethreads

  make ${J}
  make install 

  unset BUILD_ZLIB BUILD_BZIP2

  final ${PKG_NAME}
}


#
# Build xml-parser
#
function xml-parser() {
  descomprimir "XML-Parser" "XML-Parser" 

  perl Makefile.PL

  make ${J}
  make install 

  final ${PKG_NAME}
}


#
# Build intltool
#
function intltool() {
  descomprimir "intltool" "intltool" 

  sed -i 's:\\\${:\\\$\\{:' intltool-update.in

  ./configure --prefix=/usr

  make ${J}
  make install 

  install -v -Dm644 doc/I18N-HOWTO /usr/share/doc/intltool-0.51.0/I18N-HOWTO

  final ${PKG_NAME}
}


#
# Build autoconf
#
function autoconf() {
  descomprimir "autoconf" "autoconf" 

  ./configure --prefix=/usr

  make ${J}
  make install 

  final ${PKG_NAME}
}


#
# Build automake
#
function automake() {
  descomprimir "automake" "automake" 

  ./configure --prefix=/usr --docdir=/usr/share/doc/automake-1.16.4

  make ${J}
  make install 

  final ${PKG_NAME}
}


#
# Build kmod
#
function kmod() {
  descomprimir "kmod" "kmod" 

  ./configure --prefix=/usr          \
              --sysconfdir=/etc      \
              --with-xz              \
              --with-zstd            \
              --with-zlib

  make ${J}
  make install 


  for target in depmod insmod modinfo modprobe rmmod; do
    ln -sfv ../bin/kmod /usr/sbin/$target
  done

  ln -sfv kmod /usr/bin/lsmod

  final ${PKG_NAME}
}


#
# Build elfutils
#
function elfutils() {
  descomprimir "elfutils" "elfutils" 

  ./configure --prefix=/usr                \
	      --disable-debuginfod         \
	      --enable-libdebuginfod=dummy


  make ${J}

  make -C libelf install
  install -vm644 config/libelf.pc /usr/lib/pkgconfig
  rm /usr/lib/libelf.a

  final ${PKG_NAME}
}


#
# Build libffi
#
function libffi() {
  descomprimir "libffi" "libffi" 

  ./configure --prefix=/usr          \
	      --disable-static       \
	      --with-gcc-arch=native \
	      --disable-exec-static-tramp

  make ${J}
  make install 

  final ${PKG_NAME}
}


#
# Build openssl
#
function openssl() {
  descomprimir "openssl" "openssl" 

  ./config --prefix=/usr         \
	   --openssldir=/etc/ssl \
	   --libdir=lib          \
	   shared                \
	   zlib-dynamic

  make ${J}

  sed -i '/INSTALL_LIBS/s/libcrypto.a libssl.a//' Makefile
  make MANSUFFIX=ssl install
  mv -v /usr/share/doc/openssl /usr/share/doc/openssl-1.1.1l
  cp -vfr doc/* /usr/share/doc/openssl-1.1.1l

  final ${PKG_NAME}
}


#
# Build python-final
#
function python-final() {
  descomprimir "Python" "Python" 

  ./configure --prefix=/usr        \
              --enable-shared      \
              --with-system-expat  \
              --with-system-ffi    \
              --with-ensurepip=yes \
              --enable-optimizations

  make ${J}
  make install 

  install -v -dm755 /usr/share/doc/python-3.9.6/html 

  tar --strip-components=1  \
      --no-same-owner       \
      --no-same-permissions \
      -C /usr/share/doc/python-3.9.6/html \
      -xvf ${SRC_SOURCES}/python-3.9.6-docs-html.tar.bz2

  final ${PKG_NAME}
}


#
# Build ninja
#
function ninja() {
  descomprimir "ninja" "ninja" 

  export NINJAJOBS=4
  sed -i '/int Guess/a \
	   int   j = 0;\
	   char* jobs = getenv( "NINJAJOBS" );\
	   if ( jobs != NULL ) j = atoi( jobs );\
	   if ( j > 0 ) return j;\
  ' src/ninja.cc

  python3 configure.py --bootstrap
  install -vm755 ninja /usr/bin/
  install -vDm644 misc/bash-completion /usr/share/bash-completion/completions/ninja
  install -vDm644 misc/zsh-completion  /usr/share/zsh/site-functions/_ninja

  final ${PKG_NAME}
}


#
# Build meson
#
function meson() {
  descomprimir "meson" "meson" 

  python3 setup.py build

  python3 setup.py install --root=dest
  cp -rv dest/* /
  install -vDm644 data/shell-completions/bash/meson /usr/share/bash-completion/completions/meson
  install -vDm644 data/shell-completions/zsh/_meson /usr/share/zsh/site-functions/_meson

  final ${PKG_NAME}
}


#
# Build coreutils
#
function coreutils() {
  descomprimir "coreutils" "coreutils" 

  patch -Np1 -i ${SRC_PATH}/coreutils-8.32-i18n-1.patch

  autoreconf -fiv
  FORCE_UNSAFE_CONFIGURE=1 ./configure \
     --prefix=/usr            \
     --enable-no-install-program=kill,uptime

  make ${J}
  make NON_ROOT_USERNAME=tester check-root
  make install 

  mv -v /usr/bin/chroot /usr/sbin
  mv -v /usr/share/man/man1/chroot.1 /usr/share/man/man8/chroot.8
  sed -i 's/"1"/"8"/' /usr/share/man/man8/chroot.8

  final ${PKG_NAME}
}


#
# Build check
#
function check() {
  descomprimir "check" "check" 

  ./configure --prefix=/usr --disable-static

  make ${J}
  make docdir=/usr/share/doc/check-0.15.2 install

  final ${PKG_NAME}
}


#
# Build diffutils
#
function diffutils() {
  descomprimir "diffutils" "diffutils" 

  ./configure --prefix=/usr

  make ${J}
  make install 

  final ${PKG_NAME}
}


#
# Build gawk
#
function gawk() {
  descomprimir "gawk" "gawk" 

  sed -i 's/extras//' Makefile.in
  ./configure --prefix=/usr

  make ${J}
  make install 

  final ${PKG_NAME}
}


#
# Build findutils
#
function findutils() {
  descomprimir "findutils" "findutils" 

  ./configure --prefix=/usr --localstatedir=/var/lib/locate

  make ${J}

  chown -Rv tester .
  su tester -c "PATH=$PATH make check"

  make install 

  final ${PKG_NAME}
}


#
# Build groff
#
function groff() {
  descomprimir "groff" "groff" 

  PAGE=A4 ./configure --prefix=/usr

  make ${J}
  make install 

  final ${PKG_NAME}
}


#
# Build grub
#
function grub() {
  descomprimir "grub" "grub" 

  ./configure --prefix=/usr          \
              --sysconfdir=/etc      \
              --disable-efiemu       \
              --disable-werror

  make ${J}
  make install 
  mv -v /etc/bash_completion.d/grub /usr/share/bash-completion/completions

  final ${PKG_NAME}
}


#
# Build gzip
#
function gzip() {
  descomprimir "gzip" "gzip" 

  ./configure --prefix=/usr

  make ${J}
  make install 

  final ${PKG_NAME}
}


#
# Build iproute2
#
function iproute2() {
  descomprimir "iproute2" "iproute2" 

  sed -i /ARPD/d Makefile
  rm -fv man/man8/arpd.8

  sed -i 's/.m_ipt.o//' tc/Makefile

  make ${J}

  make SBINDIR=/usr/sbin install

  mkdir -v              /usr/share/doc/iproute2-5.13.0
  cp -v COPYING README* /usr/share/doc/iproute2-5.13.0

  final ${PKG_NAME}
}


#
# Build kbd
#
function kbd() {
  descomprimir "kbd" "kbd" 

  patch -Np1 -i ${SRC_PATH}/kbd-2.4.0-backspace-1.patch

  sed -i '/RESIZECONS_PROGS=/s/yes/no/' configure
  sed -i 's/resizecons.8 //' docs/man/man8/Makefile.in

  ./configure --prefix=/usr --disable-vlock

  make ${J}
  make install 

  mkdir -v            /usr/share/doc/kbd-2.4.0
  cp -R -v docs/doc/* /usr/share/doc/kbd-2.4.0

  final ${PKG_NAME}
}


#
# Build libpipeline
#
function libpipeline() {
  descomprimir "libpipeline" "libpipeline" 
  
  ./configure --prefix=/usr

  make ${J}
  make install

  final ${PKG_NAME}
}


#
# Build make-final
#
function make-final() {
  descomprimir "make" "make" 

  ./configure --prefix=/usr

  make ${J}
  make install 

  final ${PKG_NAME}
}


#
# Build patch
#
function patch-final() {
  descomprimir "patch" "patch" 

  ./configure --prefix=/usr

  make ${J}
  make install 

  final ${PKG_NAME}
}


#
# Build tar-final
#
function tar-final() {
  descomprimir "tar" "tar" 

  FORCE_UNSAFE_CONFIGURE=1  \
  ./configure --prefix=/usr

  make ${J}
  make install 
  make -C doc install-html docdir=/usr/share/doc/tar-1.34

  final ${PKG_NAME}
}


#
# Build texinfo
#
function texinfo() {
  descomprimir "texinfo" "texinfo" 

  ./configure --prefix=/usr
  sed -e 's/__attribute_nonnull__/__nonnull/' \
      -i gnulib/lib/malloc/dynarray-skeleton.c

  make ${J}
  make install 

  make TEXMF=/usr/share/texmf install-tex

  final ${PKG_NAME}
}


#
# Build vim-final
#
function vim-final() {
  descomprimir "vim" "vim" 

  echo '#define SYS_VIMRC_FILE "/etc/vimrc"' >> src/feature.h
  ./configure --prefix=/usr

  make ${J}
  make install 

  ln -sv vim /usr/bin/vi
  for L in  /usr/share/man/{,*/}man1/vim.1; do
      ln -sv vim.1 $(dirname $L)/vi.1
  done

  ln -sv ../vim/vim82/doc /usr/share/doc/vim-8.2.3337

  # Configuracion
cat > /etc/vimrc << "EOF"
" Begin /etc/vimrc

" Ensure defaults are set before customizing settings, not after
source $VIMRUNTIME/defaults.vim
let skip_defaults_vim=1 

set nocompatible
set backspace=2
set mouse=
syntax on
if (&term == "xterm") || (&term == "putty")
	  set background=dark
  endif

  " End /etc/vimrc
EOF

  final ${PKG_NAME}
}


#
# Build eudev
#
function eudev() {
  descomprimir "eudev" "eudev" 

  ./configure --prefix=/usr           \
              --bindir=/usr/sbin      \
              --sysconfdir=/etc       \
              --enable-manpages       \
              --disable-static

  make ${J}
  mkdir -pv /usr/lib/udev/rules.d
  mkdir -pv /etc/udev/rules.d
  make install 

  tar -xvf ../udev-lfs-20171102.tar.xz
  make -f udev-lfs-20171102/Makefile.lfs install

  udevadm hwdb --update

  final ${PKG_NAME}
}


#
# Build man-db
#
function man-db() {
  descomprimir "man-db" "man-db" 



  ./configure --prefix=/usr                        \
              --docdir=/usr/share/doc/man-db-2.9.4 \
              --sysconfdir=/etc                    \
              --disable-setuid                     \
              --enable-cache-owner=bin             \
              --with-browser=/usr/bin/lynx         \
              --with-vgrind=/usr/bin/vgrind        \
              --with-grap=/usr/bin/grap            \
              --with-systemdtmpfilesdir=           \
              --with-systemdsystemunitdir=


  make ${J}
  make install 

  final ${PKG_NAME}
}


#
# Build procps-ng
#
function procps-ng() {
  cd ${SRC_FILES}
  PKG_NAME="procps-ng"
  PKG_NAME2="procps-"
  PKG_DIR=$(echo ${SRC_FILES}/${PKG_NAME2}*)

  inicio "procps-ng"

  tar xf ${SRC_SOURCES}/${PKG_NAME}* || exit 1
  cd ${PKG_DIR}

  ./configure --prefix=/usr                            \
	      --docdir=/usr/share/doc/procps-ng-3.3.17 \
	      --disable-static                         \
	      --disable-kill

  make ${J}
  make install 

  final ${PKG_NAME2}
}


#
# Build util-linux
#
function util-linux() {
  descomprimir "util-linux" "util-linux" 

  ./configure ADJTIME_PATH=/var/lib/hwclock/adjtime   \
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
        --without-systemd    \
        --without-systemdsystemunitdir \
        runstatedir=/run

  make ${J}
  make install 

  final ${PKG_NAME}
}


#
# Build e2fsprogs
#
function e2fsprogs() {
  descomprimir "e2fsprogs" "e2fsprogs" 

  mkdir -v build
  cd       build
  ../configure --prefix=/usr           \
               --sysconfdir=/etc       \
               --enable-elf-shlibs     \
               --disable-libblkid      \
               --disable-libuuid       \
               --disable-uuidd         \
               --disable-fsck

  make ${J}
  make install 

  rm -fv /usr/lib/{libcom_err,libe2p,libext2fs,libss}.a
  gunzip -v /usr/share/info/libext2fs.info.gz
  install-info --dir-file=/usr/share/info/dir /usr/share/info/libext2fs.info
  makeinfo -o      doc/com_err.info ../lib/et/com_err.texinfo
  install -v -m644 doc/com_err.info /usr/share/info
  install-info --dir-file=/usr/share/info/dir /usr/share/info/com_err.info

  final ${PKG_NAME}
}


#
# Build sysklogd
#
function sysklogd() {
  descomprimir "sysklogd" "sysklogd" 

  sed -i '/Error loading kernel symbols/{n;n;d}' ksym_mod.c
  sed -i 's/union wait/int/' syslogd.c

  make ${J}
  make BINDIR=/sbin install

cat > /etc/syslog.conf << "EOF"
# Begin /etc/syslog.conf

auth,authpriv.* -/var/log/auth.log
*.*;auth,authpriv.none -/var/log/sys.log
daemon.* -/var/log/daemon.log
kern.* -/var/log/kern.log
mail.* -/var/log/mail.log
user.* -/var/log/user.log
*.emerg *

# End /etc/syslog.conf
EOF

  final ${PKG_NAME}
}


#
# Build sysvinit-final
#
function sysvinit-final() {
  descomprimir "sysvinit" "sysvinit" 

  patch -Np1 -i ${SRC_PATH}/sysvinit-2.99-consolidated-1.patch

  make ${J}
  make install 

  final ${PKG_NAME}
}

#
# stripping
# 
function stripping() {
  save_usrlib="$(cd /usr/lib; ls ld-linux*)
             libc.so.6
             libthread_db.so.1
             libquadmath.so.0.0.0 
             libstdc++.so.6.0.29
             libitm.so.1.0.0 
             libatomic.so.1.2.0"
   cd /usr/lib
   for LIB in $save_usrlib; do
      objcopy --only-keep-debug $LIB $LIB.dbg
      cp $LIB /tmp/$LIB
      strip --strip-unneeded /tmp/$LIB
      objcopy --add-gnu-debuglink=$LIB.dbg /tmp/$LIB
      install -vm755 /tmp/$LIB /usr/lib
      rm /tmp/$LIB
   done

   online_usrbin="bash find strip"
   online_usrlib="libbfd-2.37.so
          libhistory.so.8.1
          libncursesw.so.6.2
          libm.so.6
          libreadline.so.8.1
          libz.so.1.2.11
          $(cd /usr/lib; find libnss*.so* -type f)"

    for BIN in $online_usrbin; do
       cp /usr/bin/$BIN /tmp/$BIN
       strip --strip-unneeded /tmp/$BIN
       install -vm755 /tmp/$BIN /usr/bin
       rm /tmp/$BIN
    done

    for LIB in $online_usrlib; do
       cp /usr/lib/$LIB /tmp/$LIB
       strip --strip-unneeded /tmp/$LIB
       install -vm755 /tmp/$LIB /usr/lib
       rm /tmp/$LIB
    done

    for i in $(find /usr/lib -type f -name \*.so* ! -name \*dbg) \
       $(find /usr/lib -type f -name \*.a)                 \
       $(find /usr/{bin,sbin,libexec} -type f); do
       case "$online_usrbin $online_usrlib $save_usrlib" in
          *$(basename $i)* ) 
             ;;
          * ) strip --strip-unneeded $i 
             ;;
       esac
     done

   unset BIN LIB save_usrlib online_usrbin online_usrlib
}


#
# Limpieza
#
function limpieza() {
   rm -rv /sources
   find /usr/lib /usr/libexec -name \*.la -delete
   find /usr -depth -name $(uname -m)-lfs-linux-gnu\* | xargs rm -rf
   rm -rf /tmp/*
}


#
# Backup
#
function backup(){
   cd ${BACKUP}
   tar cvfj 04-backup-lfs-package-$(date +"%m-%d-%y").tar.bz2 ${LFS}
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
   man-pages
   sleep 1
   iana-etc
   sleep 1
   glibc
   sleep 1
   zlib
   sleep 1
   bzip2
   sleep 1
   xz
   sleep 1
   zstd
   sleep 1
   file
   sleep 1
   readline
   sleep 1
   m4
   sleep 1
   bc
   sleep 1
   flex
   sleep 1
   tcl
   sleep 1
   expect
   sleep 1
   dejagnu
   sleep 1
   binutils
   sleep 1
   gmp
   sleep 1
   mpfr
   sleep 1
   mpc
   sleep 1
   attr
   sleep 1
   acl
   sleep 1
   libcap
   sleep 1
   cracklib
   sleep 1
   shadow
   sleep 1
   gcc-final
   sleep 1
   pkg-config
   sleep 1
   ncurses
   sleep 1
   sed-final
   sleep 1
   psmisc
   sleep 1
   gettext
   sleep 1
   bison
   sleep 1
   grep-final
   sleep 1
   bash-final
   sleep 1
   libtool
   sleep 1
   gdbm
   sleep 1
   gperf
   sleep 1
   expat
   sleep 1
   inetutils
   sleep 1
   less-final
   sleep 1
   perl-final
   sleep 1
   xml-parser
   sleep 1
   intltool
   sleep 1
   autoconf
   sleep 1
   automake
   sleep 1
   kmod
   sleep 1
   elfutils
   sleep 1
   libffi
   sleep 1
   openssl
   sleep 1
   python-final
   sleep 1
   ninja
   sleep 1
   meson
   sleep 1
   coreutils
   sleep 1
   check
   sleep 1
   diffutils
   sleep 1
   gawk
   sleep 1
   findutils
   sleep 1
   groff
   sleep 1
   grub
   sleep 1
   gzip
   sleep 1
   iproute2
   sleep 1
   kbd
   sleep 1
   libpipeline
   sleep 1
   make-final
   sleep 1
   patch-final
   sleep 1
   tar-final
   sleep 1
   texinfo
   sleep 1
   vim-final
   sleep 1
   eudev
   sleep 1
   man-db
   sleep 1
   procps-ng
   sleep 1
   util-linux
   sleep 1
   e2fsprogs
   sleep 1
   sysklogd
   sleep 1
   sysvinit-final
   sleep 1
   stripping
   sleep 1
   limpieza
   sleep 1
   desmontaje
   sleep 1
   backup
}

# Menu principal
if [ $# -eq 0 ]; then
	  ayuda
elif [ $# -eq 1 ]; then
   case ${1} in
       p0)   man-pages
	     ;;
       p1)   iana-etc
	     ;;
       p2)   glibc
	     ;;
       p3)   zlib
	     ;;
       p4)   bzip2
	     ;;
       p5)   xz
	     ;;
       p6)   zstd
	     ;;
       p7)   file
	     ;;
       p8)   readline
	     ;;
       p9)   m4
	     ;;
       p10)  bc
	     ;;
       p11)  flex
	     ;;
       p12)  tcl
	     ;;
       p13)  expect
	     ;;
       p14)  dejagnu
	     ;;
       p15)  binutils
	     ;;
       p16)  gmp
	     ;;
       p17)  mpfr
	     ;;
       p18)  mpc
	     ;;
       p19)  attr
	     ;;
       p20)  acl
	     ;;
       p21)  libcap
	     ;;
       p22)  cracklib
	     ;;
       p23)  shadow
	     ;;
       p24)  gcc-final
	     ;;
       p25)  pkg-config
	     ;;
       p26)  ncurses
	     ;;
       p27)  sed-final
	     ;;
       p28)  psmisc
	     ;;
       p29)  gettext
	     ;;
       p30)  bison
	     ;;
       p31)  grep-final
	     ;;
       p32)  bash-final
	     ;;
       p33)  libtool
	     ;;
       p34)  gdbm
	     ;;
       p35)  gperf
	     ;;
       p36)  expat
	     ;;
       p37)  inetutils
	     ;;
       p38)  less-final
	     ;;
       p39)  perl-final
	     ;;
       p40)  xml-parser
	     ;;
       p41)  intltool
	     ;;
       p42)  autoconf
	     ;;
       p43)  automake
	     ;;
       p44)  kmod
	     ;;
       p45)  elfutils
	     ;;
       p46)  libffi
	     ;;
       p47)  openssl
	     ;;
       p48)  python-final
	     ;;
       p49)  ninja
	     ;;
       p50)  meson
	     ;;
       p51)  coreutils
	     ;;
       p52)  check
	     ;;
       p53)  diffutils
	     ;;
       p54)  gawk
	     ;;
       p55)  findutils
	     ;;
       p56)  groff
	     ;;
       p57)  grub
	     ;;
       p58)  gzip
	     ;;
       p59)  iproute2
	     ;;
       p60)  kbd
	     ;;
       p61)  libpipeline
	     ;;
       p62)  make-final
	     ;;
       p63)  patch-final
	     ;;
       p64)  tar-final
	     ;;
       p65)  texinfo
	     ;;
       p66)  vim-final
	     ;;
       p67)  eudev
	     ;;
       p68)  man-db
	     ;;
       p69)  procps-ng
	     ;;
       p70)  util-linux
	     ;;
       p71)  e2fsprogs
	     ;;
       p72)  sysklogd
	     ;;
       p73)  sysvinit-final
	     ;;
       p74)  stripping
	     ;;
       p75)  limpieza
	     ;;
       p76)  desmontaje
	     ;;
       p77)  backup
	     ;;
       all)  all
	     ;;
	*)   ayuda
             ;;
   esac
fi
