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







printhelp(){

    echo "Usage: "
    echo "act.sh [-s] -[cdk] "
    echo "act.sh -f DESKTOP"
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



sel(){
	  xdotool selectwindow
}




if [ "$1" = "-s" ] || [ "$1" = "--select" ]; then
    window=$(sel)
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
    -s|--select)
	sel
    	;;
    -h|--help)
	printhelp
	;;
    *)
	printhelp
	exit 1
	;;
esac

exit 0
       
