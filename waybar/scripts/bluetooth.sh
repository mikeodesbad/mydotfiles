#!/bin/bash

if bluetoothctl show | grep -q "Powered: yes"; then
    if bluetoothctl info | grep -q "Device"; then
        echo "Connected"
    else
        echo "On"
    fi
else
    echo "Off"
fi

