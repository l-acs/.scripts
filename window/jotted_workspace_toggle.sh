#!/bin/sh

#to emulate the use of tags.
#never actually show multiple desktops at once, but rather always display one mega workspace and track membership

#intended for cwm

#usage: ./jotted_workspace_toggle.sh <workspace_num>


fifo_d="$HOME/.scripts/window/.cache/"
mega=9 #let workspace 9 be the megaworkspace
desktop="$1"

#todo: hide all current

show(){
    echo $shown$desktop >> $fifo_d/current

    while read i; do

	xdotool set_desktop_for_window "$i" 9 \
		windowactivate "$i" \
		windowraise "$i"
	
    done < $fifo_d/desktop$desktop


}


hide(){
    
    sed -i "/$desktop/d" $fifo_d/current
    
    while read i; do
	
	xdotool set_desktop_for_window "$i" $desktop 

    done < $fifo_d/desktop$desktop


}






if $(grep -q "$desktop" $fifo_d/current); then #currently displayed
#    echo hiding...
    hide
else
#    echo showing...
    show
fi

     
   



#thinking: group new windows based on oldest currently displayed group?
