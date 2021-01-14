#!/bin/sh


active_win_class="$(xprop -id "$(xdotool getactivewindow)" WM_CLASS | cut -f4 -d'"')"

case "$active_win_class" in
    Emacs)
	key="ctrl+x k"
	;;
    firefox|"Tor Browser")
	key="ctrl+w"
	;;
    URxvt) # works for tmux, etc; aligns with the intuition that 3 fingers is 'soft' close and 4 'hard'
	key="ctrl+u ctrl+d"
	;;
    Signal) # close media, etc
	key="Escape"
	;;
    Zathura)
	key="q"
	;;
    *)
	key=F4
	;;
esac

xdotool key $key
    
