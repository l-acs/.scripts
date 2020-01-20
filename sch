#!/bin/bash
#source ~/.bashrc
td='/home/user/.scripts/td'
compiled_location='/home/user/.scripts'
old_todos='/home/user/doc/productivity/days'
date_flags=""

#get all lines beginning with ">" from  old_todos txt files and add them to a file
ls $old_todos/*.txt | while read file; do echo -e "`grep -e "^>" -e "^\?" $file`\n" >> $compiled_location/compiled_tasks.txt; done

#remove blank lines (lines containing start_of_lineend_of_line) and switch > to -
sed '/^$/d' "$compiled_location/compiled_tasks.txt" | sed '/^> /d' > "$compiled_location/formatted_tasks.txt"

#if the arguments are simply "ls", output aforementioned todos and quit
[[ $@ = "ls" ]] && cat "$compiled_location/formatted_tasks.txt" && rm "$compiled_location/formatted_tasks.txt" "$compiled_location/compiled_tasks.txt" && exit

# if there's no arguments, use normal td (today)
[[ $# -eq 0 ]] && bash $td --novim 
#if there's an argument, use that day as td input
[[ ! $# -eq 0 ]] && bash $td $1 --novim 

#if the first argument is nonzero, set appropriate flags for the date command
[[ -n $1 ]] && date_flags="-d $1"

#add gathered tasks to the desired to-do list
cat "$compiled_location/formatted_tasks.txt" >> "$old_todos/`date $date_flags +%Y-%m-%d`.txt"

#remove unnecessary files created
rm "$compiled_location/formatted_tasks.txt" "$compiled_location/compiled_tasks.txt"

#remove the original > lines from the original .txt to-do lists
sed -i '/^>/d' $old_todos/*.txt && sed -i '/^\?/d' $old_todos/*.txt
