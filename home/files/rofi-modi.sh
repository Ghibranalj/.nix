#!/usr/bin/env sh
swaync-client -cp

export YOFF=30px
export HEIGHT=50%
export INPUT=false

rofi -click-to-exit -location 3 -show b -modi "b:$1"
