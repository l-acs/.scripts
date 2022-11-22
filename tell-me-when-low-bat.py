#!/bin/python3

import requests

from os import popen as sh
from time import sleep
from os import environ as env

# todo: change
url = env.get("NTFY_POMO_URL")


def get_bat ():
    out = sh("acpi").read().strip('\n')
    return out

def bat_draining(bat_info):
    return bat_info[2] == "Discharging,"

def percent(bat_info):
    return int(bat_info[3].strip('%,'))

def below_threshold (bat_info, min):
    bat_percent = percent(bat_info)
    return bat_percent <= min




while True:
     bat_str = get_bat()
     bat = bat_str.split(' ')

     if below_threshold(bat, 20) and bat_draining(bat):
         requests.post(url,
                       data = bat_str,
                       headers = { "Tags": "battery" })
         sleep (60 * 5) # remind me in 5min

     else:
         sleep (60 * 3) # check again in 3min
         



