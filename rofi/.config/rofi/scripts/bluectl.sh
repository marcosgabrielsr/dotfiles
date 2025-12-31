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

get_conn_device_name() {
    local add_info_size=$((6 + 1 + 17 + 1))
    local conn_device="$(get_conn_device)"
    local dname=""
    if [ -n "$conn_device" ]; then
        dname="${conn_device:$add_info_size}"
    fi

    echo "$dname"
}

get_paired_devices() {
    echo "$(bluetoothctl devices Paired | sed 's/Device //')"
}

open_bluetoothctl() {
    kitty_exec_tui bluetoothctl
}

get_paired_devices_names() {
    local mac_address_size=17
    local dnames=""
    while IFS= read -r line; do
        dnames+="${line:((mac_address_size + 1))}\n"
    done <<< "$(get_paired_devices)"

    echo "$dnames"
}

# Main code
power_status="$(get_power_status)"
conn_device="$(get_conn_device_name)"
status_msg_config="$(set_status_msg "$conn_device" "$power_status" "$conn_device" "yes")"
options=(
    "$(set_toggle_option "$power_status" "yes")"
    " Scan devices"
    "󰟴 Paired devices"
    " bluetoothctl"
)

selected_option="$(printf "%s\n" "${options[@]}" | rofi \
    -dmenu \
    -theme "$conn_applet_menu" \
    -theme-str "$(set_top_msg_conn_applet "󰂯 Bluetooth")" \
    -theme-str "$status_msg_config"
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
        paired_devices="$(get_paired_devices_names)"

        paired_device="$(printf "$paired_devices" | rofi \
            -dmenu \
            -theme "$menu_list" \
            -theme-str "$(set_top_msg_menulist '󰟴 Paired devices')" \
            -theme-str "$(set_rofi_window_width '18%')" \
            -theme-str "$(rofi_hide 'column-headers')" \
        )"
        [ -z "$paired_device" ] && exit 0
        ;;

    " bluetoothctl")
        open_bluetoothctl
        ;;
esac