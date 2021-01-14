#!/bin/sh

compiled_location="$(mktemp)"

# get all lines beginning with > or ? from  old_todos txt files and add them to a file
grep  -e "^>" -e "^\?" "$TD_DIR"/*.txt > "$compiled_location"

# remove blank lines and switch > to -
sed -e '/^$/d' -e 's/^> /- /' "$compiled_location" -i

# if the arguments are simply "ls", output aforementioned todos and quit
[ $@ = "ls" ] && cat "$compiled_location" && rm "$compiled_location" && exit

# create (read: format) the file for the chosen day
# if there's no arguments, use normal td (today)
[ $# -eq 0 ] && td --noedit
# if there's an argument, use that day as td input
[ ! $# -eq 0 ] && td $1 --noedit

# if the first argument is nonzero, set appropriate flags for the date command
[ -n $1 ] && date_flags="-d $1"

# add gathered tasks to the desired to-do list
cat "$compiled_location" >> "$TD_DIR/$(date $date_flags +%Y-%m-%d).txt"

# remove unnecessary files created
rm "$compiled_location"

# remove the > / ? lines from to-do lists
sed -e '/^>/d' -e '/^\?/d' "$TD_DIR"/*.txt -i
