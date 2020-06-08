#!/bin/sh

# Delete m4a/mp3s of which I have flacs


# update the database
mpc -q update --wait

cd $MUSIC
mpc search filename flac |
    sed 's/\.flac$//' |
    while read i; do
	mpc search filename "$i.m"; done |
    xargs -d '\n' rm

# update again
mpc -q update --wait
