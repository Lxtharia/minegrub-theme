"""MIT License, see LICENSE for more details."""

import os
import random
import shutil
import subprocess
import sys
from os.path import abspath, dirname
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

def update_splash(slogan: str) -> None:
    # Choose random splash text
    if slogan: # I just want it
        splash_text = slogan
    else:
        index = random.randint(0, len(text_options) - 1)
        # Use cached image if it exists
        if os.path.isfile(f"{cachedir}/{index}.png"):
            return use_logo(index)
        splash_text = text_options[index]
    font = ImageFont.truetype(f"{assetdir}/MinecraftRegular-Bmg3.otf", font_size)
    img = Image.open(f"{assetdir}/logo_clear.png")
    original_size = img.size
    # Rotate image before drawing text
    img = img.rotate(360 - angle, expand=True)
    d = ImageDraw.Draw(img)
    # Draw text and shadow
    if text_shadow:
        d.text(
            (
                text_coords[0] + shadow_offset,
                text_coords[1] + shadow_offset
            ),
            splash_text, fill=shadow_color, anchor="ms", font=font,
        )
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
    # no cache here if you want what you like
    if slogan:
        print(f"Using splash from CLI: '{splash_text}'.")
        new.save(f"{themedir}/logo.png")
    else:
        new.save(f"{cachedir}/{index}.png")
        use_logo(index)

def use_logo(index: int):
    print(f"Using splash #{index}: '{text_options[index]}'.")
    shutil.copyfile(f"{cachedir}/{index}.png", f"{themedir}/logo.png")

def update_package_count() -> None:
    packages: int = int(
        subprocess.run(
            ["neofetch", "packages", "--package_managers", "off"],
            stdout=subprocess.PIPE,
        ).stdout.decode().split()[-1]
    )
    path = Path(f"{themedir}/theme.txt")
    text = "Packages Installed"
    old_lines = path.read_text().splitlines(keepends=False)
    new_line = f'\ttext = "{packages} {text}"'
    # Replace lines that have {text} to {new_line}
    for i, old_line in enumerate(old_lines):
        if text in old_line:
            patch(path, i, new_line)
    print(f"Updated packages installed to {packages}.")

def patch(path: Path, linenum: int, new_line: str) -> None:
    lines = path.read_bytes().splitlines(keepends=True)
    lines[linenum] = new_line.encode() + b"\n"
    text = b"".join(lines)
    path.write_bytes(text)

def get_slogan() -> str:
    argv_len = len(sys.argv)
    if argv_len == 1:
        the_slogan_you_want = ""
    elif argv_len == 2:
        the_slogan_you_want = sys.argv[1]
    else:
        the_slogan_you_want = ""
        print("You want too much and only can get the random one")
    return the_slogan_you_want

if __name__ == "__main__":
    # Annoying dir path things
    themedir = dirname(abspath(__file__))
    if not os.path.isdir(f"{themedir}/cache"):
        os.mkdir(f"{themedir}/cache")
    assetdir = f"{themedir}/assets"
    cachedir = f"{themedir}/cache"

    splash_path = Path(f"{assetdir}/splashes.txt")
    text_options = splash_path.read_text().splitlines(keepends=False)
    font_size = 48
    text_color = "rgb(255, 255, 0)"
    shadow_color = "rgb(59, 64, 2)"
    text_coords = (770, 450)
    angle = 20
    text_shadow = True
    shadow_offset = 5
    slogan = get_slogan()

    update_splash(slogan)
    update_package_count()
