#!/bin/bash
set -u

# Imporing dependencies
source "$HOME/.config/rofi/scripts/utils/conn-utils.sh"

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

get_all_already_connected() {
    echo "$(nmcli -t connection show | awk -F: '{print $1}' | grep -vx 'lo')"
}

get_ssid_from_network_format() {
    local network=$1
    local raw_ssid="${network:0:$2}"
    local real_ssid="$(echo "$raw_ssid" | sed 's/ *$//')"
    echo "$real_ssid"
}

get_security_from_network_format() {
    local network=$1
    local raw_sec="${network:$2}"
    local real_sec="$(echo "$raw_sec" | sed 's/ *$//')"
    echo "$real_sec"
}

device_refresh() {
    # nmcli radio wifi off
    # sleep 1
    # nmcli radio wifi on
    # sleep 1
    nmcli device wifi rescan
}

connect_to_wifi() {
    local ssid="$1"
    local pass="$2"
    
    if nmcli connection show "$ssid" &> /dev/null; then
        if nmcli connection up id "$ssid"; then
            notify-send "Network " "Connection established (Saved Profile)"
            return 0
        else
            nmcli connection delete id "$ssid" &> /dev/null
        fi
    fi

    if nmcli -w 20 device wifi connect "$ssid" password "$pass"; then
        notify-send "Network " "Connection established"
    else
        notify-send "Network " "Connection failure"
        nmcli device wifi rescan
    fi
}

delete_conn() {
    ssid="$1"
    alert_msg="Are you sure to delete the $ssid connection?"
    alert_msg_style="textbox-alert-msg { str: \"$alert_msg\"; }"

    selected_option=$(printf "yes\nno" | rofi \
        -dmenu \
        -theme "$menu_confirm" \
        -theme-str "$alert_msg_style"
    )
    [ -z "$selected_option" ] && exit 

    if [ "$selected_option" = "yes" ]; then
        if nmcli connection delete id "$ssid" &> /dev/null; then
            notify-send "Network " "$ssid network was deleted"
        else
            notify-send "Network " "Error to delete $ssid network"
        fi
    fi
}

open_nmtui() {
    kitty_exec_tui nmtui
}

# Main code
ssid_width=20
signal_width=6
bars_width=6
security_width=8
layout="%-${ssid_width}s %-${signal_width}s %-${bars_width}s %-${security_width}s\n"

status="$(nmcli radio wifi)"
current_network="$(get_current_wifi_conn)"
headers=$(printf "$layout" "SSID" "SIGNAL" "BARS" "SECURITY")
column_headers_config="textbox-column-headers { str: \"$headers\"; }"
status_msg_config="$(set_status_msg "$current_network" "$status" "$current_network" "enabled")"
options=(
    "$(set_toggle_option "$status" "enabled")"
    "󱄙 Get NetWorks"
    " Refresh"
    "󰩹 Remove Network"
    " nmtui"
)

selected_option="$(printf "%s\n" "${options[@]}" | rofi \
    -dmenu \
    -theme "$conn_applet_menu" \
    -theme-str "$(set_top_msg_conn_applet " Wifi")" \
    -theme-str "$status_msg_config" \
)"
[ -z "$selected_option" ] && exit 0

case "$selected_option" in
    "⏻ Power on")
        nmcli radio wifi on
        ;;

    "⏻ Power off")
        nmcli radio wifi off
        ;;

    "󱄙 Get NetWorks")
        networks="$(get_formatted_networks_list "$layout")"
        selected_network="$(echo "$networks" | rofi \
            -dmenu \
            -theme "$menu_list" \
            -theme-str "$(set_top_msg_menulist '󱄙 Get NetWorks')" \
            -theme-str "$column_headers_config"
        )"
        [ -z "$selected_network" ] && exit 0

        ssid="$(get_ssid_from_network_format "$selected_network" "$ssid_width")"
        if nmcli connection show "$ssid" &> /dev/null; then
            connect_to_wifi "$ssid" ""
            exit 0
        fi

        textbox_network_name_style="textbox-network-name { str: \"Wifi name: $ssid\"; }"
        sec_pos=$(($ssid_width + 1 + $signal_width + 1 + bars_width + 1))
        sec_type="$(get_security_from_network_format "$selected_network" "$sec_pos")"

        if echo "$current_network" | grep -q "$ssid"; then
            notify-send "Network " "Network already connected"
        
        elif [[ "$sec_type" == *"WPA"* || "$sec_type" == *"WPE"* ]]; then
            password=$(rofi \
                -dmenu \
                -password \
                -theme "$menu_password" \
                -theme-str "$textbox_network_name_style"
            )
            [ -z "$password" ] && exit 0

            connect_to_wifi "$ssid" "$password"
        else
            alert_msg="The security type is differnte from WPA/WPA2 and WPE. Would you like to access nmtui to configure the connection manually?"
            alert_msg_style="textbox-alert-msg { str: \"$alert_msg\"; }"

            selected_option=$(printf "yes\nno" | rofi \
                -dmenu \
                -theme "$menu_confirm" \
                -theme-str "$alert_msg_style"
            )
            [ -z "$selected_option" ] && exit 

            if [ "$selected_option" = "yes" ]; then
                open_nmtui
            fi
        fi
        ;;
    
    " Refresh")
        device_refresh
        ;;

    "󰩹 Remove Network")
        already_conn="$(get_all_already_connected)"

        selected_conn="$(printf "$already_conn" | rofi \
            -dmenu \
            -theme "$menu_list" \
            -theme-str "$(set_top_msg_menulist '󰩹 Remove Network')" \
            -theme-str "$(set_rofi_window_width '18%')" \
            -theme-str "$(rofi_hide 'column-headers')" \
        )"
        [ -z "$selected_conn" ] && exit 0
        
        delete_conn "$selected_conn"
        ;;

    " nmtui")
        open_nmtui
        ;;
esac
