.TL
l-acs' i3 keybindings

.LP

.B "XF86AudioRaiseVolume"
.LP
exec --no-startup-id pactl set-sink-volume @DEFAULT_SINK@ +5%  \*-   Use pactl to adjust volume in PulseAudio.

.B "XF86Forward"
.LP
exec mpc next && exec reload-cover   \*-  use mpc to go to next song

.B "XF86Back"
.LP
exec mpc prev && exec reload-cover   \*-  use mpc to go to previous song

.B "Shift+XF86Back"
.LP
exec mpc seek 0%  \*-  use mpc to restart the current song

.B "Shift+XF86Forward"
.LP
exec mpc toggle  \*-  use mpc to pause current song

.B "$mod+Return"
.LP
exec i3-sensible-terminal  \*-   start a terminal

.B "$mod+Shift+space"
.LP
floating toggle  \*-   toggle tiling / floating

.B "$mod+space"
.LP
focus mode_toggle  \*-   change focus between tiling / floating windows

.B "$mod+1"
.LP
workspace $ws1  \*-   switch to workspace

.B "$mod+Shift+1"
.LP
move container to workspace $ws1  \*-   move focused container to workspace

.B "$mod+F12"
.LP
exec "i3-nagbar -t warning -m 'You pressed the exit shortcut. Do you really want to exit i3? This will end your X session.' -B 'Yes, exit i3' 'i3-msg exit'"  \*-   exit i3 (logs you out of your X session)

.B "$mod+a"
.LP
focus parent  \*-   focus the parent container

.B "$mod+Shift+a"
.LP
exec feh --scale-down -g 599x377 --image-bg black --reload=1 .scripts/output/cover.jpg  \*-   display cover art

.B "$mod+b"
.LP
exec firefox  \*-  browser:

.B "$mod+Shift+b"
.LP
exec i3-sensible-terminal -e $EDITOR ~/.bashrc  \*-  open .bashrc

.B "$mod+c"
.LP
exec i3-sensible-terminal -e $EDITOR ~/.config/i3/config  \*-  open this file:

.B "$mod+Shift+c"
.LP
reload  \*-   reload the configuration file

.B "$mod+d"
.LP
exec dmenu_run -b -p "Type to search"  \*-   start dmenu (a program launcher)

.B "$mod+Shift+d"
.LP
border toggle  \*-   display title toggle

.B "$mod+e"
.LP
exec i3-sensible-terminal -e neomutt &  \*-  email:

.B "$mod+Shift+e"
.LP
exec mailsync  \*-  refresh email:

.B "$mod+f"
.LP
fullscreen toggle  \*-   enter fullscreen mode for the focused container

.B "$mod+g"
.LP
exec sudo killall compton && compton & disown  \*-  may fail: compton

.B "$mod+h"
.LP
focus left  \*-   change focus

.B "$mod+Shift+h"
.LP
move left  \*-   move focused window

.B "$mod+i"
.LP
gaps inner all plus 1  \*-  increase inner gaps in real time

.B "$mod+Shift+i"
.LP
gaps inner all minus 1  \*-  decrease inner gaps in real time

.B "$mod+m"
.LP
exec i3-sensible-terminal  -e ncmpcpp &  \*-  music:

.B "$mod+Shift+m"
.LP
exec monitor toggle  \*-  add dual-monitor support

.B "$mod+n"
.LP
exec i3-sensible-terminal -e newsboat &  \*-  newsboat:

.B "$mod+Shift+n"
.LP
exec newsboat -x reload  \*-  refresh newsboat

.B "$mod+o"
.LP
gaps outer all plus 1  \*-  increase outer gaps in real time

.B "$mod+Shift+o"
.LP
gaps outer all minus 1  \*-  decrease outer gaps in real time

.B "$mod+p"
.LP
exec dmenumanpdf  \*-  dmenu for pdfs of man pages

.B "$mod+Shift+p"
.LP
[title="/home/user/.scripts/output/man.pdf"] scratchpad show; [title="/home/user/.scripts/output/man.pdf"] move position center  \*-  pull up man page pdf 

.B "$mod+Shift+q"
.LP
kill  \*-   kill focused window

.B "$mod+r"
.LP
mode "resize"  \*-   enter resize mode

.B "$mod+Shift+r"
.LP
restart; exec sudo killall compton && compton & disown  \*-   restart i3 inplace (preserves your layout/session, can be used to upgrade i3)

.B "$mod+Shift+u"
.LP
exec sudo pacman -Syuw --noconfirm >> /home/user/.scripts/output/pacman.log  \*-  download updates

.B "$mod+s"
.LP
split toggle  \*-  switch split from horizontal to vertical or vice versa

.B "$mod+Shift+s"
.LP
exec feh ~/Media/pic/sch.jpg  \*-  open schedule

.B "$mod+t"
.LP
exec tdsel   \*-  td selector:

.B "$mod+Shift+t"
.LP
exec i3-sensible-terminal -e td &  \*-  td:

.B "$mod+v"
.LP
exec vsel  \*-  select videos to watch:

.B "$mod+Shift+v"
.LP
exec vlc  \*-  open vlc:

.B "$mod+w"
.LP
exec i3-sensible-terminal -e jot "$(ls doc/productivity/brainstorming/jot/ | sed 's/.txt//' | dmenu)" &  \*-  select jot list:

.B "$mod+x"
.LP
exec xournalpp  \*-  open xournal:

.B "$mod+Shift+x"
.LP
exec zathura /home/user/doc/ref/latex/latex_math.pdf  \*-  latex math manual

.B "$mod+z"
.LP
exec zathura  \*-  open zathura

.B "$mod+apostrophe"
.LP
exec echo -n '"' | xsel --clipboard  \*-  double quotes

.B "$mod+grave"
.LP
exec echo -n '~' | xsel --clipboard  \*-  tilde

.B "$mod+Shift+slash"
.LP
exec echo -n '¯\_(ツ)_/¯' | xsel --clipboard  \*-  shrug emoji

.B "$mod+Shift+Return"
.LP
exec drop-down; [instance="dropdown"] scratchpad show; [instance="dropdown"] move position center  \*-  open dropdown terminal

.B "--whole-window"
.LP
$mod+button1 move left  \*-  move window left

.B "--whole-window"
.LP
$mod+button3 move right  \*-  move window right

.B "$mod+Shift+button2"
.LP
--whole-window --border exec rectmove  \*-  select region to which to resize the current window

.B "$mod+Shift+button3"
.LP
--whole-window --border exec rectlaunch  \*-  launch an application and draw its container

