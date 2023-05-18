#!/bin/bash
IMAGE="$1"
CURRENT_WALLPAPER="$HOME/.cache/swww/cache.txt"
ABSOLUTE_PATH_IMAGE=$(realpath "$IMAGE")
#wal -l -i "$ABSOLUTE_PATH_IMAGE" -n -e -t -s
# Check if the file exists
if [ ! -f "$CURRENT_WALLPAPER" ]; then
    # File does not exist, create it
    touch "$CURRENT_WALLPAPER"
fi

# Command to change wallpaper
              swww img "$IMAGE"\
             --transition-bezier .43,1.19,1,.4 \
             --transition-type grow \
             --transition-duration 1 \
             --transition-fps 60 \
             --transition-pos top-right
{
    echo "$ABSOLUTE_PATH_IMAGE"
    tail -n +2 "$CURRENT_WALLPAPER"
} > temp.txt && mv temp.txt "$CURRENT_WALLPAPER"
notify-send "Wallpaper Changed" -i "$ABSOLUTE_PATH_IMAGE" "$IMAGE"
