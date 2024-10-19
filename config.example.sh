#!/bin/bash
# Set user for running factorio
user="factorio"
group="factorio"
port="34196"

# Set working directory for script, by default
workingDirectory=$(pwd)

# Experimental branch of factorio
experimental=false

# Experimental use of ZRAM for faster server saves if used on slow drive
zramOn=0

factorioTar="$workingDirectory/factorio.tar.xz"
serverPath="$workingDirectory/server"
factorioBin="$serverPath/factorio/bin/x64/factorio"
factorioSource="https://factorio.com/get-download/latest/headless/linux64"