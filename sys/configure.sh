#!/bin/sh

#clickable trackpoint
#echo -n 1 > /sys/devices/platform/i8042/serio1/press_to_select

#trackpoint sensitivity


echo -n 142 > /sys/devices/platform/i8042/serio1/sensitivity



#trackpoint speed
echo -n 115 > /sys/devices/platform/i8042/serio1/speed
