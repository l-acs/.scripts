#!/bin/sh

#To automate blogging
date_readable="$(date +"%A, %b %-d %Y - %-I:%M%P")"

tmp=entry_tmp.html
filename="entry_$(date +"%m-%d-%y_%H:%M").html"

header=something
footer=something
template=something





EDIT="emacs -nw" #open in the console
if [ "$TERM" = 'dumb' ]; then #emacs is running
    EDIT=unsure #probably emacsclient -c
fi


$EDIT $tmp


cat $header $
