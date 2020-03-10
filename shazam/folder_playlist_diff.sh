#!/bin/bash
playlist=/home/user/.config/mpd/playlists/Shazam.m3u
dir=/home/user/Media/music/Shazam
diff -u \
     <(sort "$playlist") \
     <(cat \
	   "$playlist" \
	   <(find "$dir" -type f | sed "s|$(dirname "$dir")/||" ) \
       | sort -u ) 
#     > /home/user/.scripts/shazam/shazam.patch



#works. should this write to file or std out?

#shouldn't I abstract this so it isn't specific to the playlist?
