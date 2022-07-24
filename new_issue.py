#!/bin/python3

from os import environ as env
from os import system as sh
from os import popen
from time import sleep


repos = {
    'admin': ('school', 'db-admin'),
    'contact': ('external', 'contact'),
    'jobs': ('external', 'jobs'),
    'mgmt': ('school', 'db-mgmt'),
    'syntax': ('school/s2022', 'syntax')
}


default_browser = env.get("WEB", "firefox")
gitlab_browser = env.get("GITLAB_WEB", default_browser)

base = env.get("GITLAB_URL", "gitlab.com")
suffix = '/-/issues'
new = '/new'

def build_url(repo_id):
    return base + repo_id + suffix + new

def format (d):
    return '\n'.join(d.keys())

def join (item):
    if (type(item) is tuple):
        ns, repo = item
        return f"{ns}/{repo}"

    else:
        return item

def rofi_select ():
    # todo: fall back to dmenu if rofi is not installed
    selection = popen(f'echo "{format(repos)}" | rofi -dmenu').read().strip()

    return join(repos[selection]) \
        if selection in repos \
           else selection

def open_and_go (url, browser):
    sh(browser + " " + url)


sel = rofi_select()

if sel:
    url = build_url(sel)
    print(url)
    open_and_go(url, gitlab_browser)
