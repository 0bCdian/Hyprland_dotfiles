#!/usr/bin/fish
set loop_status (playerctl -p spotify loop)
if test "None" = "$loop_status"
    playerctl -p spotify loop 'Track'
else
    playerctl -p spotify loop 'None'
end