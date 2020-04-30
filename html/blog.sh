#!/bin/sh
#  To automate blogging

date_readable="$(date +"%A, %b %-d %Y - %-I:%M%P")"

tmp=entry_tmp.html
filename="entry_$(date +"%m-%d-%y_%H:%M").html"

header=something
footer=something
template=something


#  Goal: try to figure out if this has been run from Emacs. If so,
#  open in Emacs. Otherwise, open Emacs and edit it there.

EDIT="emacs -nw" # open in the console
if [ "$TERM" = 'dumb' ]; then # emacs is running
    EDIT=unsure # probably emacsclient -c
fi



cp $template $tmp
echo "<h4>$date_readable</h4>" >> $tmp
$EDIT $tmp
cat $header $tmp $footer > "$filename"
rm $tmp


echo -n "Please enter the name of your post:  "
read title

# TODO: add to some monolith of blog entries



git add $filename
git commit -m "add entry \'$entry\' via blog.sh"
git push














