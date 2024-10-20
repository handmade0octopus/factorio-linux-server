#!/bin/bash
currentPath=$(pwd)
if [ ! -f config.sh ]; then
    cp config.example.sh config.sh
    chmod +x config.sh
fi

newPath="/opt/factorio"
if [ $1 ]; then newPath=$1; fi

echo "Installing factorio in: $newPath"

#sudo apt -qq update
sudo apt -qq install -y python3
sudo apt -qq install -y python3-requests
sudo apt -qq install -y wget
sudo apt -qq install -y conspy

sudo mkdir -pm 777 $newPath

sudo cp -r $currentPath/scripts/* $newPath
sudo cp -f $currentPath/config.sh $newPath/config.sh
sudo cp -f $currentPath/factorio.tar.xz $newPath/factorio.tar.xz

cd $newPath
source config.sh $newPath

sudo mkdir -pm 777 $serverPath

if !(id -u $user); then
    echo "User created"
    sudo adduser --disabled-login --no-create-home --gecos $user $group
else
    echo "$user user exists"
fi

function zram() {
    if [ $1 ] && [ -d $1 ]; then
        if (mountpoint -q "$1"); then
            echo "ZRAM already working"
        else
            sudo modprobe zram num_devices=1

            #$zram_dev is created device path (eg. /dev/zram1)
            zram_dev=$(sudo zramctl -f -s 2G -a lz4)

            echo "New ZRAM added $zram_dev"

            # format it to ext4
            yes | sudo /usr/sbin/mkfs.ext4 $zram_dev 

            # mount it on /tmp 
            sudo mount $zram_dev $1
        fi
        return $1
    else
        echo "Specify location!"
        return 1
    fi
}

if $zramOn; then 
    zram $serverPath
fi

downloadFactorio
sudo cp -nr $currentPath/factorio/ $serverPath
sudo chown -R factorio:factorio $newPath

#sudo su $user -c
#sudo runuser $user -c "screen -S screenName -D -m $factorioBin --port $port --start-server-load-latest --server-settings $serverPath/factorio/data/server-settings.json"
#sudo runuser $user -c "screen -S screenName -L -Logfile $workingDirectory/log.txt -D -m $factorioBin --port $port --start-server $serverPath/factorio/data/saves/NEWONE.zip --server-settings $serverPath/factorio/data/server-settings.json"
#exit 1

factorioServiceStr="[Unit]
Description=Factorio Headless Server
After=network.target

[Service]
Type=simple
User=$user
Group=$group
StandardInput=tty-force
TTYVHangup=yes
TTYPath=/dev/tty20
TTYReset=yes
WorkingDirectory=$serverPath/factorio
ExecStart=$factorioBin --port $port --start-server-load-latest --server-settings $serverPath/factorio/data/server-settings.json
TimeoutStopSec=100s
Restart=always
RestartSec=120s

[Install]
WantedBy=multi-user.target"

sudo sh -c "echo '$factorioServiceStr' > /etc/systemd/system/factorio.service"



factorioUpdateServiceStr="
[Unit]
Description=Factorio Update Service
Wants=network-online.target
After=network-online.target

[Service]
Type=oneshot
ExecStart=screen -S factorioUpdaterConsole -L -Logfile $workingDirectory/factorioUpdater.log -D -m $workingDirectory/run.sh $workingDirectory
RuntimeMaxSec=100s
"

sudo sh -c "echo '$factorioUpdateServiceStr' > /etc/systemd/system/factorio-update.service"


factorioUpdateTimerStr="
[Unit]
Description=Run Factorio Update Service every hour

[Timer]
OnCalendar=hourly
Persistent=true

[Install]
WantedBy=timers.target
"

sudo sh -c "echo '$factorioUpdateTimerStr' > /etc/systemd/system/factorio-update.timer"

sudo sudo systemctl daemon-reload
sudo systemctl stop   factorio.service
sudo systemctl stop   factorio-update.timer
sudo systemctl stop   factorio-update.service
sudo systemctl enable factorio-update.service
sudo systemctl enable factorio-update.timer
sudo systemctl start --no-block factorio-update.service
sudo systemctl start --no-block factorio-update.timer