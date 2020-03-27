#!/bin/sh

#perform actions on a window, according to the current WM
WM="$($HOME/.scripts/window/getname.sh)"
window="$(xdotool getactivewindow)"

close(){
    case "$WM" in
	bspwm)
	    bspc node "$window" -c
	    ;;

	*)
	    xdotool windowclose "$window"

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


focus(){
    #show a desktop or window group
    #todo: toggle visibility, rather than binary show
    #todo: nogroup
    case "$WM" in
	bspwm)
	    wmctrl -s "$(($1 - 1))"
	    ;;
	i3)
	    #??
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
	    ;;
    esac
    
}



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
    -p|--pick)
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
       
