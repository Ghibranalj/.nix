#!/usr/bin/env sh
# -*- mode:sh -*-

# Required packages:
# 1. pamixer
# 3. bc

STEP=5

VOL=$(pamixer --get-volume)
[[ $(pamixer --get-mute) == "true" ]] && VOL="0"

# if vol < 5% then step = 1
if [[ $VOL -lt 15 ]]; then
    STEP=1
fi

if [[ "$1" == "up" ]]; then
    pamixer -i $STEP #to increase 5%

elif [[ "$1" == "down" ]]; then
    pamixer -d $STEP #to decrease 5%

elif [[ "$1" == "mute" ]]; then
    pamixer -t #to toggle mute

elif [[ "$1" == "get" ]]; then
    VOL=$(pamixer --get-volume)
    [[ $(pamixer --get-mute) == "true" ]] && VOL="0"
    echo $VOL #to show volume status
elif [[ "$1" == "set" ]]; then

    echo $2
    pamixer --set-volume "$2"
fi

[[ "$2" == "--no-prompt" ]] && exit 0

NUMBER=$(pamixer --get-volume)
[[ $(pamixer --get-mute) == "true" ]] && NUMBER="0"

N=$(bc <<< "($NUMBER / 1.1)")
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

notify-send "Volume $NUMBER%" "<span color=\'$COL\'>$BAR</span>" -c "Volume" --replace-id="69" -e
