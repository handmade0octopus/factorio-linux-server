#!/bin/bash
newPath="/opt/factorio"
if [ $1 ]; then newPath=$1; fi
source $newPath/config.sh $newPath

sudo systemctl disable factorio-update.timer
sudo systemctl stop    factorio-update.timer
sudo systemctl disable factorio-update.service
sudo systemctl stop    factorio-update.service

backupFactorioSudo

sudo systemctl stop    factorio.service