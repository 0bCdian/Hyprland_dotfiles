#!/usr/bin/fish
playerctl position (math (math (playerctl -p spotify metadata --format "{{ mpris:length }}") x $argv[1]) / 100000000)

