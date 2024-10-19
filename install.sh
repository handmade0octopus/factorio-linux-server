#!/bin/bash
if [ ! -f config.sh ]; then cp config.example.sh config.sh; fi
source config.sh

sudo apt install python3
sudo apt install python3-requests

sudo mkdir -m 777 $serverPath

if !(id -u $user); then
    echo "User created"
    sudo adduser --disabled-login --no-create-home --gecos $user $group
else
    echo "$user user exists"
fi

sudo chown -R $user:$group $serverPath/factorio
#sudo chown -R factorio:factorio $serverPath/factorio

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

if [ $zramOn != 0 ]; then 
    zram $serverPath
fi

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
WorkingDirectory=$serverPath/factorio
ExecStart=screen -S factorioConsole -L -Logfile $workingDirectory/factorio.log -D -m $factorioBin --port $port --start-server-load-latest --server-settings $serverPath/factorio/data/server-settings.json
ExecStop=/bin/kill -s SIGINT $MAINPID
TimeoutStopSec=600
Restart=on-failure

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
sudo systemctl enable factorio-update.timer
sudo systemctl start factorio-update.timer
sudo systemctl start factorio-update.service

#screen -r factorioUpdaterConsole
