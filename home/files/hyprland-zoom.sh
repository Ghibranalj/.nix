#!/usr/bin/env bash
# Get the current zoom factor
new_zoom="2.5"
lock_file="/tmp/zoom"

if [[ -f $lock_file ]]; then
  hyprctl keyword cursor:zoom_rigid false
  hyprctl keyword cursor:zoom_factor "1.0"
  # delete lock file
  rm $lock_file
  exit 0
fi

if [[ "$1" == "rigid" ]]; then
  hyprctl keyword cursor:zoom_rigid "true"
fi
# create lock file
touch  $lock_file
hyprctl keyword cursor:zoom_factor "$new_zoom"
