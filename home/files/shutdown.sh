#!/usr/bin/env bash

PARENT=`cat /proc/$PPID/comm`


function lock_screen() {
	hyprlock &
	LOCK_PID=$!

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
	'

	# Wait for lock to finish
	wait $LOCK_PID

	# Kill all swayidle instances
	pkill -f "swayidle -w.*timeout"

	# Make sure screen is on
	hyprctl dispatch dpms on
}


# Options for powermenu
lock="    Lock"
logout="󰍃    Logout"
shutdown="    Poweroff"
reboot="    Reboot"
sleep="󰤄   Sleep"
hibernate="  UEFI setup"
hibernateFR="󰒲  Hibernate"

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
$reboot
$shutdown
$hibernate
$hibernateFR
$sleep" | $ROFI_CMD -dmenu -i -p "Power" \
		-font "Symbols Nerd Font 12" \
		-width "15" \
		-lines 4 -line-margin 3 -line-padding 10 -scrollbar-width "0"
)



if [ "$selected_option" == "$lock" ]; then
	lock_screen
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
elif [ "$selected_option" == "$hibernate" ]; then
	systemctl reboot --firmware-setup
elif [ "$selected_option" == "$hibernateFR" ]; then
	lock_screen
	systemctl hibernate --force &
else
	echo "No match"
fi
