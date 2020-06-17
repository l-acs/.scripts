#!/bin/sh

#perform actions on a window, according to the current WM
WM="$($HOME/.scripts/window/getname.sh)"
window="$(xdotool getactivewindow)"
cache="$HOME/.scripts/window/.cache"
activetags="$cache/current"
thumbquality=100
mkdir -p "$cache/thumbnails"


capture(){
    echo "Capturing..."
    # higher quality makes this faster. It means less effort spent on compression, which means less time spent before scrot returns
    tmp="$cache"/thumbnails/temp.png
    scrot -q $thumbquality -o "$tmp"
    for i in $(getactiveworkspaces); do
	cp "$tmp" "$cache/thumbnails/$i.png"
    done
    


}


capturefocuscapture(){
    hidethumbnail
    capture && focus "$1" && capture

}




close(){
    case "$WM" in
	bspwm)
	    bspc node "$window" -c
	    ;;

	awesome|CWM)
	    wmctrl -c :ACTIVE:
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


#idea: for cwm/tags mod4 when ws 4 is not active is the same thing as moving all windows in group 4 into the mega group. mod4 when ws 4 is active is the same thing as moving all windows in ws 4 out of the mega group
















focus(){
    #show a desktop or window group
    #problem: this hides others as well. it should only toggle the visibility of the current group
    case "$1" in
	next|n)
	    arg="$(("$(getactiveworkspaces)" + 1))"
	    ;;
	prev|p)
	    arg="$(("$(getactiveworkspaces)" - 1))"
	    ;;
	
	*)
	    arg="$1"
	    ;;

    esac

    
    case "$WM" in
	bspwm)
	    case "$arg" in
		[1-9])
		    wmctrl -s "$(("$arg" - 1))"
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
	    #$HOME/.scripts/window/jotted_workspace_toggle.sh "$arg"
	    group --tog $arg
	    ;;
	*)
	    wmctrl -s "$arg"
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

    case "$WM" in
	bspwm)
	    xdotool set_desktop_for_window "$window" $(($1 - 1))
	    ;;
	i3)
	    #something
	    ;;
	cwm|CWM)
	    group --add $1 $(pfw)
	    ;;
	
	*)
	    grep -q $1 "$activetags" || xdotool set_desktop_for_window "$window" $1 #either it's currently shown or move it
	    sed -i "/$1/d" "$cache/desktop"* && echo success
	    xdotool search --desktop $1 "" > "$cache/desktop$1"


	    ;;
    esac
    
}


getwindowsinworkspace(){ #start count at 0
    case "$WM" in
	bspwm)
	    var="$(xdotool search --desktop "$1" "")"
	    #$(($1 - 1))" "")"
	    ;;

	cwm|CWM)
	    var="$(cat "$cache/desktop$1")"
	    

	    ;;
	*)
	    #something

    esac
    echo $var
}



getworkspaces(){
    case "$WM" in
	bspwm)
	    var="$(for i in $(wmctrl -d | tr -s '[:blank:]' | awk '{print $2$10}' ); do echo -n "$i  "; done)"
	    ;;

	cwm|CWM)
	    var="$(for i in $(wmctrl -d | tr -s '[:blank:]' | awk '{print $2$10}' ); do echo -n "$i  "; done)"
	    

	    ;;
	*)
	    #something

    esac
    echo $var
}



getactiveworkspaces(){
    case "$WM" in
	bspwm)
	    echo "$((1 + "$(wmctrl -d | grep '*' | tr -s '[:blank:]' | cut -f1 -d ' ')"))"
	    ;;
	cwm|CWM)
	    group -l | tr '\t' ' ' | cut -f1 -d' ' | cut -f2 -d'_'
	    ;;
	*)
	    wmctrl -d | grep '*' | tr -s '[:blank:]' | cut -f1 -d ' '
	    ;;
	

    esac
}


showthumbnail(){
    hidethumbnail
    
    case "$WM" in
	bspwm)
	    bspc rule -a workspacethumbnail -o manage=off
	    ;;

    esac

    file="$cache/thumbnails/$1.png" 


    
    #figure out window size
    width="$(feh -L '%w' "$file")"
    height="$(feh -L '%h' "$file")"
    thumbwidth=248

    #yuck math in the shell. there's _hopefully_ a better way to do this, but this was faster than continuing to dig for what that is.
    scale="$(echo "scale=3;$width/$thumbwidth" | bc)"
    thumbheight="$(echo "$height/$scale" | bc)"

 
    #figure out mouse location
    eval $(xdotool getmouselocation --shell)
    
    
    winX=$((X-thumbwidth/2)) #problematic: this assumes the workspaces are on the left #1100
    winY=25
    #winY=$((Y+20)) #problematic: this assumes the bar is on the top
    
    #instead, checks should be done against the screen resolution


    [ "$winX" -lt 10 ] && winX=10    
    
    

    # TODO: change feh call so any keypress will kill the window
    [ $Y -lt 25 ] && [ $X -lt 350 ] && feh "$file" --class workspacethumbnail  -g "$thumbwidth"x"$thumbheight"+$winX+$winY -. &
    sleep 2.5 && hidethumbnail &

    
}


hidethumbnail(){

    pkill -f workspacethumbnail

}





#todo: cwm focus $1 & hide other tags






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
    --getworkspace*|--getdesktop*)
	getworkspaces
	;;
    --getwindows*)
	getwindowsinworkspace $2
	;;
    --*actived*|--*activew*)
	getactiveworkspaces
	;;
    --capture|--thumbnail)
	capture
	;;
    --capturefocuscapture)
	capturefocuscapture $2
	;;
    --showthumbnail)
	showthumbnail $2
	;;
    --hidethumbnail)
	hidethumbnail
	;;
    *)
	helpme
	exit 1
	;;
esac

exit 0

