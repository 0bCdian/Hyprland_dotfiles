#!/usr/bin/env bash

## Author : Aditya Shakya (adi1090x)
## Github : @adi1090x
#
## Rofi   : Launcher (Modi Drun, Run, File Browser, Window)
#
## Available Styles
#
## style-1     style-2     style-3     style-4     style-5
## style-6     style-7     style-8     style-9     style-10
## style-11    style-12    style-13    style-14    style-15

background_image=$(cat "$HOME/.cache/swww/cache.txt")
dir="$HOME/.config/rofi/launchers/type-7"
theme='style-clipboard'
# -theme ${dir}/${theme}.rasi
## Run
cliphist list | rofi -dmenu -theme-str 'inputbar {background-image: url("'$background_image'", width);}' -theme ${dir}/${theme}.rasi | cliphist decode | wl-copy 
