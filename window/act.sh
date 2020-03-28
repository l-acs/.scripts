#!/bin/sh

#perform actions on a window, according to the current WM
WM="$($HOME/.scripts/window/getname.sh)"
window="$(xdotool getactivewindow)"
mkdir -p $HOME/.scripts/window/.cache/



close(){
    case "$WM" in
	bspwm)
	    bspc node "$window" -c
	    ;;

	*)
	    wmctrl -i -c "$window"

    esac
}



draw(){
    input="$(xrectsel)"
    position="$(echo "$input" | cut -d '+' -f2-3 | tr '+' ' ')"
    size="$(echo "$input" | cut -d '+' -f1 | tr 'x' ' ')"
    case "$WM" in
	bspwm)
	    bspc node -t floating "$window"
	    ;;
	i3)
	    #something
	    ;;
	*)
	    #nothing?
	    ;;
    esac
    xdotool windowmove "$window"  $position windowsize "$window" $size

}


#idea: for cwm/tags mod4 when ws 4 is not active is the same thing as moving all windows in group 4 into the mega group. mod4 when ws 4 is active is the same thing as moving all windows in ws 4 out of the mega group
















focus(){
    #show a desktop or window group
    #problem: this hides others as well. it should only toggle the visibility of the current group
    case "$WM" in
	bspwm)
	    case $1 in
		[1-9])
		    wmctrl -s "$(($1 - 1))"
		    ;;
		0|10)
		    wmctrl -s 9
		    ;;
	    esac
	    
	    ;;
	i3)
	    #??
	    ;;

	
	CWM|cwm)
	    #sneakily implement tags
	    $HOME/.scripts/window/jotted_workspace_toggle.sh $1 
	    ;;
	*)
	    wmctrl -s $1
	    ;;
    esac
}

helpme(){

    echo "Usage: "
    echo "act.sh [-p] -[cdk] "
    echo "act.sh -[fs] DESKTOP"
    echo "act.sh [-h]"



}



kill(){
    case "$WM" in
	bspwm)
	    bspc node "$window" -k
	    ;;

	*)
	    xdotool windowkill "$window"
    esac

}

pick(){
	  xdotool selectwindow
}

send(){
    #send window to desktop
    #todo: nogroup
    case "$WM" in
	bspwm)
	    xdotool set_desktop_for_window "$window" $(($1 - 1))
	    ;;
	i3)
	    #something
	    ;;
	*)
	    xdotool set_desktop_for_window "$window" $1
	    xdotool search --desktop $1 "" > $HOME/.scripts/window/.cache/desktop$1

	    ;;
    esac
    
}


#maximizev()
#log window id and current vertical geometry in a cache file
#if a window doesn't match max vertical monitor size (minus gaps), maximize it vertically; otherwise, revert it to cached value (or if that value is not stored, do nothing)

#maximizeh()
#log window id and current horizontal geometry in a cache file
#if a window doesn't match max horizontal monitor size (minus gaps), maximize it horizontally; otherwise, revert it to cached value (or if that value is not stored, do nothing)




if [ "$1" = "-p" ] || [ "$1" = "--pick" ]; then
    window=$(pick)
fi

case "$1" in
    -c|--close)
	close
	;;
    -d|--draw)
	draw
	;;

    -f|--focus)
	focus $2
	;;
    
    -k|--kill)
	kill
	;;
    -r|--resize)
	draw
	;;
    -p|--pick|--select)
	pick
    	;;

    -s|--send)
	send $2
	;;
    
    -h|--help)
	helpme
	;;
    *)
	helpme
	exit 1
	;;
esac

exit 0
       
