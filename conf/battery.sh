#!/bin/sh

export DISPLAY=:0
export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/1000/bus"

LEVEL=`acpi -b | grep "Battery 0" | grep -P -o '[0-9]+(?=%)'`
TIME=`date +%R`
notify-send "${LEVEL}% ${TIME}" -t 1000
