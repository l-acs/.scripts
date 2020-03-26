#!/bin/sh

case "$*" in
    play|pause|toggle)
	mpc "$*"
	;;
    


    
    "play *")
	mpc find any "$*" | mpc insert
	mpc next
	;;
esac

