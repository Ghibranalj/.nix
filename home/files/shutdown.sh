#!/usr/bin/env bash

PARENT=`cat /proc/$PPID/comm`


function dimmer(){
	# Start initial short-timeout swayidle
	swayidle -w \
	timeout 1 'hyprctl dispatch dpms off' \
	resume '
		hyprctl dispatch dpms on

		# Start long-timeout swayidle
		swayidle -w \
		timeout 30 "hyprctl dispatch dpms off" \
		resume "hyprctl dispatch dpms on" &

		# Kill short-timeout swayidle (this one)
		pkill -f "swayidle -w.*timeout 1"
	' &
    
}


function lock_screen() {
	hyprlock &
    dimmer
	sleep 0.5
}


function lock_screen_and_wait() {
	hyprlock &
	LOCK_PID=$!
    dimmer
	# Wait for lock to finish
	wait $LOCK_PID
	# Kill all swayidle instances
	pkill -f "swayidle -w.*timeout"
	# Make sure screen is on
	hyprctl dispatch dpms on
}


# Options for powermenu
lock="  Lock"
logout="󰍃  Logout"
shutdown="⏻  Poweroff"
reboot="󰜉  Reboot"
sleep="󰤄  Sleep"
uefi="  UEFI setup"
hibernate="󰒲  Hibernate"

ROFI_CMD="rofi"
# Get answer from user via rofi
export COL=3
export LINES=2
export INPUT=false

if [[ $PARENT == ".waybar-wrapped" || $PARENT == ".swaync-wrapped" ]]; then
	ROFI_CMD="rofi -location 3 -no-fixed-num-lines"
	export COL=1
	unset LINES
	export YOFF=27px
fi

selected_option=$(
	echo "$lock
$logout
$sleep
$hibernate
$reboot
$uefi
$shutdown" | $ROFI_CMD -dmenu -i -p "Power" \
		-font "Symbols Nerd Font 12" \
		-width "15" \
		-lines 4 -line-margin 3 -line-padding 10 -scrollbar-width "0"
)

if [ "$selected_option" == "$lock" ]; then
	lock_screen_and_wait
elif [ "$selected_option" == "$logout" ]; then
	hyprctl dispatch exit
elif [ "$selected_option" == "$shutdown" ]; then
	systemctl poweroff
elif [ "$selected_option" == "$reboot" ]; then
	systemctl reboot
elif [ "$selected_option" == "$sleep" ]; then
	lock_screen
	sleep 2
	systemctl suspend
elif [ "$selected_option" == "$uefi" ]; then
	systemctl reboot --firmware-setup
elif [ "$selected_option" == "$hibernate" ]; then
    systemd-inhibit --what=sleep --who=powermenu --why="Lock after hibernate" --mode=delay  sh -c 'systemctl hibernate; hyprlock' &
else
	echo "No match"
fi
