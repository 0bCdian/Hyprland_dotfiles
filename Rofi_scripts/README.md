# Rofi scrips for wifi and changing alacritty colorscheme
## Dependencies:
- Rofi
- The rofi folder in this repo inside your .config
## Wifi
the wifi script you just run it and it works, in the rofi folder there are many styles and colors for you to change in the script to make it look different, just make sure the paths to the themes in the script are correct, otherwise rofi just reverts to the default theme.
## Rofficritty
For this to work you need to put my alacritty.yml config inside your configs, I put all the schemes there and the script only changes a specific line where the color scheme is applied with the selection you made, if you use any other alacritty config it wont work because I hardcoded it to my own config. Of course you can always change things in the config, just make sure to leave the "colors * _colorscheme_" in the same line, or the script will break, or you can just change the script to match the line in the alacritty.yml config.
  - Also the list.txt file is used to feed rofi the selection of themes available in my alacritty.yml schemes, feel free to add your own, just make sure to also add the scheme in the alacritty.yml config file.
