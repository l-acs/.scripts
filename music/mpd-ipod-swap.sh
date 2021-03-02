#!/bin/sh

# to allow using iPod attached via USB as an MPD database
dotfiles=~/.dot
rm ~/.config/ncmpcpp/error.log

case "$1" in
    ipod)
	cd "$dotfiles" || exit 2 ; stow -D mpd ncmpcpp ; stow ipod
	;;

    computer)
	cd "$dotfiles" || exit 2 ; stow -D ipod ; stow mpd ncmpcpp
	;;

    *)
	echo Invalid argument.
	exit 1
	;;

esac

# start mpd and mpdas
systemctl restart --user mpd &&
     systemctl restart --user mpdas && mpc update
