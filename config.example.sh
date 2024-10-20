#!/bin/bash
# Set user for running factorio
user="factorio"
group="factorio"
port="34196"

# Experimental branch of factorio
experimental=false

# Experimental use of ZRAM for faster server saves if used on slow drive
zramOn=false


#####################################
######### DO NOT EDIT BELOW #########
#####################################
# Set working directory for script
if [ $1 ]; then cd $1; fi
workingDirectory=$(pwd)

viewUser=$(whoami)

factorioTar="$workingDirectory/factorio.tar.xz"
serverPath="$workingDirectory/server"
factorioBin="$serverPath/factorio/bin/x64/factorio"
factorioSource="https://factorio.com/get-download/latest/headless/linux64"

echo $workingDirectory

function downloadFactorio() {
    if [ ! -f $factorioTar ]; then
        echo "Downloading Factorio"
        (wget -nc $factorioSource -O $factorioTar)
    fi
}

function backupFactorio() {
    echo "Backing up Factorio"
    (tar -cf $factorioTar -C $serverPath factorio)
}

function unpackFactorio() {
    echo "Unpacking Factorio"
    (tar --keep-newer-files -xf $factorioTar -C $serverPath)
    chown -R $user:$group $serverPath/factorio
}