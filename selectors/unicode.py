#!/usr/bin/env python3

import sys

def hex_to_UTF8 (word_code):
    hex_to_int = int (word_code, 16)
    as_char = chr(hex_to_int)
    return as_char
    

out = [ hex_to_UTF8(word_code) for word_code in sys.argv[1:] ]

print(*out, end = "")
