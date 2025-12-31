#!/bin/bash
set -u

# Imporing dependencies
source "$HOME/.config/rofi/scripts/utils/conn-utils.sh"

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

get_paired_devices() {
    echo "$(bluetoothctl devices Paired | sed 's/Device //')"
}

open_bluetoothctl() {
    kitty_exec_tui bluetoothctl
}

power_status="$(get_power_status)"
conn_device="$(get_conn_device)"
blue_applet="$HOME/.config/rofi/themes/connapplet.rasi"
device_menu_list="$HOME/.config/rofi/themes/menulist.rasi"
top_msg_config="$(set_status_msg "$conn_device" "$power_status" "In working..." "yes")"
options=(
    "$(set_toggle_option "$power_status" "yes")"
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

case "$selected_option" in
    "⏻ Power on")
        bluetoothctl power on > /dev/null 2>&1
        ;;
    
    "⏻ Power off")
        bluetoothctl power off > /dev/null 2>&1
        ;;

    " Scan devices")
        echo -e " Scan devices"
        ;;

    "󰟴 Paired devices")
        paired_devices="$(get_paired_devices)"

        paired_device="$(printf "$paired_devices" | rofi \
            -dmenu \
            -theme "$device_menu_list" \
            -themes-str "$top_msg_config" \
        )"
        [ -z "$paired_device" ] && exit 0
        ;;

    " bluetoothctl")
        open_bluetoothctl
        ;;
esac