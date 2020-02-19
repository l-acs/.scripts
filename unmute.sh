#!/bin/sh

amixer -c 0 sset "Auto-Mute Mode" Disabled
amixer sset Master unmute
amixer sset Speaker unmute
#amixer sset Speaker+LO unmute
amixer sset Headphone unmute

amixer set Speaker+LO 100%
