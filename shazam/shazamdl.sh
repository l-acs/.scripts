#!/bin/bash

link="https://open.spotify.com/playlist/0WQZwff8F8pYazozpqA3rx"
dest="/home/user/Media/music/Shazam"


case "$#" in
    0)
	echo 'Downloading "My Shazam Tracks"'
       ;;
    2)
	music_dir="$(dirname "$dest")"
	link="$1"
	dest="$2"
	echo "$2" | grep -q "$music_dir" || dest="$music_dir/$2" && mkdir -p "$dest"
	echo "Downloading \"$link\""

	;;
    *)
	echo -e "Wrong number of arguments. Usage:\n  shazamdl.sh [link destination]"
	exit 1
	;;
esac


case "$(echo "$link" | grep -o -e album -e playlist -e track)" in
    album)
	flags="-sa"
	;;
    playlist)
	flags="-sp"
	
	;;
    track)
	flags="-ss"
	;;
    *)
	echo "Error: invalid link."
	exit 2
	
esac





smd "$flags" "$link" -p "$dest"

