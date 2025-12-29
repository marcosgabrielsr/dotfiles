#!/bin/bash
set -u

get_power_status() {
    echo "$(bluetoothctl show | grep Powered | awk '{print $2}')"
}

get_conn_device() {
    echo "$(bluetoothctl devices Connected)"
}

set_toggle_option() { 
    local powered="$1"
    
    if [ "$powered" = "yes" ]; then
        echo "⏻ Power off"
    else
        echo "⏻ Power on"
    fi
}

set_status_msg() {
    local msg=""
    local top_msg_config=""
    if [ -n "$1" ]; then
        msg="Status:\n$1"
        top_msg_config="textbox-status-msg { str: \"$msg\"; background-color: @success;}"
    elif [ "$2" = "yes" ]; then
        msg="Status:\nEnabled"
        top_msg_config="textbox-status-msg { str: \"$msg\"; background-color: @urgent;}"
    else
        msg="Status:\nDisabled"
        top_msg_config="textbox-status-msg { str: \"$msg\"; background-color: @urgent;}"
    fi

    echo "$top_msg_config"
}

power_status="$(get_power_status)"
conn_device="$(get_conn_device)"
blue_applet="$HOME/.config/rofi/themes/connapplet.rasi"
top_msg_config="$(set_status_msg "$conn_device" "$power_status")"
options=(
    "$(set_toggle_option "$power_status")"
    " Scan devices"
    "󰟴 Paired devices"
    " bluetoothctl"
)

selected_option="$(printf "%s\n" "${options[@]}" | rofi \
    -dmenu \
    -theme "$blue_applet" \
    -theme-str "$top_msg_config"
)"
[ -z "$selected_option" ] && exit 0