#!/bin/sh
wmctrl -m  | head -n 1 | cut -f2 -d ' ' 
