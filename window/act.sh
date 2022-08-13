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
	next|n) echo "$(("$(getactiveworkspaces)" + 1))" ;; # todo: make these cycle
	prev|p) echo "$(("$(getactiveworkspaces)" - 1))" ;;
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
    desktop="$(wmdesktopmatch "$1")"

    case "$WM" in
	awesome|GNOME) wmctrl -s "$desktop" ;;

	bspwm) bspc desktop --focus "$desktop" ;;

	CWM|cwm) wmctrl -s "$desktop" ;;

	*) wmctrl -s "$desktop" ;;
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
    desktop="$(wmdesktopmatch "$1")"

    case "$WM" in
	awesome) xdotool set_desktop_for_window "$window" "$desktop" ;;

	bspwm)   bspc node "$window" --to-desktop "$desktop" ;;

	cwm|CWM) wmctrl -r :ACTIVE: -t "$desktop" ;; # group --add $1 $(pfw) ;;

	GNOME)   wmctrl -r :ACTIVE: -t "$desktop" ;;

	*) grep -q $desktop "$activetags" || xdotool set_desktop_for_window "$window" "$desktop" # either it's currently shown or move it
	   sed -i "/$desktop/d" "$cache/desktop"* && echo success
	   xdotool search --desktop "$desktop" "" > "$cache/desktop$desktop" ;;
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



getworkspaces(){
    case "$WM" in
	bspwm)
	    workspaces="$(for i in $(wmctrl -d | tr -s '[:blank:]' | awk '{print $2$10}' ); do echo -n "$i  "; done)"
	    ;;

	cwm|CWM)
	    workspaces="$(for i in $(wmctrl -d | tr -s '[:blank:]' | awk '{print $2$10}' ); do echo -n "$i  "; done)"
	    

	    ;;
	*)
	    #something

    esac
    echo $workspaces
}

getactiveworkspaces(){
    parsed="$(wmctrl -d | grep '*' | tr -s '[:blank:]' | cut -f1 -d ' ')"

    case "$WM" in
	awesome|bspwm|cwm|GNOME) echo "$((1 + parsed))" ;;
	# cwm|CWM) group -l | tr '\t' ' ' | cut -f1 -d' ' | cut -f2 -d'_' ;;
	*) echo "$parsed" ;;
    esac
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
fi

case "$1" in
    --carry) send $2 && focus $2 ;;

    -c|--close) close ;;

    -d|--draw) draw ;;

    -f|--focus) focus $2 ;;
    
    -k|--kill) act-kill ;;

    -m|--max|--maximize|--fullscreen) maximize $2 ;;

    -r|--resize) draw ;;

    -p|--pick|--select) pick ;;

    -s|--send) send $2 ;;

    -X|--max-horizontal|--max-h|--horizontal) maximizeh $2 ;;

    -Y|--max-vertical|--max-v|--vertical) maximizev $2 ;;
    
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

