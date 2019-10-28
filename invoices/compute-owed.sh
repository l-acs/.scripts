#!/bin/sh

while read i
do
	name="$(echo "$i" | cut -f2)"
	email="$(echo "$i" | cut -f3)"
	owed="$(echo "$i" | cut -f4 | grep -o [0-9] | tr -d "\n" | tr -d ' ' | sed 's/1315/13/')"
	o2="$(echo "$i" | cut -f8 | grep -o [0-9] | tr -d "\n" | tr -d ' ' | sed 's/1315/13/')"
	o3="$(echo "$i" | cut -f12 | grep -o [0-9] | tr -d "\n" | tr -d ' ' | sed 's/1315/13/')"
	if [ -n "$owed" -a -n "$o2" ]; then owed=$(($owed+$o2)); fi
	if [ -n "$owed" -a -n "$o3" ];	then owed=$(($owed+$o3)); fi
	./combine.sh "$name" "$(echo "$i" | cut -f4-7)\n.PP\n$(echo "$i" | cut -f8-11)\n.PP\n$(echo "$i" | cut -f12-15)" "$owed"
	./email.sh "$name" "lucas.sahar@mail.mcgill.ca" body.txt invoices/"$(echo "$name" | tr ' ' '_').pdf"
done < "$1"

#todo: combine entries under the same name
