#!/usr/bin/env sh

if kdeconnect-cli -a | grep -q "Connected: yes"; then
  echo '{"text": "󰄜", "class": "connected"}'
else
  echo '{"text": ""}'
fi

