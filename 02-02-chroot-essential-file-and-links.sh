#!/bin/bash

##
# Autor    : Marcos Pablo Russo
# E-Mail   : marcospr1974@gmail.com
# Fecha    : 24/12/2021
# Licencia : GPL-3
#
# Descripcion:
#
#   Mediante este script nos permite realizar el capitulo 7.6 de Linux From Scratch.
#   De esta forma podemos automatizar toda la creacion de los paquetes.
#   Esta basado en LFS-11.0
#
#   https://www.linuxfromscratch.org/lfs/view/stable/index.html
#
##

ln -sv /proc/self/mounts /etc/mtab
cat > /etc/hosts << EOF
127.0.0.1  localhost $(hostname)
::1        localhost
EOF

cat > /etc/passwd << "EOF"
root:x:0:0:root:/root:/bin/bash
bin:x:1:1:bin:/dev/null:/bin/false
daemon:x:6:6:Daemon User:/dev/null:/bin/false
messagebus:x:18:18:D-Bus Message Daemon User:/var/run/dbus:/bin/false
nobody:x:99:99:Unprivileged User:/dev/null:/bin/false
EOF

cat > /etc/group << "EOF"
root:x:0:
bin:x:1:daemon
sys:x:2:
kmem:x:3:
tape:x:4:
tty:x:5:
daemon:x:6:
floppy:x:7:
disk:x:8:
lp:x:9:
dialout:x:10:
audio:x:11:
video:x:12:
utmp:x:13:
usb:x:14:
cdrom:x:15:
adm:x:16:
messagebus:x:18:
input:x:24:
mail:x:34:
nogroup:x:99:
users:x:999:
EOF

exec /bin/bash --login +h

touch /var/log/{btmp,lastlog,faillog,wtmp}
chgrp -v utmp /var/log/lastlog
chmod -v 664  /var/log/lastlog
chmod -v 600  /var/log/btmp
