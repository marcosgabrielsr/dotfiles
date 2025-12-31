# === Variabels ===
# Common Variables
conn_applet_menu="$HOME/.config/rofi/themes/connapplet.rasi"
menu_list="$HOME/.config/rofi/themes/menulist.rasi"
menu_password="$HOME/.config/rofi/themes/passwordbox.rasi"
menu_confirm="$HOME/.config/rofi/themes/confirmbox.rasi"

# === Functions ===
# Function to set the top-message on the conn-applet
# Receive the follow arguments:
# - $1: 'string' cotent for the textbox-top-msg
set_top_msg() {
    echo "textbox-top-msg { str: \"$1\"; }"
}

# Function to set the status msg on the menu list
# Receive the follow arguments:
# - $1: connected device
# - $2: working status
# - $3: Connected Status msg
# - $4: is working status
set_status_msg() {
    local msg=""
    local status_msg_config=""
    if [ -n "$1" ]; then
        msg="Status:\n$3"
        status_msg_config="textbox-status-msg { str: \"$msg\"; background-color: @success;}"
    elif [ "$2" = "$4" ]; then
        msg="Status:\nEnabled"
        status_msg_config="textbox-status-msg { str: \"$msg\"; background-color: @urgent;}"
    else
        msg="Status:\nDisabled"
        status_msg_config="textbox-status-msg { str: \"$msg\"; background-color: @urgent;}"
    fi

    echo "$status_msg_config"
}

# Function to set the toggle option on connections controller menu
# Receive the follow arguments:
# - $1: Status of connection device (power on/ power off)
# - $2: Messages that indicante if the deivce is working
set_toggle_option() {
    if [ "$1" = "$2" ]; then
        echo "⏻ Power off"
    else
        echo "⏻ Power on"
    fi
}

# Function to exec a tui/cli into a new kitty window
# Receie the follow arguments:
# - $1: Name of the command that will be executed
kitty_exec_tui() {
    kitty --detach -e "$1"
}