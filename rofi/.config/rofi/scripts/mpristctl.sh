#!/bin/bash
player_list="$HOME/.config/rofi/scripts/mprislist.sh"
player_applet="$HOME/.config/rofi/scripts/mprisapplet.sh"

# Get the selected player id
selected_player=$("$player_list")
echo -e "selected player: $selected_player"

# Call the applet to the selected player
"$player_applet" "$selected_player"