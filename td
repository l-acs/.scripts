#!/bin/bash
FLAGS=$(for arg; do echo $arg | grep "^-"; done)
NONFLAGS=$(for arg; do echo $arg | grep "^-" -v; done)
DATE_CMD="date"
INPUT=$NONFLAGS
ed="$VISUAL +1000"
[ "$FLAGS" = "-v" ] && ed="vim"
[ "$FLAGS" = "--vim" ] && ed="vim"

#if $1 is a valid date, use that for date input and use other nonflag args as input
date -d $1 > /dev/null 2>/dev/null
#[[ "$1" != "-v" ]] && 
[[ $? -eq 0 ]] && [[ "$1" != "-v" ]] && DATE_CMD="date -d $1" && INPUT=$(echo $NONFLAGS | cut -d " " -f2-)

FILE_FORMAT=`$DATE_CMD +%Y-%m-%d` #date to call the file
HEADER_FORMAT=`$DATE_CMD +%A\,\ %B\ %d` #date to write in the header
FILEPATH="$TD_DIR/$FILE_FORMAT.txt" #file path with correct name

#if the file does not exist, create it with the appropriate name and header
[[ ! -f $FILEPATH ]] && echo -e "$HEADER_FORMAT - to do:\n\n\n\n\n###\nCalendar:\n" > "$FILEPATH"

#if input is not simply the date (and there is an input), add input to the file as a todo and don't open in vim
[[ $DATE_CMD != "date -d $INPUT" ]] && [[ -n $INPUT ]] && echo - $INPUT >> "$FILEPATH" && FLAGS="--noedit"
#the above is a quirk due to cut: `td yesterday` added "yesterday" to yesterday's to-do

#if there is no "--noedit" flag, open the file in $ed with the cursor on the last line
[[ $FLAGS != "--noedit" ]] && $ed "$FILEPATH" 
