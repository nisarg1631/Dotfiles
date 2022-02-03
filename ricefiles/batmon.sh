#!/bin/bash 
export DISPLAY=:0.0
export $(egrep -z DBUS_SESSION_BUS_ADDRESS /proc/$(pgrep -ou nisarg dbus-daemon)/environ)

THRESHOLD=20

lock_path='/tmp/batmon.lock'

lockfile-create -r 0 -l $lock_path || exit

acpi_path=$(find /sys/class/power_supply/ -name 'BAT*' | head -1)
charge_status=$(cat "$acpi_path/status")
charge_percent=$(acpi | cut -d ' ' -f 4 | sed 's/[^0-9]//g')

if [[ $charge_status == 'Discharging' ]] && [[ $charge_percent -le $THRESHOLD ]]; then
  message="Battery running critically low at $charge_percent%!"
  DISPLAY=:0.0 /usr/bin/notify-send -u critical 'Low battery' "$message"
fi

rm -f $lock_path