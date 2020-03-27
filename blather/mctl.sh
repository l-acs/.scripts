#!/bin/bash

case "$1" in
    "")
	mpc play
	;;
    
    pause|toggle|next)
	mpc "$*"
	;;

    remove|delete|clear)
	mpc clear
	;;
    
    skip)
	mpv next
	;;
    back)
	mpc prev
	;;
	
esac


if [ "$1" = play ]; then
    shift 1
    args="$(echo "$*" | tr ' ' '*')"
    if [ -n "$*" ]; then
	find "$MUSIC" -type f -iname "*$args*" | grep -v -e "\.log$" -v -e "\.jpg$" -v -e "\.png$" -v -e "\.jpeg$" -v -e "\.m3u$" -v -e "\.pdf$" | sed "s|$MUSIC/||" | sort -u | mpc insert &&
	    (mpc next || mpc play) && echo success
    else
	mpc play
    fi
    
fi

if [ "$1" = queue ]; then
    shift 1
    args="$(echo "$*" | tr ' ' '*')"
   [ -n "$*" ] && find "$MUSIC" -type f -iname "*$args*" | sed "s|$MUSIC/||" | sort -u | mpc add &&
       (mpc next || mpc play) && echo success
   

fi


