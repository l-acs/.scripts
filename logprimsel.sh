#!/bin/dash

#logs primary selection for retroactive plumbing
#should the delimeter be something other than a newline? sometimes you select multiline text...
logfile="~/.scripts/output/primsel.log"
current_sel=""
#prev_sel="$(tail -n 1 "$logfile)"
log_time="1s"
cleanup_time="30s"

#useful function
logme(){
	#writes current primary selection to log
	[ -n "$current_sel" ] && echo "$current_sel" >> "$logfile"
	current_sel="$(xsel -o)"
}

remove_duplicates(){
	#deletes all but latest instance of duplicates in logfile
	cat -n "$logfile" | sort -rn | sort -uk2 | sort -nk1 | cut -f2- > tmpfile && mv tmpfile "$logfile"
}

logme


#trap "logme" EXIT #and remove duplicates from file without sorting it...
trap 'logme && remove_duplicates' EXIT

while true; do
	sleep "$cleanup_time"
	remove_duplicates
done &

while true; do 
	sleep "$log_time"
	if [ "$current_sel" != "$(xsel -o)" ]; then
		logme
	fi
done 



trap - EXIT


