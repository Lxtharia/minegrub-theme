"""MIT License, see LICENSE for more details."""

import os
import random
import shutil
from os.path import abspath, dirname

from PIL import Image, ImageDraw, ImageFont

# Annoying dir path things
repodir = dirname(abspath(__file__))
if not os.path.isdir(f"{repodir}/cache"):
    os.mkdir(f"{repodir}/cache")
resourcedir = f"{repodir}/resources"
cachedir = f"{repodir}/cache"

with open(f"{resourcedir}/splashes.txt", "r") as f:
    text_options = [i for i in f.read().splitlines() if i != ""]

font_size = 48
text_color = "rgb(255, 255, 0)"
shadow_color = "rgb(59, 64, 2)"
text_coords = (770, 450)
angle = 20
text_shadow = True
shadow_offset = 5

def generate():
    # Choose random splash text
    index = random.randint(0, len(text_options) - 1)
    # Use cached image if it exists
    if os.path.isfile(f"{cachedir}/{index}.png"):
        return use_logo(index)
    splash_text = text_options[index]
    font = ImageFont.truetype(f"{resourcedir}/MinecraftRegular-Bmg3.otf", font_size)
    img = Image.open(f"{resourcedir}/logo_clear.png")
    original_size = img.size
    # Rotate image before drawing text
    img = img.rotate(360 - angle, expand=True)
    d = ImageDraw.Draw(img)
    # Draw text and shadow
    if text_shadow:
        d.text((text_coords[0] + shadow_offset, text_coords[1] + shadow_offset), splash_text, fill=shadow_color, anchor="ms", font=font)
    d.text(text_coords, splash_text, fill=text_color, anchor="ms", font=font)
    # Rotate image back to original angle
    img = img.rotate(angle, expand=True)
    # Mathy stuff (crop image back to original size)
    coordinates = (
        (img.size[0] - original_size[0]) / 2,
        (img.size[1] - original_size[1]) / 2,
        (img.size[0] + original_size[0]) / 2,
        (img.size[1] + original_size[1]) / 2,
    )
    new = img.crop(coordinates)
    new.save(f"{cachedir}/{index}.png")
    use_logo(index)

def use_logo(index: int):
    shutil.copyfile(f"{cachedir}/{index}.png", f"{repodir}/logo.png")

generate()
