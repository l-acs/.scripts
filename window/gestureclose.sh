#!/bin/sh

active_win_class="$(xprop -id "$(xdotool getactivewindow)" WM_CLASS | cut -f4 -d'"')"

case "$active_win_class" in
    Chromium|Emacs|Firefox|firefox|Org.gnome.Nautilus|"Tor Browser"|thunderbird|Thunderbird) key="ctrl+w" ;;
    URxvt|kitty) key="ctrl+u ctrl+d ctrl+c" ;;
    # hopefully putting them in this order means that at most one program is closed (whereas e.g.`ctrl+c ctrl+d` could kill a running process and then close the shell)
    Signal) key="ctrl+shift+a" ;; # archive convo
    Zathura|mpv) key="q" ;;
    *) key="alt+F4" ;;
esac

xdotool key $key
    
