#!/bin/bash

# perform actions on a window, according to the current WM

WM="$(getname.sh)"
[ $WM = 'compiz' ] && WM=bspwm

pick(){
    xdotool selectwindow
}

case "$1" in
    -p|--pick|--select)
	window=$(pick)
	shift 1
	;;
    *)
	window="$(xdotool getactivewindow)"
	;;
esac

cache="$HOME/.scripts/window/.cache"
activetags="$cache/current"
thumbquality=100
mkdir -p "$cache/thumbnails"


capture(){
    # todo: only have there be *one* file; just have it autoreload and have a window that feh is watching there

    echo "Capturing..."
    # higher quality makes this faster. It means less effort spent on compression, which means less time spent before scrot returns
    tmp="$cache"/thumbnails/temp.png
    pgrep -f workspacethumbnail || if bspc query -d focused -N; then
	# screenshot, overwriting, at quality, the autoselected region encompassing the primary monitor
	scrot -o \
	      -q $thumbquality \
	      -a $(xrandr -q | # grep primary
		       grep default | grep -E '[0-9]+x[0-9]+\+[0-9]+\+[0-9]+' -o | tr + x | awk -F x '{print $3","$4","$1","$2}') \
	      "$tmp" 
	for i in $(getactiveworkspaces); do
	    cp "$tmp" "$cache/thumbnails/$i.png"
	done
    else
	for i in $(getactiveworkspaces); do
	    rm "$cache/thumbnails/$i.png"
	done
    fi
    
}


capturefocuscapture(){
    focus "$1"
    (sleep 5 && capture) &
}



close(){
    case "$WM" in
	bspwm) bspc node "$window" -c ;;

	awesome|CWM) wmctrl -c :ACTIVE: ;;

	*) xdotool windowclose "$window" ;;

    esac
}



draw(){
    input="$(xrectsel)"
    position="$(echo "$input" | cut -d '+' -f2-3 | tr '+' ' ')"
    size="$(echo "$input" | cut -d '+' -f1 | tr 'x' ' ')"

    case "$WM" in
	bspwm) bspc node "$window" -t floating ;;
	*) ;; # nothing?
    esac

    xdotool windowmove "$window"  $position windowsize "$window" $size

}



identifydesktop() {
    case "$1" in
	next|n)     echo "$(("$(getactiveworkspaces)" + 1))" ;; # todo: make these cycle
	prev|p)     echo "$(("$(getactiveworkspaces)" - 1))" ;;
	empty)      getnextempty ;;
	nextfilled) getnextfilled ;;
	prevfilled) getprevfilled ;;
	*) echo "$1" ;;
    esac
}

wmdesktopmatch() {
   id="$(identifydesktop "$1")"

   case "$WM" in
	awesome) case "$id" in
		    [1-9]) echo "$((id - 1))" ;;
		    0|10)  echo 9 ;;
	         esac ;;

	GNOME) echo "$((id - 1))" ;;

	bspwm|i3|cwm|CWM|*) echo "$id" ;;
   esac

}

focus(){
    # show a desktop or window group

    case "$WM" in
	awesome|GNOME) wmctrl -s "$1" ;;

	bspwm) bspc desktop --focus "$1" ;;

	CWM|cwm) wmctrl -s "$1" ;;

	*) wmctrl -s "$1" ;;
    esac
}

helpme(){
    name="$(basename "$0")"
    echo "Usage:
    $name -p -[cdk]
    $name -[fs] DESKTOP
    $name -h"
}



act-kill(){
    case "$WM" in
	bspwm) bspc node "$window" -k ;;
	*) xdotool windowkill "$window" ;;
    esac
}


send(){
    # send window to desktop

    case "$WM" in
	awesome) xdotool set_desktop_for_window "$window" "$1" ;;

	bspwm)   bspc node "$window" --to-desktop "$1" ;;

	cwm|CWM) wmctrl -r :ACTIVE: -t "$1" ;; # group --add $1 $(pfw) ;;

	GNOME)   wmctrl -r :ACTIVE: -t "$1" ;;

	*) grep -q $desktop "$activetags" || xdotool set_desktop_for_window "$window" "$1" # either it's currently shown or move it
	   sed -i "/$1/d" "$cache/desktop"* && echo success
	   xdotool search --desktop "$1" "" > "$cache/desktop$1" ;;
    esac
    
}

getwindowsinworkspace(){ #start count at 0
    case "$WM" in
	bspwm) windows="$(xdotool search --desktop "$1" "")" ;;

	cwm|CWM) windows="$(cat "$cache/desktop$1")" ;;

	*) ;; #something

    esac

    echo $windows
}


complement(){
    diff --unchanged-group-format="" --changed-group-format="%<" $*
}


getworkspaces(){
    case "$WM" in
	bspwm) for i in $(wmctrl -d | tr -s '[:blank:]' | awk '{print $2$10}' ); do
		   echo -n "$i  "
	       done ;;

	cwm|CWM) wmctrl -d | grep -v nogroup | cut -f1 -d' ' ;;

	*) ;; #something

    esac
}

getactiveworkspaces(){
    parsed="$(wmctrl -d | grep '*' | tr -s '[:blank:]' | cut -f1 -d ' ')"

    case "$WM" in
	awesome|bspwm|GNOME) echo "$((1 + parsed))" ;;
	cwm|CWM|*) echo "$parsed" ;;
    esac
}

getfilledworkspaces(){
    case "$WM" in
	bspwm) ;; # something
	cwm|CWM|*) wmctrl -l | tr -s '[:blank:]' | cut -f2 -d' ' | sed '/-1/d'  | sort -u ;;
    esac
}

getemptyworkspaces(){
    complement <(getworkspaces) <(getfilledworkspaces)
}

getfirstempty(){
    getemptyworkspaces | head -n 1
}

getnextempty(){
    active="$(getactiveworkspaces)"
    getemptyworkspaces | grep -q $active && exit # if we're already in an empty desktop, quit

    next="$(cat <(getemptyworkspaces) <(echo $active) | sort -u | grep $active -A1 | tail -n 1)"

    ([ "$next" != "$active" ] &&
	 echo $next | grep '[[:digit:]]') || getfirstempty
}

getfirstfilled(){
    getfilledworkspaces | head -n 1
}

getlastfilled(){
    getfilledworkspaces | tail -n 1
}

getnextfilled(){
    active="$(getactiveworkspaces)"

    filledplusactive=$(cat <(getfilledworkspaces) <(echo $active) | sort -u)

    next="$(echo "$filledplusactive" | grep $active -A1 | tail -n 1)"

    # if the result is the same as the active desktop, it means we're at the rightmost filled desktop
    # therefore we wrap around
    ([ "$next" != "$active" ] &&
	 echo $next | grep '[[:digit:]]') || getfirstfilled

}

getprevfilled(){
    active="$(getactiveworkspaces)"

    filledplusactive=$(cat <(getfilledworkspaces) <(echo $active) | sort -u)

    prev="$(echo "$filledplusactive" | grep $active -B1 | head -n 1)"

    # if the result is the same as the active desktop, it means we're at the leftmost filled desktop
    # therefore we wrap around
    ([ "$prev" != "$active" ] &&
	 echo $prev | grep '[[:digit:]]') || getlastfilled

}

showthumbnail(){
    case "$WM" in
	bspwm)   bspc rule -a workspacethumbnail -o manage=off
		 file="$cache/thumbnails/$1.png" ;;

	awesome) file="$cache/thumbnails/$(($1 - 1)).png" ;;

	*)       file="$cache/thumbnails/$1.png" ;;

    esac

    
    #figure out window size
    width="$(feh -L '%w' "$file")"
    height="$(feh -L '%h' "$file")"
    thumbwidth=600

    #yuck math in the shell. there's _hopefully_ a better way to do this, but this was faster than continuing to dig for what that is.
    scale="$(echo "scale=3;$width/$thumbwidth" | bc)"
    thumbheight="$(echo "$height/$scale" | bc)"

 
    #figure out mouse location
    eval $(xdotool getmouselocation --shell)
    
    
    winX=$((X-thumbwidth/2)) #problematic: this assumes the workspaces are on the left #1100
    winY=25 # maybe should be 30
    #winY=$((Y+20)) #problematic: this assumes the bar is on the top
    
    #instead, checks should be done against the screen resolution


    fixedX=30
    fixedY=50


    [ "$winX" -lt 10 ] && winX=10    
    
    echo $winX $winY $X $Y
    
    if [ $Y -lt 25 -a $X -lt 800 ]; then
	thumbnails=$(pgrep -f workspacethumbnail)

	feh "$file" --class workspacethumbnail  -g "$thumbwidth"x"$thumbheight"+$fixedX+$fixedY -. &
	kill $thumbnails
	ours=$(pgrep -f workspacethumbnail)
	(sleep 5 && kill $ours) &

    fi
    
    
}

hidethumbnail(){
    pkill -f workspacethumbnail
}



#todo: cwm focus $1 & hide other tags


maximizev() {
    # $1 is toggle, add, or remove
    [ $# -gt 0 ] && arg="$1" || arg="toggle"
    wmctrl -r :ACTIVE: -b $arg,maximized_vert
}

maximizeh() {
    # $1 is toggle, add, or remove
    [ $# -gt 0 ] && arg="$1" || arg="toggle"
    wmctrl -r :ACTIVE: -b $arg,maximized_horz
}

maximize() {
    # $1 is toggle, add, or remove
    [ $# -gt 0 ] && arg="$1" || arg="toggle"
    wmctrl -r :ACTIVE: -b $arg,maximized_vert,maximized_horz
}


if [ "$1" = "-p" ] || [ "$1" = "--pick" ]; then
    window=$(pick)
    shift 1
fi

case "$1" in
    --carry) desktop="$(wmdesktopmatch "$2")"
	     send $desktop && focus $desktop ;;

    -c|--close) close ;;

    -d|--draw) draw ;;

    -f|--focus) desktop="$(wmdesktopmatch "$2")"
	        focus $desktop ;;
    
    -k|--kill) act-kill ;;

    -m|--max|--maximize|--fullscreen) maximize $2 ;;

    -r|--resize) draw ;;

    -p|--pick|--select) pick ;;

    -s|--send) desktop="$(wmdesktopmatch "$2")"
	       send $desktop ;;

    -X|--max-horizontal|--max-h|--horizontal) maximizeh $2 ;;

    -Y|--max-vertical|--max-v|--vertical) maximizev $2 ;;
    
    --getempty*|--empty*) getemptyworkspaces ;;

    --getfirstempty*|--firstempty*) getfirstempty ;;

    --getnextempty*|--nextempty*) getnextempty ;;

    --getfilled*|--filled*) getfilledworkspaces ;;

    --getnextfilled*|--nextfilled*) getnextfilled ;;

    --getprevfilled*|--prevfilled*) getprevfilled ;;

    --getworkspace*|--getdesktop*) getworkspaces ;;

    --getwindows*) getwindowsinworkspace $2 ;;

    --*actived*|--*activew*) getactiveworkspaces ;;

    --capture|--thumbnail) capture ;;

    --capturefocuscapture) capturefocuscapture $2 ;;

    --showthumbnail) showthumbnail $2 ;;

    --hidethumbnail) hidethumbnail ;;

    -h|--help) helpme ;;

    *) helpme
       exit 1 ;;
esac

exit 0

