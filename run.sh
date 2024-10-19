#!/bin/bash

factorioTar="factorio.tar.xz"
factorioBin="server/factorio/bin/x64/factorio"
factorioSource="https://factorio.com/get-download/latest/headless/linux64"

function backupFactorio() {
    echo "Backing up Factorio"
    (tar -cf $factorioTar -C server factorio)
}

if [ ! -f $factorioBin ]; then
    if [ ! -f $factorioTar ]; then
        echo "Downloading Factorio"
        (wget -nc $factorioSource -O $factorioTar)
    fi
    echo "Unpacking Factorio"
    (tar --keep-newer-files -xf $factorioTar -C server)
else
    (backupFactorio)
fi

function checkUpdate() {
    local addTo=""

    if [ $1 ] ; then 
        addTo=$1
    fi

    echo $addTo

    #(python3 update_factorio.py $addTo -xDO server --for-version 1.1.109)
    (python3 update_factorio.py $addTo -xDO server -a $factorioBin)

    return $?
}


(checkUpdate -d)
ret=$?

if [ $ret == 0 ]; then
    echo "New Factorio version found. Updating..."

    # Stop the Factorio service
    systemctl stop factorio

    # Wait until the service is fully stopped
    echo "Waiting for Factorio service to stop..."
    MAX_WAIT=600
    WAIT_INTERVAL=5
    WAIT_TIME=0

    while systemctl is-active --quiet factorio; do
        sleep $WAIT_INTERVAL
        WAIT_TIME=$(($WAIT_TIME + $WAIT_INTERVAL))
        if [ "$WAIT_TIME" -ge "$MAX_WAIT" ]; then
            echo "Factorio service failed to stop after $MAX_WAIT seconds."
            exit 1
        fi
    done
    echo "Factorio service stopped."

    # Apply the update
    while (checkUpdate); do
        echo "Factorio updated"
    done

    # Start the Factorio service
    systemctl start factorio
    echo "Factorio server updated and restarted."
else
    echo "No new Factorio version available"
fi

echo $ret
exit $ret