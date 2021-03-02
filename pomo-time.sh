#!/bin/dash

# this is ridiculously slow

scriptName="$0"

elapsedSecondsLastPomo()
{
    ps -C pomo -o etimes | tail -n 1 | tr -d '[:blank:]'
}

isPomoRunning ()
{
    pgrep -a pomo | grep -qv "$scriptName"
}

pomoTime ()
{
    # only works for minutes

    secondArgNum="$(ps -C pomo -o cmd | tail -n 1 | cut -f3 -d' ' | grep -o '[0-9]*')"

    if [ -n "$secondArgNum" ]
    then
	echo "$secondArgNum"
    else
	# there was no time specified when pomo was run
	isPomoRunning && # but pomo *was* run
	    echo 25
    fi

    # unnecessary redundancy and echo but probably clearer though probably not idiomatic
}


minutesToSeconds ()
{
    [ -n "$1" ] && echo "$(( $1 * 60))"
}


pomoTimeSeconds()
{
    timeMinutes="$(pomoTime)"

    [ -n "$timeMinutes" ] && minutesToSeconds "$timeMinutes"
    
    # likewise

}



timeLeftLastPomo ()
{
    # figure out how long it was for and use elapsedSecondsLastPomo to subtract

    totalTime="$(pomoTimeSeconds)"
    elapsedTime="$(elapsedSecondsLastPomo)"

    [ -n "$totalTime" -a -n "$elapsedTime" ] &&
	echo "$(( totalTime - elapsedTime))"
    
}

zeroPad()
{
    # first argument is the int to pad
    # second argument is number of digits

    if [ $(echo -n "$1" | wc -c) -lt "$2" ] # if you need more padding than your int is long, pad
    then
	zeroPad "0$1" "$2"
	# pad one zero then recurse
    else
	echo $1
    fi
    
}


secondsToMinutesAndSeconds()
{
    [ -z "$1" ] && echo -n "" && exit 1

    minutes="$(( $1 / 60 ))"
    [ -z  "$minutes" ] && minutes="00"

    seconds="$(( $1 % 60 ))"

    echo $(zeroPad $minutes 2):$(zeroPad $seconds 2)
}


formatTimeLeftLastPomo ()
{
    secondsToMinutesAndSeconds $(timeLeftLastPomo)

}

pomoCmd ()
{
    ps -C pomo -o cmd | tail -n 1 | cut -f3- -d' '
}

pomoName ()
{
    isPomoRunning || exit 1

    cmdFirstNum="$(pomoCmd | sed -E 's/^[0-9]+[a-zA-Z]* *//')"
    name="$(pomoCmd | sed -E 's/[0-9]+[a-zA-Z]* *//' | grep '[a-zA-Z0-9]')" # it has any kind of name


    if pomoCmd | grep -qE -e '(25|25m)' || pomoCmd | grep -qv -E '^[0-9]+[a-zA-Z]*' # either it's got 25 minutes explicitly or it's got no number in $1
    then
	if [ -n "$name" ]; then
	    echo "Pomo: $name" 
	else
	    echo Pomodoro
	fi

    else
	if [ -n "$name" ]; then
	    echo "Timer: $name" 
	else
	    echo Timer
	fi

    fi
}


if [ "$1" = name ]
then
    pomoName
else
    isPomoRunning && formatTimeLeftLastPomo
fi
