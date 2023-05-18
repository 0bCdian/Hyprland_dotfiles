#!/usr/bin/env --split-string=python -u
import gi
import shutil
import colorgram
import requests
import json
import os
from urllib.parse import urlparse, unquote

gi.require_version("Playerctl", "2.0")
from gi.repository import Playerctl, GLib


def save_image(url):
    if url.startswith("file://"):
        file_path = urlparse(url).path
        file_path = unquote(file_path)
        dst_path = os.path.join("/home/obsy/.config/eww/spotify_cache", "album_art.png")
        shutil.copy(file_path, dst_path)
        return True
    response = requests.get(url)
    if response.status_code == 200:
        with open("/home/obsy/.config/eww/spotify_cache/album_art.png", "wb") as f:
            f.write(response.content)
        return True
    else:
        return False


def get_palette():
    # Set the number of colors to extract from the image
    num_colors = 10
    # Set the input image filename
    image_file = "/home/obsy/.config/eww/spotify_cache/album_art.png"
    # Extract colors from the image using colorgram
    colors = colorgram.extract(image_file, num_colors)
    # Sort the colors by brightness
    most_saturated = max(colors, key=lambda c: c.hsl.s)
    colors = sorted(colors, key=lambda c: c.rgb.r + c.rgb.g + c.rgb.b)
    # Convert the brightest and darkest colors to hex codes
    darkest_color = "#{:02x}{:02x}{:02x}".format(*colors[0].rgb)
    # Define mixing ratio (0 = pure most_saturated color, 1 = pure white)
    mix_ratio = 0.85
    # Mix colors
    mixed_color = (
        round((1 - mix_ratio) * most_saturated.rgb.r + mix_ratio * 255),
        round((1 - mix_ratio) * most_saturated.rgb.g + mix_ratio * 255),
        round((1 - mix_ratio) * most_saturated.rgb.b + mix_ratio * 255),
    )
    mix_ratio = 0.3
    shadow = (
        round((1 - mix_ratio) * most_saturated.rgb.r + mix_ratio * 255),
        round((1 - mix_ratio) * most_saturated.rgb.g + mix_ratio * 255),
        round((1 - mix_ratio) * most_saturated.rgb.b + mix_ratio * 255),
    )
    shadow_hex = "#{:02x}{:02x}{:02x}".format(*shadow)
    # Convert mixed color to hex string
    hex_color = "#{:02x}{:02x}{:02x}".format(*mixed_color)
    # Create a dictionary to store the color values
    color_dict = {
        "shadow": shadow_hex,
        "darkest": darkest_color,
        "tint": hex_color,
    }
    # Output the colors as JSON
    return color_dict


def on_metadata(*args):
    save_image(args[1]["mpris:artUrl"])
    palette = get_palette()
    os.system(
        "convert -modulate 95,65 /home/obsy/.config/eww/spotify_cache/album_art.png /home/obsy/.config/eww/spotify_cache/album_art_modified.png"
    )
    metadata_new = {
        "url": args[1]["mpris:artUrl"],
        "shadow": palette["shadow"],
        "tint": palette["tint"],
        "dark": palette["darkest"],
        "title": args[1]["xesam:title"],
        "artist": args[1]["xesam:artist"][0],
        "current_player": args[0].props.player_name,
    }
    print(json.dumps(metadata_new), flush=True)


def on_play_pause(player, *_):
    """Callback function to regenerate and print the current state of the
    player when it is paused.

    Arguments:
        player: A Player object.
    """
    on_metadata(player, player.props.metadata)


def player_null_check(player_manager) -> bool:
    """Checks if there are any players being managed by the manager and print
    the default metadata if there are none.

    Arguments:
        player_manager: A PlayerManager object.

    Returns:
        A bool i.e. True if there are no active players, False otherwise.
    """
    if not len(player_manager.props.player_names):
        metadata = {
            "url": "/spotify_cache/default.png",
            "bright": "#ebdbb2",
            "tint": "#ebdbb2",
            "dark": "#323232",
            "title": "Unknown",
            "artist": "Uknown",
            "current_player": "none",
        }
        print(json.dumps(metadata), flush=True)
        return False
    return True


def on_name_appeared_vanished(player_manager, name):
    """Callback function for taking action when a player gets either connected or,
    disconnected from the manager.

    Arguments:
        player_manager: A PlayerManager object.
        name: A PlayerName object.
    """
    if player_null_check(player_manager):
        init_player(name)


def init_player(name):
    """Creates a Player object by passing a PlayerName object.
    It basically prepares and equips the player with instructions
    (callbacks) on what to do if a player:
        - receives track metadata
        - if a player is paused
        - if a player is not paused
    Finally it will add it to the PlayerManager object.

    Arguments:
        name: A PlayerName object.
    """
    player = Playerctl.Player.new_from_name(name)
    player.connect("metadata", on_metadata, manager)
    player.connect("playback-status::playing", on_play_pause, manager)
    player.connect("playback-status::paused", on_play_pause, manager)
    manager.manage_player(player)


manager = Playerctl.PlayerManager()
manager.connect("name-appeared", on_name_appeared_vanished)
manager.connect("name-vanished", on_name_appeared_vanished)

# loop through and initialize all registered and active MPRIS player on first run.
[init_player(name) for name in manager.props.player_names]
# if there are no player on the first run then print fallback / dummy metadata.
# WARN: Note that a really bad error is thrown when this check is not done.
# WARN: IIRC it is from the underlying C library so, you can't really try-except that.
if player_null_check(manager):
    player = Playerctl.Player()
    on_metadata(player, player.props.metadata)
    try:
        loop = GLib.MainLoop()
        loop.run()
    except (KeyboardInterrupt, Exception) as excep:
        loop.quit()
