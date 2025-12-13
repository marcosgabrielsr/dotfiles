#!/bin/bash
player_list="$HOME/.config/rofi/themes/mprislist.rasi"
sep=$'\x1f'

players_raw=$(playerctl -l 2>/dev/null)
[ -z "$players_raw" ] && notify-send "Rofi Player" "No players found" && exit 0

menu_display=""
declare -a player_ids
counter=0
while IFS= read -r p_id; do
    status=$(playerctl -p "$p_id" status 2>/dev/null)
    
    if [ "$status" != "Stopped" ]; then
        title=$(playerctl -p "$p_id" metadata xesam:title 2>/dev/null)
        artist=$(playerctl -p "$p_id" metadata xesam:artist 2>/dev/null)

        [ -z "$title" ] && title="(no title)"
        [ -z "$artist" ] && artist="(unknown)"

        case "$p_id" in
            *Spotify*|*spotify*)    display_name="Spotify" ;;
            *Brave*|*brave*)        display_name="Brave ($p_id)" ;;
            *)                      display_name="$p_id" ;;
        esac

        if [ "$status" = "Paused" ]; then
            icon=""
        else
            icon=""
        fi

        visual_item=" $icon $display_name | $artist"$'\n'"$title"
        player_ids[$counter]="$p_id"
        menu_display+="$visual_item$sep"

        ((counter++))
    fi

done <<< "$players_raw"

selected_index=$(printf "%s" "$menu_display" | rofi -dmenu -sep "$sep" -mesg "Players" -i -theme "$player_list" -format i)
[ -z "$selected_index" ] && exit 0

chosen_player="${player_ids[$selected_index]}"
echo "$chosen_player"