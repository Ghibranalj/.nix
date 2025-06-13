#!/usr/bin/env sh
swaync-client -cp

export YOFF=30px
export INPUT=false
export WIDTH=450px

rofi -no-fixed-num-lines -click-to-exit -location 3 -show b -modi "b:$1"
