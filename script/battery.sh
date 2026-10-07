#!/bin/sh

export DISPLAY=:0
export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/1000/bus"

LEVEL=$(acpi -b | rg "Battery 0" | rg -P -o '[0-9]+(?=%)')
TIME=$(date +%R)
notify-send "${LEVEL}% ${TIME}" -t 1000
