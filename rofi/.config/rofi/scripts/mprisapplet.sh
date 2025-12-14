#!/bin/bash
player_applet="$HOME/.config/rofi/themes/mprisapplet.rasi"

if [ -z $1 ]; then
    notify-send "MPRIS Applet" "No players found"
fi

selected_player="$1"

status=$(playerctl -p "$selected_player" status 2>/dev/null)
title=$(playerctl -p "$selected_player" metadata xesam:title 2>/dev/null)
artist=$(playerctl -p "$selected_player" metadata xesam:artist 2>/dev/null)

if [ ${#title} -gt 45 ]; then
    final_title="${title:0:45}..."
else
    final_title="$title"
fi

toggle=""
if [ "$status" = "Playing" ]; then
    toggle=""
fi

prev=""
next=""

display_title="<span weight='light' size='small' alpha='40%'>${selected_player} ${status}</span>"
display_song="<span size='85%'>${final_title}</span>\n<span size='small' style='italic' alpha='60%'>${artist}</span>"

selected_option=$(echo -e "$prev\n$toggle\n$next" | rofi -dmenu -theme "$player_applet" -theme-str "textbox-title { str: \"$display_title\";}" -theme-str "textbox-song { str: \"$display_song\";}" -select "$toggle")
[ -z "$selected_option"] && exit 0

case "$selected_option" in
    "$prev")    playerctl previous ;;
    "$toggle")  playerctl play-pause ;;
    "$next")    playerctl next ;;
    *)          notify-send "MPRIS Applet" "Invalid Option" ;;
esac