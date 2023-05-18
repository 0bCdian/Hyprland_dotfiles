#!/usr/bin/fish

set dividend  (playerctl metadata --format "{{ position }}")
set divisor (playerctl  metadata --format "{{ mpris:length }}")
set -x result (math "$dividend / $divisor * 100")
echo $result
