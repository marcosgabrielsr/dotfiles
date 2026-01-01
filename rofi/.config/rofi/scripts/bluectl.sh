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

get_devices() {
    echo "$(bluetoothctl devices | sed 's/Device //')"
}

get_paired_devices() {
    echo "$(bluetoothctl devices Paired | sed 's/Device //')"
}

open_bluetoothctl() {
    kitty_exec_tui bluetoothctl
}

get_devices_names() {
    local mac_address_size=17
    local devices="$1"
    local dnames=""
    while IFS= read -r line; do
        dnames+="${line:((mac_address_size + 1))}\n"
    done <<< "$devices"

    echo "$dnames"
}

get_mac_by_name() {
    local dname="$1"
    local devices="$2"
    local info_device="$( get_paired_devices | grep "$dname")"
    
    if [ -z "$info_device" ]; then
        printf "Dispositivo não encontrado."
        return 1
    fi
    
    local mac="$(echo "$info_device" | awk -F' ' '{printf $1}')"
    echo "$mac"
}

connect_to_paired_device() {
    local mac="$1"
    local timeout_duration="10s"
    local dname=$(bluetoothctl info "$mac" | grep "Alias" | cut -d ' ' -f 2-)
    [[ -z "$dname" ]] && device_name="$mac"

    # Executa o comando com timeout e captura a saída (stdout e stderr)
    local output
    output=$(timeout "$timeout_duration" bluetoothctl connect "$mac" 2>&1)
    local exit_code=$?

    # Lógica de verificação
    if [[ $exit_code -eq 0 ]]; then
        # Sucesso (Código 0)
        notify-send -u normal -i bluetooth-active "Bluetooth Conectado" "Dispositivo: $device_name"
    
    elif [[ $exit_code -eq 124 ]]; then
        # Código 124 é específico do comando 'timeout'
        notify-send -u critical -i bluetooth-disabled "Bluetooth Timeout" "Falha ao conectar em $timeout_duration.\nDispositivo: $device_name"
        # Opcional: tentar cancelar a tentativa pendente
        bluetoothctl disconnect "$mac" &> /dev/null 
    
    else
        # Qualquer outro erro (falha do bluetoothctl)
        # Limita a mensagem de erro para não ficar gigante na notificação
        local short_error=$(echo "$output" | head -n 1) 
        notify-send -u critical -i dialog-error "Bluetooth Falhou" "Erro: $short_error"
    fi

    bluetoothctl connect "$mac" &> /dev/null
}

remove_paired_device() {
    local mac="$1"
    local dname="$2"
    alert_msg="Are you sure to delete the $dname device?"
    alert_msg_style="textbox-alert-msg { str: \"$alert_msg\"; }"

    selected_option=$(printf "yes\nno" | rofi \
        -dmenu \
        -theme "$menu_confirm" \
        -theme-str "$alert_msg_style"
    )
    [ -z "$selected_option" ] && exit 

    if [ "$selected_option" = "yes" ]; then
        if bluetoothctl remove "$mac" &> /dev/null; then
            notify-send "󰂯 Bluetooth" "$dname device was removed"
        else
            notify-send "󰂯 Bluetooth" "Error to remove $dname device"
        fi
    fi
}

# Main code
power_status="$(get_power_status)"
conn_device="$(get_conn_device_name)"
status_msg_config="$(set_status_msg "$conn_device" "$power_status" "$conn_device" "yes")"
options=(
    "$(set_toggle_option "$power_status" "yes")"
    " Scan devices"
    "󰟴 Paired devices"
    "󰩹 Remove device"
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
        devices="$(get_devices_names "$(get_devices)")"
        ;;

    "󰟴 Paired devices")
        paired_devices="$(get_devices_names "$(get_paired_devices)")"

        paired_device="$(printf "$paired_devices" | rofi \
            -dmenu \
            -theme "$menu_list" \
            -theme-str "$(set_top_msg_menulist '󰟴 Paired devices')" \
            -theme-str "$(set_rofi_window_width '18%')" \
            -theme-str "$(rofi_hide 'column-headers')" \
        )"
        [ -z "$paired_device" ] && exit 0
        
        device_mac="$(get_mac_by_name "$paired_device" "$(get_paired_devices)")"
        connect_to_paired_device "$device_mac"
        ;;

    "󰩹 Remove device")
        paired_devices="$(get_devices_names "$(get_paired_devices)")"

        paired_device="$(printf "$paired_devices" | rofi \
            -dmenu \
            -theme "$menu_list" \
            -theme-str "$(set_top_msg_menulist '󰟴 Paired devices')" \
            -theme-str "$(set_rofi_window_width '18%')" \
            -theme-str "$(rofi_hide 'column-headers')" \
        )"
        [ -z "$paired_device" ] && exit 0

        device_mac="$(get_mac_by_name "$paired_device" "$(get_paired_devices)")"
        remove_paired_device "$device_mac" "$paired_device"
        ;;

    " bluetoothctl")
        open_bluetoothctl
        ;;
esac