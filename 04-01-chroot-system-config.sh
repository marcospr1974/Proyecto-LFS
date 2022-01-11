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
   echo -e "\n\n\t${grayColour}[p0]${endColour}${yellowColour}  Instalar lfs-bootscripts${endColour}"
   echo -e "\t${grayColour}[p1]${endColour}${yellowColour}  Creando udev rules${endColour}"
   echo -e "\t${grayColour}[p2]${endColour}${yellowColour}  Creando red${endColour}"
   echo -e "\t${grayColour}[p3]${endColour}${yellowColour}  Systemv${endColour}"
   echo -e "\t${grayColour}[p4]${endColour}${yellowColour}  Bash-Config${endColour}"
   echo -e "\t${grayColour}[p5]${endColour}${yellowColour}  inputrc-config${endColour}"
   echo -e "\t${grayColour}[p6]${endColour}${yellowColour}  shells-config${endColour}"
   echo -e "\t${grayColour}[p7]${endColour}${yellowColour}  Realizar limpieza${endColour}"
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
# Build lfs-bootscripts
#
function lfs-bootscripts() {
  descomprimir "lfs-bootscripts" "lfs-bootscripts" 

  make install

  final ${PKG_NAME}
}


#
# Build udev-ruler
#
function udev-ruler() {
  echo -e "${grayColour}----------------------------------------------------------------${endColour}"
  echo -e "${grayColour}- Building : ${endColour}${yellowColour}${1}...${endColour}"

  chmod +x /usr/lib/udev/init-net-rules.sh
  /usr/lib/udev/init-net-rules.sh
  cat /etc/udev/rules.d/70-persistent-net.rules
  sed -e 's/"write_cd_rules"/"write_cd_rules mode"/' \
	      -i /etc/udev/rules.d/83-cdrom-symlinks.rules

cat > /etc/udev/rules.d/83-duplicate_devs.rules << "EOF"

# Persistent symlinks for webcam and tuner
KERNEL=="video*", ATTRS{idProduct}=="1910", ATTRS{idVendor}=="0d81", SYMLINK+="webcam"
KERNEL=="video*", ATTRS{device}=="0x036f",  ATTRS{vendor}=="0x109e", SYMLINK+="tvtuner"

EOF
}

#
# Build red
#
function red() {
  echo -e "${grayColour}----------------------------------------------------------------${endColour}"
  echo -e "${grayColour}- Building : ${endColour}${yellowColour}red...${endColour}"

  cd /etc/sysconfig/
cat > ifconfig.eth0 << "EOF"
ONBOOT=yes
IFACE=eth0
SERVICE=ipv4-static
IP=192.168.1.6
GATEWAY=192.168.1.1
PREFIX=24
BROADCAST=192.168.1.255
EOF

cat > /etc/resolv.conf << "EOF"
# Begin /etc/resolv.conf

#domain <Your Domain Name>
nameserver 192.168.1.1
#nameserver <IP address of your primary nameserver>
#nameserver <IP address of your secondary nameserver>

# End /etc/resolv.conf
EOF

echo "<lfs>" > /etc/hostname

cat > /etc/hosts << "EOF"
# Begin /etc/hosts

127.0.0.1 localhost.localdomain localhost
#127.0.1.1 <FQDN> <HOSTNAME>
#<192.168.1.1> <FQDN> <HOSTNAME> [alias1] [alias2 ...]
::1       localhost ip6-localhost ip6-loopback
ff02::1   ip6-allnodes
ff02::2   ip6-allrouters

# End /etc/hosts
EOF
}


#
# Build systemv
#
function systemv() {
  echo -e "${grayColour}----------------------------------------------------------------${endColour}"
  echo -e "${grayColour}- Building : ${endColour}${yellowColour}systemv...${endColour}"

  cat > /etc/inittab << "EOF"
# Begin /etc/inittab

id:3:initdefault:

si::sysinit:/etc/rc.d/init.d/rc S

l0:0:wait:/etc/rc.d/init.d/rc 0
l1:S1:wait:/etc/rc.d/init.d/rc 1
l2:2:wait:/etc/rc.d/init.d/rc 2
l3:3:wait:/etc/rc.d/init.d/rc 3
l4:4:wait:/etc/rc.d/init.d/rc 4
l5:5:wait:/etc/rc.d/init.d/rc 5
l6:6:wait:/etc/rc.d/init.d/rc 6

ca:12345:ctrlaltdel:/sbin/shutdown -t1 -a -r now

su:S016:once:/sbin/sulogin

1:2345:respawn:/sbin/agetty --noclear tty1 9600
2:2345:respawn:/sbin/agetty tty2 9600
3:2345:respawn:/sbin/agetty tty3 9600
4:2345:respawn:/sbin/agetty tty4 9600
5:2345:respawn:/sbin/agetty tty5 9600
6:2345:respawn:/sbin/agetty tty6 9600

# End /etc/inittab
EOF

cat > /etc/sysconfig/clock << "EOF"
# Begin /etc/sysconfig/clock

UTC=1

# Set this to any options you might need to give to hwclock,
# such as machine hardware clock type for Alphas.
CLOCKPARAMS=

# End /etc/sysconfig/clock
EOF

cat > /etc/sysconfig/console << "EOF"
# Begin /etc/sysconfig/console

UNICODE="1"
KEYMAP="es"
KEYMAP_CORRECTIONS="euro2"
LEGACY_CHARSET="iso-8859-1"
FONT="lat0-16 -m 8859-15"

# End /etc/sysconfig/console
EOF

cat > /etc/sysconfig/rc.site << "EOF"
# rc.site
# Optional parameters for boot scripts.

# Distro Information
# These values, if specified here, override the defaults
#DISTRO="Linux From Scratch" # The distro name
#DISTRO_CONTACT="lfs-dev@linuxfromscratch.org" # Bug report address
#DISTRO_MINI="LFS" # Short name used in filenames for distro config

# Define custom colors used in messages printed to the screen

# Please consult `man console_codes` for more information
# under the "ECMA-48 Set Graphics Rendition" section
#
# Warning: when switching from a 8bit to a 9bit font,
# the linux console will reinterpret the bold (1;) to
# the top 256 glyphs of the 9bit font.  This does
# not affect framebuffer consoles

# These values, if specified here, override the defaults
#BRACKET="\\033[1;34m" # Blue
#FAILURE="\\033[1;31m" # Red
#INFO="\\033[1;36m"    # Cyan
#NORMAL="\\033[0;39m"  # Grey
#SUCCESS="\\033[1;32m" # Green
#WARNING="\\033[1;33m" # Yellow

# Use a colored prefix
# These values, if specified here, override the defaults
#BMPREFIX="      "
#SUCCESS_PREFIX="${SUCCESS}  *  ${NORMAL} "
#FAILURE_PREFIX="${FAILURE}*****${NORMAL} "
#WARNING_PREFIX="${WARNING} *** ${NORMAL} "

# Manually seet the right edge of message output (characters)
# Useful when resetting console font during boot to override
# automatic screen width detection
#COLUMNS=120

# Interactive startup
#IPROMPT="yes" # Whether to display the interactive boot prompt
#itime="3"    # The amount of time (in seconds) to display the prompt

# The total length of the distro welcome string, without escape codes
#wlen=$(echo "Welcome to ${DISTRO}" | wc -c )
#welcome_message="Welcome to ${INFO}${DISTRO}${NORMAL}"

# The total length of the interactive string, without escape codes
#ilen=$(echo "Press 'I' to enter interactive startup" | wc -c )
#i_message="Press '${FAILURE}I${NORMAL}' to enter interactive startup"

# Set scripts to skip the file system check on reboot
#FASTBOOT=yes

# Skip reading from the console
#HEADLESS=yes

# Write out fsck progress if yes
#VERBOSE_FSCK=no

# Speed up boot without waiting for settle in udev
#OMIT_UDEV_SETTLE=y

# Speed up boot without waiting for settle in udev_retry
#OMIT_UDEV_RETRY_SETTLE=yes

# Skip cleaning /tmp if yes
#SKIPTMPCLEAN=no

# For setclock
#UTC=1
#CLOCKPARAMS=

# For consolelog (Note that the default, 7=debug, is noisy)
#LOGLEVEL=7

# For network
#HOSTNAME=mylfs

# Delay between TERM and KILL signals at shutdown
#KILLDELAY=3

# Optional sysklogd parameters
#SYSKLOGD_PARMS="-m 0"

# Console parameters
#UNICODE=1
#KEYMAP="de-latin1"
#KEYMAP_CORRECTIONS="euro2"
#FONT="lat0-16 -m 8859-15"
#LEGACY_CHARSET=
EOF
}


#
# bash-config
#
function bash-config() {
  echo -e "${grayColour}----------------------------------------------------------------${endColour}"
  echo -e "${grayColour}- Building : ${endColour}${yellowColour}bash-config...${endColour}"

locale -a

cat > /etc/profile << "EOF"
# Begin /etc/profile

#export LANG=<ll>_<CC>.<charmap><@modifiers>
export LANG="es_ES.UTF-8"
TZ='America/Argentina/Buenos_Aires'; export TZ
export LC_ALL=POSIX

# End /etc/profile
EOF
}


#
# Build inputrc-config
#
function inputrc-config() {
  echo -e "${grayColour}----------------------------------------------------------------${endColour}"
  echo -e "${grayColour}- Building : ${endColour}${yellowColour}inputrc-config...${endColour}"

cat > /etc/inputrc << "EOF"
# Begin /etc/inputrc
# Modified by Chris Lynn <roryo@roryo.dynup.net>

# Allow the command prompt to wrap to the next line
set horizontal-scroll-mode Off

# Enable 8bit input
set meta-flag On
set input-meta On

# Turns off 8th bit stripping
set convert-meta Off

# Keep the 8th bit for display
set output-meta On

# none, visible or audible
set bell-style none

# All of the following map the escape sequence of the value
# contained in the 1st argument to the readline specific functions
"\eOd": backward-word
"\eOc": forward-word

# for linux console
"\e[1~": beginning-of-line
"\e[4~": end-of-line
"\e[5~": beginning-of-history
"\e[6~": end-of-history
"\e[3~": delete-char
"\e[2~": quoted-insert

# for xterm
"\eOH": beginning-of-line
"\eOF": end-of-line

# for Konsole
"\e[H": beginning-of-line
"\e[F": end-of-line

# End /etc/inputrc
EOF
}


#
# shells-config
#
function shells-config() {
  echo -e "${grayColour}----------------------------------------------------------------${endColour}"
  echo -e "${grayColour}- Building : ${endColour}${yellowColour}shells-config...${endColour}"

cat > /etc/shells << "EOF"
# Begin /etc/shells

/bin/sh
/bin/bash

# End /etc/shells
EOF
}

function limpieza() {
   rm -rfv /sources
}


#
# Backup
#
function backup(){
   cd ${BACKUP}
   tar cvfj 04-backup-lfs-config-$(date +"%m-%d-%y").tar.bz2 ${LFS}
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
   lfs-bootscripts
   sleep 1
   udev-ruler
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
       p0)   lfs-bootscripts
	     ;;
       p1)   udev-ruler
	     ;;
       p2)   red
	     ;;
       p3)   systemv
	     ;;
       p4)   bash-config
	     ;;
       p5)   inputrc-config
	     ;;
       p6)   shells-config
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
