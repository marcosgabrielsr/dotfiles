#!/bin/bash
set -u

# Functions
get_wifi_networks() {
    nmcli -t -f SSID,SIGNAL,BARS,SECURITY device wifi list
}

get_formatted_networks_list() {
    get_wifi_networks | \
    awk -F: -v fmt="$1" '{ printf fmt, $1, $2, $3, $4 }'
}

get_current_wifi_conn() {
    nmcli -t -f ACTIVE,SSID,SIGNAL device wifi list | awk -F: '$1=="yes" {print $2 " " $3}'
}

set_status_msg() {
    local msg=""
    local top_msg_config=""
    if [ -n "$1" ]; then
        msg="Status:\n$1"
        top_msg_config="textbox-status-msg { str: \"$msg\"; background-color: @success;}"
    elif [ "$2" = "enabled"]; then
        msg="Status:\nEnabled"
        top_msg_config="textbox-status-msg { str: \"$msg\"; background-color: @urgent;}"
    else
        msg="Status:\nDisabled"
        top_msg_config="textbox-status-msg { str: \"$msg\"; background-color: @urgent;}"
    fi

    echo "$top_msg_config"
}

set_toggle_option() {
    local toggle_msg=""
    if [ $1 = "enabled" ]; then
        toggle_msg="Power off"
    else
        toggle_msg="Power on"
    fi

    echo "$toggle_msg"
}

# Variables Attribution
layout="%-20s %-6s %-6s %-8s\n"
status="$(nmcli radio wifi)"
current_network="$(get_current_wifi_conn)"
nmcli_applet="$HOME/.config/rofi/themes/nmcliapplet.rasi"
menu_wifi_list="$HOME/.config/rofi/themes/wifilist.rasi"
headers=$(printf "$layout" "SSID" "SIGNAL" "BARS" "SECURITY")
column_headers_config="textbox-column-headers { str: \"$headers\"; }"
top_msg_config="$(set_status_msg "$current_network" "$status")"
options=(
    "$(set_toggle_option "$status")"
    "󱄙 Get NetWorks"
    " Refresh"
    " nmtui"
)

selected_option="$(printf "%s\n" "${options[@]}" | rofi \
    -dmenu \
    -theme "$nmcli_applet" \
    -theme-str "$top_msg_config" \
)"
[ -z "$selected_option" ] && exit 0

echo "$selected_option"

case "$selected_option" in
    "Power on")
        nmcli radio wifi on
        ;;

    "Power off")
        nmcli radio wifi off
        ;;

    "󱄙 Get NetWorks")
        networks="$(get_formatted_networks_list "$layout")"
        selected_network="$(echo "$networks" | rofi \
            -dmenu \
            -theme "$menu_wifi_list" \
            -theme-str "$column_headers_config"
        )"
        ;;
    
    " Refresh")
        nmcli radio wifi off
        sleep 2
        nmcli radio wifi on
        sleep 2
        nmcli device wifi rescan
        ;;

    " nmtui")
        kitty --detach -e nmtui
        ;;
esac
