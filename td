#!/bin/dash
flags=$(for arg; do echo $arg | grep "^-"; done)
args=$(for arg; do echo $arg | grep "^-" -v; done)
datecmd="date"
input=$args
ed="$VISUAL +1000"
( [ "$flags" = "-v" ] || [ "$flags" = "--vim" ] ) &&
    ed="vim"
bullet="- "

# if $1 is a valid date, use that for date input and use other nonflag args as input
date -d $1 > /dev/null 2>/dev/null  &&
    [ "$1" != "-v" ] &&
    datecmd="date -d $1" &&
    input="$(echo $args | cut -d ' ' -f2-)"

filename="$($datecmd +%m-%d)"
header="$($datecmd +"%A, %B %d")\n\n\n"
fpath="$TD_DIR/$filename.org" # file path with correct name

# if the file does not exist, create it with the appropriate name and header
[ ! -f "$fpath" ] && printf %s "$header" > "$fpath"

# if input is not simply the date (and there is an input), add input to the file as a todo and don't open
if [ "$datecmd" != "date -d $input" ] && [ -n "$input" ]; then
    printf '%s%s\n' "$bullet" "$input" >> "$fpath"

else
    $ed "$fpath"

fi
