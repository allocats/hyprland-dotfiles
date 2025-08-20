#!/usr/bin/bash

if [ "$#" -ne 1 ]; then
  echo "Usage: $0 config/to/run"
  exit 1
fi

case $1 in

  launcher)
    rofi -show drun -theme "configs/launcher.rasi"

esac
