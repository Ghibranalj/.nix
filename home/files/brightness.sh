#!/usr/bin/env sh
# -*- mode:sh -*-

# Required packages
# 1. brightnessctl
# 2. adwaita-icon-theme-41

PERC=$(awk -F',' '{print $4}' <<<"$(brightnessctl -m)" | tr -d '%')
case $1 in
    get)
        echo $PERC%
        ;;
    up)
        brightnessctl set +5%
        ;;
    down)
        brightnessctl set 5%-
        ;;
    off)
        xset dpms force off
        ;;
    *)
        echo "Usage: $0 {get|up|down}"
        exit 1
        ;;
esac

NUMBER=$(awk -F',' '{print $4}' <<<"$(brightnessctl -m)" | tr -d '%')
N=$(($PERC / 5 - 2))

N=$(bc <<< "($NUMBER / 3.33)")
for i in $(seq 1 $N); do
    BAR+="|"
done
echo $N

COL="#ffffff"
if [[ $NUMBER -gt 75 ]]; then
    COL="#ff0000"
elif [[ $NUMBER -gt 50 ]]; then
    COL="#ffff00"
elif [[ $NUMBER -gt 25 ]]; then
    COL="#00ff00"
fi
ICON=/usr/share/icons/Adwaita41/scalable/status/display-brightness-symbolic.svg

ID=234
notify-send -i "$ICON" "Brightness: $NUMBER%" "<span color=\'$COL\'>$BAR</span>" -c "Volume" -r $ID
