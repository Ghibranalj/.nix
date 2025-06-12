#!/usr/bin/env sh

## Check if caffeine service is running
num=$(systemctl status caffeine --user | grep -i running | wc -l)

if [[ "$1" == "status" ]]; then
    if [ $num -eq 0 ]; then
        echo "false"
        exit 0
    else
        echo "true"
        exit 0
    fi
fi

if [ $num -eq 0 ]; then
    systemctl --user start caffeine
    echo "Caffeine started."
    notify-send -a 'Caffeine' "Caffeine" "Caffeine has been started to prevent the system from sleeping."
    exit 0
else
    echo "Caffeine is running."
    systemctl --user stop caffeine
    echo "Caffeine stopped."
    notify-send -a 'Caffine' "Caffeine" "Caffeine has been stopped to allow the system to sleep."
    exit 0
fi
