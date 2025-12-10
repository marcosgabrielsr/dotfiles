#!/bin/bash
path="~/.config/rofi/themes/cliphist.rasi"
cliphist list | rofi -dmenu -display-columns 2 -theme $path | cliphist decode | wl-copy