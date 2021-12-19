#!/bin/bash

 Bajos los source
if [ -f sources.list ]; then
   ( cd ../sources/packages
     wget -i ../../scripts/sources.list
   )
else
  echo "- No existe el archivo: sources.list"
fi

# Bajos los patches
#if [ -f patches.list ]; then
#   ( cd ../sources/patches
#     wget -i ../../scripts/patches.list
#   )
#else
#  echo "- No existe el archivo: patches.list"
#fi
