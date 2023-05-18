#!/usr/bin/env bash

## Author  : Aditya Shakya (adi1090x)
## Github  : @adi1090x
#
## Applets : Screenshot

# Import Current Theme
source "$HOME"/.config/rofi/applets/shared/theme.bash
theme="$type/$style"
slurp_select_area="slurp -d -b '#ebdbb244' -c '#323232FF' -B '#323232FF' -F 'JetBrains Mono Nerd Font' -w '1'"
# Theme Elements
prompt='Screenshot'
mesg="DIR: $(xdg-user-dir PICTURES)/Screenshots"
background_image=$(cat "$HOME/.cache/swww/cache.txt")

if [[ "$theme" == *'type-1'* ]]; then
	list_col='1'
	list_row='5'
	win_width='400px'
elif [[ "$theme" == *'type-3'* ]]; then
	list_col='1'
	list_row='5'
	win_width='120px'
elif [[ "$theme" == *'type-5'* ]]; then
	list_col='1'
	list_row='5'
	win_width='520px'
elif [[ ( "$theme" == *'type-2'* ) || ( "$theme" == *'type-4'* ) ]]; then
	list_col='5'
	list_row='1'
	win_width='670px'
fi

# Options
layout=$(echo "${theme}" | grep 'USE_ICON' | cut -d'=' -f2)
if [[ "$layout" == 'NO' ]]; then
	option_1=" Capture Desktop"
	option_2=" Capture Area"
	option_3=" Capture Window"
	option_4=" Capture in 5s"
	option_5=" Capture in 10s"
else
	option_1=""
	option_2=""
	option_3=""
	option_4=""
	option_5=""
fi

# Rofi CMD
rofi_cmd() {
	rofi -theme-str "window {width: $win_width;}" \
		-theme-str "listview {columns: $list_col; lines: $list_row;}" \
		-theme-str 'textbox-prompt-colon {str: " ";}' \
		-theme-str 'inputbar {background-image: url("'$background_image'", width);}' \
		-dmenu \
		-p "$prompt" \
		-mesg "$mesg" \
		-markup-rows \
		-theme "${theme}"
}

# Pass variables to rofi dmenu
run_rofi() {
	echo -e "$option_1\n$option_2\n$option_3\n$option_4\n$option_5" | rofi_cmd
}


dir="$(xdg-user-dir PICTURES)/Screenshots"
before=$(ls "$dir" -1q | wc -l)
if [[ ! -d "$dir" ]]; then
	mkdir -p "$dir"
fi

# notify and view screenshot
notify_view() {
	local before="$1"
	after=$(ls "$dir" -1q | wc -l)
	echo "$after"
	notify_cmd_shot='dunstify -u low -i gnome-screenshot Rofishot --replace=699'
	if [ "$after" -gt "$before" ]; then
    ${notify_cmd_shot} "Screenshot Saved."
	else
    ${notify_cmd_shot} "Screenshot Not Saved."
	fi
	
}

# Grab window wayland 

function grab_window() {
    local monitors=`hyprctl -j monitors`
    local clients=`hyprctl -j clients | jq -r '[.[] | select(.workspace.id | contains('$(echo $monitors | jq -r 'map(.activeWorkspace.id) | join(",")')'))]'`
    # Generate boxes for each visible window and send that to slurp
    # through stdin
    local boxes="$(echo $clients | jq -r '.[] | "\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1]) \(.title)"')"
    slurp -r <<< "$boxes"
}

# countdown
countdown () {
	for sec in $(seq "$1" -1 1); do
		dunstify -t 1000 --replace=699 "Taking shot in : $sec"
		sleep 1
	done
}

# take shots
shotnow () {
	grim -g "$(slurp -o)" - | swappy -f - && notify_view "$1"
	
}

shot5 () {
	countdown '5'
	sleep 0.2 && grim -g "$(slurp -d -b '#ebdbb244' -c '#323232FF' -B '#323232FF' -F 'JetBrains Mono Nerd Font' -w '1')" - | convert - -trim +repage - | swappy -f -
	notify_view "$1"
}

shot10 () {
	countdown '10'
	sleep 1 && grim -g "$(slurp -d -b '#ebdbb244' -c '#323232FF' -B '#323232FF' -F 'JetBrains Mono Nerd Font' -w '1')" - | convert - -trim +repage - | swappy -f -
	notify_view "$1"
}

shotwin () {
	sleep 0.3 && grim -g "$(grab_window)" - | convert - -trim +repage - | swappy -f -
	notify_view "$1"
}

shotarea () {
	sleep 0.2 && grim -g "$(slurp -d -b '#ebdbb244' -c '#323232FF' -B '#323232FF' -F 'JetBrains Mono Nerd Font' -w '1')" - | convert - -trim +repage - | swappy -f - 
	notify_view "$1"
}

# Execute Command
run_cmd() {
	if [[ "$1" == '--opt1' ]]; then
		shotnow "$before" 
	elif [[ "$1" == '--opt2' ]]; then
		shotarea "$before"
	elif [[ "$1" == '--opt3' ]]; then
		shotwin "$before"
	elif [[ "$1" == '--opt4' ]]; then
		shot5 "$before"
	elif [[ "$1" == '--opt5' ]]; then
		shot10 "$before"
	fi
}

# Actions
chosen="$(run_rofi)"
case ${chosen} in
    $option_1)
		run_cmd --opt1
        ;;
    $option_2)
		run_cmd --opt2
        ;;
    $option_3)
		run_cmd --opt3
        ;;
    $option_4)
		run_cmd --opt4
        ;;
    $option_5)
		run_cmd --opt5
        ;;
esac


