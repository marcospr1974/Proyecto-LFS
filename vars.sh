
##
# Autor    : Marcos Pablo Russo
# E-Mail   : marcospr1974@gmail.com
# Fecha    : 23/12/2021
# Licencia : GPL-3
#
# Descripcion:
#
#   Contiene las variable globales para el uso.
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
BUILD_ROOT=/mnt/LFS-11.0
LFS=/mnt/lfs
BACKUP=${BUILD_ROOT}/backup
SRC_SOURCES=${BUILD_ROOT}/sources/packages
SRC_FILES=${BUILD_ROOT}/sources/files
SRC_PATCH=${BUILD_ROOT}/sources/patches
LFS_TOOLS=${LFS}/tools
LFS_LOGS=${BUILD_ROOT}/logs

# Declaracion de PATH, y otras variales
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
