#!/bin/bash
player_applet="$HOME/.config/rofi/themes/mprisapplet.rasi"

if [ -z $1 ]; then
    notify-send "MPRIS Applet" "No players found"
fi

selected_player="$1"
status=$(playerctl -p "$selected_player" status 2>/dev/null)
title=$(playerctl -p "$p_id" metadata xesam:title 2>/dev/null)
artist=$(playerctl -p "$p_id" metadata xesam:artist 2>/dev/null)

toggle=""
if [ "$status" = "Playing" ]; then
    toggle=""
fi

prev=""
next=""

display_text="<span weight='light' size='small' alpha='50%'>${selected_player} ${status}</span>\n\n${title}\n<span size='small' style='italic' alpha='65%'>${artist}</span>"


selected_option=$(echo -e "$prev\n$toggle\n$next" | rofi -dmenu -theme "$player_applet" -theme-str "textbox-custom { str: \"$display_text\";}" -select "$toggle")
[ -z "$selected_option" ] && exit 0

case "$selected_option" in
    "$prev")    playerctl previous ;;
    "$toggle")  playerctl play-pause ;;
    "$next")    playerctl next ;;
    *)          notify-send "MPRIS Applet" "Invalid Option" ;;
esac