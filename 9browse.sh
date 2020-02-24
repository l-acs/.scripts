#!/bin/bash

filebrowser="urxvt -cd"
path_to_recursive_call="9browse.sh"
nineflags="$NINEFLAGS -file -"

start="$PWD" #where should browsing begin
[ "$#" -gt 0 ] && start="$@" 
echo "$start" | grep -q "/$" || start="$(echo "$start" | sed 's|$|/|')" #make sure start ends in a slash

#tmpfile stuff
tmp_current=$(mktemp)
exec 3> "$tmp_current"


#format this folder for 9menu
echo "Open $(echo $filebrowser | cut -f1 -d ' ')":"$filebrowser $start" > $tmp_current

#format dirs for 9menu
find $start -mindepth 1 -maxdepth 1 -type d -not -path '*/\.*' | sort | sed -e "s|^$start||" -e "s|^.*|&:9browse.sh $start&|" >> $tmp_current

#format files for 9menu
find $start -mindepth 1 -maxdepth 1 -type f -not -path '*/\.*' -not -path '*~' | sort | sed -e "s|^$start||" -e "s|^.*|Open &:xdg-open \"$start&\" \&>/dev/null|" >> $tmp_current


#call 9menu
cat $tmp_current | 9menu $nineflags
echo foo >&3
