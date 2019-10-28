#!/bin/sh
name="$1"
address="$2"
body="$3"
files="$4"
neomutt -F /home/user/.config/mutt/accounts/4-mcgill.muttrc -s "SLUMwear Invoice - $name" -a $files -- $address < $body 
