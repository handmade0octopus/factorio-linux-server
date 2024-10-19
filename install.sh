#!/bin/bash

zramOn=0

if [ $1 ]; then
zramOn=1
fi


function zram() {
    if [ $1 ] && [ -d $1 ]; then
        if (mountpoint -q "$1"); then
            echo "ZRAM already working"
        else
            sudo modprobe zram num_devices=1

            #$zram_dev is created device path (eg. /dev/zram1)
            zram_dev=$(sudo zramctl -f -s 2G -a lz4)

            echo $zram_dev

            # format it to ext4
            yes | sudo /usr/sbin/mkfs.ext4 $zram_dev 

            # mount it on /tmp 
            sudo mount $zram_dev $1
        fi
    else
        echo "Specify location!"
    fi
}

sudo apt install python3
sudo apt install pip
sudo apt install python3-requests

mkdir -m 777 server

if [ $zramOn != 0 ]; then 
    zram server
fi

