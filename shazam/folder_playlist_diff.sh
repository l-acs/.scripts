#!/bin/bash
dir=/home/user/Media/music/Shazam
playlist=/home/user/.config/mpd/playlists/Shazam.m3u

case "$#" in
    0)

       ;;
    2)
	music_dir="$(dirname "$dir")"
	playlist_dir="$(dirname "$playlist")"

	dir="$1"
	playlist="$2"
	echo "$1" | grep -q "$music_dir" || dir="$music_dir/$1" #&& mkdir -p "$dest"
	echo "$2" | grep -q "$music_dir" || playlist="$playlist_dir/$2.m3u" && echo -n >> "$playlist"


	;;
    *)
	echo -e "Wrong number of arguments. Usage:\n  folder_playlist_diff.sh [dir list]"
	exit 1
	;;
esac





diff -u \
     <(sort "$playlist") \
     <(cat \
	   "$playlist" \
	   <(find "$dir" -type f | sed "s|$(dirname "$dir")/||" ) \
       | sort -u ) 
#     > /home/user/.scripts/shazam/shazam.patch



#works. should this write to file or std out?




#todo: prevent reordering
