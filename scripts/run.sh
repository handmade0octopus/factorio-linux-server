#!/bin/bash
if [ $1 ]; then cd $1; fi

echo "_________________"
date

thisPath=$(pwd)
source config.sh $thisPath

if [ ! -f $factorioBin ]; then
    (downloadFactorio)
    (unpackFactorio)
else
    (backupFactorio)
fi

function checkUpdate() {
    local addTo=""

    if [ $1 ] ; then addTo=$1; fi

    if $experimental; then addTo+=" -x "; fi

    echo "Extra parameters $addTo"

    #(python3 update_factorio.py $addTo -DO $serverPath --for-version 1.1.109)
    (python3 update_factorio.py $addTo -DO $serverPath -a $factorioBin)

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

    checkUpdate

    # Apply the update
    while (checkUpdate -d); do
        checkUpdate
    done

    # Start the Factorio service
    systemctl start factorio
    echo "Factorio server updated and restarted."
else
    if systemctl is-active --quiet factorio; then
        echo "No new Factorio version available"
    else
        systemctl start factorio
    fi
fi

echo $ret
exit $ret