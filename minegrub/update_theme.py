"""MIT License, see LICENSE for more details."""

import os
import random
import shutil
import subprocess
from os.path import abspath, dirname
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

def update_splash() -> None:
    # Choose random splash text
    splash_text= random.choice(text_options)
    # Use cached image if it exists
    if os.path.isfile(splash_file := cache_file_name(splash_text)):
        return use_logo(splash_text, splash_file)
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
    new.save(splash_file)
    use_logo(splash_text, splash_file)

def use_logo(splash_text: str, splash_file: str):
    print(f"Using splash {splash_file}: '{splash_text}'.")
    shutil.copyfile(splash_file, f"{themedir}/logo.png")

def cache_file_name(splash_text: str) -> str:
    return f"{cachedir}/{hash(splash_text)}.png"

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

    update_splash()
    update_package_count()
