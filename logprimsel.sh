#!/bin/sh

#logs primary selection for retroactive plumbing
#should the delimeter be something other than a newline? sometimes you select multiline text...
logfile="/home/user/.scripts/output/primsel.log"
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

while sleep "$cleanup_time"; do remove_duplicates; done &

while sleep "$log_time"; do
	if [ "$current_sel" != "$(xsel -o)" ]; then
		logme
	fi

done 



trap - EXIT


