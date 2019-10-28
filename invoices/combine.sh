#!/bin/sh
name="$1"
order="$2"
total="$3"
o="invoices/$(echo "$name" | tr ' ' '_').ms"
echo -e ".TL\nSLUMwear Invoice - $name" > $o && cat groff/1.ms >> $o
echo -e "$order" >> $o && cat groff/2.ms >> $o 
echo ".B \"Your total is \$$total\" ." >> $o && cat groff/3.ms >> $o

#if [ -f invoices/"$(echo "$name" | tr ' ' '_').pdf" ]
#	then groff -ms -Tpdf $o > invoices/"$(echo "$name" | tr ' ' '_')_2.pdf"
#	else groff -ms -Tpdf $o > invoices/"$(echo "$name" | tr ' ' '_').pdf"
#fi


groff -ms -Tpdf $o > invoices/"$(echo "$name" | tr ' ' '_').pdf"


 #\n.SH\nYour order:\n.PP\n$order" > $o

