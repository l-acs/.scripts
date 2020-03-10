#!/bin/sh

#clickable trackpoint
#echo -n 1 > /sys/devices/platform/i8042/serio1/press_to_select

#trackpoint sensitivity


echo -n 160 > /sys/devices/platform/i8042/serio1/sensitivity



#trackpoint speed
echo -n 120 > /sys/devices/platform/i8042/serio1/speed 
