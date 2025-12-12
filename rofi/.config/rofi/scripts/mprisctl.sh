#!/bin/bash
player_list="$HOME/.config/rofi/themes/mprislist.rasi"
sep=$'\x1f'

players=$(playerctl -l 2>/dev/null)
[ -z "$players" ] && notify-send "Rofi Player" "No players found" && exit 0

menu=""
while IFS= read -r p; do
    status=$(playerctl -p "$p" status 2>/dev/null)
    
    if [ "$status" != "Stopped" ]; then
        title=$(playerctl -p "$p" metadata xesam:title 2>/dev/null)
        artist=$(playerctl -p "$p" metadata xesam:artist 2>/dev/null)

        [ -z "$title" ] && title="(no title)"
        [ -z "$artist" ] && artist="(unknown)"

        line1="$p | $artist"
        line2="$title"
        entry="$line1\n$line2"
    
        if [ "$status" = "Paused" ]; then
            menu+=" $entry$sep"
        elif [ "$status" = "Playing" ]; then
            menu+=" $entry$sep"
        fi
    fi

done <<< "$players"

choice=$(printf "%b" "$menu" | rofi -dmenu -sep "$sep" -p "Players" -i -theme "$player_list")
[ -z "$choice" ] && exit 0