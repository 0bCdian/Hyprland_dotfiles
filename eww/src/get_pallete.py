import colorgram


def get_palette():
    # Set the number of colors to extract from the image
    num_colors = 10
    # Set the input image filename
    image_file = "/home/obsy/.config/eww/spotify_cache/album_art.png"
    # Extract colors from the image using colorgram
    colors = colorgram.extract(image_file, num_colors)
    print(colors)
    print("------------------------")
    colors_by_saturation = sorted(colors, key=lambda c: c.hsl.s)
    print(colors_by_saturation)


get_palette()
